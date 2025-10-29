/**
 * Toast Notification System
 * Hệ thống thông báo toast đẹp và nhất quán
 */

class ToastManager {
    constructor() {
        this.container = null;
        this.init();
    }

    init() {
        // Tạo container cho toast nếu chưa có
        if (!document.getElementById('toast-container')) {
            this.container = document.createElement('div');
            this.container.id = 'toast-container';
            this.container.className = 'toast-container';
            
            // CSS cho toast container
            const style = document.createElement('style');
            style.textContent = `
                .toast-container {
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    z-index: 9999;
                    display: flex;
                    flex-direction: column;
                    gap: 10px;
                }
                
                .toast {
                    min-width: 300px;
                    max-width: 400px;
                    padding: 16px 20px;
                    border-radius: 8px;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    font-size: 14px;
                    font-weight: 500;
                    line-height: 1.4;
                    opacity: 0;
                    transform: translateX(100%);
                    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                    backdrop-filter: blur(10px);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                }
                
                .toast.show {
                    opacity: 1;
                    transform: translateX(0);
                }
                
                .toast.success {
                    background: linear-gradient(135deg, #10b981, #059669);
                    color: white;
                }
                
                .toast.error {
                    background: linear-gradient(135deg, #ef4444, #dc2626);
                    color: white;
                }
                
                .toast.warning {
                    background: linear-gradient(135deg, #f59e0b, #d97706);
                    color: white;
                }
                
                .toast.info {
                    background: linear-gradient(135deg, #3b82f6, #2563eb);
                    color: white;
                }
                
                .toast-icon {
                    font-size: 20px;
                    flex-shrink: 0;
                }
                
                .toast-content {
                    flex: 1;
                }
                
                .toast-close {
                    background: none;
                    border: none;
                    color: inherit;
                    font-size: 18px;
                    cursor: pointer;
                    padding: 0;
                    width: 24px;
                    height: 24px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border-radius: 50%;
                    transition: background-color 0.2s;
                    opacity: 0.7;
                }
                
                .toast-close:hover {
                    background-color: rgba(255, 255, 255, 0.2);
                    opacity: 1;
                }
                
                @media (max-width: 768px) {
                    .toast-container {
                        top: 10px;
                        right: 10px;
                        left: 10px;
                    }
                    
                    .toast {
                        min-width: auto;
                        max-width: none;
                    }
                }
            `;
            
            document.head.appendChild(style);
            document.body.appendChild(this.container);
        } else {
            this.container = document.getElementById('toast-container');
        }
    }

    show(message, type = 'info', duration = 4000) {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        // Icons cho từng loại toast
        const icons = {
            success: '✓',
            error: '✕',
            warning: '⚠',
            info: 'ℹ'
        };
        
        toast.innerHTML = `
            <div class="toast-icon">${icons[type] || icons.info}</div>
            <div class="toast-content">${message}</div>
            <button class="toast-close" onclick="toastManager.close(this.parentElement)">×</button>
        `;
        
        this.container.appendChild(toast);
        
        // Trigger animation
        setTimeout(() => {
            toast.classList.add('show');
        }, 10);
        
        // Auto remove
        if (duration > 0) {
            setTimeout(() => {
                this.close(toast);
            }, duration);
        }
        
        return toast;
    }

    close(toast) {
        toast.classList.remove('show');
        setTimeout(() => {
            if (toast.parentElement) {
                toast.parentElement.removeChild(toast);
            }
        }, 300);
    }

    success(message, duration = 4000) {
        return this.show(message, 'success', duration);
    }

    error(message, duration = 5000) {
        return this.show(message, 'error', duration);
    }

    warning(message, duration = 4000) {
        return this.show(message, 'warning', duration);
    }

    info(message, duration = 4000) {
        return this.show(message, 'info', duration);
    }

    // Convenience methods cho các thông báo phổ biến
    addedToCart(productName = 'sản phẩm') {
        return this.success(`Đã thêm ${productName} vào giỏ hàng! 🛒`);
    }

    removedFromCart(productName = 'sản phẩm') {
        return this.info(`Đã xóa ${productName} khỏi giỏ hàng`);
    }

    orderPlaced() {
        return this.success('Đặt hàng thành công! Cảm ơn bạn đã mua sắm 🎉');
    }

    loginSuccess() {
        return this.success('Đăng nhập thành công! 👋');
    }

    loginError() {
        return this.error('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin');
    }

    registrationSuccess() {
        return this.success('Đăng ký thành công! Vui lòng kiểm tra email để xác nhận 📧');
    }
}

// Khởi tạo toast manager global
window.toastManager = new ToastManager();

// Export functions để sử dụng dễ dàng
window.showToast = (message, type = 'info', duration = 4000) => {
    return toastManager.show(message, type, duration);
};

window.showSuccess = (message, duration = 4000) => {
    return toastManager.success(message, duration);
};

window.showError = (message, duration = 5000) => {
    return toastManager.error(message, duration);
};

window.showWarning = (message, duration = 4000) => {
    return toastManager.warning(message, duration);
};

window.showInfo = (message, duration = 4000) => {
    return toastManager.info(message, duration);
};
