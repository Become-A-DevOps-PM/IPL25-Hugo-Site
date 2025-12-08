# Feedback System Solution

> **STATUS:** Current implementation. Repository: `Become-A-DevOps-PM/ipl25-hugo-site-feedback`

This document describes the implementation of the feedback system for the DevOps PM IPL25 documentation site. The system allows users to submit anonymous feedback from any page, which is then stored as GitHub Issues in a private repository.

---

## Part 1: Solution Overview

### Architecture at a Glance

```
┌─────────────────────┐     HTTPS POST      ┌──────────────────────┐     GitHub API     ┌─────────────────────────┐
│   Hugo Static Site  │ ─────────────────▶  │   Azure Function     │ ─────────────────▶ │   GitHub Issues         │
│   (GitHub Pages)    │                     │   (Consumption Plan) │                    │   (Private Repository)  │
│                     │                     │                      │                    │                         │
│ • Feedback button   │                     │ • Validates input    │                    │ • Stores feedback       │
│ • Modal dialog      │                     │ • Rate limits        │                    │ • Labels by source      │
│ • JavaScript client │                     │ • Bot detection      │                    │ • Tracks resolution     │
└─────────────────────┘                     │ • Creates issues     │                    └─────────────────────────┘
                                            └──────────┬───────────┘
                                                       │
                                            ┌──────────┴───────────┐
                                            │  Azure Table Storage │
                                            │  (Rate Limit State)  │
                                            └──────────────────────┘
```

### Key Components

| Component | Technology | Location |
|-----------|------------|----------|
| Frontend | Vanilla JavaScript | Hugo site (`static/js/feedback.js`) |
| Backend | Azure Functions v4 (Node.js 20) | Azure (`func-feedback-roisuzmacurw6`) |
| Storage | Azure Table Storage | Azure (`stfeedbackroisuzmacurw6`) |
| Issues | GitHub Issues API | `Become-A-DevOps-PM/ipl25-hugo-site-feedback` |
| Infrastructure | Bicep templates | `ipl25-hugo-site-feedback/infra/` |

### Endpoints

| Environment | URL |
|-------------|-----|
| Production API | `https://func-feedback-roisuzmacurw6.azurewebsites.net/api/submitfeedback` |
| Hugo Site | `https://devops-pm-25.educ8.se` |
| Local Dev | `http://localhost:1313` |

### Security Features Summary

- **Rate Limiting**: 5 requests per IP per hour
- **Honeypot Field**: Hidden form field to catch bots
- **Timing Validation**: Rejects submissions faster than 3 seconds or older than 30 minutes
- **Domain Validation**: Only accepts feedback from allowed domains
- **Input Sanitization**: Escapes HTML characters in feedback text
- **CORS**: Restricts cross-origin requests to known domains

### Cost

- **Azure Functions**: Free tier (1 million executions/month)
- **Table Storage**: ~$0.01/month
- **Total**: Essentially free for expected usage

### Repositories

| Repository | Purpose | Visibility |
|------------|---------|------------|
| `Become-A-DevOps-PM/Become-A-DevOps-PM-IPL25` | Hugo documentation site | Public |
| `Become-A-DevOps-PM/ipl25-hugo-site-feedback` | Azure Function code + issues | Private |

---

## Part 2: Detailed Implementation

### 2.1 Frontend Implementation

#### File Structure

```
static/
└── js/
    └── feedback.js          # All frontend logic (modal, form, API calls)

content/
└── privacy-feedback.md      # Privacy information page

layouts/
└── partials/
    └── flex/
        └── scripts.html     # Includes feedback.js
```

#### How the Button Detection Works

The existing feedback button is defined in `hugo.toml`:

```toml
[[menu.shortcuts]]
  name = "<i class='fa fa-comment'></i> Feedback"
  url = "#"
  weight = 10
```

Since Hugo's menu system doesn't support custom data attributes, the JavaScript uses a fallback detection method:

