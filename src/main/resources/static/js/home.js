/**
 * Activewear Store - Home Page JavaScript
 * Dynamic content loading and interactions
 */

class HomePage {
    constructor() {
        this.currentTab = 'new';
        this.products = {
            new: [],
            'best-selling': [],
            discounted: []
        };
        this.categories = [];
        this.brands = [];
        
        this.init();
    }

    init() {
        this.loadQuickCategories();
        this.loadBrands();
        this.loadProducts('new');
        this.loadPromoCard();
        this.loadWishlistStatus();
        this.setupEventListeners();
        this.setupLazyLoading();
        
        // Test image paths
        this.testImagePaths();
    }

    setupEventListeners() {
        // Tab switching
        document.querySelectorAll('.tab-button').forEach(button => {
            button.addEventListener('click', (e) => {
                const tab = e.target.dataset.tab;
                this.switchTab(tab);
            });
        });

        // Search functionality
        const searchInput = document.getElementById('searchInput');
        const searchButton = document.getElementById('searchButton');
        
        if (searchInput) {
            searchInput.addEventListener('input', this.debounce(this.handleSearch.bind(this), 300));
            searchInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    this.performSearch();
                }
            });
        }
        
        // Search button click
        if (searchButton) {
            searchButton.addEventListener('click', () => {
                this.performSearch();
            });
        }

        // Newsletter form
        const newsletterForm = document.getElementById('newsletterForm');
        if (newsletterForm) {
            newsletterForm.addEventListener('submit', this.handleNewsletterSubmit.bind(this));
        }

        // OPTIMIZED: Single delegated click handler for all interactions
        document.addEventListener('click', (e) => {
            // Search button
            if (e.target.closest('#searchButton')) {
                e.preventDefault();
                this.performSearch();
                return;
            }

            // Add to cart
            if (e.target.classList.contains('btn-add-cart')) {
                e.preventDefault();
                const productId = e.target.dataset.productId;
                this.addToCart(productId);
                return;
            }

            // Favorite buttons
            const favoriteBtn = e.target.closest('.plp-wishlist-btn');
            if (favoriteBtn) {
                e.preventDefault();
                const productId = favoriteBtn.dataset.productId;
                if (productId) {
                    window.toggleWishlist(productId);
                }
                return;
            }

            // Quick action buttons
            const quickActionBtn = e.target.closest('.quick-action-btn');
            if (quickActionBtn) {
                e.preventDefault();
                const productId = quickActionBtn.dataset.productId;
                const title = quickActionBtn.title;
                
                if (title === 'Xem nhanh') {
                    window.quickViewProduct(productId);
                } else if (title === 'Tùy chọn') {
                    window.location.href = `/products/${productId}`;
                } else if (title === 'Thêm vào yêu thích') {
                    this.toggleFavorite(productId);
                }
                return;
            }

            // Category cards
            const categoryCard = e.target.closest('.category-card');
            if (categoryCard) {
                const categoryId = categoryCard.dataset.categoryId;
                if (categoryId) {
                    window.location.href = `/products?category=${categoryId}`;
                }
                return;
            }
        }, { passive: false }); // Not passive because we use preventDefault

        // Enhanced Mega menu with hover delay and keyboard navigation
        const categoriesTrigger = document.getElementById('categoriesTrigger');
        const megaMenu = document.getElementById('megaMenu');
        
        if (categoriesTrigger && megaMenu) {
            let hoverTimeout;
            let isMenuOpen = false;
            let lastFocusedElement = null;

            // Open mega menu
            const openMegaMenu = () => {
                if (isMenuOpen) return;
                
                megaMenu.classList.add('active');
                isMenuOpen = true;
                megaMenu.setAttribute('aria-hidden', 'false');
                
                // Focus first menu item
                const firstMenuItem = megaMenu.querySelector('.mega-menu-item');
                if (firstMenuItem) {
                    firstMenuItem.focus();
                }
                
                // Lock body scroll on mobile
                if (window.innerWidth <= 768) {
                    document.body.style.overflow = 'hidden';
                }
            };

            // Close mega menu
            const closeMegaMenu = () => {
                if (!isMenuOpen) return;
                
                megaMenu.classList.remove('active');
                isMenuOpen = false;
                megaMenu.setAttribute('aria-hidden', 'true');
                
                // Return focus to trigger
                if (categoriesTrigger) {
                    categoriesTrigger.focus();
                }
                
                // Unlock body scroll
                document.body.style.overflow = '';
            };

            // Click to toggle (priority)
            categoriesTrigger.addEventListener('click', (e) => {
                e.preventDefault();
                if (isMenuOpen) {
                    closeMegaMenu();
                } else {
                    openMegaMenu();
                }
            });

            // Hover to open with delay
            categoriesTrigger.addEventListener('mouseenter', function() {
                clearTimeout(hoverTimeout);
                hoverTimeout = setTimeout(openMegaMenu, 180);
            });

            // Keep menu open when hovering over it
            megaMenu.addEventListener('mouseenter', function() {
                clearTimeout(hoverTimeout);
            });

            // Close when mouse leaves both trigger and menu
            const handleMouseLeave = () => {
                hoverTimeout = setTimeout(closeMegaMenu, 200);
            };

            categoriesTrigger.addEventListener('mouseleave', handleMouseLeave);
            megaMenu.addEventListener('mouseleave', handleMouseLeave);

            // Keyboard navigation
            const handleKeyboardNav = (e) => {
                if (!isMenuOpen) return;

                const menuItems = Array.from(megaMenu.querySelectorAll('.mega-menu-item'));
                const currentIndex = menuItems.indexOf(document.activeElement);
                
                switch(e.key) {
                    case 'ArrowDown':
                        e.preventDefault();
                        const nextIndex = (currentIndex + 1) % menuItems.length;
                        menuItems[nextIndex].focus();
                        break;
                    case 'ArrowUp':
                        e.preventDefault();
                        const prevIndex = currentIndex === 0 ? menuItems.length - 1 : currentIndex - 1;
                        menuItems[prevIndex].focus();
                        break;
                    case 'Escape':
                        e.preventDefault();
                        closeMegaMenu();
                        break;
                    case 'Tab':
                        // Allow normal tab navigation
                        break;
                }
            };

            megaMenu.addEventListener('keydown', handleKeyboardNav);

            // OPTIMIZED: Combined event handler for menu closing
            const handleMenuClose = (e) => {
                if (e.type === 'keydown' && e.key === 'Escape' && isMenuOpen) {
                    closeMegaMenu();
                } else if (e.type === 'click' && isMenuOpen && 
                    !categoriesTrigger.contains(e.target) && 
                    !megaMenu.contains(e.target)) {
                    closeMegaMenu();
                }
            };
            
            document.addEventListener('click', handleMenuClose, { passive: true });
            document.addEventListener('keydown', handleMenuClose, { passive: true });

            // Track menu interactions for analytics
            megaMenu.addEventListener('click', function(e) {
                const tracking = e.target.closest('[data-tracking]');
                if (tracking) {
                    const trackingType = tracking.dataset.tracking;
                    const category = tracking.dataset.category;
                    const collection = tracking.dataset.collection;
                    
                    // Analytics tracking (implement based on your analytics system)
                    console.log('Menu interaction:', {
                        type: trackingType,
                        category: category,
                        collection: collection,
                        element: e.target.textContent.trim()
                    });
                }
            });

            // OPTIMIZED: Debounced window resize
            let resizeTimeout;
            window.addEventListener('resize', function() {
                clearTimeout(resizeTimeout);
                resizeTimeout = setTimeout(() => {
                    if (window.innerWidth > 768 && document.body.style.overflow === 'hidden') {
                        document.body.style.overflow = '';
                    }
                }, 150);
            }, { passive: true });
        }

        // Mobile Off-Canvas Menu
        this.setupMobileMenu();
    }

    async loadQuickCategories() {
        try {
            const response = await fetch('/api/home/quick-categories');
            const data = await response.json();
            
            if (data.success) {
                this.categories = data.categories;
                this.renderQuickCategories();
            }
        } catch (error) {
            console.error('Error loading categories:', error);
            this.showError('Không thể tải danh mục sản phẩm');
        }
    }

    renderQuickCategories() {
        const container = document.getElementById('quickCategories');
        if (!container) return;

        const categoryIcons = {
            'Nam': 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z',
            'Nữ': 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z',
            'Chạy bộ': 'M13 10V3L4 14h7v7l9-11h-7z',
            'Gym/Yoga': 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z',
            'Bóng đá': 'M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9',
            'Phụ kiện': 'M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z'
        };

        const html = this.categories.slice(0, 6).map(category => {
            const iconPath = categoryIcons[category.ten] || categoryIcons['Phụ kiện'];
            return `
                <div class="category-card" data-category-id="${category.id}">
                    <svg class="category-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${iconPath}"></path>
                    </svg>
                    <div class="category-name">${category.ten}</div>
                </div>
            `;
        }).join('');

        container.innerHTML = html;
    }

    async loadBrands() {
        try {
            const response = await fetch('/api/home/brands');
            const data = await response.json();
            
            if (data.success) {
                this.brands = data.brands;
                this.renderBrandStrip();
                this.renderMegaMenuBrands();
            }
        } catch (error) {
            console.error('Error loading brands:', error);
        }
    }

    renderBrandStrip() {
        const container = document.getElementById('brandStrip');
        if (!container) return;

        const html = this.brands.slice(0, 8).map(brand => `
            <div class="brand-logo">
                <div style="width: 120px; height: 32px; background: #f3f4f6; border-radius: 4px; display: flex; align-items: center; justify-content: center; color: #6b7280; font-size: 12px; font-weight: 600;">
                    ${brand.ten}
                </div>
            </div>
        `).join('');

        container.innerHTML = html;
    }

    renderMegaMenuBrands() {
        const container = document.getElementById('megaMenuBrands');
        if (!container) return;

        const html = this.brands.slice(0, 6).map(brand => `
            <li>
                <a href="/products?brand=${brand.id}" class="mega-menu-item" data-brand="${brand.id}" data-tracking="brand">
                    ${brand.ten}
                </a>
            </li>
        `).join('');

        container.innerHTML = html;
    }

    async loadPromoCard() {
        try {
            const response = await fetch('/api/promotions/featured');
            const data = await response.json();
            
            if (data.success && data.promotion) {
                this.renderPromoCard(data.promotion);
            } else {
                this.hidePromoCard();
            }
        } catch (error) {
            console.error('Error loading promo card:', error);
            this.hidePromoCard();
        }
    }

    renderPromoCard(promotion) {
        const promoCard = document.getElementById('promoCard');
        const promoImage = document.getElementById('promoCardImage');
        const promoTitle = document.getElementById('promoCardTitle');
        const promoSubtitle = document.getElementById('promoCardSubtitle');
        const promoCta = document.getElementById('promoCardCta');

        if (!promoCard) return;

        // Update content
        if (promoImage) {
            promoImage.src = promotion.image || '/images/promo-default.jpg';
            promoImage.alt = promotion.title || 'Khuyến mãi đặc biệt';
        }

        if (promoTitle) {
            promoTitle.textContent = promotion.title || 'Khuyến mãi đặc biệt';
        }

        if (promoSubtitle) {
            promoSubtitle.textContent = promotion.subtitle || 'Khám phá ngay những ưu đãi hấp dẫn';
        }

        if (promoCta) {
            promoCta.href = promotion.url || '/promotions';
            promoCta.textContent = promotion.ctaText || 'Khám phá';
        }

        // Show promo card
        promoCard.style.display = 'flex';
    }

    hidePromoCard() {
        const promoCard = document.getElementById('promoCard');
        if (promoCard) {
            promoCard.style.display = 'none';
        }
    }

    setupMobileMenu() {
        const mobileMenu = document.getElementById('mobileMenu');
        const mobileMenuClose = document.querySelector('.mobile-menu-close');
        const mobileMenuBackdrop = document.querySelector('.mobile-menu-backdrop');
        const accordionTriggers = document.querySelectorAll('.mobile-menu-accordion-trigger');
        
        if (!mobileMenu) return;

        let isMobileMenuOpen = false;
        let touchStartX = 0;
        let touchStartY = 0;

        // Open mobile menu
        const openMobileMenu = () => {
            if (isMobileMenuOpen) return;
            
            mobileMenu.classList.add('active');
            mobileMenu.setAttribute('aria-hidden', 'false');
            isMobileMenuOpen = true;
            
            // Lock body scroll
            document.body.style.overflow = 'hidden';
            
            // Focus first focusable element
            const firstFocusable = mobileMenu.querySelector('button, a, input, select, textarea, [tabindex]:not([tabindex="-1"])');
            if (firstFocusable) {
                firstFocusable.focus();
            }
            
            // Setup focus trap
            this.setupFocusTrap(mobileMenu);
        };

        // Close mobile menu
        const closeMobileMenu = () => {
            if (!isMobileMenuOpen) return;
            
            mobileMenu.classList.remove('active');
            mobileMenu.setAttribute('aria-hidden', 'true');
            isMobileMenuOpen = false;
            
            // Unlock body scroll
            document.body.style.overflow = '';
            
            // Return focus to trigger
            const categoriesTrigger = document.getElementById('categoriesTrigger');
            if (categoriesTrigger) {
                categoriesTrigger.focus();
            }
        };

        // Toggle mobile menu on categories trigger click (mobile only)
        const categoriesTrigger = document.getElementById('categoriesTrigger');
        if (categoriesTrigger) {
            categoriesTrigger.addEventListener('click', (e) => {
                if (window.innerWidth <= 768) {
                    e.preventDefault();
                    if (isMobileMenuOpen) {
                        closeMobileMenu();
                    } else {
                        openMobileMenu();
                    }
                }
            });
        }

        // Close on close button click
        if (mobileMenuClose) {
            mobileMenuClose.addEventListener('click', closeMobileMenu);
        }

        // Close on backdrop click
        if (mobileMenuBackdrop) {
            mobileMenuBackdrop.addEventListener('click', closeMobileMenu);
        }

        // Close on escape key - handled by global keydown handler

        // Accordion functionality
        accordionTriggers.forEach(trigger => {
            trigger.addEventListener('click', () => {
                const isExpanded = trigger.getAttribute('aria-expanded') === 'true';
                const content = document.getElementById(trigger.getAttribute('aria-controls'));
                
                if (isExpanded) {
                    trigger.setAttribute('aria-expanded', 'false');
                    trigger.classList.remove('active');
                    content.classList.remove('active');
                } else {
                    trigger.setAttribute('aria-expanded', 'true');
                    trigger.classList.add('active');
                    content.classList.add('active');
                }
            });
        });

        // OPTIMIZED: Touch gestures with passive listeners
        mobileMenu.addEventListener('touchstart', (e) => {
            touchStartX = e.touches[0].clientX;
            touchStartY = e.touches[0].clientY;
        }, { passive: true });

        mobileMenu.addEventListener('touchmove', (e) => {
            if (!isMobileMenuOpen) return;
            
            const touchCurrentX = e.touches[0].clientX;
            const touchCurrentY = e.touches[0].clientY;
            const touchDiffX = touchStartX - touchCurrentX;
            const touchDiffY = touchStartY - touchCurrentY;
            
            // Only handle horizontal swipes
            if (Math.abs(touchDiffX) > Math.abs(touchDiffY) && touchDiffX > 50) {
                closeMobileMenu();
            }
        });

        // Handle window resize
        window.addEventListener('resize', () => {
            if (window.innerWidth > 768 && isMobileMenuOpen) {
                closeMobileMenu();
            }
        });

        // Track mobile menu interactions
        mobileMenu.addEventListener('click', (e) => {
            const tracking = e.target.closest('[data-tracking]');
            if (tracking) {
                const trackingType = tracking.dataset.tracking;
                const category = tracking.dataset.category;
                const collection = tracking.dataset.collection;
                const brand = tracking.dataset.brand;
                
                console.log('Mobile menu interaction:', {
                    type: trackingType,
                    category: category,
                    collection: collection,
                    brand: brand,
                    element: e.target.textContent.trim()
                });
            }
        });
    }

    setupFocusTrap(container) {
        const focusableElements = container.querySelectorAll(
            'button, a, input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        const firstFocusable = focusableElements[0];
        const lastFocusable = focusableElements[focusableElements.length - 1];

        container.addEventListener('keydown', (e) => {
            if (e.key === 'Tab') {
                if (e.shiftKey) {
                    if (document.activeElement === firstFocusable) {
                        lastFocusable.focus();
                        e.preventDefault();
                    }
                } else {
                    if (document.activeElement === lastFocusable) {
                        firstFocusable.focus();
                        e.preventDefault();
                    }
                }
            }
        });
    }

    async loadProducts(tab) {
        if (this.products[tab].length > 0) {
            this.renderProducts(tab);
            return;
        }

        try {
            this.showProductsLoading();
            
            const endpoint = this.getProductsEndpoint(tab);
            const response = await fetch(endpoint);
            const data = await response.json();
            
            if (data.success) {
                this.products[tab] = data.products;
                this.renderProducts(tab);
            } else {
                this.showError('Không thể tải sản phẩm');
            }
        } catch (error) {
            console.error('Error loading products:', error);
            this.showError('Không thể tải sản phẩm');
        }
    }

    async loadWishlistStatus() {
        try {
            // Get all product IDs from the page
            const productButtons = document.querySelectorAll('.plp-wishlist-btn[data-product-id]');
            if (productButtons.length === 0) return;

            const productIds = Array.from(productButtons).map(btn => btn.dataset.productId);
            console.log('Loading wishlist status for products:', productIds);

            // Check each product's wishlist status
            for (const productId of productIds) {
                try {
                    const response = await fetch(`/api/wishlist/check/${productId}`);
                    const data = await response.json();
                    
                    if (data.success) {
                        const button = document.querySelector(`[data-product-id="${productId}"].plp-wishlist-btn`);
                        if (button) {
                            if (data.isInWishlist) {
                                button.classList.add('active');
                            } else {
                                button.classList.remove('active');
                            }
                        }
                    }
                } catch (error) {
                    console.error(`Error checking wishlist status for product ${productId}:`, error);
                }
            }
        } catch (error) {
            console.error('Error loading wishlist status:', error);
        }
    }

    getProductsEndpoint(tab) {
        const endpoints = {
            'new': '/api/products/new',
            'best-selling': '/api/products/best-selling',
            'discounted': '/api/products/discounted'
        };
        return endpoints[tab] || endpoints['new'];
    }

    showProductsLoading() {
        const container = document.getElementById('productsGrid');
        if (!container) return;

        container.innerHTML = `
            <div class="products-loading">
                ${Array(8).fill(0).map(() => `
                    <div class="product-skeleton">
                        <div class="skeleton-image"></div>
                        <div class="skeleton-content">
                            <div class="skeleton-line short"></div>
                            <div class="skeleton-line medium"></div>
                            <div class="skeleton-line short"></div>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    }

    renderProducts(tab) {
        const container = document.getElementById('productsGrid');
        if (!container) return;

        const products = this.products[tab];
        if (products.length === 0) {
            container.innerHTML = `
                <div class="col-12 text-center" style="grid-column: 1 / -1;">
                    <p>Chưa có sản phẩm phù hợp</p>
                </div>
            `;
            return;
        }

        // Filter out products without images and render only valid cards
        const validCards = products
            .map(product => this.createProductCard(product))
            .filter(card => card.trim() !== ''); // Remove empty cards

        if (validCards.length === 0) {
            container.innerHTML = `
                <div class="col-12 text-center" style="grid-column: 1 / -1;">
                    <p>Chưa có sản phẩm phù hợp</p>
                </div>
            `;
            return;
        }

        container.innerHTML = validCards.join('');
        
        // Load wishlist status after rendering products
        setTimeout(() => {
            this.loadWishlistStatus();
        }, 100);
    }

    // Map tên sản phẩm với hình ảnh thực tế
    getProductImage(product) {
        // Debug: Log product data
        console.log('Product data:', product);
        
        // Nếu có anhChinh từ database, sử dụng nó trước
        if (product.anhChinh && product.anhChinh.trim() !== '') {
            console.log('Using anhChinh:', product.anhChinh);
            return product.anhChinh;
        }
        
        const productName = product.ten?.toLowerCase() || '';
        const brandName = product.thuongHieu?.ten?.toLowerCase() || '';
        const productId = product.id || 0;
        
        // Danh sách hình ảnh có sẵn (tránh file 0 bytes)
        const availableImages = {
            'ao-dau-nike': ['/images/products/ao-dau-nike-1.jpg', '/images/products/ao-dau-nike-2.jpg', '/images/products/ao-dau-nike-3.jpg'],
            'giay-adidas-ultraboost': ['/images/products/giay-adidas-ultraboost-1.jpg', '/images/products/giay-adidas-ultraboost-2.jpg', '/images/products/giay-adidas-ultraboost-3.jpg'],
            'quan-short-puma': ['/images/products/quan-short-puma-1.jpg', '/images/products/quan-short-puma-2.jpg'],
            'ao-thun-vans': ['/images/products/ao-thun-vans-2.jpg'], // Chỉ file 2 có dữ liệu
            'hoodie-nike': ['/images/products/hoodie-nike-1.jpg', '/images/products/hoodie-nike-2.jpg'],
            'legging-adidas': ['/images/products/legging-adidas-1.jpg', '/images/products/legging-adidas-2.jpg'],
            'giay-tennis-adidas': ['/images/products/giay-tennis-adidas-1.jpg', '/images/products/giay-tennis-adidas-2.jpg', '/images/products/giay-tennis-adidas-3.jpg'],
            'giay-vans-oldskool': ['/images/products/giay-vans-oldskool-1.jpg', '/images/products/giay-vans-oldskool-2.jpg', '/images/products/giay-vans-oldskool-3.jpg'],
            'tui-puma': ['/images/products/tui-puma-1.jpg', '/images/products/tui-puma-2.jpg', '/images/products/tui-puma-3.jpg']
        };
        
        // Danh sách tất cả hình ảnh để fallback
        const allImages = [
            '/images/products/ao-dau-nike-1.jpg',
            '/images/products/ao-dau-nike-2.jpg', 
            '/images/products/ao-dau-nike-3.jpg',
            '/images/products/giay-adidas-ultraboost-1.jpg',
            '/images/products/giay-adidas-ultraboost-2.jpg',
            '/images/products/giay-adidas-ultraboost-3.jpg',
            '/images/products/quan-short-puma-1.jpg',
            '/images/products/quan-short-puma-2.jpg',
            '/images/products/ao-thun-vans-2.jpg',
            '/images/products/hoodie-nike-1.jpg',
            '/images/products/hoodie-nike-2.jpg',
            '/images/products/legging-adidas-1.jpg',
            '/images/products/legging-adidas-2.jpg',
            '/images/products/giay-tennis-adidas-1.jpg',
            '/images/products/giay-tennis-adidas-2.jpg',
            '/images/products/giay-tennis-adidas-3.jpg',
            '/images/products/giay-vans-oldskool-1.jpg',
            '/images/products/giay-vans-oldskool-2.jpg',
            '/images/products/giay-vans-oldskool-3.jpg',
            '/images/products/tui-puma-1.jpg',
            '/images/products/tui-puma-2.jpg',
            '/images/products/tui-puma-3.jpg'
        ];
        
        // Map dựa trên tên sản phẩm và thương hiệu
        let imageKey = '';
        console.log('Product name:', productName, 'Brand name:', brandName);
        
        if (productName.includes('áo đấu') && brandName.includes('nike')) {
            imageKey = 'ao-dau-nike';
        } else if (productName.includes('giày chạy') && brandName.includes('adidas')) {
            imageKey = 'giay-adidas-ultraboost';
        } else if (productName.includes('quần short') && brandName.includes('puma')) {
            imageKey = 'quan-short-puma';
        } else if (productName.includes('áo thun') && brandName.includes('vans')) {
            imageKey = 'ao-thun-vans';
        } else if (productName.includes('hoodie') && brandName.includes('nike')) {
            imageKey = 'hoodie-nike';
        } else if (productName.includes('legging') && brandName.includes('adidas')) {
            imageKey = 'legging-adidas';
        } else if (productName.includes('giày tennis') && brandName.includes('adidas')) {
            imageKey = 'giay-tennis-adidas';
        } else if (productName.includes('giày vans') || productName.includes('oldskool')) {
            imageKey = 'giay-vans-oldskool';
        } else if (productName.includes('túi') && brandName.includes('puma')) {
            imageKey = 'tui-puma';
        }
        
        console.log('Matched imageKey:', imageKey);
        
        // Chọn hình ảnh dựa trên product ID để có sự đa dạng
        if (imageKey && availableImages[imageKey]) {
            const images = availableImages[imageKey];
            const index = productId % images.length;
            const selectedImage = images[index];
            console.log('Selected image:', selectedImage);
            return selectedImage;
        }
        
        // Nếu không tìm thấy mapping cụ thể, chọn ngẫu nhiên từ danh sách có sẵn
        if (allImages.length > 0) {
            const index = productId % allImages.length;
            const selectedImage = allImages[index];
            console.log('Using random image:', selectedImage);
            return selectedImage;
        }
        
        // Fallback to placeholder
        console.log('Using placeholder');
        return '/images/products/placeholder.svg';
    }
    
    // Test function để kiểm tra hình ảnh
    testImagePaths() {
        const testPaths = [
            '/images/products/ao-dau-nike-1.jpg',
            '/images/products/giay-adidas-ultraboost-1.jpg',
            '/images/products/quan-short-puma-1.jpg',
            '/images/products/ao-thun-vans-2.jpg'
        ];
        
        testPaths.forEach(path => {
            const img = new Image();
            img.onload = () => console.log('✅ Image loaded:', path);
            img.onerror = () => console.log('❌ Image failed:', path);
            img.src = path;
        });
    }

    createProductCard(product) {
        // Skip products without images
        const productImage = this.getProductImage(product);
        if (!productImage || productImage.includes('no-image') || productImage.includes('placeholder')) {
            return ''; // Don't render cards without images
        }

        const hasDiscount = product.giaGoc && product.gia < product.giaGoc;
        const discountPercent = hasDiscount 
            ? Math.round(((product.giaGoc - product.gia) / product.giaGoc) * 100 / 5) * 5 
            : 0;

        const isOutOfStock = product.soLuongTon === 0;
        const cardClass = isOutOfStock ? 'plp-product-card out-of-stock' : 'plp-product-card';

        // Swatches - max 5 colors
        const colors = product.mauSac ? [product.mauSac] : [];
        const visibleColors = colors.slice(0, 5);
        const hasMore = colors.length > 5;

        const badgeHtml = discountPercent > 0 
            ? `<div class="plp-badge">-${discountPercent}%</div>`
            : '';

        const priceHtml = hasDiscount
            ? `
                <div class="plp-product-price">
                    <div class="plp-price-original">${this.formatPrice(product.giaGoc)}</div>
                    <div class="plp-price-current">${this.formatPrice(product.gia)}</div>
                </div>
            `
            : `
                <div class="plp-product-price">
                    <div class="plp-price-current">${this.formatPrice(product.gia)}</div>
                </div>
            `;

        // Clean product name (remove leading/trailing dashes, slashes)
        const cleanName = product.ten
            .replace(/^[–\-\/\/\s]+|[–\-\/\/\s]+$/g, '')
            .trim();

        return `
            <a href="/product/${product.id}" class="${cardClass}" data-product-id="${product.id}">
                <div class="plp-product-image">
                    <img src="${productImage}" 
                         alt="${product.thuongHieu?.ten || 'Thương hiệu'} ${cleanName} - ${product.gioiTinh || 'Unisex'} - ${product.mauSac || 'Đa màu'}" 
                         loading="lazy">
                    ${badgeHtml}
                    <button class="plp-wishlist-btn" data-product-id="${product.id}">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                        </svg>
                    </button>
                    
                    <!-- Quick Actions - Hiện khi hover -->
                    <div class="quick-actions">
                        <button class="quick-action-btn btn-options" data-product-id="${product.id}" title="Tùy chọn">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
                            </svg>
                            Tùy chọn
                        </button>
                        <button class="quick-action-btn btn-quick-view" data-product-id="${product.id}" title="Xem nhanh">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                            </svg>
                            Xem nhanh
                        </button>
                    </div>
                </div>
                <div class="plp-product-info">
                    <div class="plp-product-brand">${product.thuongHieu?.ten || ''}</div>
                    <div class="plp-product-name">${cleanName}</div>
                    ${priceHtml}
                    ${visibleColors.length > 0 ? `
                        <div class="plp-swatches">
                            ${visibleColors.map(color => `
                                <div class="plp-swatch" style="background: ${color}" title="${color}"></div>
                            `).join('')}
                            ${hasMore ? `<span class="plp-swatch-more">+${colors.length - 5}</span>` : ''}
                        </div>
                    ` : ''}
                </div>
            </a>
        `;
    }

    switchTab(tab) {
        // Update active tab button
        document.querySelectorAll('.tab-button').forEach(button => {
            button.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tab}"]`).classList.add('active');

        // Load and render products for the selected tab
        this.currentTab = tab;
        this.loadProducts(tab);
    }

    async addToCart(productId) {
        try {
            const response = await fetch('/api/cart/add', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    productId: parseInt(productId),
                    quantity: 1
                })
            });

            const data = await response.json();
            
            if (data.success) {
                this.showSuccess('Đã thêm 1 sản phẩm • <a href="/cart" style="color: inherit; text-decoration: underline;">Xem giỏ</a>');
                this.updateCartBadge();
            } else {
                this.showError(data.message || 'Không thể thêm vào giỏ hàng');
            }
        } catch (error) {
            console.error('Error adding to cart:', error);
            this.showError('Không thể thêm vào giỏ hàng');
        }
    }

    async toggleFavorite(productId) {
        try {
            const response = await fetch('/favorites/api/toggle', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    productId: parseInt(productId)
                })
            });

            const data = await response.json();
            
            if (data.success) {
                const button = document.querySelector(`[data-product-id="${productId}"].btn-favorite`);
                if (button) {
                    button.classList.toggle('active', data.isFavorite);
                }
                this.showSuccess(data.isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích');
            }
        } catch (error) {
            console.error('Error toggling favorite:', error);
            this.showError('Không thể cập nhật yêu thích');
        }
    }

    async updateCartBadge() {
        try {
            const response = await fetch('/api/cart/count');
            const data = await response.json();
            
            if (data.success) {
                const badge = document.getElementById('cartBadge');
                if (badge) {
                    badge.textContent = data.count;
                    badge.style.display = data.count > 0 ? 'flex' : 'none';
                }
            }
        } catch (error) {
            console.error('Error updating cart badge:', error);
        }
    }

    handleSearch(e) {
        const query = e.target.value.trim();
        if (query.length >= 2) {
            // Show search suggestions
            this.showSearchSuggestions(query);
        } else {
            this.hideSearchSuggestions();
        }
    }

    async showSearchSuggestions(query) {
        try {
            const response = await fetch(`/api/products/search-suggestions?q=${encodeURIComponent(query)}`);
            const data = await response.json();
            
            if (data.success && data.suggestions.length > 0) {
                // Create or update suggestions dropdown
                this.renderSearchSuggestions(data.suggestions);
            }
        } catch (error) {
            console.error('Error loading search suggestions:', error);
        }
    }

    renderSearchSuggestions(suggestions) {
        // Implementation for search suggestions dropdown
        // This would create a dropdown with the suggestions
    }

    hideSearchSuggestions() {
        // Hide search suggestions dropdown
    }

    performSearch() {
        const query = document.getElementById('searchInput').value.trim();
        console.log('Performing search with query:', query);
        if (query) {
            window.location.href = `/products?search=${encodeURIComponent(query)}`;
        } else {
            console.log('No search query provided');
        }
    }

    async handleNewsletterSubmit(e) {
        e.preventDefault();
        
        const emailInput = e.target.querySelector('input[type="email"]');
        const errorDiv = document.getElementById('newsletterError');
        const email = emailInput.value.trim();
        
        // Clear previous errors
        emailInput.classList.remove('error');
        if (errorDiv) {
            errorDiv.style.display = 'none';
            errorDiv.textContent = '';
        }
        
        // Validate email
        if (!email) {
            this.showNewsletterError('Vui lòng nhập email');
            return;
        }
        
        if (!this.isValidEmail(email)) {
            this.showNewsletterError('Vui lòng nhập email hợp lệ');
            return;
        }

        try {
            const response = await fetch('/api/newsletter/subscribe', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email })
            });

            const data = await response.json();
            
            if (data.success) {
                this.showSuccess('Đăng ký thành công! Kiểm tra email để nhận mã giảm giá.');
                e.target.reset();
            } else {
                this.showNewsletterError(data.message || 'Đăng ký thất bại');
            }
        } catch (error) {
            console.error('Error subscribing to newsletter:', error);
            this.showNewsletterError('Đăng ký thất bại');
        }
    }

    showNewsletterError(message) {
        const emailInput = document.querySelector('.newsletter-input');
        const errorDiv = document.getElementById('newsletterError');
        
        if (emailInput) {
            emailInput.classList.add('error');
        }
        
        if (errorDiv) {
            errorDiv.textContent = message;
            errorDiv.style.display = 'block';
        }
    }

    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }


    setupLazyLoading() {
        if ('IntersectionObserver' in window) {
            // OPTIMIZED: Add rootMargin to preload images before they enter viewport
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        if (img.dataset.src) {
                            img.src = img.dataset.src;
                            img.removeAttribute('data-src');
                        }
                        img.classList.remove('lazy');
                        observer.unobserve(img);
                    }
                });
            }, {
                rootMargin: '50px', // Preload 50px before entering viewport
                threshold: 0.01
            });

            document.querySelectorAll('img[loading="lazy"]').forEach(img => {
                imageObserver.observe(img);
            });
        }
    }

    formatPrice(price) {
        if (!price || price === 0) return '';
        return new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(price);
    }

    showSuccess(message) {
        if (window.showToast) {
            window.showToast(message, 'success');
        } else {
            alert(message);
        }
    }

    showError(message) {
        if (window.showToast) {
            window.showToast(message, 'error');
        } else {
            alert(message);
        }
    }

    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
}

