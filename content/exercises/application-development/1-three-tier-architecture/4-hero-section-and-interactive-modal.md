+++
title = "Hero Section and Interactive Modal"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Build a visually engaging landing page with a styled hero section and an accessible modal dialog"
weight = 3
+++

# Hero Section and Interactive Modal

## Goal

Build a visually engaging landing page with a styled hero section and an accessible modal dialog that opens when users click the subscribe button.

> **What you'll learn:**
>
> - How to use CSS gradients for modern backgrounds
> - When to use Jinja2 template blocks for page-specific CSS and JavaScript
> - Best practices for building accessible modal dialogs

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ A Flask application with base template and working routes
> - ✓ Flask development server running
> - ✓ Browser developer tools available (F12)
> - ✓ Virtual environment activated (`cd application && source .venv/bin/activate`)

## Exercise Steps

### Overview

1. **Build the Hero Section HTML**
2. **Style the Hero with CSS Gradients**
3. **Add the Modal Dialog HTML**
4. **Implement Modal JavaScript**
5. **Test Your Implementation**

### **Step 1:** Build the Hero Section HTML

The hero section is the first thing visitors see when they land on your page. It needs to immediately communicate what your application does and provide a clear call-to-action. A well-designed hero section combines compelling copy with visual appeal to convert visitors into subscribers.

1. **Open** the index template file

2. **Replace** the entire content with the hero section structure:

   > `application/app/presentation/templates/index.html`

   ```html
   {% extends "base.html" %}

   {% block title %}News Flash - Stay Informed{% endblock %}

   {% block content %}
   <section class="hero">
       <div class="hero__container">
           <h1 class="hero__title">Stay Ahead of the Curve</h1>
           <p class="hero__subtitle">
               Get the latest tech news delivered straight to your inbox.
               No spam, just the stories that matter.
           </p>
           <button class="btn btn--primary hero__cta" id="subscribeBtn">
               Subscribe Now
           </button>
       </div>
   </section>
   {% endblock %}
   ```

> **About BEM Naming Convention**
>
> The CSS class names use BEM (Block Element Modifier) notation:
> - `.hero` is the Block (the component)
> - `.hero__title` is an Element (part of the hero)
> - `.btn--primary` is a Modifier (a variation of the button)
>
> BEM makes CSS more maintainable by creating clear relationships between classes.
>
> **Quick check:** Hero section displays with heading and button

### **Step 2:** Style the Hero with CSS Gradients

Now we add the visual styling that makes the hero section stand out. CSS gradients create smooth color transitions that add depth and visual interest without requiring image files. The flexbox layout ensures the content stays centered both horizontally and vertically.

1. **Add** the extra CSS block after the content block:

   > `application/app/presentation/templates/index.html`

   ```html
   {% block extra_css %}
   <style>
       .hero {
           background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 50%, #60a5fa 100%);
           color: white;
           padding: 6rem 2rem;
           text-align: center;
           min-height: 60vh;
           display: flex;
           align-items: center;
           justify-content: center;
       }

       .hero__container {
           max-width: 800px;
           margin: 0 auto;
       }

       .hero__title {
           font-size: 3rem;
           font-weight: 800;
           margin-bottom: 1.5rem;
           line-height: 1.2;
           text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
       }

       .hero__subtitle {
           font-size: 1.25rem;
           margin-bottom: 2.5rem;
           opacity: 0.95;
           max-width: 600px;
           margin-left: auto;
           margin-right: auto;
           line-height: 1.7;
       }

       .hero__cta {
           font-size: 1.125rem;
           padding: 1rem 2.5rem;
           background-color: white;
           color: var(--color-primary);
       }

       .hero__cta:hover {
           background-color: #f8fafc;
           transform: translateY(-2px);
           box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
       }

       @media (max-width: 768px) {
           .hero {
               padding: 4rem 1.5rem;
           }

           .hero__title {
               font-size: 2rem;
           }

           .hero__subtitle {
               font-size: 1rem;
           }
       }
   </style>
   {% endblock %}
   ```

2. **Save** and refresh your browser to see the styled hero

