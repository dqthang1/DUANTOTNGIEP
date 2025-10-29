/* =========================================================
   Product Detail Page JavaScript
   Modern E-commerce Product Detail Interactions
   ========================================================= */

class ProductDetail {
    constructor() {
        this.selectedColor = null;
        this.selectedSize = null;
        this.selectedVariant = null;
        this.quantity = 1;
        this.productId = null;
        this.variants = [];
        this.init();
    }
    
    init() {
        // Get product data from window
        if (window.productData) {
            this.productId = window.productData.id;
            this.variants = window.productData.variants || [];
        }
        
        this.bindEvents();
        this.initializeGallery();
        this.initializeTabs();
        this.setupStickyBar();
        this.initializeModal();
        this.updateStickySelection();
        
        console.log('ProductDetail initialized with product ID:', this.productId);
    }
    
    bindEvents() {
        // Thumbnails
        document.querySelectorAll('.thumbnail').forEach(thumb => {
            thumb.addEventListener('click', (e) => this.handleThumbnailClick(e));
        });
        
        // Color swatches
        document.querySelectorAll('.color-swatch').forEach(swatch => {
            swatch.addEventListener('click', (e) => this.handleColorSelect(e));
        });
        
        // Size chips
        document.querySelectorAll('.size-chip').forEach(chip => {
            chip.addEventListener('click', (e) => this.handleSizeSelect(e));
        });
        
        // Quantity controls
        const decreaseBtn = document.getElementById('quantityDecrease');
        const increaseBtn = document.getElementById('quantityIncrease');
        const quantityInput = document.getElementById('quantityInput');
        
        if (decreaseBtn) {
            decreaseBtn.addEventListener('click', () => this.decreaseQuantity());
        }
        if (increaseBtn) {
            increaseBtn.addEventListener('click', () => this.increaseQuantity());
        }
        if (quantityInput) {
            quantityInput.addEventListener('input', (e) => this.handleQuantityInput(e));
        }
        
        // CTA buttons
        const addToCartBtn = document.getElementById('addToCartBtn');
        const buyNowBtn = document.getElementById('buyNowBtn');
        const stickyAddToCartBtn = document.getElementById('stickyAddToCart');
        
        if (addToCartBtn) {
            addToCartBtn.addEventListener('click', () => this.handleAddToCart());
        }
        if (buyNowBtn) {
            buyNowBtn.addEventListener('click', () => this.handleBuyNow());
        }
        if (stickyAddToCartBtn) {
            stickyAddToCartBtn.addEventListener('click', () => this.handleAddToCart());
        }
        
        // Shipping calculator
        const shippingBtn = document.querySelector('.shipping-calculator button');
        if (shippingBtn) {
            shippingBtn.addEventListener('click', () => this.calculateShipping());
        }
        
        // Notify form
        const notifyBtn = document.querySelector('.notify-form button');
        if (notifyBtn) {
            notifyBtn.addEventListener('click', () => this.submitNotification());
        }
        
        // Wishlist button
        const wishlistBtn = document.querySelector('.wishlist-btn');
        if (wishlistBtn) {
            wishlistBtn.addEventListener('click', () => this.handleWishlist());
        }
        
        // Share button
        const shareBtn = document.querySelector('.share-btn');
        if (shareBtn) {
            shareBtn.addEventListener('click', () => this.handleShare());
        }
        
        console.log('All events bound successfully');
    }
    
    initializeGallery() {
        const mainImage = document.getElementById('mainImage');
        const thumbnails = document.querySelectorAll('.thumbnail');
        
        if (mainImage && thumbnails.length > 0) {
            // Set initial image
            const firstThumbnail = thumbnails[0];
            if (firstThumbnail) {
                const imageSrc = firstThumbnail.getAttribute('data-image');
                if (imageSrc) {
                    mainImage.src = imageSrc;
                }
            }
        }
        
        console.log('Gallery initialized with', thumbnails.length, 'thumbnails');
    }
    
