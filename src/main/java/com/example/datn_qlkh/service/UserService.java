package com.example.datn_qlkh.service;

import com.example.datn_qlkh.entity.NguoiDung;
import com.example.datn_qlkh.dto.RegistrationDto;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

public interface UserService {
    NguoiDung register(RegistrationDto dto) throws IllegalArgumentException;

    void processGoogleLogin(Map<String, Object> attributes);

    NguoiDung findByEmail(String email);

    void updateUserInfo(String email, NguoiDung updatedUser);

    void changePassword(String email, String oldPassword, String newPassword, String confirmPassword);

    String updateAvatar(String email, MultipartFile avatar, String avatarUrl) throws IOException;

    void setInitialPassword(String email, String newPassword, String confirmPassword);

}
