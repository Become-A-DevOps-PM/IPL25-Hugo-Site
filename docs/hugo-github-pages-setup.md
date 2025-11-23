# Set Up Hugo Site with DocDock Theme on GitHub Pages

## Goal

Build a documentation site with Hugo and the DocDock theme, deployed to GitHub Pages with a custom subdomain. This setup includes reveal.js presentation support for creating slides directly in Markdown.

> **What you'll learn:**
>
> - How to set up Hugo with the DocDock theme for documentation sites
> - How to deploy Hugo sites to GitHub Pages using GitHub Actions
> - How to configure a custom subdomain for a repository in an organization
> - How to patch legacy themes for modern Hugo compatibility

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Hugo Extended installed (v0.128.0 or later) - <https://gohugo.io/installation/>
> - ✓ Git installed and configured with GitHub access
> - ✓ A GitHub organization with admin access
> - ✓ Access to DNS settings for your domain
> - ✓ Basic familiarity with command line and Git

## Exercise Steps

### Overview

1. **Create GitHub Repository in Organization**
2. **Initialize Hugo Site Locally**
3. **Add DocDock Theme and Patch for Compatibility**
4. **Configure Hugo for GitHub Pages**
5. **Create Initial Content Structure**
6. **Set Up GitHub Actions Workflow**
7. **Configure Custom Subdomain DNS**
8. **Test Your Deployment**

### **Step 1:** Create GitHub Repository in Organization

Set up a new repository in your GitHub organization to host the Hugo site. Unlike organization sites (which use `<org>.github.io`), project sites in organizations can have any name and will be served from a subdomain you configure.

1. **Navigate to** your GitHub organization page

2. **Click** the "New repository" button

3. **Configure** the repository settings:
   - Repository name: Choose a descriptive name (e.g., `documentation`, `course-site`)
   - Visibility: Public (required for GitHub Pages on free plans)
   - Initialize with README: Yes

4. **Clone** the repository to your local machine:

   ```bash
   git clone https://github.com/YOUR-ORG/YOUR-REPO.git
   cd YOUR-REPO
   ```

> ℹ **Concept Deep Dive**
>
> GitHub Pages supports two types of sites: organization/user sites (`<name>.github.io`) and project sites. Project sites in organizations are perfect for separate documentation or course materials. Each repository can have its own custom domain, making it ideal for subdomain-based hosting like `docs.example.com` or `course.example.com`.
>
> ⚠ **Common Mistakes**
>
> - Creating a private repository prevents GitHub Pages from working (on free plans)
> - Forgetting to clone with the correct URL causes push failures
> - Not having admin access to the organization limits Pages configuration
>
> ✓ **Quick check:** Repository exists in organization and is cloned locally

### **Step 2:** Initialize Hugo Site Locally

Create the Hugo site structure in your repository. Hugo uses a specific directory layout for content, themes, and configuration.

1. **Navigate to** your cloned repository directory

2. **Initialize** a new Hugo site:

   ```bash
   hugo new site . --force
   ```

3. **Verify** the created structure:

   ```bash
   ls -la
   ```

   You should see: `archetypes/`, `content/`, `layouts/`, `static/`, `themes/`, and a configuration file.

4. **Create** a `.gitignore` file:

   > `.gitignore`

   ```text
   # Hugo build output
   /public/
   /resources/_gen/

   # Hugo lock file
   .hugo_build.lock

   # OS files
   .DS_Store
   Thumbs.db

   # Editor files
   *.swp
   *.swo
   *~
   .idea/
   .vscode/

   # Node modules (if using npm packages)
   node_modules/
   ```

> ℹ **Concept Deep Dive**
>
> The `--force` flag allows Hugo to initialize in a non-empty directory (your cloned repo). Hugo's directory structure follows conventions: `content/` for pages, `static/` for assets copied directly to output, `layouts/` for template overrides, and `themes/` for installed themes. The `public/` directory is the build output and should never be committed.
>
> ⚠ **Common Mistakes**
>
> - Running `hugo new site` without `--force` in an existing directory fails
> - Forgetting `.gitignore` leads to committing build artifacts
> - Not using Hugo Extended edition causes theme build failures
>
> ✓ **Quick check:** Hugo directory structure exists with configuration file

