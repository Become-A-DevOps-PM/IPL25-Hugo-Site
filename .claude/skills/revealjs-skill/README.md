# Reveal.js Swedish Tech Presentation Skill

## Overview
This skill enables Claude Code to create professional Reveal.js presentations with a distinctive Swedish tech aesthetic. Presentations are created as standalone HTML files in `static/presentations/` and linked from Hugo content pages.

## Files

- `SKILL.md` - Complete skill documentation with templates
- `template.css` - Swedish tech styling (copy to `static/presentations/swedish-tech-slides.css`)
- `config.js` - Reveal.js configuration (optional, settings are included in HTML template)
- `example-template.html` - Working example with all 5 slide types

## The 5 Slide Types

### 1. Hero Slide
Opening title slide with course badge, multi-line title, subtitle, and decorative elements.
```html
<section class="hero-slide" data-background-color="#0A0E27">
```

### 2. Profile Card Slide
Card positioned on the right for introductions or audience questions.
```html
<section class="profile-card-slide" data-background-color="#0A0E27">
```

### 3. Bullet Slide
Progressive info-boxes with yellow highlighting.
```html
<section class="bullet-slide" data-background-color="#0A0E27">
```

### 4. Timeline Slide
Horizontal timeline with week indicators and description boxes that fade in/out.
```html
<section class="timeline-slide" data-background-color="#0A0E27">
```

### 5. Closing Slide
Centered content for questions or closing statements.
```html
<section class="closing-slide" data-background-color="#0A0E27">
```

## Quick Start

### 1. Copy CSS to your project
```bash
cp template.css /path/to/your-project/static/presentations/swedish-tech-slides.css
```

### 2. Create a new presentation
Create an HTML file in `static/presentations/`:

```html
<!DOCTYPE html>
<html lang="sv">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Presentation</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/5.0.4/reveal.min.css">
    <link rel="stylesheet" href="swedish-tech-slides.css">
</head>
<body>
    <div class="reveal">
        <div class="slides">
            <!-- Add slides here -->
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/5.0.4/reveal.min.js"></script>
    <script>
        Reveal.initialize({
            hash: true,
            controls: true,
            progress: true,
            center: false,
            transition: 'slide',
            backgroundTransition: 'fade',
            slideNumber: 'c/t',
            history: true,
            width: 1920,
            height: 1080,
            margin: 0.04,
            minScale: 0.2,
            maxScale: 1.0
        });
    </script>
</body>
</html>
```

### 3. Create a Hugo content page
Link to your presentation from a markdown file:

```markdown
+++
title = "My Presentation"
description = "Description"
weight = 5
+++

# My Presentation

**[Öppna presentationen](/presentations/my-presentation.html)**
```

## Color Scheme

| Color | Hex | Usage |
|-------|-----|-------|
| Swedish Blue | #006AA7 | Backgrounds, timeline |
| Swedish Yellow | #FECC00 | Highlights, headers, accents |
| Tech Cyan | #00D9FF | Subtitles, accents |
| Dark Background | #0A0E27 | Slide backgrounds |

## Usage with Claude Code

### Basic Request
```
"Create a Reveal.js presentation about [topic] with 5 slides"
```

### Specific Slide Types
```
"Create a presentation with:
- Hero slide for title
- Profile card for instructor intro
- Two bullet slides for content
- Timeline slide for schedule
- Closing slide for questions"
```

## Navigation

- **→ / Space**: Next slide
- **←**: Previous slide
- **F**: Fullscreen
- **ESC**: Slide overview
- **?**: Help menu

## Best Practices

1. **Hero slide**: Use for opening only
2. **Bullet slides**: Maximum 5 info-boxes
3. **Timeline slides**: 6-8 items maximum
4. **Text**: Use `<span class="highlight">` for emphasis
5. **Fragments**: Use `fade-in-then-out` for timeline descriptions (except the last one)

## Troubleshooting

### Content scaling beyond window
Ensure `maxScale: 1.0` is set in Reveal.initialize()

### Fonts too small
The template is optimized for 1920x1080. Check your display resolution.

### Fragments not working
Verify `data-fragment-index` values are sequential and match between timeline items and description boxes.
