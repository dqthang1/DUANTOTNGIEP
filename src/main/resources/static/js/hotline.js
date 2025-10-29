/**
 * Hotline Page JavaScript
 * Handles modal tracking, sticky CTA, form validation, and chat integration
 */

class HotlinePage {
    constructor() {
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupStickyCTA();
        this.setupFormValidation();
        this.setupUserDropdown();
    }

    setupEventListeners() {
        // User dropdown functionality
        const profileToggle = document.getElementById('profileToggle');
        const userDropdown = document.getElementById('userDropdown');
        
        if (profileToggle && userDropdown) {
            profileToggle.addEventListener('click', (e) => {
                e.preventDefault();
                userDropdown.classList.toggle('show');
            });
            
            document.addEventListener('click', (e) => {
                if (!profileToggle.contains(e.target) && !userDropdown.contains(e.target)) {
                    userDropdown.classList.remove('show');
                }
            });
        }

        // Contact form submission
        const contactForm = document.getElementById('contactForm');
        if (contactForm) {
            contactForm.addEventListener('submit', this.handleFormSubmission.bind(this));
        }

        // File upload validation
        const fileInput = document.getElementById('attachment');
        if (fileInput) {
            fileInput.addEventListener('change', this.validateFileUpload.bind(this));
        }

        // Tracking form submission
        const trackingForm = document.getElementById('trackingForm');
        if (trackingForm) {
            trackingForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.trackOrder();
            });
        }
    }

    setupStickyCTA() {
        const stickyCta = document.getElementById('stickyCta');
        if (!stickyCta) return;

        let isVisible = false;
        let lastScrollY = window.scrollY;

        const toggleStickyCTA = () => {
            const scrollY = window.scrollY;
            const windowHeight = window.innerHeight;
            const documentHeight = document.documentElement.scrollHeight;
            const footer = document.querySelector('footer');
            
            // Show when scrolled more than 300px
            const shouldShow = scrollY > 300;
            
            // Hide when near footer
            const nearFooter = footer && (scrollY + windowHeight) >= (documentHeight - 100);
            
            // Hide when modal is open
            const modalOpen = document.querySelector('.modal.show');
            
            const finalShouldShow = shouldShow && !nearFooter && !modalOpen;

            if (finalShouldShow && !isVisible) {
                stickyCta.style.display = 'flex';
                isVisible = true;
            } else if (!finalShouldShow && isVisible) {
                stickyCta.style.display = 'none';
                isVisible = false;
            }

            lastScrollY = scrollY;
        };

        // Throttle scroll events
        let ticking = false;
        const handleScroll = () => {
            if (!ticking) {
                requestAnimationFrame(() => {
                    toggleStickyCTA();
                    ticking = false;
                });
                ticking = true;
            }
        };

        window.addEventListener('scroll', handleScroll);
        
        // Initial check
        toggleStickyCTA();
    }

    setupFormValidation() {
        const form = document.getElementById('contactForm');
        if (!form) return;

        // Real-time validation
        const inputs = form.querySelectorAll('input, textarea, select');
        inputs.forEach(input => {
            input.addEventListener('blur', () => this.validateField(input));
            input.addEventListener('input', () => this.clearFieldError(input));
        });
    }

    validateField(field) {
        const value = field.value.trim();
        let isValid = true;
        let errorMessage = '';

        // Required field validation
        if (field.hasAttribute('required') && !value) {
            isValid = false;
            errorMessage = 'Trường này là bắt buộc';
        }

        // Email validation
        if (field.type === 'email' && value) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(value)) {
                isValid = false;
                errorMessage = 'Email không hợp lệ';
            }
        }

        // Phone validation
        if (field.type === 'tel' && value) {
            const phoneRegex = /^(\+84|84|0)[1-9][0-9]{8,9}$/;
            if (!phoneRegex.test(value.replace(/\s/g, ''))) {
                isValid = false;
                errorMessage = 'Số điện thoại không hợp lệ';
            }
        }

        // Message length validation
        if (field.name === 'message' && value) {
            if (value.length < 10) {
                isValid = false;
                errorMessage = 'Nội dung phải có ít nhất 10 ký tự';
            }
        }

        if (!isValid) {
            this.showFieldError(field, errorMessage);
        } else {
            this.clearFieldError(field);
        }

        return isValid;
    }

    showFieldError(field, message) {
        this.clearFieldError(field);
        
        field.classList.add('is-invalid');
        
        const errorDiv = document.createElement('div');
        errorDiv.className = 'invalid-feedback';
        errorDiv.textContent = message;
        
        field.parentNode.appendChild(errorDiv);
    }

    clearFieldError(field) {
        field.classList.remove('is-invalid');
        const errorDiv = field.parentNode.querySelector('.invalid-feedback');
        if (errorDiv) {
            errorDiv.remove();
        }
    }

    validateFileUpload(event) {
        const file = event.target.files[0];
        if (!file) return;

        const maxSize = 5 * 1024 * 1024; // 5MB
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];

        if (file.size > maxSize) {
            this.showFieldError(event.target, 'File không được vượt quá 5MB');
            event.target.value = '';
            return;
        }

        if (!allowedTypes.includes(file.type)) {
            this.showFieldError(event.target, 'Chỉ chấp nhận file ảnh (JPG, PNG, GIF) và PDF');
            event.target.value = '';
            return;
        }

        this.clearFieldError(event.target);
    }

    async handleFormSubmission(event) {
        event.preventDefault();
        
        const form = event.target;
        const submitBtn = document.getElementById('submitBtn');
        const originalText = submitBtn.innerHTML;

        // Validate all fields
        const inputs = form.querySelectorAll('input, textarea, select');
        let isValid = true;
        let firstErrorField = null;

        inputs.forEach(input => {
            if (!this.validateField(input)) {
                isValid = false;
                if (!firstErrorField) {
                    firstErrorField = input;
                }
            }
        });

        if (!isValid) {
            if (firstErrorField) {
                firstErrorField.scrollIntoView({ behavior: 'smooth', block: 'center' });
                firstErrorField.focus();
            }
            this.showToast('Vui lòng kiểm tra lại thông tin', 'error');
            return;
        }

        // Show loading state
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Đang gửi...';

        try {
            const formData = new FormData(form);
            
            const response = await fetch('/hotline/contact', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                const message = result.referenceCode ? 
                    `Đã nhận yêu cầu! Mã ${result.referenceCode}. Chúng tôi sẽ phản hồi trong 24h làm việc.` :
                    result.message;
                this.showToast(message, 'success');
                form.reset();
                this.clearAllFieldErrors();
            } else {
                this.showToast(result.message, 'error');
            }
        } catch (error) {
            console.error('Error submitting form:', error);
            this.showToast('Có lỗi xảy ra khi gửi tin nhắn. Vui lòng thử lại sau.', 'error');
        } finally {
            // Reset button state
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    }

    clearAllFieldErrors() {
        const form = document.getElementById('contactForm');
        const inputs = form.querySelectorAll('input, textarea, select');
        inputs.forEach(input => this.clearFieldError(input));
    }

    openTrackingModal() {
        const modal = new bootstrap.Modal(document.getElementById('trackingModal'));
        modal.show();
        
        // Clear previous results
        const resultDiv = document.getElementById('trackingResult');
        resultDiv.style.display = 'none';
        resultDiv.innerHTML = '';
        
        // Reset form
        document.getElementById('trackingForm').reset();
    }

    async trackOrder() {
        const orderCode = document.getElementById('orderCode').value.trim();
        const contactInfo = document.getElementById('contactInfo').value.trim();
        const trackBtn = document.getElementById('trackBtn');
        const spinner = trackBtn.querySelector('.spinner-border');
        const resultDiv = document.getElementById('trackingResult');

        if (!orderCode) {
            this.showToast('Vui lòng nhập mã đơn hàng', 'error');
            return;
        }

        // Show loading state
        trackBtn.disabled = true;
        spinner.style.display = 'inline-block';

        try {
            const params = new URLSearchParams({
                code: orderCode,
                contact: contactInfo
            });

            const response = await fetch(`/api/orders/track?${params}`);
            const result = await response.json();

            if (result.success) {
                this.displayTrackingResult(result.data);
            } else {
                this.displayTrackingError(result.message);
            }
        } catch (error) {
            console.error('Error tracking order:', error);
            this.displayTrackingError('Có lỗi xảy ra khi tra cứu đơn hàng');
        } finally {
            trackBtn.disabled = false;
            spinner.style.display = 'none';
        }
    }

    displayTrackingResult(orderData) {
        const resultDiv = document.getElementById('trackingResult');
        const emptyDiv = document.getElementById('trackingEmpty');
        
        const statusMap = {
            'CHO_XAC_NHAN': { text: 'Đã nhận đơn', color: 'warning', step: 1 },
            'DA_XAC_NHAN': { text: 'Đang xử lý', color: 'info', step: 2 },
            'DANG_GIAO': { text: 'Đang giao', color: 'primary', step: 3 },
            'DA_GIAO': { text: 'Hoàn tất', color: 'success', step: 4 },
            'DA_HUY': { text: 'Đã hủy', color: 'danger', step: 0 },
            // Legacy support
            'PENDING': { text: 'Đã nhận đơn', color: 'warning', step: 1 },
            'CONFIRMED': { text: 'Đang xử lý', color: 'info', step: 2 },
            'SHIPPED': { text: 'Đang giao', color: 'primary', step: 3 },
            'DELIVERED': { text: 'Hoàn tất', color: 'success', step: 4 },
            'CANCELLED': { text: 'Đã hủy', color: 'danger', step: 0 }
        };

        const status = statusMap[orderData.status] || { text: orderData.status, color: 'secondary', step: 0 };

        // Timeline steps
        const steps = [
            { key: 'received', text: 'Đã nhận đơn', icon: 'fas fa-check-circle' },
            { key: 'processing', text: 'Đang xử lý', icon: 'fas fa-cog' },
            { key: 'shipping', text: 'Đang giao', icon: 'fas fa-truck' },
            { key: 'delivered', text: 'Hoàn tất', icon: 'fas fa-check-double' }
        ];

        resultDiv.innerHTML = `
            <div class="card">
                <div class="card-body">
                    <h6 class="card-title">Thông tin đơn hàng</h6>
                    <div class="row g-3">
                        <div class="col-6">
                            <strong>Mã đơn hàng:</strong><br>
                            <span class="text-primary">${orderData.orderCode}</span>
                        </div>
                        <div class="col-6">
                            <strong>Trạng thái:</strong><br>
                            <span class="badge bg-${status.color}">${status.text}</span>
                        </div>
                        <div class="col-6">
                            <strong>Ngày đặt:</strong><br>
                            ${new Date(orderData.createdAt).toLocaleDateString('vi-VN')}
                        </div>
                        <div class="col-6">
                            <strong>Tổng tiền:</strong><br>
                            <span class="text-success fw-bold">${orderData.totalAmount.toLocaleString('vi-VN')}đ</span>
                        </div>
                    </div>
                    
                    <!-- Timeline -->
                    <div class="mt-4">
                        <strong>Tiến độ đơn hàng:</strong>
                        <div class="timeline mt-3">
                            ${steps.map((step, index) => `
                                <div class="timeline-item ${index < status.step ? 'completed' : index === status.step ? 'current' : ''}">
                                    <div class="timeline-icon">
                                        <i class="${step.icon}"></i>
                                    </div>
                                    <div class="timeline-content">
                                        <span class="timeline-text">${step.text}</span>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                    
                    <div class="mt-3">
                        <strong>Sản phẩm:</strong>
                        <ul class="list-unstyled mt-2">
                            ${orderData.items.map(item => `
                                <li class="d-flex justify-content-between">
                                    <span>${item.productName}</span>
                                    <span class="text-muted">x${item.quantity}</span>
                                </li>
                            `).join('')}
                        </ul>
                    </div>
                    
                    <div class="mt-3 text-center">
                        <a href="/orders/${orderData.orderCode}" class="btn btn-outline-primary btn-sm">
                            <i class="fas fa-eye me-1"></i>Xem chi tiết
                        </a>
                    </div>
                </div>
            </div>
        `;
        
        resultDiv.style.display = 'block';
        emptyDiv.style.display = 'none';
    }

    displayTrackingError(message) {
        const resultDiv = document.getElementById('trackingResult');
        const emptyDiv = document.getElementById('trackingEmpty');
        
        resultDiv.style.display = 'none';
        emptyDiv.style.display = 'block';
    }

    showToast(message, type = 'info') {
        const toast = document.getElementById('toast');
        const toastBody = document.getElementById('toastBody');
        const toastIcon = toast.querySelector('.toast-header i');

        // Update icon based on type
        const iconMap = {
            success: 'fas fa-check-circle text-success',
            error: 'fas fa-exclamation-circle text-danger',
            warning: 'fas fa-exclamation-triangle text-warning',
            info: 'fas fa-info-circle text-primary'
        };

        toastIcon.className = `${iconMap[type] || iconMap.info} me-2`;
        toastBody.textContent = message;

        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
    }

    // Global functions for inline event handlers
    static openChat() {
        if (window.openChat) {
            window.openChat();
        } else {
            // Fallback
            window.open('https://tawk.to/chat', '_blank');
        }
    }

    static openTrackingModal() {
        const page = new HotlinePage();
        page.openTrackingModal();
    }

    static trackOrder() {
        const page = new HotlinePage();
        page.trackOrder();
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new HotlinePage();
});

// Make functions globally available
window.openTrackingModal = HotlinePage.openTrackingModal;
window.trackOrder = HotlinePage.trackOrder;
