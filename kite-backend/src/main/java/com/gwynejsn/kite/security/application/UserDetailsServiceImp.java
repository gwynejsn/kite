package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.application.dto.CreateUserResponse;
import com.gwynejsn.kite.security.application.dto.LoginUserResponse;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.security.infrastructure.CustomUserDetails;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserDetailsServiceImp implements UserDetailsService {
    private UserRepo userRepo;

    public UserDetailsServiceImp(UserRepo userRepo) {
        this.userRepo = userRepo;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Optional<User> user = userRepo.findUserByEmail(email);
        if (user.isPresent()) {
            return CustomUserDetails.builder().user(user.get()).build();
        } else throw new UsernameNotFoundException(email);
    }
}
