/**
 * Scroll Animations JavaScript
 * Handles smooth scroll animations and parallax effects
 */

class ScrollAnimations {
    constructor() {
        this.init();
    }

    init() {
        // Wait for DOM to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.setupAnimations());
        } else {
            this.setupAnimations();
        }
    }

    setupAnimations() {
        this.setupScrollReveal();
        this.setupParallaxEffects();
        this.setupSmoothScrolling();
        this.setupStaggeredAnimations();
    }

    /**
     * Setup scroll reveal animations
     */
    setupScrollReveal() {
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate');
                }
            });
        }, observerOptions);

        // Observe all scroll animate elements
        const animateElements = document.querySelectorAll('.scroll-animate, .scroll-animate-left, .scroll-animate-right, .scroll-animate-scale');
        animateElements.forEach(el => observer.observe(el));
    }

    /**
     * Setup parallax scrolling effects
     */
    setupParallaxEffects() {
        const parallaxElements = document.querySelectorAll('.parallax-element');
        
        if (parallaxElements.length === 0) return;

        let ticking = false;

        const updateParallax = () => {
            const scrolled = window.pageYOffset;
            const rate = scrolled * -0.5;

            parallaxElements.forEach(element => {
                const speed = element.dataset.speed || 0.5;
                const yPos = -(scrolled * speed);
                element.style.transform = `translateY(${yPos}px)`;
            });

            ticking = false;
        };

        const requestTick = () => {
            if (!ticking) {
                requestAnimationFrame(updateParallax);
                ticking = true;
            }
        };

        window.addEventListener('scroll', requestTick, { passive: true });
    }

    /**
     * Setup smooth scrolling for anchor links
     */
    setupSmoothScrolling() {
        const anchorLinks = document.querySelectorAll('a[href^="#"]');
        
        anchorLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                const href = link.getAttribute('href');
                
                if (href === '#') return;
                
                const target = document.querySelector(href);
                if (!target) return;
                
                e.preventDefault();
                
                const headerHeight = document.querySelector('.header-sticky')?.offsetHeight || 0;
                const targetPosition = target.offsetTop - headerHeight - 20;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            });
        });
    }

    /**
     * Setup staggered animations for grid items
     */
    setupStaggeredAnimations() {
        const gridContainers = document.querySelectorAll('.categories-grid, .plp-products-grid, .value-props-grid, .blog-grid');
        
        gridContainers.forEach(container => {
            const items = container.querySelectorAll('.category-card, .product-card, .value-prop-card, .blog-card');
            
            items.forEach((item, index) => {
                // Add delay class based on index
                if (index < 6) { // Limit to 6 items for performance
                    item.classList.add(`scroll-animate-delay-${Math.min(index + 1, 5)}`);
                }
                
                // Add scroll animate class
                item.classList.add('scroll-animate');
            });
        });
    }

    /**
     * Add scroll animations to specific sections
     */
    addSectionAnimations() {
        // Intro band section
        const introSection = document.querySelector('.intro-band');
        if (introSection) {
            introSection.classList.add('scroll-animate');
        }

        // Section titles
        const sectionTitles = document.querySelectorAll('.section-title');
        sectionTitles.forEach(title => {
            title.classList.add('scroll-animate');
        });

        // Value props section
        const valueProps = document.querySelector('.value-props');
        if (valueProps) {
            valueProps.classList.add('scroll-animate');
        }

        // Featured products section
        const featuredProducts = document.querySelector('.featured-products');
        if (featuredProducts) {
            featuredProducts.classList.add('scroll-animate');
        }

        // Collection banners
        const collectionBanners = document.querySelector('.collection-banners');
        if (collectionBanners) {
            collectionBanners.classList.add('scroll-animate');
        }

        // Blog section
        const blogSection = document.querySelector('.blog-section');
        if (blogSection) {
            blogSection.classList.add('scroll-animate');
        }

        // Newsletter section
        const newsletterSection = document.querySelector('.newsletter-section');
        if (newsletterSection) {
            newsletterSection.classList.add('scroll-animate');
        }
    }

    /**
     * Enhanced scroll performance
     */
    optimizeScrollPerformance() {
        // Throttle scroll events
        let scrollTimeout;
        
        const handleScroll = () => {
            if (scrollTimeout) {
                clearTimeout(scrollTimeout);
            }
            
            scrollTimeout = setTimeout(() => {
                // Update any scroll-dependent elements here
                this.updateScrollProgress();
            }, 16); // ~60fps
        };

        window.addEventListener('scroll', handleScroll, { passive: true });
    }

    /**
     * Update scroll progress indicator
     */
    updateScrollProgress() {
        const scrollProgress = document.querySelector('.scroll-progress');
        if (!scrollProgress) return;

        const scrollTop = window.pageYOffset;
        const docHeight = document.body.scrollHeight - window.innerHeight;
        const scrollPercent = (scrollTop / docHeight) * 100;

        scrollProgress.style.width = `${scrollPercent}%`;
    }

    /**
     * Add scroll progress bar
     */
    addScrollProgressBar() {
        const progressBar = document.createElement('div');
        progressBar.className = 'scroll-progress';
        progressBar.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 0%;
            height: 3px;
            background: linear-gradient(90deg, var(--primary), var(--primary-hover));
            z-index: 9999;
            transition: width 0.1s ease;
        `;
        
        document.body.appendChild(progressBar);
    }

    /**
     * Initialize all animations
     */
    start() {
        this.addSectionAnimations();
        this.addScrollProgressBar();
        this.optimizeScrollPerformance();
    }
}

// Initialize scroll animations when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const scrollAnimations = new ScrollAnimations();
    scrollAnimations.start();
});

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ScrollAnimations;
}
