/**
 * Reveal.js Configuration for Swedish Tech Template
 * Optimized settings for IPL presentations
 */

// Initialize Reveal.js with Swedish Tech settings
Reveal.initialize({
    // Display controls in the bottom right corner
    controls: true,
    controlsLayout: 'bottom-right',
    controlsTutorial: true,
    
    // Display a presentation progress bar
    progress: true,
    
    // Display the page number of the current slide
    slideNumber: 'c/t',
    
    // Add the current slide number to the URL hash
    hash: true,
    
    // Push each slide change to the browser history
    history: true,
    
    // Enable keyboard shortcuts for navigation
    keyboard: true,
    
    // Enable the slide overview mode
    overview: true,
    
    // Vertical centering of slides
    center: false,
    
    // Enables touch navigation on devices with touch input
    touch: true,
    
    // Loop the presentation
    loop: false,
    
    // Change the presentation direction to be RTL
    rtl: false,
    
    // Randomizes the order of slides each time the presentation loads
    shuffle: false,
    
    // Turns fragments on and off globally
    fragments: true,
    
    // Flags whether to include the current fragment in the URL
    fragmentInURL: true,
    
    // Flags if the presentation is running in an embedded mode
    embedded: false,
    
    // Flags if we should show a help overlay when the ? key is pressed
    help: true,
    
    // Flags if speaker notes should be visible to all viewers
    showNotes: false,
    
    // Global override for autoplaying embedded media
    autoPlayMedia: null,
    
    // Global override for preloading lazy-loaded iframes
    preloadIframes: null,
    
    // Number of milliseconds between automatically proceeding to the
    // next slide, disabled when set to 0
    autoSlide: 0,
    
    // Stop auto-sliding after user input
    autoSlideStoppable: true,
    
    // Use this method for navigation when auto-sliding
    autoSlideMethod: Reveal.navigateNext,
    
    // Specify the average time in seconds that you think you will spend
    // presenting each slide. This is used to show a pacing timer in the
    // speaker view
    defaultTiming: 120,
    
    // Enable slide navigation via mouse wheel
    mouseWheel: false,
    
    // Opens links in an iframe preview overlay
    previewLinks: false,
    
    // Transition style
    transition: 'slide', // none/fade/slide/convex/concave/zoom
    
    // Transition speed
    transitionSpeed: 'default', // default/fast/slow
    
    // Transition style for full page slide backgrounds
    backgroundTransition: 'fade', // none/fade/slide/convex/concave/zoom
    
    // Number of slides away from the current that are visible
    viewDistance: 3,
    
    // Parallax background image
    parallaxBackgroundImage: '', // CSS syntax, e.g. "url('image.png')"
    
    // Parallax background size
    parallaxBackgroundSize: '', // CSS syntax, e.g. "2100px 900px"
    
    // Number of pixels to move the parallax background per slide
    parallaxBackgroundHorizontal: null,
    parallaxBackgroundVertical: null,
    
    // The display mode that will be used to show slides
    display: 'block',
    
    // Hide cursor if inactive
    hideInactiveCursor: true,
    
    // Time before the cursor is hidden (ms)
    hideCursorTime: 3000,
    
    // Script dependencies to load
    dependencies: [],
    
    // Plugin configuration
    plugins: []
});

// Custom event handlers for Swedish Tech template
Reveal.on('ready', event => {
    console.log('Swedish Tech Presentation Ready');
    
    // Add custom class to body for additional styling hooks
    document.body.classList.add('swedish-tech-theme');
});

// Animate elements when slide changes
Reveal.on('slidechanged', event => {
    const currentSlide = event.currentSlide;
    
    // Reset animations for timeline items
    const timelineItems = currentSlide.querySelectorAll('.timeline-item');
    timelineItems.forEach((item, index) => {
        item.style.animation = 'none';
        setTimeout(() => {
            item.style.animation = `slideInFromBottom 0.5s ease-out ${index * 0.1}s forwards`;
        }, 10);
    });
    
    // Reset animations for group cards
    const groupCards = currentSlide.querySelectorAll('.group-card');
    groupCards.forEach((card, index) => {
        card.style.animation = 'none';
        setTimeout(() => {
            card.style.animation = `fadeIn 0.5s ease-out ${index * 0.1}s forwards`;
        }, 10);
    });
});

// Custom keyboard shortcuts
Reveal.addKeyBinding({keyCode: 84, key: 'T', description: 'Toggle theme'}, () => {
    // Toggle between light and dark theme (if implemented)
    document.body.classList.toggle('light-theme');
});

// Helper function to add custom slide behaviors
function customizeSlideBehaviors() {
    // Add click handlers to timeline items
    document.querySelectorAll('.timeline-item').forEach(item => {
        item.addEventListener('click', function() {
            this.querySelector('.timeline-week').style.transform = 'scale(1.2)';
            setTimeout(() => {
                this.querySelector('.timeline-week').style.transform = 'scale(1)';
            }, 300);
        });
    });
    
    // Add hover effects to group cards
    document.querySelectorAll('.group-card').forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px) scale(1.02)';
        });
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
}

// Initialize custom behaviors when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', customizeSlideBehaviors);
} else {
    customizeSlideBehaviors();
}

// Export configuration for potential external use
window.RevealConfig = {
    theme: 'swedish-tech',
    colors: {
        primary: '#006AA7',
        secondary: '#FECC00',
        accent: '#00D9FF',
        background: '#0A0E27'
    }
};