package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.application.AuthService;
import com.gwynejsn.kite.security.infrastructure.exceptions.InvalidTokenException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.Nullable;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageDeliveryException;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtService jwtService;
    private final AuthService authService;

    @Override
    public @Nullable Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authorizationHeader = accessor.getFirstNativeHeader("Authorization");

            if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
                String token = authorizationHeader.substring(7);

                try {
                    Claims claims = jwtService.validateToken(token);
                    if (claims != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                        String email = claims.getSubject();
                        String userIdStr = claims.get("userId", String.class);
                        if (userIdStr != null && userIdStr.startsWith("UserId[id=") && userIdStr.endsWith("]")) {
                            userIdStr = userIdStr.substring(10, userIdStr.length() - 1);
                        }
                        UserId userId = userIdStr != null ? new UserId(UUID.fromString(userIdStr)) : null;

                        UsernamePasswordAuthenticationToken authToken =
                                authService.getUsernamePasswordAuthenticationToken(
                                        claims
                                );
                        accessor.setUser(authToken); // similar to putting to securityContextHolder
                    }
                } catch (InvalidTokenException | JwtException ex) {
                    throw new MessageDeliveryException(ex.getMessage());
                }
            } else {
                log.warn("Authorization header is missing from STOMP CONNECT frame");
                throw new MessageDeliveryException("Missing Authorization header");
            }
        }
        return message;
    }
}