```javascript
document.addEventListener('click', function(e) {
    // Primary: check for data attribute
    let feedbackTrigger = e.target.closest('[data-feedback-trigger]');

    // Fallback: detect menu link by content
    if (!feedbackTrigger) {
        const link = e.target.closest('a[href="#"]');
        if (link && link.innerHTML.includes('Feedback')) {
            feedbackTrigger = link;
        }
    }

    if (feedbackTrigger) {
        e.preventDefault();
        openModal();
    }
});
```

This approach avoids modifying theme partials while still detecting the button reliably.

#### Modal Dialog

The modal is created dynamically via JavaScript (not in Hugo templates) to:
- Avoid theme modifications
- Ensure consistent behavior across all pages
- Allow easy updates without rebuilding the site

The modal includes:
- Page title display (shows which page feedback is about)
- Textarea for feedback (max 5000 characters)
- Hidden honeypot field
- Hidden timestamp field
- Privacy information link
- Cancel and Submit buttons

#### Form Submission Flow

1. User clicks "Send Feedback"
2. Button disabled, text changes to "Sending..."
3. Payload constructed with:
   - `pageUrl`: Current page URL
   - `pageTitle`: Current page title
   - `feedback`: User's text
   - `honeypot`: Hidden field value (should be empty)
   - `formLoadTime`: Timestamp when modal opened
4. POST request sent to Azure Function
5. Response handled:
   - Success: Show green message, auto-close after 3 seconds
   - Error: Show red message, re-enable submit button

### 2.2 Backend Implementation

#### Azure Function Structure

```
function/
├── host.json                      # Function host configuration
├── package.json                   # Dependencies
└── src/
    └── functions/
        └── submitFeedback.js      # Main handler
```

#### Request Processing Pipeline

The function processes requests in this order:

```
Request → Honeypot Check → Timing Check → Rate Limit Check → Input Validation → Domain Validation → Create GitHub Issue → Response
```

Each check can short-circuit the pipeline with an appropriate response.

#### Security Measures in Detail

##### 1. Honeypot Field

```javascript
if (honeypot && honeypot.trim() !== '') {
    context.log('Honeypot triggered - bot detected');
    return {
        status: 200,  // Returns success to not reveal detection
        jsonBody: { success: true, message: 'Thank you for your feedback!' }
    };
}
```

**How it works**: The honeypot is a hidden form field that humans won't see or fill out, but automated bots typically fill all fields. If this field contains any value, the request is from a bot.

**Why return 200**: Returning an error would inform the bot that it was detected, allowing it to adapt. Returning success wastes the bot's time without revealing our detection method.

##### 2. Time-Based Validation

```javascript
const currentTime = Date.now();
const submissionTime = (currentTime - formLoadTime) / 1000; // seconds

// Too fast (< 3 seconds) - likely a bot
if (submissionTime < 3) {
    return { status: 200, jsonBody: { success: true, message: '...' } };
}

// Too slow (> 30 minutes) - form expired
if (submissionTime > 1800) {
    return { status: 400, jsonBody: { success: false, message: 'Form expired...' } };
}
```

**Rationale**:
- **Minimum 3 seconds**: A human needs time to read the form, think, and type. Anything faster is suspicious.
- **Maximum 30 minutes**: Prevents replay attacks and ensures the context is still relevant.

##### 3. Rate Limiting

Rate limiting uses Azure Table Storage to track requests per IP address.

**Configuration**:
- `RATE_LIMIT_MAX`: 5 requests
- `RATE_LIMIT_WINDOW_MINUTES`: 60 minutes

**Storage Schema**:
```javascript
{
    partitionKey: 'ratelimit',
    rowKey: '192_168_1_1',  // IP with special chars replaced
    count: 3,
    resetTime: '2024-01-15T10:30:00.000Z'
}
```