/**
 * Banner Carousel Class
 * Handles auto-play, navigation, and touch gestures
 */
class BannerCarousel {
    constructor() {
        this.currentSlide = 0;
        this.totalSlides = 3;
        this.autoPlayInterval = null;
        this.autoPlayDelay = 5000; // 5 seconds
        this.isTransitioning = false;
        
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.startAutoPlay();
    }
    
    setupEventListeners() {
        // Navigation arrows
        const prevBtn = document.querySelector('.carousel-prev');
        const nextBtn = document.querySelector('.carousel-next');
        
        if (prevBtn) {
            prevBtn.addEventListener('click', () => this.previousSlide());
        }
        
        if (nextBtn) {
            nextBtn.addEventListener('click', () => this.nextSlide());
        }
        
        // Dots navigation
        document.querySelectorAll('.carousel-dot').forEach((dot, index) => {
            dot.addEventListener('click', () => this.goToSlide(index));
        });
        
        // Keyboard navigation - handled by global keydown handler
        
        // Touch gestures
        this.setupTouchGestures();
        
        // Pause on hover
        const carousel = document.querySelector('.banner-carousel');
        if (carousel) {
            carousel.addEventListener('mouseenter', () => this.pauseAutoPlay());
            carousel.addEventListener('mouseleave', () => this.startAutoPlay());
        }
    }
    