### **Step 3:** Add DocDock Theme and Patch for Compatibility

Install the DocDock theme as a Git submodule and create overrides to fix compatibility issues with modern Hugo versions. DocDock was last updated in 2018, so several patches are required.

1. **Add** the DocDock theme as a submodule:

   ```bash
   git submodule add https://github.com/vjeantet/hugo-theme-docdock.git themes/docdock
   ```

2. **Create** the layouts override directory structure:

   ```bash
   mkdir -p layouts/partials/flex layouts/partials/original
   ```

3. **Create** the header.html override to fix nil pointer errors:

   > `layouts/partials/header.html`

   ```html
   {{ $header := print "_header." .Lang }}
   {{ $found := false }}
   {{ range .Site.Pages }}
     {{ with .File }}
       {{ if eq .BaseFileName $header }}
         {{ $.Scratch.Set "headerContent" $.Content }}
         {{ $found = true }}
       {{ end }}
     {{ end }}
   {{ end }}
   {{ if $found }}
     {{ .Scratch.Get "headerContent" }}
   {{ else }}
     {{ if .Site.GetPage "page" "_header.md" }}
       {{(.Site.GetPage "page" "_header.md").Content}}
     {{ else }}
       <a class="baselink" href="{{.Site.BaseURL}}">{{.Site.Title}}</a>
     {{ end }}
   {{ end }}
   ```

4. **Create** the body-aftercontent.html override:

   > `layouts/partials/flex/body-aftercontent.html`

   ```html
     <div class="chevrons">
       {{ partial "next-prev-page.html" . }}
     </div>

     </section>
   </article>

   <footer>

   <div class="footline">
       {{if .Params.tags }}
       <div class="tags">
         {{ range $index, $tag := .Params.tags }}
           <a class="label label-default" href="{{$.Site.BaseURL}}tags/{{ $tag | urlize }}">{{ $tag }}</a>
         {{ end }}
       </div>
       {{end}}

       {{with .Params.LastModifierDisplayName}}
       <div class="author">
           <i class='fa fa-user'></i> <a href="mailto:{{ $.Params.LastModifierEmail }}">{{ . }}</a>
       </div>
       {{end}}

       {{ if not .Page.Lastmod.IsZero }}
       <div class="date">
           <i class='fa fa-calendar'></i> {{T "last-update-on"}} {{ .Page.Lastmod.Format "02/01/2006" }}
       </div>
       {{end}}

       {{ if and .Site.Params.editURL .File }}
       <div class="github-link">
         <a href="{{ .Site.Params.editURL }}{{ replace .File.Dir "\\" "/" }}{{ .File.LogicalName }}" target="blank"><i class="fa fa-code-fork"></i>
           {{T "Edit-this-page"}}</a>
       </div>
       {{end}}
     </div>


   	<div>
   {{ $footer := print "_footer." .Lang }}
   {{ $found := false }}
   {{ range .Site.Pages }}
     {{ with .File }}
       {{ if eq .BaseFileName $footer }}
         {{ $.Scratch.Set "footerContent" $.Content }}
         {{ $found = true }}
       {{ end }}
     {{ end }}
   {{ end }}
   {{ if $found }}
     {{ .Scratch.Get "footerContent" }}
   {{ else }}
     {{ if .Site.GetPage "page" "_footer.md" }}
       {{(.Site.GetPage "page" "_footer.md").Content}}
     {{ else }}
       {{ T "create-footer-md" }}
     {{ end }}
   {{ end }}


   	</div>
   </footer>

   {{ partial "flex/scripts.html" . }}

   {{ $layoutsPartialsMenu := resources.Get "js/layouts/partials/menu.js" }}

   {{ $concatjs := slice $layoutsPartialsMenu | resources.Concat "js/scripts.js" | resources.Minify }}
   <script src="{{ $concatjs.Permalink }}"></script>
   ```