**Algorithm**:
```javascript
try {
    const entity = await tableClient.getEntity(partitionKey, rowKey);
    const now = Date.now();

    if (now > new Date(entity.resetTime).getTime()) {
        // Window expired - reset counter
        await tableClient.upsertEntity({
            partitionKey, rowKey,
            count: 1,
            resetTime: new Date(now + windowMs).toISOString()
        });
    } else if (entity.count >= rateLimitMax) {
        // Limit exceeded
        return { status: 429, jsonBody: { message: 'Too many submissions...' } };
    } else {
        // Increment counter
        await tableClient.upsertEntity({
            partitionKey, rowKey,
            count: entity.count + 1,
            resetTime: entity.resetTime
        });
    }
} catch (error) {
    if (error.statusCode === 404) {
        // First request from this IP
        await tableClient.upsertEntity({
            partitionKey, rowKey,
            count: 1,
            resetTime: new Date(Date.now() + windowMs).toISOString()
        });
    }
}
```

**Why Table Storage**:
- Serverless-compatible (no connection pooling issues)
- Pay-per-use pricing
- Simple key-value access pattern
- Persistent across function cold starts

##### 4. Input Validation

```javascript
// Required field check
if (!feedback || feedback.trim() === '') {
    return { status: 400, jsonBody: { message: 'Feedback text is required.' } };
}

// Length limit
if (feedback.length > 5000) {
    return { status: 400, jsonBody: { message: 'Feedback is too long...' } };
}

// HTML sanitization
const sanitizedFeedback = feedback
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .trim();
```

##### 5. Domain Validation

```javascript
const allowedDomains = ['devops-pm-25.educ8.se', 'localhost'];
let isValidDomain = false;

try {
    const url = new URL(pageUrl);
    isValidDomain = allowedDomains.some(domain =>
        url.hostname === domain || url.hostname.endsWith('.' + domain)
    );
} catch (e) {
    isValidDomain = false;
}

if (!isValidDomain) {
    return { status: 400, jsonBody: { message: 'Invalid page URL.' } };
}
```

**Why validate domain**: Prevents abuse where someone could use the API to spam the issues with feedback appearing to come from other websites.

#### CORS Configuration

Configured in the Bicep template:

```bicep
cors: {
    allowedOrigins: [
        allowedOrigin           // https://devops-pm-25.educ8.se
        'http://localhost:1313' // Local development
    ]
}
```

This ensures only requests from the Hugo site (or local development) are accepted.

#### GitHub Issue Creation

```javascript
const issueTitle = `Feedback: ${pageTitle || pagePath}`;
const issueBody = `## Page Information
- **URL:** ${pageUrl}
- **Title:** ${pageTitle || 'N/A'}

## Feedback
${sanitizedFeedback}

