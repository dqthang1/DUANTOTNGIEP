package com.example.datn_qlkh.service;

import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserRequest;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserService;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class GoogleOAuth2UserService extends OidcUserService {

    private final UserService userService;

    public GoogleOAuth2UserService(UserService userService) {
        this.userService = userService;
    }

    @Override
    public OidcUser loadUser(OidcUserRequest userRequest) throws OAuth2AuthenticationException {
        // Lấy OidcUser bằng cách gọi super (có ID token + user info)
        OidcUser oidcUser = super.loadUser(userRequest);

        // Attributes chứa email, name, picture...
        Map<String, Object> attributes = oidcUser.getAttributes();

        // Gọi service để lưu user nếu cần
        userService.processGoogleLogin(attributes);

        return oidcUser;
    }
}