5. **Create** the scripts.html override to fix deprecated APIs and improve menu behavior:

   > `layouts/partials/flex/scripts.html`

   ```html
   <script src="{{"js/jquery-2.x.min.js" | relURL}}"></script>
   <script type="text/javascript">
       {{if hugo.IsMultilingual}}
           var baseurl = "{{.Site.BaseURL}}{{.Site.LanguagePrefix}}";
       {{else}}
           var baseurl = "{{.Site.BaseURL}}";
       {{end}}
   </script>
   <script src="{{"js/clipboard.min.js" | relURL}}"></script>
   <script src="{{"js/featherlight.min.js" | relURL}}"></script>
   {{if eq .Site.Params.highlightClientSide true}}
   <script src="{{"js/highlight.pack.js" | relURL}}"></script>
   <script>hljs.initHighlightingOnLoad();</script>
   {{end}}
   <script type="text/javascript" src="{{"js/lunr.min.js" | relURL}}"></script>
   <script type="text/javascript" src="{{"js/auto-complete.js" | relURL}}"></script>
   <script type="text/javascript" src="{{"js/search.js" | relURL}}"></script>
   <script src="{{(printf "theme-%s/script.js" (.Site.Params.themeStyle| default "flex")) | relURL}}"></script>

   <!-- Override menu collapse behavior to keep active section expanded -->
   <script type="text/javascript">
   jQuery(document).ready(function() {
       // Remove the default click handler and add our custom one
       jQuery('#sidebar .category-icon').off('click').on('click', function() {
           var menuItem = jQuery(this).parent().parent();

           // If this section contains the active page, don't allow collapse
           if (menuItem.hasClass('parent') || menuItem.hasClass('active')) {
               return false;
           }

           // Otherwise, toggle as normal
           jQuery(this).toggleClass("fa-angle-down fa-angle-right");
           menuItem.children('ul').toggle();
           return false;
       });
   });
   </script>
   ```

6. **Create** the language-selector.html override:

   > `layouts/partials/language-selector.html`

   ```html
   {{- if and hugo.IsMultilingual (not .Site.Params.DisableLanguageSwitchingButton)}}
   <select id="select-language" onchange="location = this.value;">
   	{{ $siteLanguages := .Site.Languages}}
   	{{ $pageLang := .Page.Lang}}
   	{{ range .Page.AllTranslations }}
   	  {{ $translation := .}}
   	  {{ range $siteLanguages }}
   	    {{ if eq $translation.Lang .Lang }}
   	      {{ if eq $pageLang .Lang}}
   	        <option id="{{ $translation.Language }}" value="{{ $translation.Permalink }}" selected>{{ .LanguageName }}</option>
   	      {{ else }}
   	        <option id="{{ $translation.Language }}" value="{{ $translation.Permalink }}">{{ .LanguageName }}</option>
   	      {{ end }}
   	    {{ end }}
   	  {{ end }}
   	{{ end }}
   </select>
   {{- end }}
   ```

7. **Create** the original/scripts.html override:

   > `layouts/partials/original/scripts.html`

   ```html
   <script src="{{"js/jquery-2.x.min.js" | relURL}}"></script>
   <script type="text/javascript">
       {{if hugo.IsMultilingual}}
           var baseurl = "{{.Site.BaseURL}}{{.Site.LanguagePrefix}}";
       {{else}}
           var baseurl = "{{.Site.BaseURL}}";
       {{end}}
   </script>
   <script src="{{"js/clipboard.min.js" | relURL}}"></script>
   <script src="{{"js/featherlight.min.js" | relURL}}"></script>
   <script src="{{"js/html5shiv-printshiv.min.js" | relURL}}"></script>
   {{if eq .Site.Params.highlightClientSide true}}
   <script src="{{"js/highlight.pack.js" | relURL}}"></script>
   <script>hljs.initHighlightingOnLoad();</script>
   {{end}}
   <script src="{{"js/modernizr.custom.71422.js" | relURL}}"></script>
   <script src="{{"js/docdock.js" | relURL}}"></script>
   <script type="text/javascript" src="{{"js/lunr.min.js" | relURL}}"></script>
   <script type="text/javascript" src="{{"js/auto-complete.js" | relURL}}"></script>
   <script type="text/javascript" src="{{"js/search.js" | relURL}}"></script>
   <script src="{{"theme-original/script.js" | relURL}}"></script>
   ```