> **Understanding the CSS**
>
> - `linear-gradient(135deg, ...)` creates a diagonal gradient from dark blue to light blue
> - `min-height: 60vh` makes the hero at least 60% of the viewport height
> - `display: flex` with `align-items: center` and `justify-content: center` centers content both ways
> - The `@media` query adjusts font sizes for mobile devices
> - `transform: translateY(-2px)` creates a subtle lift effect on hover
>
> **Why page-specific styles?**
>
> Using `{% block extra_css %}` keeps hero styles with the hero template rather than bloating the base template. This is a form of component-based thinking: styles live with the markup they affect.
>
> **Quick check:** Hero displays with gradient background and centered text

### **Step 3:** Add the Modal Dialog HTML

The modal dialog will eventually contain a subscription form, but for now it displays a "Coming Soon" message. Modals need careful attention to accessibility so that keyboard and screen reader users can interact with them properly.

1. **Add** the modal HTML inside the content block, after the hero section:

   > `application/app/presentation/templates/index.html`

   ```html
   {% block content %}
   <section class="hero">
       <!-- ... existing hero content ... -->
   </section>

   <!-- Subscribe Modal -->
   <div class="modal-overlay" id="modalOverlay">
       <div class="modal" role="dialog" aria-labelledby="modalTitle" aria-modal="true">
           <div class="modal__header">
               <h2 class="modal__title" id="modalTitle">Coming Soon!</h2>
               <button class="modal__close" id="modalClose" aria-label="Close modal">&times;</button>
           </div>
           <div class="modal__body">
               <p>We're working hard to bring you the best newsletter experience.</p>
               <p style="margin-top: 1rem;">Check back soon to subscribe!</p>
           </div>
       </div>
   </div>
   {% endblock %}
   ```

> **Accessibility Attributes Explained**
>
> These ARIA attributes are essential for screen reader users:
>
> - `role="dialog"` tells assistive technology this is a dialog window
> - `aria-labelledby="modalTitle"` links the dialog to its title for screen readers
> - `aria-modal="true"` indicates the rest of the page is inert while the modal is open
> - `aria-label="Close modal"` provides a text label for the X button
>
> Without these attributes, screen reader users would not understand the modal's purpose or how to interact with it.
>
> **About the Modal CSS**
>
> The modal styling is already defined in `base.html`. Open the base template to see:
> - `.modal-overlay` creates the dark backdrop
> - `.modal` styles the white dialog box
> - The `@keyframes modalSlideIn` animation provides the slide-in effect
> - `.modal-overlay.active` controls visibility via the `display` property
>
> **Quick check:** Modal HTML is in place (will not display until JavaScript is added)

### **Step 4:** Implement Modal JavaScript

JavaScript brings the modal to life by handling user interactions. A well-implemented modal should be closeable in multiple ways: clicking a close button, clicking outside the modal, or pressing the Escape key. Focus management ensures keyboard users can navigate the modal properly.

1. **Add** the scripts block at the end of your template:

   > `application/app/presentation/templates/index.html`

   ```html
   {% block scripts %}
   <script>
       // Modal functionality
       const subscribeBtn = document.getElementById('subscribeBtn');
       const modalOverlay = document.getElementById('modalOverlay');
       const modalClose = document.getElementById('modalClose');
       const modal = modalOverlay.querySelector('.modal');

       // Open modal
       subscribeBtn.addEventListener('click', function() {
           modalOverlay.classList.add('active');
           modalClose.focus();
       });

       // Close modal - close button
       modalClose.addEventListener('click', function() {
           modalOverlay.classList.remove('active');
           subscribeBtn.focus();
       });

       // Close modal - click outside
       modalOverlay.addEventListener('click', function(event) {
           if (event.target === modalOverlay) {
               modalOverlay.classList.remove('active');
               subscribeBtn.focus();
           }
       });

       // Close modal - Escape key
       document.addEventListener('keydown', function(event) {
           if (event.key === 'Escape' && modalOverlay.classList.contains('active')) {
               modalOverlay.classList.remove('active');
               subscribeBtn.focus();
           }
       });
   </script>
   {% endblock %}
   ```

