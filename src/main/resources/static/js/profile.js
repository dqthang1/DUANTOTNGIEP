// Profile Page JavaScript functionality
class ProfileManager {
    constructor() {
        this.provinces = [];
        this.districts = [];
        this.wards = [];
        this.currentAddressId = null;
        this.init();
    }

    init() {
        this.loadProvinces();
        this.setupEventListeners();
        this.setupFormValidation();
    }

    setupEventListeners() {
        // Avatar file preview
        const avatarFileInput = document.getElementById('avatarFile');
        if (avatarFileInput) {
            avatarFileInput.addEventListener('change', this.previewAvatarFile.bind(this));
        }

        // Province change
        const provinceSelect = document.getElementById('province');
        if (provinceSelect) {
            provinceSelect.addEventListener('change', this.onProvinceChange.bind(this));
        }

        // District change
        const districtSelect = document.getElementById('district');
        if (districtSelect) {
            districtSelect.addEventListener('change', this.onDistrictChange.bind(this));
        }

        // Form validation
        const forms = document.querySelectorAll('form');
        forms.forEach(form => {
            form.addEventListener('submit', this.validateForm.bind(this));
        });

        // Password confirmation
        const newPasswordInput = document.querySelector('input[name="newPassword"]');
        const confirmPasswordInput = document.querySelector('input[name="confirmPassword"]');
        if (newPasswordInput && confirmPasswordInput) {
            confirmPasswordInput.addEventListener('input', this.validatePasswordMatch.bind(this));
        }
    }

    setupFormValidation() {
        // Real-time validation for required fields
        const requiredInputs = document.querySelectorAll('input[required], select[required], textarea[required]');
        requiredInputs.forEach(input => {
            input.addEventListener('blur', this.validateField.bind(this));
            input.addEventListener('input', this.clearFieldError.bind(this));
        });
    }

    async loadProvinces() {
        try {
            const response = await fetch('/api/v2/address/provinces');
            if (response.ok) {
                this.provinces = await response.json();
                this.populateProvinces();
            }
        } catch (error) {
            console.error('Error loading provinces:', error);
        }
    }

    populateProvinces() {
        const provinceSelect = document.getElementById('province');
        if (!provinceSelect) return;

        provinceSelect.innerHTML = '<option value="">Chọn tỉnh/thành phố</option>';
        this.provinces.forEach(province => {
            const option = document.createElement('option');
            option.value = province.id;
            option.textContent = province.name;
            provinceSelect.appendChild(option);
        });
    }

    async onProvinceChange(event) {
        const provinceId = event.target.value;
        const districtSelect = document.getElementById('district');
        const wardSelect = document.getElementById('ward');

        // Clear districts and wards
        districtSelect.innerHTML = '<option value="">Chọn quận/huyện</option>';
        wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';

        if (!provinceId) return;

        try {
            const response = await fetch(`/api/v2/address/districts/${provinceId}`);
            if (response.ok) {
                this.districts = await response.json();
                this.districts.forEach(district => {
                    const option = document.createElement('option');
                    option.value = district.id;
                    option.textContent = district.name;
                    districtSelect.appendChild(option);
                });
            }
        } catch (error) {
            console.error('Error loading districts:', error);
        }
    }

    async onDistrictChange(event) {
        const districtId = event.target.value;
        const wardSelect = document.getElementById('ward');

        // Clear wards
        wardSelect.innerHTML = '<option value="">Chọn phường/xã</option>';

        if (!districtId) return;

        try {
            const response = await fetch(`/api/v2/address/wards/${districtId}`);
            if (response.ok) {
                this.wards = await response.json();
                this.wards.forEach(ward => {
                    const option = document.createElement('option');
                    option.value = ward.id;
                    option.textContent = ward.name;
                    wardSelect.appendChild(option);
                });
            }
        } catch (error) {
            console.error('Error loading wards:', error);
        }
    }

