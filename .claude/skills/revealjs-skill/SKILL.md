# Reveal.js Swedish Tech Presentation Skill

## Overview
Expert skill for creating professional Reveal.js presentations with a distinctive Swedish tech aesthetic. This skill enables Claude Code to create modern, web-based presentations with consistent branding and interactive elements.

## Core Capabilities
- Create multi-slide Reveal.js presentations
- Apply Swedish tech design system (blue/yellow color scheme)
- Generate interactive elements and animations
- Maintain consistent typography and spacing
- Create various slide layouts (title, content, timeline, grid)
- Add fragment animations and transitions

## Design System

### Color Palette
```css
--swedish-blue: #006AA7
--swedish-blue-light: #0090E3
--swedish-blue-dark: #004B79
--swedish-yellow: #FECC00
--tech-cyan: #00D9FF
--dark-background: #0A0E27
--muted-text: #94A3B8
```

### Typography
- **Headers**: Segoe UI, 800 weight, uppercase
- **Body**: Segoe UI, 400 weight
- **Title sizes**: 2.5em (h1), 1.8em (h2), 1.2em (h3)
- **Body sizes**: 0.95em standard, 0.8em small

### Spacing System
- Use 4px base unit
- Margins: 20px, 30px, 40px
- Padding: 15px, 20px, 40px
- Consistent gaps between elements

## Workflow

### 1. Analyze Requirements
```
- Identify presentation purpose and audience
- Determine number of slides needed
- List content types (text, timelines, grids, lists)
- Note any specific branding requirements
```

### 2. Create HTML Structure
```html
<!DOCTYPE html>
<html lang="sv">
<head>
    <meta charset="utf-8">
    <title>Presentation Title</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/5.0.4/reveal.min.css">
    <link rel="stylesheet" href="template.css">
</head>
<body>
    <div class="reveal">
        <div class="slides">
            <!-- Slides go here -->
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/5.0.4/reveal.min.js"></script>
    <script src="config.js"></script>
</body>
</html>
```

### 3. Apply Template Styling
Always include the template.css file with Swedish tech theme. This provides:
- Dark background with blue gradients
- Swedish flag color scheme
- Geometric decorative elements
- Consistent animations

### 4. Create Slide Types

#### Title Slide
```html
<section class="title-slide">
    <div class="geometric-bg"></div>
    <div class="course-badge"><span>BADGE</span></div>
    <h1 class="main-title">TITLE<br>LINE 2<br>LINE 3</h1>
    <p class="subtitle">Subtitle text</p>
    <p class="course-info">Additional info</p>
    <div class="corner-accent"></div>
    <div class="bottom-accent"></div>
</section>
```

#### Content Slide
```html
<section class="content-slide">
    <h2>Section Title</h2>
    <ul>
        <li class="fragment">Point 1</li>
        <li class="fragment">Point 2</li>
    </ul>
</section>
```

#### Timeline Slide
```html
<section class="content-slide">
    <h2>Timeline Title</h2>
    <div class="timeline">
        <div class="timeline-item fragment">
            <div class="timeline-week">1</div>
            <div class="timeline-label">Label</div>
        </div>
        <!-- More timeline items -->
    </div>
</section>
```

#### Grid Slide
```html
<section class="content-slide">
    <h2>Grid Title</h2>
    <div class="groups-grid">
        <div class="group-card fragment">
            <div class="group-number">Group 1</div>
            <div class="group-members">Members list</div>
        </div>
        <!-- More cards -->
    </div>
</section>
```

### 5. Add Interactivity
- Use `class="fragment"` for sequential reveals
- Add `data-fragment-index="1"` for specific order
- Apply transitions: slide, fade, zoom
- Include hover effects on interactive elements

### 6. Configure Reveal.js
```javascript
Reveal.initialize({
    hash: true,
    controls: true,
    progress: true,
    center: false,
    transition: 'slide',
    backgroundTransition: 'fade',
    slideNumber: 'c/t',
    history: true
});
```

## Best Practices

### Design Principles
1. **Bold choices** - Use strong contrasts and geometric shapes
2. **Visual hierarchy** - Clear size and color differences
3. **Consistent spacing** - Follow the 4px grid system
4. **Swedish identity** - Blue/yellow prominently featured
5. **Tech aesthetic** - Cyan accents, dark backgrounds

### Content Guidelines
1. **Concise text** - Maximum 5-7 bullet points per slide
2. **Progressive disclosure** - Use fragments for complex info
3. **Visual elements** - Include decorative accents sparingly
4. **Readable fonts** - Minimum 0.75em for body text
5. **High contrast** - White/cyan on dark background

### Technical Requirements
1. **CDN links** - Use Reveal.js 5.0.4 from CDN
2. **Responsive** - Presentations scale to screen size
3. **Cross-browser** - Test in Chrome, Firefox, Safari
4. **Keyboard navigation** - Arrow keys must work
5. **File structure** - Separate CSS and JS files

## Common Patterns

### Swedish Tech Elements
```css
/* Geometric background */
.geometric-bg {
    position: absolute;
    top: 0;
    right: 0;
    width: 45%;
    height: 100%;
    background: linear-gradient(135deg, #006AA7 0%, #0090E3 100%);
    clip-path: polygon(25% 0, 100% 0, 100% 100%, 0% 100%);
    opacity: 0.25;
}

/* Yellow accent bar */
.bottom-accent {
    position: absolute;
    bottom: 20px;
    left: 20px;
    width: 200px;
    height: 3px;
    background: linear-gradient(90deg, #FECC00 0%, transparent 100%);
}

/* Corner decoration */
.corner-accent {
    position: absolute;
    top: 20px;
    right: 20px;
    width: 50px;
    height: 50px;
    border-top: 2px solid #00D9FF;
    border-right: 2px solid #00D9FF;
}
```

### Animation Patterns
```css
@keyframes pulse {
    0%, 100% { opacity: 0.5; }
    50% { opacity: 0.2; }
}

@keyframes slideInFromLeft {
    from { transform: translateX(-50px); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}
```

## File Outputs
When creating a presentation, generate these files:
1. `presentation.html` - Main HTML file
2. `template.css` - Swedish tech styling
3. `config.js` - Reveal.js configuration
4. `README.md` - Usage instructions

## Quality Checklist
- [ ] All text is readable (proper sizing)
- [ ] Colors follow Swedish tech palette
- [ ] Animations work smoothly
- [ ] Navigation functions properly
- [ ] Fragments appear in correct order
- [ ] No text overflow on standard screens
- [ ] Consistent spacing throughout
- [ ] Swedish/English text properly formatted

## Example Usage
```
User: "Create a Reveal.js presentation about cloud infrastructure with 5 slides"

Claude Code will:
1. Create title slide with course name
2. Add overview slide with timeline
3. Create content slides for each topic
4. Apply Swedish tech template
5. Add fragment animations
6. Generate all required files
```