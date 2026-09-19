package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.infrastructure.CustomUserDetails;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserDetailsServiceImpTest {

    @Mock
    private UserRepo userRepo;

    @InjectMocks
    private UserDetailsServiceImp userDetailsService;

    @Test
    @DisplayName("""
            GIVEN: User with matching email exists in repository
            WHEN: loadUserByUsername is called
            THEN: CustomUserDetails representing the user is returned
            """)
    void loadUserByUsername_success() {
        String email = "alice@example.com";
        User user = User.builder()
                .id(new UserId(UUID.randomUUID()))
                .email(email)
                .password("encoded-pass")
                .build();

        when(userRepo.findUserByEmail(email)).thenReturn(Optional.of(user));

        UserDetails userDetails = userDetailsService.loadUserByUsername(email);

        assertThat(userDetails).isInstanceOf(CustomUserDetails.class);
        assertThat(userDetails.getUsername()).isEqualTo(email);
        assertThat(userDetails.getPassword()).isEqualTo("encoded-pass");
    }

    @Test
    @DisplayName("""
            GIVEN: User with matching email does not exist
            WHEN: loadUserByUsername is called
            THEN: UsernameNotFoundException is thrown
            """)
    void loadUserByUsername_notFound() {
        String email = "missing@example.com";
        when(userRepo.findUserByEmail(email)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userDetailsService.loadUserByUsername(email))
                .isInstanceOf(UsernameNotFoundException.class)
                .hasMessage(email);
    }
}