> **Focus Management for Accessibility**
>
> Notice how focus is managed throughout:
>
> 1. When the modal opens, focus moves to the close button (`modalClose.focus()`)
> 2. When the modal closes, focus returns to the subscribe button (`subscribeBtn.focus()`)
>
> This is critical for keyboard users. Without focus management, the user's cursor would be "lost" after closing the modal, forcing them to tab through the entire page to find their place again.
>
> **Event Handling Patterns**
>
> The JavaScript uses several event handling patterns:
>
> - `getElementById()` retrieves elements by their `id` attribute
> - `addEventListener()` attaches functions to events like `click` and `keydown`
> - `classList.add()` and `classList.remove()` toggle CSS classes
> - `event.target` identifies which element triggered the event
>
> The overlay click handler checks `if (event.target === modalOverlay)` to ensure clicks on the modal itself do not close it - only clicks on the dark background do.
>
> **Quick check:** Modal opens when clicking Subscribe button

### **Step 5:** Test Your Implementation

Testing interactive components requires checking multiple user flows. You need to verify that the visual design works across different screen sizes and that all interaction methods function correctly.

1. **Start** the Flask development server:

   ```bash
   cd application
   flask run
   ```

2. **Navigate to:** `http://localhost:5000`

3. **Test the hero section:**
   - Verify the gradient background displays correctly
   - Check that "Stay Ahead of the Curve" is large and prominent
   - Hover over the Subscribe button to see the lift effect
   - Resize the browser window to test responsive design

4. **Test modal opening:**
   - Click the "Subscribe Now" button
   - Verify the modal slides in with animation
   - Confirm focus moves to the close button (press Tab to verify)

5. **Test modal closing methods:**
   - Click the X button - modal should close
   - Open modal again, then click the dark overlay - modal should close
   - Open modal again, then press Escape - modal should close

6. **Test focus management:**
   - After closing the modal by any method, the Subscribe button should be focused
   - You can verify this by pressing Tab immediately after closing - the next element should receive focus

> ✓ **Success indicators:**
>
> - Hero section fills at least 60% of the viewport height
> - Gradient smoothly transitions from dark blue to light blue
> - Button hover shows subtle lift and shadow
> - Modal appears with slide-in animation
> - All three close methods work (button, overlay, Escape)
> - Focus returns to Subscribe button after closing
>
> ✓ **Final verification checklist:**
>
> - ☐ Hero displays with gradient background
> - ☐ Text is readable against the gradient
> - ☐ Subscribe button has hover effect
> - ☐ Modal opens on button click
> - ☐ Modal closes via X button
> - ☐ Modal closes via overlay click
> - ☐ Modal closes via Escape key
> - ☐ Focus management works correctly
> - ☐ Responsive design works on mobile widths

## Common Issues

> **If you encounter problems:**
>
> **Modal does not appear:** Check that the JavaScript is inside `{% block scripts %}` and verify there are no console errors (F12 > Console)
>
> **Clicking modal closes it:** The overlay click handler should check `event.target === modalOverlay`, not just respond to any click
>
> **Gradient not showing:** Ensure the CSS is inside `{% block extra_css %}` and the style tag is properly formed
>
> **Button hover not working:** The `.hero__cta:hover` styles may conflict with base button styles; check specificity
>
> **Focus not moving:** Verify the element IDs match between HTML and JavaScript (`subscribeBtn`, `modalClose`)
>
> **Still stuck?** Open browser developer tools (F12) and check the Console tab for JavaScript errors

## Summary

You've successfully built an interactive landing page that:

- ✓ Uses CSS gradients for a modern, professional appearance
- ✓ Implements responsive design with media queries
- ✓ Creates an accessible modal dialog with ARIA attributes
- ✓ Handles multiple user interaction methods
- ✓ Manages focus for keyboard accessibility

> **Key takeaway:** Accessible interactive components require attention to both visual users (animations, hover effects) and keyboard/screen reader users (ARIA attributes, focus management). Building accessibility in from the start is much easier than retrofitting it later.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Try changing the gradient colors or direction to create a different mood
> - Add a focus trap so Tab cannot leave the modal while it is open
> - Implement a fade-out animation when the modal closes
> - Add a second button in the modal to prepare for the subscription form
> - Research the `inert` attribute as a modern alternative to manual focus trapping

## Done! 🎉

Great job! You've learned how to build an engaging hero section with CSS gradients and implement an accessible modal dialog with proper focus management. These frontend skills form the foundation for creating polished, user-friendly web applications.
