// Enhanced Checkout Manager
class CheckoutManager {
    constructor() {
        this.selectedAddressId = null;
        this.selectedShippingMethod = null;
        this.selectedPaymentMethod = 'COD';
        this.appliedVouchers = [];
        this.orderItems = [];
        this.idempotencyKey = null;
        this.isSubmitting = false;
        
        this.init();
    }

    init() {
        console.log('CheckoutManager initializing...');
        console.log('CheckoutManager version:', Date.now());
        // Use setTimeout to ensure DOM is fully ready
        setTimeout(() => {
            this.loadCartItems();
            this.loadAddresses();
            this.bindEvents();
            console.log('CheckoutManager initialized');
        }, 0);
    }
    
    showLoginMessage() {
        const container = document.getElementById('order-items');
        if (container) {
            container.innerHTML = `
                <div class="alert alert-warning text-center">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <strong>Vui lòng đăng nhập</strong><br>
                    Bạn cần đăng nhập để xem giỏ hàng và thanh toán.
                    <div class="mt-3">
                        <a href="/login" class="btn btn-primary me-2">
                            <i class="fas fa-sign-in-alt me-1"></i>Đăng nhập
                        </a>
                        <a href="/register" class="btn btn-outline-primary">
                            <i class="fas fa-user-plus me-1"></i>Đăng ký
                        </a>
                    </div>
                </div>
            `;
        }
    }

    bindEvents() {
        console.log('Binding events...');
        
        // Address selection
        document.addEventListener('click', (e) => {
            if (e.target.closest('.address-card')) {
                this.selectAddress(e.target.closest('.address-card'));
            }
        });

        // Add address button - with retry logic
        this.bindAddAddressButton();

        // Shipping method selection
        document.addEventListener('click', (e) => {
            if (e.target.closest('.shipping-method-card')) {
                this.selectShippingMethod(e.target.closest('.shipping-method-card'));
            }
        });

        // Payment method selection
        document.addEventListener('click', (e) => {
            if (e.target.closest('.payment-method-card')) {
                this.selectPaymentMethod(e.target.closest('.payment-method-card'));
            }
        });

        // Voucher application
        this.bindVoucherButton();

        // Place order
        this.bindPlaceOrderButton();

        // Terms checkbox
        this.bindTermsCheckbox();
    }

    bindAddAddressButton(retryCount = 0) {
        console.log(`Attempting to bind add address button - attempt ${retryCount + 1}`);
        const addAddressBtn = document.getElementById('add-address-btn');
        console.log('Button element:', addAddressBtn);
        
        if (addAddressBtn) {
            console.log('Add address button found:', addAddressBtn);
            console.log('Button classes:', addAddressBtn.className);
            console.log('Button text:', addAddressBtn.textContent);
            
            // Remove any existing event listeners to prevent duplicates
            if (this.handleAddAddressClick) {
                console.log('Removing existing event listener');
                addAddressBtn.removeEventListener('click', this.handleAddAddressClick);
            }
            
            this.handleAddAddressClick = (e) => {
                console.log('Add address button clicked!');
                e.preventDefault();
                e.stopPropagation();
                console.log('About to show address modal');
                this.showAddressModal();
            };
            
            addAddressBtn.addEventListener('click', this.handleAddAddressClick);
            console.log('Event listener added successfully');
            
            // Test if button is clickable
            console.log('Button disabled:', addAddressBtn.disabled);
            console.log('Button style display:', addAddressBtn.style.display);
            
        } else if (retryCount < 10) {
            console.warn(`Add address button not found - retry ${retryCount + 1}/10`);
            setTimeout(() => this.bindAddAddressButton(retryCount + 1), 100);
        } else {
            console.error('Add address button not found after 10 retries');
        }
    }

    bindVoucherButton(retryCount = 0) {
        const applyVoucherBtn = document.getElementById('apply-voucher-btn');
        if (applyVoucherBtn) {
            // Remove any existing event listeners to prevent duplicates
            if (this.handleVoucherClick) {
                applyVoucherBtn.removeEventListener('click', this.handleVoucherClick);
            }
            this.handleVoucherClick = () => this.applyVoucher();
            applyVoucherBtn.addEventListener('click', this.handleVoucherClick);
        } else if (retryCount < 10) {
            console.warn(`Apply voucher button not found - retry ${retryCount + 1}/10`);
            setTimeout(() => this.bindVoucherButton(retryCount + 1), 100);
        } else {
            console.error('Apply voucher button not found after 10 retries');
        }
    }

    bindPlaceOrderButton(retryCount = 0) {
        const placeOrderBtn = document.getElementById('place-order-btn');
        if (placeOrderBtn) {
            // Remove any existing event listeners to prevent duplicates
            if (this.handlePlaceOrderClick) {
                placeOrderBtn.removeEventListener('click', this.handlePlaceOrderClick);
            }
            this.handlePlaceOrderClick = () => this.placeOrder();
            placeOrderBtn.addEventListener('click', this.handlePlaceOrderClick);
        } else if (retryCount < 10) {
            console.warn(`Place order button not found - retry ${retryCount + 1}/10`);
            setTimeout(() => this.bindPlaceOrderButton(retryCount + 1), 100);
        } else {
            console.error('Place order button not found after 10 retries');
        }
    }