    handleThumbnailClick(e) {
        const thumbnail = e.currentTarget;
        const imageSrc = thumbnail.getAttribute('data-image');
        const mainImage = document.getElementById('mainImage');
        
        if (mainImage && imageSrc) {
            // Remove active class from all thumbnails
            document.querySelectorAll('.thumbnail').forEach(thumb => {
                thumb.classList.remove('active');
            });
            
            // Add active class to clicked thumbnail
            thumbnail.classList.add('active');
            
            // Update main image
            mainImage.src = imageSrc;
            
            console.log('Thumbnail clicked, image changed to:', imageSrc);
        }
    }
    
    handleColorSelect(e) {
        const swatch = e.currentTarget;
        const color = swatch.getAttribute('data-color');
        const variantId = swatch.getAttribute('data-variant-id');
        
        // Remove active from all color swatches
        document.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('selected'));
        
        // Add active to clicked swatch
        swatch.classList.add('selected');
        
        this.selectedColor = color;
        this.selectedVariant = variantId;
        
        this.updateStockNotice();
        this.updateStickySelection();
        
        console.log('Color selected:', color, 'Variant ID:', variantId);
    }
    
    handleSizeSelect(e) {
        const chip = e.currentTarget;
        
        if (chip.classList.contains('disabled')) {
            this.showToast('Kích thước này đã hết hàng', 'error');
            return;
        }
        
        const size = chip.getAttribute('data-size');
        const stock = parseInt(chip.getAttribute('data-stock'));
        const variantId = chip.getAttribute('data-variant-id');
        
        // Remove active from all size chips
        document.querySelectorAll('.size-chip').forEach(c => c.classList.remove('selected'));
        
        // Add active to clicked chip
        chip.classList.add('selected');
        
        this.selectedSize = size;
        this.selectedVariant = variantId;
        
        this.updateStockNotice();
        this.updateStickySelection();
        
        console.log('Size selected:', size, 'Stock:', stock, 'Variant ID:', variantId);
    }
    
    updateStockNotice() {
        const notice = document.getElementById('stockNotice');
        const notifyForm = document.getElementById('notifyForm');
        const selectedChip = document.querySelector('.size-chip.selected');
        
        if (!selectedChip) {
            if (notice) notice.style.display = 'none';
            if (notifyForm) notifyForm.style.display = 'none';
            return;
        }
        
        const stock = parseInt(selectedChip.getAttribute('data-stock'));
        
        if (stock === 0) {
            if (notice) notice.style.display = 'none';
            if (notifyForm) notifyForm.style.display = 'block';
        } else if (stock <= 5) {
            if (notice) {
                notice.className = 'stock-notice low-stock';
                const stockText = notice.querySelector('.stock-text');
                if (stockText) {
                    stockText.textContent = `Chỉ còn ${stock} sản phẩm - Mua ngay!`;
                }
                notice.style.display = 'block';
            }
            if (notifyForm) notifyForm.style.display = 'none';
        } else {
            if (notice) notice.style.display = 'none';
            if (notifyForm) notifyForm.style.display = 'none';
        }
    }
    
    updateStickySelection() {
        const stickySelection = document.getElementById('stickySelection');
        if (stickySelection) {
            let selectionText = '';
            if (this.selectedSize) {
                selectionText += `Size: ${this.selectedSize}`;
            }
            if (this.selectedColor) {
                if (selectionText) selectionText += ' | ';
                selectionText += `Màu: ${this.selectedColor}`;
            }
            if (!selectionText) {
                selectionText = 'Chọn size và màu';
            }
            stickySelection.textContent = selectionText;
        }
    }
    
    decreaseQuantity() {
        if (this.quantity > 1) {
            this.quantity--;
            this.updateQuantityDisplay();
        }
    }
    
    increaseQuantity() {
        const maxStock = this.getMaxStock();
        if (this.quantity < maxStock) {
            this.quantity++;
            this.updateQuantityDisplay();
        } else {
            this.showToast(`Chỉ còn ${maxStock} sản phẩm`, 'error');
        }
    }
    
    handleQuantityInput(e) {
        const value = parseInt(e.target.value);
        const maxStock = this.getMaxStock();
        
        if (value < 1) {
            this.quantity = 1;
        } else if (value > maxStock) {
            this.quantity = maxStock;
            this.showToast(`Chỉ còn ${maxStock} sản phẩm`, 'error');
        } else {
            this.quantity = value;
        }
        
        this.updateQuantityDisplay();
    }
    
    updateQuantityDisplay() {
        const quantityInput = document.getElementById('quantityInput');
        if (quantityInput) {
            quantityInput.value = this.quantity;
        }
    }
    
    getMaxStock() {
        const selectedChip = document.querySelector('.size-chip.selected');
        if (selectedChip) {
            return parseInt(selectedChip.getAttribute('data-stock')) || 0;
        }
        return 10; // Default max
    }
    
    validateSelection() {
        if (!this.selectedSize) {
            this.showToast('Vui lòng chọn kích thước', 'error');
            const sizeChips = document.querySelector('.size-chips');
            if (sizeChips) {
                sizeChips.scrollIntoView({ behavior: 'smooth' });
            }
            return false;
        }
        
        if (!this.selectedColor) {
            this.showToast('Vui lòng chọn màu sắc', 'error');
            const colorSwatches = document.querySelector('.color-swatches');
            if (colorSwatches) {
                colorSwatches.scrollIntoView({ behavior: 'smooth' });
            }
            return false;
        }
        
        return true;
    }
    
    handleAddToCart() {
        if (!this.validateSelection()) return;
        
        const btn = document.getElementById('addToCartBtn');
        const stickyBtn = document.getElementById('stickyAddToCart');
        
        // Show loading state
        if (btn) {
            btn.classList.add('loading');
            btn.disabled = true;
        }
        if (stickyBtn) {
            stickyBtn.classList.add('loading');
            stickyBtn.disabled = true;
        }
        
        // Mock API call (replace with actual endpoint)
        setTimeout(() => {
            this.showToast('Đã thêm vào giỏ hàng!', 'success');
            
            // Reset button states
            if (btn) {
                btn.classList.remove('loading');
                btn.disabled = false;
            }
            if (stickyBtn) {
                stickyBtn.classList.remove('loading');
                stickyBtn.disabled = false;
            }
        }, 1000);
        
        console.log('Add to cart:', {
            productId: this.productId,
            variantId: this.selectedVariant,
            quantity: this.quantity,
            color: this.selectedColor,
            size: this.selectedSize
        });
    }
    
    handleBuyNow() {
        if (!this.validateSelection()) return;
        
        this.showToast('Chuyển đến trang thanh toán...', 'success');
        
        // Mock redirect to checkout
        setTimeout(() => {
            console.log('Redirect to checkout with:', {
                productId: this.productId,
                variantId: this.selectedVariant,
                quantity: this.quantity
            });
        }, 1000);
    }
    
    calculateShipping() {
        const input = document.querySelector('.shipping-calculator input');
        const result = document.getElementById('shippingResult');
        
        if (!input || !result) return;
        
        const address = input.value.trim();
        if (!address) {
            this.showToast('Vui lòng nhập địa chỉ', 'error');
            return;
        }
        
        // Mock calculation
        result.innerHTML = `
            <div class="shipping-option">
                <span>Giao hàng tiêu chuẩn (2-3 ngày)</span>
                <span class="shipping-fee">Miễn phí</span>
            </div>
            <div class="shipping-option">
                <span>Giao hàng nhanh (24h)</span>
                <span class="shipping-fee">30.000₫</span>
            </div>
        `;
        
        console.log('Shipping calculated for:', address);
    }
    
    submitNotification() {
        const emailInput = document.querySelector('.notify-form input[type="email"]');
        const phoneInput = document.querySelector('.notify-form input[type="tel"]');
        
        if (!emailInput) return;
        
        const email = emailInput.value.trim();
        const phone = phoneInput ? phoneInput.value.trim() : '';
        
        if (!email) {
            this.showToast('Vui lòng nhập email', 'error');
            return;
        }
        
        if (!this.isValidEmail(email)) {
            this.showToast('Email không hợp lệ', 'error');
            return;
        }
        
        // API call to save notification
        fetch('/api/products/notify', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                productId: this.productId,
                variantId: this.selectedVariant,
                email: email,
                phone: phone
            })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                this.showToast('Đã đăng ký nhận thông báo!', 'success');
                // Clear form
                emailInput.value = '';
                if (phoneInput) phoneInput.value = '';
            } else {
                this.showToast(data.message || 'Có lỗi xảy ra', 'error');
            }
        })
        .catch(err => {
            console.error('Error submitting notification:', err);
            this.showToast('Có lỗi xảy ra, vui lòng thử lại', 'error');
        });
    }
    
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    handleWishlist() {
        const wishlistBtn = document.querySelector('.wishlist-btn');
        const icon = wishlistBtn.querySelector('i');
        
        if (icon.classList.contains('far')) {
            // Add to wishlist
            icon.classList.remove('far');
            icon.classList.add('fas');
            wishlistBtn.style.color = '#EF4444';
            this.showToast('Đã thêm vào yêu thích!', 'success');
        } else {
            // Remove from wishlist
            icon.classList.remove('fas');
            icon.classList.add('far');
            wishlistBtn.style.color = '';
            this.showToast('Đã xóa khỏi yêu thích', 'success');
        }
    }
    
    handleShare() {
        if (navigator.share) {
            navigator.share({
                title: document.title,
                text: 'Xem sản phẩm này',
                url: window.location.href
            });
        } else {
            // Fallback: copy to clipboard
            navigator.clipboard.writeText(window.location.href).then(() => {
                this.showToast('Đã copy link chia sẻ!', 'success');
            });
        }
    }
    
    initializeTabs() {
        const tabButtons = document.querySelectorAll('.tab-btn');
        
        tabButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                const tabId = btn.getAttribute('data-tab');
                
                // Remove active from all tabs
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
                
                // Add active to clicked tab
                btn.classList.add('active');
                const panel = document.getElementById(tabId);
                if (panel) {
                    panel.classList.add('active');
                }
                
                console.log('Tab switched to:', tabId);
            });
        });
    }
    
    initializeModal() {
        const modal = document.getElementById('sizeGuideModal');
        const openBtn = document.getElementById('sizeGuideBtn');
        const closeBtn = document.querySelector('.modal-close');
        
        if (openBtn && modal) {
            openBtn.addEventListener('click', (e) => {
                e.preventDefault();
                modal.classList.add('show');
                document.body.style.overflow = 'hidden';
            });
        }
        
        if (closeBtn && modal) {
            closeBtn.addEventListener('click', () => {
                modal.classList.remove('show');
                document.body.style.overflow = '';
            });
        }
        
        // Close modal when clicking outside
        if (modal) {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.classList.remove('show');
                    document.body.style.overflow = '';
                }
            });
        }
    }
    
    setupStickyBar() {
        const stickyBar = document.querySelector('.mobile-sticky-bar');
        if (!stickyBar) return;
        
        let lastScroll = 0;
        
        window.addEventListener('scroll', () => {
            const currentScroll = window.scrollY;
            
            if (currentScroll > 400 && window.innerWidth < 1200) {
                stickyBar.style.display = 'flex';
            } else {
                stickyBar.style.display = 'none';
            }
            
            lastScroll = currentScroll;
        });
        
        console.log('Sticky bar setup completed');
    }
    
    showToast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        if (!container) return;
        
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        
        container.appendChild(toast);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 3000);
        
        console.log('Toast shown:', message, type);
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('Product detail page loaded');
    new ProductDetail();
});

// Global functions for related products
function viewProduct(productId) {
    window.location.href = `/products/${productId}`;
}

function addToCart(productId) {
    console.log('Add to cart from related product:', productId);
    // This would integrate with the main ProductDetail instance
}
