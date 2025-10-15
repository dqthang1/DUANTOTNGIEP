package com.example.datn_qlkh.service;

import com.example.datn_qlkh.entity.NguoiDung;
import com.example.datn_qlkh.dto.RegistrationDto;
import com.example.datn_qlkh.entity.VaiTro;
import com.example.datn_qlkh.repository.VaiTroRepository;
import com.example.datn_qlkh.repository.NguoiDungRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {

    private final NguoiDungRepository nguoiDungRepo;
    private final VaiTroRepository vaiTroRepo;
    private final PasswordEncoder passwordEncoder;

    public UserServiceImpl(NguoiDungRepository nguoiDungRepo,
                           VaiTroRepository vaiTroRepo,
                           PasswordEncoder passwordEncoder) {
        this.nguoiDungRepo = nguoiDungRepo;
        this.vaiTroRepo = vaiTroRepo;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public NguoiDung register(RegistrationDto dto) {
        if (nguoiDungRepo.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Email đã được sử dụng");
        }
        if (!dto.getPassword().equals(dto.getConfirmPassword())) {
            throw new IllegalArgumentException("Mật khẩu và xác nhận mật khẩu không khớp");
        }

        NguoiDung u = new NguoiDung();
        u.setTen(dto.getTen());
        u.setEmail(dto.getEmail());
        u.setMatKhau(passwordEncoder.encode(dto.getPassword()));
        u.setSoDienThoai(dto.getSoDienThoai());
        u.setGioiTinh(dto.getGioiTinh());
        u.setNgaySinh(dto.getNgaySinh());
        u.setThanhPho(dto.getThanhPho());
        u.setDiaChi(dto.getDiaChi());
        u.setHoatDong(true);
        u.setBiKhoa(false);
        u.setNgayTao(LocalDateTime.now());
        u.setNgayCapNhat(LocalDateTime.now());
        u.setProvider("local");

        VaiTro vt = vaiTroRepo.findByTenVaiTro("Khách hàng")
                .orElseGet(() -> {
                    VaiTro created = new VaiTro();
                    created.setTenVaiTro("Khách hàng");
                    created.setMoTa("Khách hàng mặc định");
                    return vaiTroRepo.save(created);
                });
        u.setVaiTro(vt);

        return nguoiDungRepo.save(u);
    }

    @Override
    @Transactional
    public void processGoogleLogin(Map<String, Object> attributes) {
        String email = (String) attributes.get("email");
        String name = (String) attributes.get("name");
        String picture = (String) attributes.get("picture");
        if (email == null) return;

        NguoiDung existing = nguoiDungRepo.findByEmail(email).orElse(null);
        if (existing != null) return;

        NguoiDung newUser = new NguoiDung();
        newUser.setEmail(email);
        newUser.setTen(name);
        newUser.setProvider("google");
        newUser.setHoatDong(true);
        newUser.setBiKhoa(false);
        newUser.setNgayTao(LocalDateTime.now());
        newUser.setNgayCapNhat(LocalDateTime.now());
        newUser.setMatKhau(null); // ❗ để null, phân biệt user Google chưa có mật khẩu
        newUser.setAvatarUrl(picture);

        VaiTro vt = vaiTroRepo.findByTenVaiTro("Khách hàng")
                .orElseGet(() -> {
                    VaiTro created = new VaiTro();
                    created.setTenVaiTro("Khách hàng");
                    created.setMoTa("Khách hàng mặc định");
                    return vaiTroRepo.save(created);
                });
        newUser.setVaiTro(vt);

        nguoiDungRepo.save(newUser);
    }

    @Override
    public NguoiDung findByEmail(String email) {
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với email: " + email));
    }

    @Override
    @Transactional
    public void updateUserInfo(String email, NguoiDung updatedUser) {
        NguoiDung existing = findByEmail(email);

        existing.setTen(updatedUser.getTen());
        existing.setSoDienThoai(updatedUser.getSoDienThoai());
        existing.setGioiTinh(updatedUser.getGioiTinh());
        existing.setNgaySinh(updatedUser.getNgaySinh());
        existing.setThanhPho(updatedUser.getThanhPho());
        existing.setDiaChi(updatedUser.getDiaChi());
        existing.setNgayCapNhat(LocalDateTime.now());

        nguoiDungRepo.save(existing);
    }

    @Override
    @Transactional
    public void changePassword(String email, String oldPassword, String newPassword, String confirmPassword) {
        NguoiDung user = findByEmail(email);

        if (user.getMatKhau() == null ||
            user.getMatKhau().isBlank() ||
            user.getMatKhau().equalsIgnoreCase("GOOGLE_OAUTH_USER")) {
            throw new IllegalArgumentException("Tài khoản Google chưa có mật khẩu, vui lòng đặt mật khẩu trước.");
        }

        if (!passwordEncoder.matches(oldPassword, user.getMatKhau())) {
            throw new IllegalArgumentException("Mật khẩu cũ không chính xác.");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu mới và xác nhận mật khẩu không khớp.");
        }

        if (newPassword.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu mới phải có ít nhất 6 ký tự.");
        }

        user.setMatKhau(passwordEncoder.encode(newPassword));
        user.setNgayCapNhat(LocalDateTime.now());
        nguoiDungRepo.save(user);
    }

    @Override
    @Transactional
    public String updateAvatar(String email, MultipartFile avatar, String avatarUrl) throws IOException {
        NguoiDung user = findByEmail(email);
        String imageUrl;

        String uploadDir = "uploads/avatar/";
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        if (avatar != null && !avatar.isEmpty()) {

            // Kiểm tra định dạng ảnh hợp lệ
            String contentType = avatar.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                throw new IllegalArgumentException("Chỉ được upload file ảnh (jpg, png, webp, ...)");
            }

            String fileName = System.currentTimeMillis() + "_" + avatar.getOriginalFilename();
            Path path = Paths.get(System.getProperty("user.dir"), uploadDir, fileName);
            Files.write(path, avatar.getBytes());
            imageUrl = "/uploads/avatar/" + fileName;
        } else if (avatarUrl != null && !avatarUrl.isBlank()) {
            imageUrl = avatarUrl.trim();
        } else {
            throw new IllegalArgumentException("Vui lòng chọn ảnh hoặc nhập link ảnh.");
        }

        user.setAvatarUrl(imageUrl);
        user.setNgayCapNhat(LocalDateTime.now());
        nguoiDungRepo.save(user);
        return imageUrl;
    }

    // 🟢 Thêm mới: đặt mật khẩu lần đầu cho user Google
    @Override
    @Transactional
    public void setInitialPassword(String email, String newPassword, String confirmPassword) {
        NguoiDung user = findByEmail(email);

        if (user.getMatKhau() != null &&
            !user.getMatKhau().isBlank() &&
            !user.getMatKhau().equalsIgnoreCase("GOOGLE_OAUTH_USER")) {
            throw new IllegalArgumentException("Tài khoản này đã có mật khẩu.");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
        }

        if (newPassword.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu phải có ít nhất 6 ký tự.");
        }

        user.setMatKhau(passwordEncoder.encode(newPassword));
        user.setNgayCapNhat(LocalDateTime.now());
        nguoiDungRepo.save(user);
    }
}