    bindTermsCheckbox(retryCount = 0) {
        const agreeTermsCheckbox = document.getElementById('agree-terms');
        if (agreeTermsCheckbox) {
            // Remove any existing event listeners to prevent duplicates
            if (this.handleTermsChange) {
                agreeTermsCheckbox.removeEventListener('change', this.handleTermsChange);
            }
            this.handleTermsChange = () => this.updatePlaceOrderButton();
            agreeTermsCheckbox.addEventListener('change', this.handleTermsChange);
        } else if (retryCount < 10) {
            console.warn(`Terms checkbox not found - retry ${retryCount + 1}/10`);
            setTimeout(() => this.bindTermsCheckbox(retryCount + 1), 100);
        } else {
            console.error('Terms checkbox not found after 10 retries');
        }
    }

    async loadCartItems() {
        try {
            console.log('Loading cart items...');
            console.log('Current URL:', window.location.href);
            console.log('Document cookie:', document.cookie);
            
            const response = await this.fetchWithTimeout('/api/cart?' + Date.now() + '&v=' + Math.random(), {
                credentials: 'include',
                headers: {
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                    'Cache-Control': 'no-cache',
                    'Pragma': 'no-cache'
                }
            });
            
            console.log('Response status:', response.status);
            console.log('Response headers:', Object.fromEntries(response.headers.entries()));
            
            if (!response.ok) {
                console.error('Cart API response status:', response.status);
                if (response.status === 401) {
                    console.log('User not authenticated, redirecting to login...');
                    window.location.href = '/login';
                    return;
                }
                throw new Error('HTTP ' + response.status);
            }
            
            // Check if response is HTML (login page) instead of JSON
            const contentType = response.headers.get('content-type');
            console.log('Content-Type:', contentType);
            
            if (contentType && contentType.includes('text/html')) {
                console.log('Received HTML response instead of JSON, user not authenticated');
                this.showLoginMessage();
                return;
            }
            
            // Try to get response text first to check if it's HTML
            const responseText = await response.text();
            console.log('Response text preview:', responseText.substring(0, 200));
            
            // Check if response is HTML
            if (responseText.trim().startsWith('<!DOCTYPE html>') || responseText.trim().startsWith('<html')) {
                console.log('Received HTML response instead of JSON, user not authenticated');
                this.showLoginMessage();
                return;
            }
            
            // Try to parse as JSON
            let data;
            try {
                data = JSON.parse(responseText);
                console.log('Cart API response:', data);
            } catch (parseError) {
                console.error('JSON parsing error:', parseError);
                console.log('Response text:', responseText);
                this.showLoginMessage();
                return;
            }

            if (data.success) {
                this.orderItems = data.cartItems || [];
                console.log('Checkout rendering order items:', this.orderItems);
                this.renderOrderItems();
                this.updateOrderSummary();
                console.log('Cart items loaded successfully:', this.orderItems);
            } else {
                console.error('Failed to load cart items:', data.message);
                this.showError('Không thể tải giỏ hàng: ' + (data.message || 'Lỗi không xác định'));
            }
        } catch (error) {
            console.error('Error loading cart items:', error);
            console.error('Error details:', {
                name: error.name,
                message: error.message,
                stack: error.stack
            });
            
            // Check if it's a JSON parsing error (likely HTML response)
            if (error.name === 'SyntaxError' && error.message.includes('JSON')) {
                console.log('JSON parsing error - likely received HTML instead of JSON');
                this.showLoginMessage();
                return;
            }
            
            if (error.message.includes('401')) {
                this.showError('Vui lòng đăng nhập để xem giỏ hàng');
            } else if (error.message.includes('404')) {
                this.showError('API không tìm thấy. Vui lòng kiểm tra kết nối.');
            } else if (error.message.includes('500')) {
                this.showError('Lỗi server. Vui lòng thử lại sau.');
            } else {
                this.showError('Có lỗi xảy ra khi tải giỏ hàng: ' + error.message);
            }
        }
    }

    renderOrderItems() {
        const container = document.getElementById('order-items');
        if (!container) {
            console.warn('Order items container not found');
            return;
        }

        if (this.orderItems.length === 0) {
            container.innerHTML = '<p class="text-muted text-center">Giỏ hàng trống</p>';
            return;
        }

        const itemsHTML = this.orderItems.map(item => {
            console.log('Checkout processing item:', item);
            console.log('Item gia:', item.gia, 'type:', typeof item.gia);
            console.log('Item soLuong:', item.soLuong, 'type:', typeof item.soLuong);
            
            return `
            <div class="order-item">
                <img src="${item.sanPham.anhChinh || '/images/placeholder.jpg'}" 
                         alt="${item.sanPham.ten}" 
                     class="order-item-image"
                     onerror="this.src='/images/placeholder.jpg'">
                <div class="order-item-content">
                    <div class="order-item-name">${item.sanPham.ten}</div>
                    <div class="order-item-variant">
                        ${item.kichThuoc ? `Size: ${item.kichThuoc}` : ''}
                        ${item.mauSac ? ` • Màu: ${item.mauSac}` : ''}
                    </div>
                    <div class="order-item-quantity">Số lượng: ${item.soLuong}</div>
                </div>
                <div class="order-item-price">${this.formatCurrency(item.gia * item.soLuong)}</div>
            </div>
        `;
        }).join('');

        container.innerHTML = itemsHTML;
    }

