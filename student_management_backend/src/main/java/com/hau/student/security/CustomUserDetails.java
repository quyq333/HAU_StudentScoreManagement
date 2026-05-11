package com.hau.student.security;

import com.hau.student.entity.Student;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@AllArgsConstructor
@Getter
public class CustomUserDetails implements UserDetails {

    private String maSV;
    private String password;
    private Collection<? extends GrantedAuthority> authorities;

    public static CustomUserDetails create(Student student) {
        return new CustomUserDetails(
                student.getMaSV(),
                student.getMatKhau(),
                Collections.singletonList(new SimpleGrantedAuthority(student.getRole()))
        );
    }

    @Override
    public String getUsername() {
        return maSV;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
