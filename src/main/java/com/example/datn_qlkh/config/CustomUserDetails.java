package com.example.datn_qlkh.config;

import com.example.datn_qlkh.entity.NguoiDung;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.Collection;
import java.util.Collections;

public class CustomUserDetails implements UserDetails {

    private final NguoiDung user;

    public CustomUserDetails(NguoiDung user) {
        this.user = user;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        if (user.getVaiTro() != null) {
            return Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getVaiTro().getTenVaiTro()));
        }
        return Collections.emptyList();
    }

    @Override
    public String getPassword() {
        return user.getMatKhau();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return !user.getBiKhoa(); }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return user.getHoatDong(); }

    public NguoiDung getUser() { return user; }
}

