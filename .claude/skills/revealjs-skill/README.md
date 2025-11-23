# Reveal.js Swedish Tech Presentation Skill

## Overview
This skill enables Claude Code to create professional Reveal.js presentations with a distinctive Swedish tech aesthetic, perfect for educational and technical presentations.

## Installation

1. Copy all files from this folder into your Claude Code project:
   - `SKILL.md` - The main skill documentation
   - `template.css` - Swedish tech styling
   - `config.js` - Reveal.js configuration
   - `example-template.html` - Example presentation

2. Place files in your project structure:
   ```
   your-project/
   ├── skills/
   │   └── revealjs-swedish/
   │       ├── SKILL.md
   │       ├── template.css
   │       ├── config.js
   │       └── example-template.html
   ```

## Usage with Claude Code

### Basic Request
```
"Create a Reveal.js presentation about [topic] with [number] slides using the Swedish tech template"
```

### Detailed Request
```
"Create a Reveal.js presentation about cloud infrastructure with:
- Title slide with course code IPL
- Overview slide with 6-week timeline
- Content slides for each topic
- Group assignment slide
- Use Swedish tech template with blue/yellow colors"
```

## Template Features

### Color Scheme
- **Primary**: Swedish Blue (#006AA7)
- **Secondary**: Swedish Yellow (#FECC00)  
- **Accent**: Tech Cyan (#00D9FF)
- **Background**: Dark Navy (#0A0E27)

### Slide Types Available

1. **Title Slide**
   - Course badge/code
   - Multi-line title
   - Subtitle
   - Additional info
   - Geometric decorations

2. **Content Slide**
   - Section headers
   - Bullet lists
   - Info boxes
   - Code snippets

3. **Timeline Slide**
   - Week/phase indicators
   - Interactive hover effects
   - Sequential animations

4. **Grid Layout**
   - Card-based layouts
   - Group/team displays
   - Hover animations

5. **Section Divider**
   - Full-width colored background
   - Large centered text

6. **Table Slide**
   - Styled headers
   - Hover effects
   - Auto-formatting

## Customization

### Modifying Colors
Edit the CSS variables in `template.css`:
```css
:root {
    --swedish-blue: #006AA7;
    --swedish-yellow: #FECC00;
    --tech-cyan: #00D9FF;
    /* ... other colors */
}
```

### Adjusting Font Sizes
Modify the typography section in `template.css`:
```css
.reveal h1 { font-size: 2.5em; }
.reveal h2 { font-size: 1.8em; }
/* ... etc */
```

### Adding New Slide Types
1. Create new CSS class in `template.css`
2. Add HTML structure example in `SKILL.md`
3. Update example template

## Navigation

### Keyboard Shortcuts
- **→ / Space**: Next slide
- **←**: Previous slide
- **↑ / ↓**: Navigate vertical slides
- **F**: Fullscreen
- **ESC**: Slide overview
- **S**: Speaker notes
- **B**: Black screen
- **?**: Help menu

### Mouse/Touch
- Click arrows in bottom-right
- Swipe on touch devices
- Scroll with mouse wheel (if enabled)

## Best Practices

### Content Guidelines
- **Title slides**: Max 3 lines for main title
- **Lists**: 4-6 items per slide
- **Text**: Keep concise, use fragments for reveals
- **Timeline**: 6-8 items maximum
- **Grid**: 4-6 cards per slide

### Performance Tips
- Use CDN-hosted Reveal.js (v5.0.4)
- Minimize custom animations
- Test on target display resolution
- Keep images optimized

## Fragment Animations

Use `class="fragment"` with `data-fragment-index="N"` for sequential reveals:
```html
<li class="fragment" data-fragment-index="1">First item</li>
<li class="fragment" data-fragment-index="2">Second item</li>
```

## Decorative Elements

Available decorations to add visual interest:
- `.geometric-bg` - Angled blue gradient background
- `.corner-accent` - Cyan corner decoration
- `.bottom-accent` - Yellow gradient bar
- `.network-decoration` - Network node visualization

## Troubleshooting

### Fonts Too Large
- Check screen resolution
- Adjust font sizes in `template.css`
- Use responsive media queries

### Animations Not Working
- Ensure Reveal.js is loaded
- Check fragment indices
- Verify `config.js` is included

### Colors Not Displaying
- Check CSS file is linked
- Verify color variables are set
- Test in different browsers

## Example Files

- `example-template.html` - Complete working example with all slide types
- Open in browser to see live presentation
- Use as reference for creating new presentations

## Support

This skill is designed for:
- Educational presentations
- Technical documentation
- Course materials
- Conference talks
- Team meetings

## License

This template is created for educational use. Feel free to modify and adapt for your needs.