    setupTouchGestures() {
        const carousel = document.querySelector('.banner-carousel');
        if (!carousel) return;
        
        let startX = 0;
        let startY = 0;
        let isDragging = false;
        
        carousel.addEventListener('touchstart', (e) => {
            startX = e.touches[0].clientX;
            startY = e.touches[0].clientY;
            isDragging = true;
            this.pauseAutoPlay();
        }, { passive: true });
        
        carousel.addEventListener('touchmove', (e) => {
            if (!isDragging) return;
            
            const currentX = e.touches[0].clientX;
            const currentY = e.touches[0].clientY;
            const diffX = startX - currentX;
            const diffY = startY - currentY;
            
            // Only handle horizontal swipes
            if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 50) {
                e.preventDefault();
            }
        }, { passive: false }); // Not passive because we use preventDefault
        
        carousel.addEventListener('touchend', (e) => {
            if (!isDragging) return;
            
            const endX = e.changedTouches[0].clientX;
            const diffX = startX - endX;
            
            if (Math.abs(diffX) > 50) {
                if (diffX > 0) {
                    this.nextSlide();
                } else {
                    this.previousSlide();
                }
            }
            
            isDragging = false;
            this.startAutoPlay();
        });
    }
    
    goToSlide(index) {
        if (this.isTransitioning || index === this.currentSlide) return;
        
        this.isTransitioning = true;
        
        // OPTIMIZED: Use requestAnimationFrame for smooth transition
        requestAnimationFrame(() => {
            // Remove active class from current slide
            const currentSlide = document.querySelector('.carousel-slide.active');
            if (currentSlide) {
                currentSlide.classList.remove('active');
            }
            
            // Add active class to new slide
            const slides = document.querySelectorAll('.carousel-slide');
            if (slides[index]) {
                slides[index].classList.add('active');
            }
            
            // Update dots
            document.querySelectorAll('.carousel-dot').forEach((dot, i) => {
                dot.classList.toggle('active', i === index);
            });
            
            this.currentSlide = index;
        });
        
        // Reset transition flag after animation
        setTimeout(() => {
            this.isTransitioning = false;
        }, 500);
    }
    
    nextSlide() {
        const nextIndex = (this.currentSlide + 1) % this.totalSlides;
        this.goToSlide(nextIndex);
    }
    
    previousSlide() {
        const prevIndex = (this.currentSlide - 1 + this.totalSlides) % this.totalSlides;
        this.goToSlide(prevIndex);
    }
    
    startAutoPlay() {
        this.pauseAutoPlay();
        this.autoPlayInterval = setInterval(() => {
            this.nextSlide();
        }, this.autoPlayDelay);
    }
    
    pauseAutoPlay() {
        if (this.autoPlayInterval) {
            clearInterval(this.autoPlayInterval);
            this.autoPlayInterval = null;
        }
    }
    
    // Public method to manually control carousel
    play() {
        this.startAutoPlay();
    }
    
    pause() {
        this.pauseAutoPlay();
    }
}