> ℹ **Concept Deep Dive**
>
> Hugo's template lookup order checks your project's `layouts/` directory before the theme's. This allows you to override specific theme files without modifying the theme itself. The main compatibility issues with DocDock are: (1) accessing `.File` properties on pages without backing files causes nil pointer errors, (2) `.Site.IsMultiLingual` was deprecated in favor of `hugo.IsMultilingual`. Using project overrides keeps the theme submodule pristine and updatable.
>
> ⚠ **Common Mistakes**
>
> - Editing theme files directly instead of creating overrides makes theme updates destructive
> - Missing the `with .File` guard causes nil pointer errors on taxonomy pages
> - Forgetting to create the full directory path for overrides causes them to be ignored
>
> ✓ **Quick check:** Five override files exist in `layouts/partials/`

### **Step 4:** Configure Hugo for GitHub Pages

Create the Hugo configuration file with settings optimized for GitHub Pages deployment and DocDock theme functionality.

1. **Create** the Hugo configuration file:

   > `hugo.toml`

   ```toml
   baseURL = "https://YOUR-SUBDOMAIN.YOUR-DOMAIN.com/"
   languageCode = "en-us"
   title = "Your Site Title"
   theme = "docdock"

   # Required for DocDock search functionality
   [outputs]
     home = ["HTML", "RSS", "JSON"]

   # DocDock theme parameters
   [params]
     # Theme style: "flex" (default) or "original"
     themeStyle = "flex"

     # Show edit link to GitHub (optional)
     # editURL = "https://github.com/YOUR-ORG/YOUR-REPO/edit/main/content/"

     # Search settings
     search = true

   # Menu configuration
   [menu]
     [[menu.shortcuts]]
       name = "<i class='fa fa-github'></i> GitHub"
       url = "https://github.com/YOUR-ORG/YOUR-REPO"
       weight = 10

     [[menu.shortcuts]]
       name = "<i class='fa fa-bookmark'></i> Hugo Documentation"
       url = "https://gohugo.io/documentation/"
       weight = 20

   # Markup settings for code highlighting
   [markup]
     [markup.highlight]
       style = "monokai"
       lineNos = false
       codeFences = true
       guessSyntax = true

     [markup.goldmark]
       [markup.goldmark.renderer]
         unsafe = true
   ```

2. **Replace** the placeholder values:
   - `YOUR-SUBDOMAIN.YOUR-DOMAIN.com` with your actual subdomain
   - `Your Site Title` with your site's title
   - `YOUR-ORG/YOUR-REPO` with your organization and repository names

> ℹ **Concept Deep Dive**
>
> The `baseURL` must include the protocol (`https://`) and should match your custom domain exactly. The `[outputs]` section enables JSON output required for DocDock's search feature. The `unsafe = true` in goldmark allows raw HTML in Markdown files, which is necessary for some Hugo shortcodes and reveal.js presentations. The `themeStyle` can be "flex" (modern) or "original" (classic DocDock look).
>
> ⚠ **Common Mistakes**
>
> - Missing trailing slash in baseURL can cause relative URL issues
> - Wrong baseURL causes all internal links to break
> - Missing `home = ["HTML", "RSS", "JSON"]` breaks the search functionality
>
> ✓ **Quick check:** Configuration file has correct baseURL and theme setting

### **Step 5:** Create Initial Content Structure

Set up the content directory with a homepage and sample content to verify the site works correctly.