    previewAvatarFile(event) {
        const file = event.target.files[0];
        const preview = document.getElementById('avatarPreview');
        const placeholder = document.getElementById('avatarPlaceholder');
        const updateBtn = document.getElementById('updateAvatarBtn');
        
        if (file) {
            // Validate file type
            if (!file.type.startsWith('image/')) {
                this.showToast('Chỉ được chọn file ảnh', 'error');
                event.target.value = '';
                return;
            }
            
            // Validate file size (5MB)
            if (file.size > 5 * 1024 * 1024) {
                this.showToast('File ảnh không được vượt quá 5MB', 'error');
                event.target.value = '';
                return;
            }
            
            // Create preview
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.style.display = 'block';
                placeholder.style.display = 'none';
                updateBtn.disabled = false;
            };
            reader.readAsDataURL(file);
        } else {
            preview.style.display = 'none';
            placeholder.style.display = 'block';
            updateBtn.disabled = true;
        }
    }

    async updateAvatar() {
        const avatarFile = document.getElementById('avatarFile').files[0];
        const updateBtn = document.getElementById('updateAvatarBtn');
        const spinner = updateBtn.querySelector('.spinner-border');
        
        if (!avatarFile) {
            this.showToast('Vui lòng chọn file ảnh', 'error');
            return;
        }

        // Show loading state
        updateBtn.disabled = true;
        spinner.style.display = 'inline-block';

        try {
            const formData = new FormData();
            formData.append('avatarFile', avatarFile);

            const response = await fetch('/profile/api/avatar', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();
            
            if (result.success) {
                // Update avatar in the page
                const avatarImg = document.getElementById('avatarImg');
                if (avatarImg) {
                    avatarImg.src = result.avatarPath;
                }
                
                // Close modal and reset form
                const modal = bootstrap.Modal.getInstance(document.getElementById('avatarModal'));
                modal.hide();
                this.resetAvatarForm();
                
                this.showToast('Cập nhật avatar thành công!', 'success');
            } else {
                this.showToast(result.message || 'Có lỗi xảy ra', 'error');
            }
        } catch (error) {
            console.error('Error updating avatar:', error);
            this.showToast('Có lỗi xảy ra khi cập nhật avatar', 'error');
        } finally {
            // Hide loading state
            updateBtn.disabled = false;
            spinner.style.display = 'none';
        }
    }

    resetAvatarForm() {
        const form = document.getElementById('avatarForm');
        const preview = document.getElementById('avatarPreview');
        const placeholder = document.getElementById('avatarPlaceholder');
        const updateBtn = document.getElementById('updateAvatarBtn');
        
        form.reset();
        preview.style.display = 'none';
        placeholder.style.display = 'block';
        updateBtn.disabled = true;
    }

    async saveAddress() {
        const form = document.getElementById('addressForm');
        if (!this.validateAddressForm()) {
            return;
        }

        const formData = new FormData();
        formData.append('hoTenNhan', document.getElementById('recipientName').value);
        formData.append('soDienThoai', document.getElementById('recipientPhone').value);
        formData.append('diaChi', document.getElementById('addressDetail').value);
        formData.append('quanHuyen', document.getElementById('district').selectedOptions[0]?.textContent || '');
        formData.append('tinhThanh', document.getElementById('province').selectedOptions[0]?.textContent || '');
        formData.append('phuongXa', document.getElementById('ward').selectedOptions[0]?.textContent || '');
        formData.append('macDinh', document.getElementById('setDefault').checked);

        try {
            const response = await fetch('/api/addresses', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();
            
            if (result.success) {
                // Close modal
                const modal = bootstrap.Modal.getInstance(document.getElementById('addressModal'));
                modal.hide();
                
                // Reset form
                form.reset();
                this.clearAddressForm();
                
                this.showToast('Thêm địa chỉ thành công!', 'success');
                
                // Reload page to show new address
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            } else {
                this.showToast(result.message || 'Có lỗi xảy ra', 'error');
            }
        } catch (error) {
            console.error('Error saving address:', error);
            this.showToast('Có lỗi xảy ra khi thêm địa chỉ', 'error');
        }
    }

    async editAddress(addressId) {
        this.currentAddressId = addressId;
        
        try {
            const response = await fetch(`/api/addresses/${addressId}`);
            if (response.ok) {
                const address = await response.json();
                this.populateAddressForm(address);
                
                // Show modal
                const modal = new bootstrap.Modal(document.getElementById('addressModal'));
                modal.show();
            }
        } catch (error) {
            console.error('Error loading address:', error);
            this.showToast('Có lỗi xảy ra khi tải địa chỉ', 'error');
        }
    }

    async deleteAddress(addressId) {
        if (!confirm('Bạn có chắc chắn muốn xóa địa chỉ này?')) {
            return;
        }

        try {
            const response = await fetch(`/api/addresses/${addressId}`, {
                method: 'DELETE'
            });

            const result = await response.json();
            
            if (result.success) {
                this.showToast('Xóa địa chỉ thành công!', 'success');
                
                // Reload page to update address list
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            } else {
                this.showToast(result.message || 'Có lỗi xảy ra', 'error');
            }
        } catch (error) {
            console.error('Error deleting address:', error);
            this.showToast('Có lỗi xảy ra khi xóa địa chỉ', 'error');
        }
    }

    async deleteAccount() {
        const password = document.getElementById('deletePassword').value;
        
        if (!password) {
            this.showToast('Vui lòng nhập mật khẩu', 'error');
            return;
        }

        if (!confirm('Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác!')) {
            return;
        }

        try {
            const response = await fetch('/profile/api/delete-account', {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `password=${encodeURIComponent(password)}`
            });

            const result = await response.json();
            
            if (result.success) {
                this.showToast('Tài khoản đã được xóa thành công', 'success');
                
                // Redirect to home page after 2 seconds
                setTimeout(() => {
                    window.location.href = '/';
                }, 2000);
            } else {
                this.showToast(result.message || 'Có lỗi xảy ra', 'error');
            }
        } catch (error) {
            console.error('Error deleting account:', error);
            this.showToast('Có lỗi xảy ra khi xóa tài khoản', 'error');
        }
    }

    validateAddressForm() {
        const requiredFields = [
            'recipientName',
            'recipientPhone', 
            'addressDetail',
            'province',
            'district',
            'ward'
        ];

        let isValid = true;

        requiredFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (!field.value.trim()) {
                this.showFieldError(field, 'Trường này là bắt buộc');
                isValid = false;
            } else {
                this.clearFieldError({ target: field });
            }
        });

        // Validate phone number
        const phoneField = document.getElementById('recipientPhone');
        if (phoneField.value && !this.isValidPhoneNumber(phoneField.value)) {
            this.showFieldError(phoneField, 'Số điện thoại không hợp lệ');
            isValid = false;
        }

        return isValid;
    }

    validateForm(event) {
        const form = event.target;
        const requiredFields = form.querySelectorAll('input[required], select[required], textarea[required]');
        
        let isValid = true;

        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                this.showFieldError(field, 'Trường này là bắt buộc');
                isValid = false;
            }
        });

        if (!isValid) {
            event.preventDefault();
        }
    }

    validateField(event) {
        const field = event.target;
        if (field.hasAttribute('required') && !field.value.trim()) {
            this.showFieldError(field, 'Trường này là bắt buộc');
        } else {
            this.clearFieldError(event);
        }
    }

    validatePasswordMatch(event) {
        const newPassword = document.querySelector('input[name="newPassword"]').value;
        const confirmPassword = event.target.value;

        if (confirmPassword && newPassword !== confirmPassword) {
            this.showFieldError(event.target, 'Mật khẩu không khớp');
        } else {
            this.clearFieldError(event);
        }
    }

    showFieldError(field, message) {
        field.classList.add('is-invalid');
        field.classList.remove('is-valid');
        
        let feedback = field.parentNode.querySelector('.invalid-feedback');
        if (!feedback) {
            feedback = document.createElement('div');
            feedback.className = 'invalid-feedback';
            field.parentNode.appendChild(feedback);
        }
        feedback.textContent = message;
    }

    clearFieldError(event) {
        const field = event.target;
        field.classList.remove('is-invalid');
        field.classList.add('is-valid');
        
        const feedback = field.parentNode.querySelector('.invalid-feedback');
        if (feedback) {
            feedback.remove();
        }
    }

    clearAddressForm() {
        document.getElementById('province').innerHTML = '<option value="">Chọn tỉnh/thành phố</option>';
        document.getElementById('district').innerHTML = '<option value="">Chọn quận/huyện</option>';
        document.getElementById('ward').innerHTML = '<option value="">Chọn phường/xã</option>';
        this.populateProvinces();
    }

    populateAddressForm(address) {
        document.getElementById('recipientName').value = address.tenNguoiNhan || '';
        document.getElementById('recipientPhone').value = address.soDienThoai || '';
        document.getElementById('addressDetail').value = address.diaChiChiTiet || '';
        document.getElementById('setDefault').checked = address.laDiaChiMacDinh || false;
        
        // Note: Province/District/Ward selection would need to be implemented
        // based on the address data structure
    }

    isValidPhoneNumber(phone) {
        const phoneRegex = /^[+0-9][0-9+]{7,19}$/;
        return phoneRegex.test(phone);
    }

    showToast(message, type = 'info') {
        // Use existing toast functionality if available
        if (typeof showToast === 'function') {
            showToast(message, type);
        } else {
            // Fallback to alert
            alert(message);
        }
    }
}

// Global functions for inline event handlers
function updateAvatar() {
    if (window.profileManager) {
        window.profileManager.updateAvatar();
    }
}

function saveAddress() {
    if (window.profileManager) {
        window.profileManager.saveAddress();
    }
}

function editAddress(addressId) {
    if (window.profileManager) {
        window.profileManager.editAddress(addressId);
    }
}

function deleteAddress(addressId) {
    if (window.profileManager) {
        window.profileManager.deleteAddress(addressId);
    }
}

function deleteAccount() {
    if (window.profileManager) {
        window.profileManager.deleteAccount();
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    window.profileManager = new ProfileManager();
});