    async loadAddresses() {
        try {
            console.log('Loading addresses...');
            const response = await this.fetchWithTimeout('/api/addresses', {
                credentials: 'include'
            });
            console.log('Addresses response status:', response.status);
            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();
            console.log('Addresses response data:', data);

            if (data.success) {
                console.log('Rendering addresses:', data.addresses);
                this.renderAddresses(data.addresses);
            } else {
                console.error('Failed to load addresses:', data.message);
                this.showError(data.message);
            }
        } catch (error) {
            console.error('Error loading addresses:', error);
            this.showError('Có lỗi xảy ra khi tải địa chỉ');
        }
    }

    renderAddresses(addresses) {
        console.log('renderAddresses called with:', addresses);
        const addressList = document.getElementById('address-list');
        console.log('Address list element:', addressList);
        
        if (!addressList) {
            console.warn('Address list container not found');
            return;
        }
        
        if (addresses.length === 0) {
            console.log('No addresses found, showing empty message');
            addressList.innerHTML = '<p class="text-muted text-center">Chưa có địa chỉ nào</p>';
            return;
        }

        const addressesHTML = addresses.map(address => `
            <div class="address-card ${address.laDiaChiMacDinh ? 'selected' : ''}" 
                 data-address-id="${address.id}">
                ${address.laDiaChiMacDinh ? '<span class="address-default-badge">Mặc định</span>' : ''}
                <div class="address-name">${address.tenNguoiNhan}</div>
                <div class="address-phone">${address.soDienThoai}</div>
                <div class="address-detail">
                    ${address.diaChiChiTiet}, ${address.phuongXa}, ${address.quanHuyen}, ${address.tinhThanh}
                </div>
            </div>
        `).join('');

        addressList.innerHTML = addressesHTML;

        // Auto-select default address
        const defaultAddress = addresses.find(addr => addr.laDiaChiMacDinh);
        if (defaultAddress) {
            this.selectedAddressId = defaultAddress.id;
            this.loadShippingMethods();
        }
    }

    selectAddress(addressCard) {
        // Remove previous selection
        document.querySelectorAll('.address-card').forEach(card => {
            card.classList.remove('selected');
        });

        // Select new address
        addressCard.classList.add('selected');
        this.selectedAddressId = addressCard.dataset.addressId;
        
        console.log('Address selected:', this.selectedAddressId);
        this.loadShippingMethods();
    }

    async loadShippingMethods() {
        if (!this.selectedAddressId) return;

        try {
            console.log('Loading shipping methods for address:', this.selectedAddressId);
            
            // Show shipping section
            const shippingSection = document.getElementById('shipping-section');
            if (shippingSection) {
                shippingSection.style.display = 'block';
            }

            // Calculate shipping fee
            const subtotal = this.calculateSubtotal();
            const response = await this.fetchWithTimeout(`/api/shipping/calculate?addressId=${this.selectedAddressId}&totalAmount=${subtotal}`, {
                credentials: 'include'
            });

            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();

            if (data.success) {
                this.renderShippingMethods(data.methods);
                this.updateShippingFee(data.shippingFee);
                this.updateDeliveryEstimate(data.eta);
            } else {
                console.error('Failed to load shipping methods:', data.message);
            }
        } catch (error) {
            console.error('Error loading shipping methods:', error);
            // Fallback to default shipping methods
            this.renderDefaultShippingMethods();
        }
    }

    renderShippingMethods(methods) {
        const container = document.getElementById('shipping-methods');
        if (!container) {
            console.warn('Shipping methods container not found');
            return;
        }

        const methodsHTML = methods.map(method => `
            <div class="shipping-method-card" data-method-id="${method.id}">
                <div class="shipping-method-icon">
                    <i class="fas fa-truck"></i>
                </div>
                <div class="shipping-method-content">
                    <div class="shipping-method-name">${method.name}</div>
                    <div class="shipping-method-desc">${method.description}</div>
                    <div class="shipping-method-eta">Dự kiến giao: ${method.eta}</div>
                </div>
                <div class="shipping-method-price">${this.formatCurrency(method.fee)}</div>
            </div>
        `).join('');

        container.innerHTML = methodsHTML;
    }

    renderDefaultShippingMethods() {
        const container = document.getElementById('shipping-methods');
        if (!container) {
            console.warn('Shipping methods container not found');
            return;
        }

        const defaultMethods = [
            {
                id: 'fast',
                name: 'Giao hàng nhanh',
                description: 'Giao hàng trong 1-2 ngày làm việc',
                eta: '1-2 ngày',
                fee: 30000
            },
            {
                id: 'standard',
                name: 'Giao hàng tiết kiệm',
                description: 'Giao hàng trong 3-5 ngày làm việc',
                eta: '3-5 ngày',
                fee: 20000
            }
        ];

        this.renderShippingMethods(defaultMethods);
    }