1. **Create** the homepage:

   > `content/_index.md`

   ```markdown
   +++
   title = "Your Site Title"
   description = "Welcome to your documentation site"
   +++

   # Welcome

   This documentation site is built with Hugo and the DocDock theme.

   ## Features

   - **Documentation** - Organize your content into chapters and pages
   - **Presentations** - Create reveal.js slides directly in Markdown
   - **Search** - Built-in search functionality
   - **Responsive** - Works on all devices
   ```

2. **Create** a sample chapter:

   ```bash
   mkdir -p content/getting-started
   ```

   > `content/getting-started/_index.md`

   ```markdown
   +++
   title = "Getting Started"
   description = "Introduction to the documentation"
   weight = 1
   chapter = true
   +++

   # Getting Started

   This chapter provides an introduction to the documentation.

   {{< children />}}
   ```

3. **Create** a sample page:

   > `content/getting-started/introduction.md`

   ```markdown
   +++
   title = "Introduction"
   description = "Introduction page"
   weight = 1
   +++

   ## Introduction

   Welcome to the documentation!

   ### What You'll Learn

   - How to navigate the documentation
   - How to create new pages
   - How to use reveal.js presentations
   ```

4. **Create** a sample reveal.js presentation:

   ```bash
   mkdir -p content/slides
   ```

   > `content/slides/_index.md`

   ```markdown
   +++
   title = "Presentations"
   description = "Course presentations and slides"
   weight = 10
   chapter = true
   +++

   # Presentations

   Browse the presentations below.

   {{< children />}}
   ```

   > `content/slides/example-presentation.md`

   ```markdown
   +++
   title = "Example Presentation"
   type = "slide"
   theme = "league"
   weight = 1

   [revealOptions]
   transition = "convex"
   controls = true
   progress = true
   history = true
   center = true
   +++

   # Welcome

   ## Example Presentation

   ---

   # Slide 2

   Content for slide 2

   ___

   ## Vertical Slide

   Use `---` for horizontal slides
   Use `___` for vertical slides

   ---

   # Thank You!

   Questions?
   ```

5. **Test** the site locally:

   ```bash
   hugo server
   ```

6. **Open** <http://localhost:1313> in your browser

> ℹ **Concept Deep Dive**
>
> Hugo uses front matter (the `+++` section) to define page metadata. The `weight` parameter controls menu ordering (lower numbers appear first). Setting `chapter = true` creates a chapter landing page with special styling. The `{{< children />}}` shortcode automatically lists child pages. For reveal.js presentations, `type = "slide"` triggers the presentation template, and slides are separated by `---` (horizontal) or `___` (vertical).
>
> ⚠ **Common Mistakes**
>
> - Missing `_index.md` in a directory means Hugo won't create a section for it
> - Using `{{% children %}}` instead of `{{< children />}}` causes parsing errors in newer Hugo
> - Forgetting `type = "slide"` in presentation front matter renders it as a normal page
>
> ✓ **Quick check:** Site runs locally and displays homepage with navigation

### **Step 6:** Set Up GitHub Actions Workflow

Create the GitHub Actions workflow to automatically build and deploy your site to GitHub Pages when you push changes.

1. **Create** the workflow directory:

   ```bash
   mkdir -p .github/workflows
   ```