// Global functions for inline event handlers
window.quickViewProduct = function(productId) {
    // Quick view modal - hiện modal với thông tin sản phẩm
    console.log('Quick view product:', productId);
    
    // Fetch product details
    fetch(`/api/products/${productId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showQuickViewModal(data.product);
            } else {
                showToast('Không thể tải thông tin sản phẩm', 'error');
            }
        })
        .catch(error => {
            console.error('Error loading product:', error);
            showToast('Có lỗi xảy ra, vui lòng thử lại', 'error');
        });
};

function showQuickViewModal(product) {
    // Tạo modal quick view
    const modal = document.createElement('div');
    modal.className = 'quick-view-modal';
    modal.innerHTML = `
        <div class="modal-backdrop" onclick="closeQuickView()"></div>
        <div class="modal-content">
            <button class="close-btn" onclick="closeQuickView()">&times;</button>
            <div class="modal-body">
                <div class="product-images">
                    <div class="main-image">
                        <img src="${product.anhSanPhams && product.anhSanPhams.length > 0 ? product.anhSanPhams[0].duongDan : '/images/no-image.svg'}" 
                             alt="${product.ten}" id="mainProductImage">
                        <div class="product-badge">NEW ARRIVAL</div>
                    </div>
                    <div class="thumbnail-images">
                        ${product.anhSanPhams && product.anhSanPhams.length > 0 ? 
                            product.anhSanPhams.slice(0, 4).map((img, index) => `
                                <div class="thumbnail ${index === 0 ? 'active' : ''}" onclick="changeMainImage('${img.duongDan}')">
                                    <img src="${img.duongDan}" alt="Thumbnail ${index + 1}">
                                </div>
                            `).join('') : 
                            '<div class="thumbnail active"><img src="/images/no-image.svg" alt="No image"></div>'
                        }
                    </div>
                </div>
                <div class="product-details">
                    <h2 class="product-name">${product.ten}</h2>
                    <div class="product-meta">
                        <span class="brand">Thương hiệu: ${product.thuongHieu?.ten || 'N/A'}</span>
                        <span class="product-code">| Mã sản phẩm: ${product.maSanPham || 'N/A'}</span>
                    </div>
                    <div class="product-price">${formatPrice(product.giaBan || product.gia)}</div>
                    
                    <div class="product-options">
                        <div class="option-group">
                            <label>Kích cỡ:</label>
                            <div class="size-options">
                                <button class="size-btn active" data-size="S">S</button>
                                <button class="size-btn" data-size="M">M</button>
                                <button class="size-btn" data-size="L">L</button>
                                <button class="size-btn" data-size="XL">XL</button>
                            </div>
                        </div>
                        
                        <div class="option-group">
                            <label>Màu sắc:</label>
                            <div class="color-options">
                                <button class="color-btn active" data-color="${product.mauSac || 'Đen'}" 
                                        style="background: ${getColorHex(product.mauSac || 'Đen')};"></button>
                            </div>
                        </div>
                        
                        <div class="option-group">
                            <label>Chất liệu:</label>
                            <div class="material-info">${product.chatLieu || '100% polyester'}</div>
                        </div>
                        
                        <div class="option-group">
                            <label>Số lượng:</label>
                            <div class="quantity-selector">
                                <button class="qty-btn" onclick="changeQuantity(-1)">-</button>
                                <span class="qty-display">1</span>
                                <button class="qty-btn" onclick="changeQuantity(1)">+</button>
                            </div>
                        </div>
                    </div>
                    
                    <button class="add-to-cart-btn" onclick="addToCartFromQuickView(${product.id})">
                        THÊM VÀO GIỎ
                    </button>
                </div>
            </div>
        </div>
    `;
    
    // Thêm CSS cho modal
    const style = document.createElement('style');
    style.textContent = `
        .quick-view-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(0, 0, 0, 0.5);
        }
        .modal-content {
            position: relative;
            background: white;
            border-radius: 12px;
            max-width: 900px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }
        .close-btn {
            position: absolute;
            top: 15px;
            right: 15px;
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #666;
            z-index: 10;
        }
        .modal-body {
            display: flex;
            gap: 30px;
            padding: 30px;
        }
        .product-images {
            flex: 1;
        }
        .main-image {
            position: relative;
            margin-bottom: 15px;
        }
        .main-image img {
            width: 100%;
            height: 400px;
            object-fit: cover;
            border-radius: 8px;
        }
        .product-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            background: #ff6b35;
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .thumbnail-images {
            display: flex;
            gap: 10px;
        }
        .thumbnail {
            width: 80px;
            height: 80px;
            border: 2px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
            cursor: pointer;
            transition: border-color 0.2s ease;
        }
        .thumbnail.active {
            border-color: #3f6ad8;
        }
        .thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .product-details {
            flex: 1;
            padding-left: 20px;
        }
        .product-name {
            font-size: 24px;
            font-weight: 600;
            margin: 0 0 15px 0;
            color: #333;
        }
        .product-meta {
            margin-bottom: 20px;
            color: #666;
            font-size: 14px;
        }
        .product-price {
            font-size: 28px;
            font-weight: 700;
            color: #e74c3c;
            margin-bottom: 25px;
        }
        .product-options {
            margin-bottom: 30px;
        }
        .option-group {
            margin-bottom: 20px;
        }
        .option-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }
        .size-options {
            display: flex;
            gap: 10px;
        }
        .size-btn {
            width: 40px;
            height: 40px;
            border: 2px solid #ddd;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.2s ease;
        }
        .size-btn.active {
            border-color: #3f6ad8;
            background: #3f6ad8;
            color: white;
        }
        .color-options {
            display: flex;
            gap: 10px;
        }
        .color-btn {
            width: 40px;
            height: 40px;
            border: 2px solid #ddd;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .color-btn.active {
            border-color: #3f6ad8;
            transform: scale(1.1);
        }
        .material-info {
            color: #666;
            font-size: 14px;
        }
        .quantity-selector {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .qty-btn {
            width: 35px;
            height: 35px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
        }
        .qty-display {
            font-size: 18px;
            font-weight: 600;
            min-width: 30px;
            text-align: center;
        }
        .add-to-cart-btn {
            width: 100%;
            padding: 15px;
            background: #333;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s ease;
        }
        .add-to-cart-btn:hover {
            background: #555;
        }
        @media (max-width: 768px) {
            .modal-body {
                flex-direction: column;
                gap: 20px;
            }
            .product-details {
                padding-left: 0;
            }
        }
    `;
    
    document.head.appendChild(style);
    document.body.appendChild(modal);
    
    // Thêm event listeners
    modal.querySelectorAll('.size-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            modal.querySelectorAll('.size-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
        });
    });
    
    modal.querySelectorAll('.color-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            modal.querySelectorAll('.color-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
        });
    });
}

function getColorHex(colorName) {
    const colorMap = {
        'Đen': '#000000',
        'Trắng': '#ffffff',
        'Xanh': '#0066cc',
        'Đỏ': '#cc0000',
        'Xám': '#666666',
        'Nâu': '#8B4513'
    };
    return colorMap[colorName] || '#000000';
}

function formatPrice(price) {
    if (!price || price === 0) return '';
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(price);
}

function changeMainImage(imageSrc) {
    const mainImage = document.getElementById('mainProductImage');
    if (mainImage) {
        mainImage.src = imageSrc;
    }
    
    // Update active thumbnail
    document.querySelectorAll('.thumbnail').forEach(thumb => {
        thumb.classList.remove('active');
    });
    event.target.closest('.thumbnail').classList.add('active');
}

window.closeQuickView = function() {
    const modal = document.querySelector('.quick-view-modal');
    if (modal) {
        modal.remove();
    }
};

window.addToCartFromQuickView = function(productId) {
    const modal = document.querySelector('.quick-view-modal');
    if (!modal) return;
    
    const selectedSize = modal.querySelector('.size-btn.active')?.dataset.size || 'S';
    const selectedColor = modal.querySelector('.color-btn.active')?.dataset.color || 'Đen';
    const quantity = parseInt(modal.querySelector('.qty-display').textContent) || 1;
    
    console.log('Adding to cart from quick view:', {
        productId,
        size: selectedSize,
        color: selectedColor,
        quantity
    });
    
    // Gọi API thêm vào giỏ hàng
    fetch('/api/cart/add', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            productId: productId,
            size: selectedSize,
            color: selectedColor,
            quantity: quantity
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast(`Đã thêm ${quantity} sản phẩm vào giỏ hàng`, 'success');
            closeQuickView();
        } else {
            showToast('Có lỗi xảy ra, vui lòng thử lại', 'error');
        }
    })
    .catch(error => {
        console.error('Error adding to cart:', error);
        showToast('Có lỗi xảy ra, vui lòng thử lại', 'error');
    });
};

window.showProductOptions = function(productId) {
    // Navigate to product detail page
    console.log('Show options for product:', productId);
    window.location.href = `/products/${productId}`;
};

// Debounce wishlist toggles to prevent double calls
const wishlistToggleDebounce = new Map();

window.toggleWishlist = function(productId) {
    // Prevent double calls
    if (wishlistToggleDebounce.has(productId)) {
        console.log('Wishlist toggle already in progress for product:', productId);
        return;
    }
    
    // Toggle wishlist status
    console.log('Toggle wishlist for product:', productId);
    
    // Mark as in progress
    wishlistToggleDebounce.set(productId, true);
    
    // Directly call wishlist toggle API
    fetch(`/api/wishlist/toggle/${productId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (response.status === 401) {
            // User not logged in
            window.location.href = '/login?redirect=/';
            return null;
        }
        return response.json();
    })
    .then(data => {
        console.log('Wishlist API response:', data);
        if (data) {
            // Update UI
            const button = document.querySelector(`[data-product-id="${productId}"].plp-wishlist-btn`);
            if (button) {
                console.log('Button found, isInWishlist:', data.isInWishlist);
                if (data.isInWishlist) {
                    button.classList.add('active');
                    showToast('Đã thêm vào yêu thích', 'success');
                } else {
                    button.classList.remove('active');
                    showToast('Đã xóa khỏi yêu thích', 'info');
                }
            } else {
                console.log('Button not found for product:', productId);
            }
        }
    })
    .catch(error => {
        console.error('Error toggling wishlist:', error);
        showToast('Có lỗi xảy ra, vui lòng thử lại', 'error');
    })
    .finally(() => {
        // Remove from debounce map after 1 second
        setTimeout(() => {
            wishlistToggleDebounce.delete(productId);
        }, 1000);
    });
};