    selectShippingMethod(methodCard) {
        // Remove previous selection
        document.querySelectorAll('.shipping-method-card').forEach(card => {
            card.classList.remove('selected');
        });

        // Select new method
        methodCard.classList.add('selected');
        this.selectedShippingMethod = methodCard.dataset.methodId;
        
        console.log('Shipping method selected:', this.selectedShippingMethod);
        this.updateOrderSummary();
    }

    selectPaymentMethod(paymentCard) {
        // Remove previous selection
        document.querySelectorAll('.payment-method-card').forEach(card => {
            card.classList.remove('selected');
        });

        // Select new method
        paymentCard.classList.add('selected');
        this.selectedPaymentMethod = paymentCard.dataset.method;
        
        // Update radio button
        const radioInput = paymentCard.querySelector('input[type="radio"]');
        if (radioInput) {
            radioInput.checked = true;
        }
        
        console.log('Payment method selected:', this.selectedPaymentMethod);
        this.updatePlaceOrderButton();
    }

    async applyVoucher() {
        const voucherCode = document.getElementById('voucher-code')?.value.trim();
        if (!voucherCode) {
            this.showError('Vui lòng nhập mã giảm giá');
            return;
        }

        // Check if voucher already applied
        if (this.appliedVouchers.some(v => v.code === voucherCode)) {
            this.showError('Mã giảm giá đã được áp dụng');
            return;
        }

        try {
            console.log('Applying voucher:', voucherCode);
            const response = await this.fetchWithTimeout('/api/voucher/apply', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                credentials: 'include',
                body: new URLSearchParams({ code: voucherCode })
            });
            
            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();

            if (data.success) {
                const voucherData = data.voucher;
                const discountAmount = this.calculateVoucherDiscount(voucherData);
                
                this.appliedVouchers.push({
                    code: voucherCode,
                    discount: discountAmount,
                    data: voucherData
                });
                this.renderAppliedVouchers();
                this.updateOrderSummary();
                this.showSuccess('Áp dụng mã giảm giá thành công');
                document.getElementById('voucher-code').value = '';
            } else {
                this.showError(data.message || 'Mã giảm giá không hợp lệ');
            }
        } catch (error) {
            console.error('Error applying voucher:', error);
            this.showError('Có lỗi xảy ra khi áp dụng mã giảm giá');
        }
    }

    calculateVoucherDiscount(voucherData) {
        const subtotal = this.calculateSubtotal();
        const minOrderAmount = voucherData.minOrderAmount || 0;
        
        // Check minimum order amount
        if (subtotal < minOrderAmount) {
            return 0;
        }
        
        let discount = 0;
        if (voucherData.type === 'PERCENTAGE') {
            discount = subtotal * (voucherData.discount / 100);
        } else if (voucherData.type === 'FIXED') {
            discount = voucherData.discount;
        }
        
        // Apply maximum discount limit
        const maxDiscount = voucherData.maxDiscount || discount;
        return Math.min(discount, maxDiscount);
    }

    renderAppliedVouchers() {
        const container = document.getElementById('applied-vouchers');
        if (!container) {
            console.warn('Applied vouchers container not found');
            return;
        }

        if (this.appliedVouchers.length === 0) {
            container.innerHTML = '';
            return;
        }

        const vouchersHTML = this.appliedVouchers.map(voucher => `
            <div class="voucher-badge">
                <span>${voucher.code}</span>
                <span class="voucher-discount">-${this.formatCurrency(voucher.discount)}</span>
                <button class="voucher-remove" onclick="checkoutManager.removeVoucher('${voucher.code}')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `).join('');

        container.innerHTML = vouchersHTML;
    }

    removeVoucher(code) {
        this.appliedVouchers = this.appliedVouchers.filter(v => v.code !== code);
        this.renderAppliedVouchers();
        this.updateOrderSummary();
        this.showSuccess('Đã xóa mã giảm giá');
    }

    calculateSubtotal() {
        return this.orderItems.reduce((total, item) => {
            const gia = Number(item.gia) || 0;
            const soLuong = Number(item.soLuong) || 0;
            console.log('Checkout formatting currency for amount:', gia, 'type:', typeof gia);
            return total + (gia * soLuong);
        }, 0);
    }

    calculateDiscount() {
        return this.appliedVouchers.reduce((total, voucher) => {
            return total + voucher.discount;
        }, 0);
    }

    calculateShippingFee() {
        const subtotal = this.calculateSubtotal();
        // Free shipping for orders >= 499k in HN/HCM
        if (subtotal >= 499000) {
            return 0;
        }
        return 30000; // Default shipping fee
    }

    updateOrderSummary() {
        const subtotal = this.calculateSubtotal();
        const discount = this.calculateDiscount();
        const shippingFee = this.calculateShippingFee();
        const total = subtotal - discount + shippingFee;

        // Update subtotal
        const subtotalElement = document.getElementById('subtotal');
        if (subtotalElement) {
            subtotalElement.textContent = this.formatCurrency(subtotal);
        }

        // Update discount
        const discountRow = document.getElementById('discount-row');
        const discountAmount = document.getElementById('discount-amount');
        if (discountRow && discountAmount) {
            if (discount > 0) {
                discountRow.style.display = 'flex';
                discountAmount.textContent = `-${this.formatCurrency(discount)}`;
            } else {
                discountRow.style.display = 'none';
            }
        }

        // Update shipping fee
        const shippingFeeElement = document.getElementById('shipping-fee');
        if (shippingFeeElement) {
            shippingFeeElement.textContent = this.formatCurrency(shippingFee);
        }

        // Update total
        const totalElement = document.getElementById('total-amount');
        if (totalElement) {
            totalElement.textContent = this.formatCurrency(total);
        }
    }

    updateShippingFee(fee) {
        const shippingFeeElement = document.getElementById('shipping-fee');
        if (shippingFeeElement) {
            shippingFeeElement.textContent = this.formatCurrency(fee);
        }
    }

    updateDeliveryEstimate(eta) {
        const estimateElement = document.getElementById('delivery-estimate');
        const dateElement = document.getElementById('delivery-date');
        
        if (estimateElement && dateElement) {
            estimateElement.style.display = 'block';
            dateElement.textContent = eta;
        }
    }

    updatePlaceOrderButton() {
        const placeOrderBtn = document.getElementById('place-order-btn');
        const agreeTermsCheckbox = document.getElementById('agree-terms');
        
        if (placeOrderBtn && agreeTermsCheckbox) {
            const isEnabled = agreeTermsCheckbox.checked && !this.isSubmitting;
            placeOrderBtn.disabled = !isEnabled;
            
            const btnText = placeOrderBtn.querySelector('.btn-text');
            if (btnText) {
                if (this.selectedPaymentMethod === 'VNPAY') {
                    btnText.textContent = 'Thanh toán & Đặt hàng';
                } else {
                    btnText.textContent = 'Đặt hàng';
                }
            }
        }
    }

    async placeOrder() {
        if (this.isSubmitting) return;

        // Validate form
        if (!this.validateForm()) {
            return;
        }

        this.isSubmitting = true;
        this.updatePlaceOrderButton();
        this.showLoadingState();

        try {
            // Generate idempotency key
            this.idempotencyKey = this.generateIdempotencyKey();
            
            const notesElement = document.getElementById('order-notes');
            const orderData = {
                addressId: this.selectedAddressId,
                paymentMethod: this.selectedPaymentMethod,
                notes: notesElement ? notesElement.value : '',
                idempotencyKey: this.idempotencyKey
            };

            console.log('Placing order with data:', orderData);

            const response = await this.fetchWithTimeout('/api/orders/create', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                credentials: 'include',
                body: new URLSearchParams(orderData)
            });

            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();

            if (data.success) {
                if (this.selectedPaymentMethod === 'VNPAY') {
                    // Redirect to VNPay
                    window.location.href = data.paymentUrl;
                } else {
                    // Redirect to thank you page
                    window.location.href = `/orders/${data.order.id}?success=true`;
                }
            } else {
                this.showError(data.message || 'Có lỗi xảy ra khi đặt hàng');
            }
        } catch (error) {
            console.error('Error placing order:', error);
            this.showError('Có lỗi xảy ra khi đặt hàng');
        } finally {
            this.isSubmitting = false;
            this.hideLoadingState();
            this.updatePlaceOrderButton();
        }
    }

    validateForm() {
        const errors = [];
        
        // Validate address
        if (!this.selectedAddressId) {
            errors.push('Vui lòng chọn địa chỉ giao hàng');
        }

        // Validate shipping method
        if (!this.selectedShippingMethod) {
            errors.push('Vui lòng chọn phương thức vận chuyển');
        }

        // Validate payment method
        if (!this.selectedPaymentMethod) {
            errors.push('Vui lòng chọn phương thức thanh toán');
        }

        // Validate terms agreement
        const agreeTerms = document.getElementById('agree-terms');
        if (agreeTerms && !agreeTerms.checked) {
            errors.push('Vui lòng đồng ý với điều khoản sử dụng');
        }

        // Validate cart items
        if (this.orderItems.length === 0) {
            errors.push('Giỏ hàng trống, vui lòng thêm sản phẩm');
        }

        // Validate order total
        const total = this.calculateSubtotal() - this.calculateDiscount() + this.calculateShippingFee();
        if (total <= 0) {
            errors.push('Tổng tiền đơn hàng không hợp lệ');
        }

        // Show errors if any
        if (errors.length > 0) {
            this.showError(errors.join('<br>'));
            return false;
        }

        return true;
    }

    validateAddressForm() {
        const name = document.getElementById('custom-recipient-name')?.value?.trim();
        const phone = document.getElementById('custom-recipient-phone')?.value?.trim();
        const province = document.getElementById('custom-province')?.value;
        const district = document.getElementById('custom-district')?.value;
        const ward = document.getElementById('custom-ward')?.value;
        const address = document.getElementById('custom-address-detail')?.value?.trim();

        const errors = [];

        if (!name || name.length < 2) {
            errors.push('Họ và tên phải có ít nhất 2 ký tự');
        }

        if (!phone || !this.isValidPhoneNumber(phone)) {
            errors.push('Số điện thoại không hợp lệ');
        }

        if (!province) {
            errors.push('Vui lòng chọn tỉnh/thành phố');
        }

        if (!district) {
            errors.push('Vui lòng chọn quận/huyện');
        }

        if (!ward) {
            errors.push('Vui lòng chọn phường/xã');
        }

        if (!address || address.length < 6) {
            errors.push('Địa chỉ cụ thể phải có ít nhất 6 ký tự');
        }

        if (errors.length > 0) {
            this.showError(errors.join('<br>'));
            return false;
        }

        return true;
    }

    isValidPhoneNumber(phone) {
        // Vietnamese phone number regex
        const phoneRegex = /^(\+84|84|0)[1-9][0-9]{8,9}$/;
        return phoneRegex.test(phone.replace(/\s/g, ''));
    }

    showLoadingState() {
        const placeOrderBtn = document.getElementById('place-order-btn');
        if (placeOrderBtn) {
            const btnText = placeOrderBtn.querySelector('.btn-text');
            const btnLoading = placeOrderBtn.querySelector('.btn-loading');
            if (btnText) btnText.style.display = 'none';
            if (btnLoading) btnLoading.style.display = 'inline';
        }
    }

    hideLoadingState() {
        const placeOrderBtn = document.getElementById('place-order-btn');
        if (placeOrderBtn) {
            const btnText = placeOrderBtn.querySelector('.btn-text');
            const btnLoading = placeOrderBtn.querySelector('.btn-loading');
            if (btnText) btnText.style.display = 'inline';
            if (btnLoading) btnLoading.style.display = 'none';
        }
    }

    generateIdempotencyKey() {
        return 'checkout_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND'
        }).format(amount);
    }

    async fetchWithTimeout(url, options = {}) {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 10000);

        try {
            const response = await fetch(url, {
                ...options,
                signal: controller.signal
            });
            clearTimeout(timeoutId);
            return response;
        } catch (error) {
            clearTimeout(timeoutId);
            throw error;
        }
    }

    showError(message) {
        // Create toast notification
        const toast = document.createElement('div');
        toast.className = 'toast align-items-center text-white bg-danger border-0';
        toast.setAttribute('role', 'alert');
        toast.innerHTML = `
            <div class="d-flex">
                <div class="toast-body">
                    <i class="fas fa-exclamation-circle me-2"></i>${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        `;

        // Add to page
        let toastContainer = document.getElementById('toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.id = 'toast-container';
            toastContainer.className = 'toast-container position-fixed top-0 end-0 p-3';
            toastContainer.style.zIndex = '9999';
            document.body.appendChild(toastContainer);
        }

        toastContainer.appendChild(toast);

        // Show toast
        if (typeof bootstrap !== 'undefined' && bootstrap.Toast) {
            const bsToast = new bootstrap.Toast(toast);
            bsToast.show();

            // Remove after hide
            toast.addEventListener('hidden.bs.toast', () => {
                toast.remove();
            });
        } else {
            // Fallback without Bootstrap
            toast.style.display = 'block';
            setTimeout(() => toast.remove(), 3000);
        }
    }

    showSuccess(message) {
        // Create toast notification
        const toast = document.createElement('div');
        toast.className = 'toast align-items-center text-white bg-success border-0';
        toast.setAttribute('role', 'alert');
        toast.innerHTML = `
            <div class="d-flex">
                <div class="toast-body">
                    <i class="fas fa-check-circle me-2"></i>${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        `;

        // Add to page
        let toastContainer = document.getElementById('toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.id = 'toast-container';
            toastContainer.className = 'toast-container position-fixed top-0 end-0 p-3';
            toastContainer.style.zIndex = '9999';
            document.body.appendChild(toastContainer);
        }

        toastContainer.appendChild(toast);

        // Show toast
        if (typeof bootstrap !== 'undefined' && bootstrap.Toast) {
            const bsToast = new bootstrap.Toast(toast);
            bsToast.show();

            // Remove after hide
            toast.addEventListener('hidden.bs.toast', () => {
                toast.remove();
            });
        } else {
            // Fallback without Bootstrap
            toast.style.display = 'block';
            setTimeout(() => toast.remove(), 3000);
        }
    }

    // Address Modal Methods
    showAddressModal() {
        console.log('Creating custom address modal...');
        
        try {
            // Remove existing modal if any
            const existingModal = document.getElementById('custom-address-modal');
            if (existingModal) {
                console.log('Removing existing modal');
                existingModal.remove();
            }
            
            console.log('Creating modal overlay...');
            // Create modal overlay
            const overlay = document.createElement('div');
            overlay.id = 'custom-address-modal';
            overlay.style.cssText = `
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                width: 100% !important;
                height: 100% !important;
                background-color: rgba(0, 0, 0, 0.5) !important;
                z-index: 99999 !important;
                display: flex !important;
                align-items: center !important;
                justify-content: center !important;
            `;
            
            // Add modal content
            overlay.innerHTML = `
                <div style="background: white; border-radius: 8px; padding: 20px; max-width: 600px; width: 90%; max-height: 80vh; overflow-y: auto; position: relative; z-index: 100000; box-shadow: 0 4px 20px rgba(0,0,0,0.3);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                        <h5 style="margin: 0; color: #333;">Thêm địa chỉ mới</h5>
                        <button type="button" id="close-address-modal" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #666;">&times;</button>
                    </div>
                    <form id="custom-address-form">
                        <div style="margin-bottom: 16px;">
                            <label style="display: block; margin-bottom: 4px; font-weight: 500; color: #333;">Họ và tên người nhận *</label>
                            <input type="text" id="custom-recipient-name" class="form-control" placeholder="Nhập họ và tên" required style="width: 100%; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
                        </div>
                        
                        <div style="margin-bottom: 16px;">
                            <label style="display: block; margin-bottom: 4px; font-weight: 500; color: #333;">Số điện thoại *</label>
                            <input type="tel" id="custom-recipient-phone" class="form-control" placeholder="Nhập số điện thoại" required style="width: 100%; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
                        </div>
                        
                        <div style="margin-bottom: 16px;">
                            <label style="display: block; margin-bottom: 4px; font-weight: 500; color: #333;">Tỉnh/Thành phố *</label>
                            <select id="custom-province" class="form-control" required style="width: 100%; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
                                <option value="">Chọn tỉnh/thành phố</option>
                            </select>
                        </div>
                        
                        <div style="margin-bottom: 16px;">
                            <label style="display: block; margin-bottom: 4px; font-weight: 500; color: #333;">Quận/Huyện *</label>
                            <select id="custom-district" class="form-control" required disabled style="width: 100%; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
                                <option value="">Chọn quận/huyện</option>
                            </select>
                        </div>
                        
                        <div style="margin-bottom: 16px;">
                            <label style="display: block; margin-bottom: 4px; font-weight: 500; color: #333;">Phường/Xã *</label>
                            <select id="custom-ward" class="form-control" required disabled style="width: 100%; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
                                <option value="">Chọn phường/xã</option>
                            </select>
                        </div>
                        
                        <div style="margin-bottom: 16px;">
                            <label style="display: block; margin-bottom: 4px; font-weight: 500; color: #333;">Địa chỉ cụ thể *</label>
                            <textarea id="custom-address-detail" class="form-control" placeholder="Nhập địa chỉ cụ thể (số nhà, tên đường...)" required style="width: 100%; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; min-height: 60px; resize: vertical;"></textarea>
                        </div>
                        
                        <div style="margin-bottom: 20px;">
                            <label style="display: flex; align-items: center; cursor: pointer;">
                                <input type="checkbox" id="custom-set-default" style="margin-right: 8px;">
                                <span style="color: #333;">Đặt làm địa chỉ mặc định</span>
                            </label>
                        </div>
                        
                        <div style="display: flex; gap: 12px; justify-content: flex-end;">
                            <button type="button" id="cancel-address-modal" style="padding: 8px 16px; border: 1px solid #ddd; background: white; border-radius: 4px; cursor: pointer;">Hủy</button>
                            <button type="button" id="save-custom-address" style="padding: 8px 16px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">Lưu địa chỉ</button>
                        </div>
                    </form>
                </div>
            `;
            
            document.body.appendChild(overlay);
            
            console.log('Modal overlay added to body');
            console.log('Modal overlay:', overlay);
            
            // Load provinces
            this.loadProvincesForCustomModal();
            
            // Bind events
            const closeBtn = document.getElementById('close-address-modal');
            const cancelBtn = document.getElementById('cancel-address-modal');
            const saveBtn = document.getElementById('save-custom-address');
            
            console.log('Close button:', closeBtn);
            console.log('Cancel button:', cancelBtn);
            console.log('Save button:', saveBtn);
            
            if (closeBtn) {
                closeBtn.addEventListener('click', () => this.hideAddressModal());
            }
            if (cancelBtn) {
                cancelBtn.addEventListener('click', () => this.hideAddressModal());
            }
            if (saveBtn) {
                saveBtn.addEventListener('click', () => this.saveCustomAddress());
            }
            
            // Close on overlay click
            overlay.addEventListener('click', (e) => {
                if (e.target === overlay) {
                    this.hideAddressModal();
                }
            });
            
            console.log('Custom address modal created and shown');
            
        } catch (error) {
            console.error('Error creating address modal:', error);
            this.showError('Có lỗi xảy ra khi tạo form thêm địa chỉ');
        }
    }
    
    hideAddressModal() {
        const modal = document.getElementById('custom-address-modal');
        if (modal) {
            modal.remove();
            console.log('Custom address modal hidden');
        }
    }
    
    async loadProvincesForCustomModal() {
        try {
            console.log('Loading provinces for custom modal...');
            const response = await this.fetchWithTimeout('/api/v2/address/provinces', {
                credentials: 'include'
            });
            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();

            if (data.success) {
                const select = document.getElementById('custom-province');
                if (select) {
                    select.innerHTML = '<option value="">Chọn tỉnh/thành phố</option>';
                    
                    data.data.forEach(province => {
                        const option = document.createElement('option');
                        option.value = province.code;
                        option.textContent = province.name;
                        select.appendChild(option);
                    });
                    
                    // Bind province change event
                    select.addEventListener('change', (e) => {
                        this.onCustomProvinceChange(e.target.value);
                    });
                    
                    console.log('Provinces loaded for custom modal');
                } else {
                    console.warn('Custom province select not found');
                }
            } else {
                console.error('Failed to load provinces:', data.message);
            }
        } catch (error) {
            console.error('Error loading provinces for custom modal:', error);
        }
    }
    
    async onCustomProvinceChange(provinceCode) {
        const districtSelect = document.getElementById('custom-district');
        const wardSelect = document.getElementById('custom-ward');
        
        // Reset district and ward
        if (districtSelect) {
            districtSelect.innerHTML = '<option value="">Chọn quận/huyện</option>';
            districtSelect.disabled = true;
        }
        if (wardSelect) {
            wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';
            wardSelect.disabled = true;
        }

        if (!provinceCode) return;

        try {
            const response = await this.fetchWithTimeout(`/api/v2/address/districts/${provinceCode}`, {
                credentials: 'include'
            });
            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();

            if (data.success && districtSelect) {
                districtSelect.innerHTML = '<option value="">Chọn quận/huyện</option>';
                data.data.forEach(district => {
                    const option = document.createElement('option');
                    option.value = district.code;
                    option.textContent = district.name;
                    districtSelect.appendChild(option);
                });
                districtSelect.disabled = false;
                
                // Bind district change event
                districtSelect.addEventListener('change', (e) => {
                    this.onCustomDistrictChange(e.target.value);
                });
            }
        } catch (error) {
            console.error('Error loading districts:', error);
        }
    }

    async onCustomDistrictChange(districtCode) {
        const wardSelect = document.getElementById('custom-ward');
        
        // Reset ward
        if (wardSelect) {
            wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';
            wardSelect.disabled = true;
        }

        if (!districtCode) return;

        try {
            const response = await this.fetchWithTimeout(`/api/v2/address/wards/${districtCode}`, {
                credentials: 'include'
            });
            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();

            if (data.success && wardSelect) {
                wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';
                data.data.forEach(ward => {
                    const option = document.createElement('option');
                    option.value = ward.code;
                    option.textContent = ward.name;
                    wardSelect.appendChild(option);
                });
                wardSelect.disabled = false;
            }
        } catch (error) {
            console.error('Error loading wards:', error);
        }
    }

    async saveCustomAddress() {
        console.log('Saving custom address...');
        
        // Validate form first
        if (!this.validateAddressForm()) {
            return;
        }
        
        const provinceSelect = document.getElementById('custom-province');
        const districtSelect = document.getElementById('custom-district');
        const wardSelect = document.getElementById('custom-ward');
        
        const addressData = {
            hoTenNhan: document.getElementById('custom-recipient-name')?.value || '',
            soDienThoai: document.getElementById('custom-recipient-phone')?.value || '',
            diaChi: document.getElementById('custom-address-detail')?.value || '',
            quanHuyen: districtSelect?.options[districtSelect?.selectedIndex]?.textContent || '',
            tinhThanh: provinceSelect?.options[provinceSelect?.selectedIndex]?.textContent || '',
            phuongXa: wardSelect?.options[wardSelect?.selectedIndex]?.textContent || '',
            macDinh: document.getElementById('custom-set-default')?.checked || false
        };
        
        console.log('Custom address data:', addressData);
        
        try {
            const response = await this.fetchWithTimeout('/api/addresses', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                credentials: 'include',
                body: new URLSearchParams(addressData)
            });
            
            if (!response.ok) throw new Error('HTTP ' + response.status);
            const data = await response.json();
            
            if (data.success) {
                this.hideAddressModal();
                this.showSuccess('Địa chỉ đã được lưu thành công');
                this.loadAddresses();
            } else {
                this.showError(data.message || 'Có lỗi xảy ra khi lưu địa chỉ');
            }
        } catch (error) {
            console.error('Error saving custom address:', error);
            this.showError('Có lỗi xảy ra khi lưu địa chỉ');
        }
    }
}

// Initialize checkout manager when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, initializing CheckoutManager...');
    console.log('CheckoutManager script version:', Date.now());
    
    // Check if Bootstrap is available
    if (typeof bootstrap === 'undefined') {
        console.error('Bootstrap is not loaded!');
    } else {
        console.log('Bootstrap is available');
    }
    
    // Check if modal element exists
    const addressModal = document.getElementById('custom-address-modal');
    if (addressModal) {
        console.log('Address modal found:', addressModal);
    } else {
        console.log('Address modal not found (will be created dynamically)');
    }
    
    // Force clear any existing manager
    if (window.checkoutManager) {
        console.log('Clearing existing CheckoutManager');
        window.checkoutManager = null;
    }
    
    window.checkoutManager = new CheckoutManager();
});