2. **Create** the workflow file:

   > `.github/workflows/hugo.yaml`

   ```yaml
   # Deploy Hugo site to GitHub Pages
   name: Deploy Hugo site to Pages

   on:
     # Runs on pushes targeting the default branch
     push:
       branches:
         - main

     # Allows you to run this workflow manually from the Actions tab
     workflow_dispatch:

   # Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
   permissions:
     contents: read
     pages: write
     id-token: write

   # Allow only one concurrent deployment
   concurrency:
     group: "pages"
     cancel-in-progress: false

   # Default to bash
   defaults:
     run:
       shell: bash

   jobs:
     # Build job
     build:
       runs-on: ubuntu-latest
       env:
         HUGO_VERSION: 0.128.0
       steps:
         - name: Install Hugo CLI
           run: |
             wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
             && sudo dpkg -i ${{ runner.temp }}/hugo.deb

         - name: Install Dart Sass
           run: sudo snap install dart-sass

         - name: Checkout
           uses: actions/checkout@v4
           with:
             submodules: recursive
             fetch-depth: 0

         - name: Setup Pages
           id: pages
           uses: actions/configure-pages@v5

         - name: Install Node.js dependencies
           run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"

         - name: Build with Hugo
           env:
             HUGO_CACHEDIR: ${{ runner.temp }}/hugo_cache
             HUGO_ENVIRONMENT: production
             TZ: Europe/Stockholm
           run: |
             hugo \
               --gc \
               --minify \
               --baseURL "${{ steps.pages.outputs.base_url }}/"

         - name: Upload artifact
           uses: actions/upload-pages-artifact@v3
           with:
             path: ./public

     # Deployment job
     deploy:
       environment:
         name: github-pages
         url: ${{ steps.deployment.outputs.page_url }}
       runs-on: ubuntu-latest
       needs: build
       steps:
         - name: Deploy to GitHub Pages
           id: deployment
           uses: actions/deploy-pages@v4
   ```

3. **Create** the CNAME file for custom domain:

   > `static/CNAME`

   ```text
   YOUR-SUBDOMAIN.YOUR-DOMAIN.com
   ```

   Replace with your actual subdomain.

> ℹ **Concept Deep Dive**
>
> This workflow uses GitHub's modern Pages deployment via Actions artifacts. The `submodules: recursive` flag ensures the DocDock theme is checked out. Hugo Extended is required for SCSS processing. The `configure-pages` action automatically handles the baseURL, which is why the workflow can override it dynamically. The CNAME file in `static/` gets copied to the build output, telling GitHub Pages which custom domain to serve.
>
> ⚠ **Common Mistakes**
>
> - Missing `submodules: recursive` causes "theme not found" errors
> - Using standard Hugo instead of Extended breaks SCSS compilation
> - Forgetting CNAME file causes custom domain to reset after each deployment
> - Setting source to "Deploy from branch" instead of "GitHub Actions" in repo settings
>
> ✓ **Quick check:** Workflow file exists at `.github/workflows/hugo.yaml`

### **Step 7:** Configure Custom Subdomain DNS

Set up DNS records to point your subdomain to GitHub Pages. This involves creating a CNAME record with your DNS provider and configuring GitHub Pages settings.

1. **Access** your domain's DNS management panel (Cloudflare, Route53, GoDaddy, etc.)

2. **Create** a CNAME record:
   - **Type:** CNAME
   - **Name:** `your-subdomain` (e.g., `docs`, `course`, `wiki`)
   - **Target:** `YOUR-ORG.github.io`
   - **TTL:** Auto or 3600

3. **Commit and push** your changes to GitHub:

   ```bash
   git add .
   git commit -m "Initial Hugo site setup"
   git push origin main
   ```

4. **Wait** for the GitHub Actions workflow to complete (check Actions tab)

5. **Configure** GitHub Pages settings:
   - Go to repository **Settings** > **Pages**
   - Set **Source** to **GitHub Actions**
   - Under **Custom domain**, enter your subdomain (e.g., `docs.example.com`)
   - Click **Save**
   - Wait for DNS check to complete (may take a few minutes to 24 hours)
   - Enable **Enforce HTTPS** once the certificate is provisioned

> ℹ **Concept Deep Dive**
>
> For project sites in organizations, the CNAME record points to `ORG-NAME.github.io` (not the repository name). GitHub's infrastructure routes requests to the correct repository based on the CNAME file in your deployment. The DNS check verifies ownership before issuing an SSL certificate via Let's Encrypt. If you use Cloudflare, ensure you're using "DNS only" mode (gray cloud) rather than proxied mode for the initial setup.
>
> ⚠ **Common Mistakes**
>
> - Creating an A record instead of CNAME for subdomains
> - Pointing to `username.github.io/repo` instead of just `username.github.io`
> - Using Cloudflare proxy (orange cloud) can interfere with GitHub's SSL provisioning
> - Not waiting for DNS propagation before expecting HTTPS to work
> - CAA records on parent domain blocking Let's Encrypt certificate issuance
>
> ✓ **Quick check:** DNS record created, GitHub Pages shows custom domain configured