---
*Submitted via feedback form*`;

const response = await fetch(
    `https://api.github.com/repos/${githubOwner}/${githubRepo}/issues`,
    {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${githubToken}`,
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json',
            'User-Agent': 'Feedback-Function'
        },
        body: JSON.stringify({
            title: issueTitle,
            body: issueBody,
            labels: ['feedback']
        })
    }
);
```

**Issue Format**:
- **Title**: `Feedback: [Page Title]`
- **Labels**: `feedback`
- **Body**: Structured markdown with page info and feedback text

### 2.3 Infrastructure as Code

#### Bicep Template Structure

The `main.bicep` template creates:

1. **Storage Account** (`stfeedback...`)
   - Standard LRS (locally redundant)
   - TLS 1.2 minimum
   - HTTPS only

2. **Table Storage**
   - Table service on storage account
   - `ratelimits` table for rate limiting data

3. **App Service Plan**
   - Consumption plan (Y1 SKU)
   - Pay-per-execution pricing

4. **Function App** (`func-feedback-...`)
   - Node.js 20 runtime
   - CORS configuration
   - Application settings (environment variables)

#### Environment Variables

| Variable | Purpose |
|----------|---------|
| `GITHUB_TOKEN` | Personal access token for GitHub API |
| `GITHUB_OWNER` | Repository owner (`Become-A-DevOps-PM`) |
| `GITHUB_REPO` | Repository name (`ipl25-hugo-site-feedback`) |
| `RATE_LIMIT_MAX` | Maximum requests per window (5) |
| `RATE_LIMIT_WINDOW_MINUTES` | Window duration (60) |
| `AZURE_STORAGE_CONNECTION_STRING` | Connection to table storage |

#### Deployment Commands

```bash
# Create resource group
az group create --name rg-feedback-ipl25 --location swedencentral

# Deploy infrastructure
az deployment group create \
  --resource-group rg-feedback-ipl25 \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json \
  --parameters githubToken='YOUR_TOKEN'

# Deploy function code
cd function
npm install
func azure functionapp publish func-feedback-roisuzmacurw6 --javascript
```

### 2.4 Data Flow Example

Here's a complete example of a feedback submission:

1. **User Action**: User on `/tutorials/setup/azure/` clicks Feedback button

2. **Frontend**:
   ```javascript
   {
       pageUrl: "https://devops-pm-25.educ8.se/tutorials/setup/azure/",
       pageTitle: "Azure Setup :: DevOps PM IPL25",
       feedback: "The screenshot in step 3 is outdated",
       honeypot: "",
       formLoadTime: 1705312800000
   }
   ```

3. **Azure Function Processing**:
   - Honeypot check: PASS (empty)
   - Timing check: PASS (15 seconds elapsed)
   - Rate limit check: PASS (2nd request this hour)
   - Input validation: PASS (47 characters)
   - Domain validation: PASS (devops-pm-25.educ8.se)

4. **GitHub Issue Created**:
   ```markdown
   Title: Feedback: Azure Setup :: DevOps PM IPL25
   Labels: feedback

   ## Page Information
   - **URL:** https://devops-pm-25.educ8.se/tutorials/setup/azure/
   - **Title:** Azure Setup :: DevOps PM IPL25

   ## Feedback
   The screenshot in step 3 is outdated

   ---
   *Submitted via feedback form*
   ```

5. **Response to User**:
   ```json
   {
       "success": true,
       "message": "Thank you for your feedback!"
   }
   ```

### 2.5 Maintenance

#### Token Renewal

The GitHub token will expire. To update:

```bash
az functionapp config appsettings set \
  --name func-feedback-roisuzmacurw6 \
  --resource-group rg-feedback-ipl25 \
  --settings GITHUB_TOKEN="NEW_TOKEN"
```

#### Monitoring

View function logs:
```bash
az webapp log tail \
  --name func-feedback-roisuzmacurw6 \
  --resource-group rg-feedback-ipl25
```

Or use Azure Portal → Function App → Monitor

#### Cleanup

When the course ends:
```bash
az group delete --name rg-feedback-ipl25 --yes --no-wait
```

This deletes all Azure resources (function, storage, plan).

---

## Appendix: File Locations

### Hugo Site (Become-A-DevOps-PM-IPL25)

| File | Purpose |
|------|---------|
| `static/js/feedback.js` | Frontend JavaScript |
| `content/privacy-feedback.md` | Privacy information page |
| `layouts/partials/flex/scripts.html` | Includes feedback.js |
| `docs/feedback-system-plan.md` | Original implementation plan |
| `docs/feedback-system-solution.md` | This document |

### Feedback System Repository (ipl25-hugo-site-feedback)

| File | Purpose |
|------|---------|
| `infra/main.bicep` | Azure infrastructure definition |
| `infra/main.parameters.json` | Deployment parameters |
| `function/host.json` | Function host configuration |
| `function/package.json` | Node.js dependencies |
| `function/src/functions/submitFeedback.js` | Main function code |
| `README.md` | Quick reference |