// Toast management to prevent multiple toasts
let currentToast = null;

function showToast(message, type = 'info') {
    // Remove existing toast if any
    if (currentToast) {
        currentToast.remove();
        currentToast = null;
    }
    
    // Create new toast
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 80px;
        right: 20px;
        background: ${type === 'success' ? '#16A34A' : type === 'error' ? '#DC2626' : '#3F6AD8'};
        color: white;
        padding: 12px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        animation: slideInRight 0.3s ease;
        max-width: 300px;
        word-wrap: break-word;
    `;
    
    document.body.appendChild(toast);
    currentToast = toast;
    
    setTimeout(() => {
        if (toast.parentNode) {
            toast.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.remove();
                }
                if (currentToast === toast) {
                    currentToast = null;
                }
            }, 300);
        }
    }, 3000);
}

// Initialize when DOM is loaded
// OPTIMIZED: Global keydown handler to reduce event listeners
let homePage, bannerCarousel;

document.addEventListener('DOMContentLoaded', () => {
    homePage = new HomePage();
    bannerCarousel = new BannerCarousel();
    
    // Single global keydown handler
    document.addEventListener('keydown', (e) => {
        // Handle Escape key for mobile menu and mega menu
        if (e.key === 'Escape') {
            const mobileMenu = document.getElementById('mobileMenu');
            const megaMenu = document.getElementById('megaMenu');
            
            if (mobileMenu && mobileMenu.classList.contains('active')) {
                const closeBtn = document.getElementById('closeMobileMenu');
                if (closeBtn) closeBtn.click();
            }
            // Mega menu escape is already handled in its own scope
        }
        
        // Handle arrow keys for carousel (only when not in input)
        if (!['INPUT', 'TEXTAREA', 'SELECT'].includes(document.activeElement.tagName)) {
            if (e.key === 'ArrowLeft' && bannerCarousel) {
                bannerCarousel.previousSlide();
            } else if (e.key === 'ArrowRight' && bannerCarousel) {
                bannerCarousel.nextSlide();
            }
        }
    }, { passive: true });
});

// Export for potential use in other scripts
window.HomePage = HomePage;
window.BannerCarousel = BannerCarousel;