### **Step 8:** Test Your Deployment

Verify that your site is correctly deployed and accessible via your custom subdomain.

1. **Check** the GitHub Actions workflow:
   - Go to repository **Actions** tab
   - Verify the workflow completed successfully (green checkmark)
   - If failed, click on the run to see error details

2. **Visit** your custom domain:
   - Open `https://YOUR-SUBDOMAIN.YOUR-DOMAIN.com`
   - Verify the homepage loads correctly
   - Check that navigation works
   - Test the search functionality

3. **Test** the presentation:
   - Navigate to the Slides section
   - Click on the example presentation
   - Verify slides render correctly
   - Test navigation with arrow keys

4. **Verify** HTTPS:
   - Check that the padlock icon appears in browser
   - Confirm no mixed content warnings

5. **Test** a content update:
   - Make a small change to `content/_index.md`
   - Commit and push
   - Verify the change appears on the live site after workflow completes

> ✓ **Success indicators:**
>
> - Site loads at custom domain with HTTPS
> - Navigation menu shows all sections
> - Search returns results
> - Reveal.js presentations work correctly
> - Changes deploy automatically on push
>
> ✓ **Final verification checklist:**
>
> - ☐ GitHub Actions workflow completes successfully
> - ☐ Site accessible at custom subdomain
> - ☐ HTTPS certificate is valid
> - ☐ All pages render correctly
> - ☐ Search functionality works
> - ☐ Presentations display properly
> - ☐ Automatic deployment works on push

## Common Issues

> **If you encounter problems:**
>
> **"Theme not found" error in build:** Ensure you used `submodules: recursive` in the checkout step and committed `.gitmodules`
>
> **Blank page or 404:** Check that `baseURL` in `hugo.toml` matches your custom domain exactly, including protocol
>
> **DNS check stuck in progress:** This can take up to 24 hours. If the site works, the status may just be slow to update. Try removing and re-adding the custom domain
>
> **HTTPS not working:** Wait for Let's Encrypt certificate provisioning (up to 24 hours). Check for CAA records on your domain that might block Let's Encrypt
>
> **CSS/JS not loading:** Usually a baseURL issue or mixed content. Check browser console for errors
>
> **Workflow fails on push:** Check the Actions tab for error messages. Common issues are Hugo version mismatches or missing files
>
> **Search not working:** Ensure `[outputs]` section includes JSON format in `hugo.toml`
>
> **Still stuck?** Check GitHub Pages documentation at <https://docs.github.com/en/pages>

## Summary

You've successfully set up a Hugo documentation site with DocDock theme on GitHub Pages which:

- ✓ Deploys automatically when you push to main branch
- ✓ Serves content from your custom subdomain with HTTPS
- ✓ Supports reveal.js presentations written in Markdown
- ✓ Uses theme overrides for maintainability and compatibility

> **Key takeaway:** Using Hugo with GitHub Actions provides a powerful, free documentation platform. The theme override pattern (project `layouts/` over theme) is essential for maintaining compatibility with legacy themes while keeping them updatable. This setup scales well for teams and integrates naturally with GitHub-based workflows.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add more reveal.js themes by exploring <https://revealjs.com/themes/>
> - Configure multilingual support in `hugo.toml`
> - Set up a custom 404 page at `layouts/404.html`
> - Add Mermaid diagram support with DocDock's built-in shortcodes
> - Create custom shortcodes for repeated content patterns
> - Set up branch previews with GitHub Actions for pull requests

## Done! 🎉

Excellent work! You've learned how to set up a complete documentation site with Hugo and GitHub Pages. This foundation supports team documentation, course materials, or any content that benefits from version control and automatic deployment. Your site will now update automatically whenever you push changes to the main branch.
