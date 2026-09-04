package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.application.AuthService;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.infrastructure.exceptions.InvalidTokenException;
import com.gwynejsn.kite.shared.enums.Role;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.HandlerExceptionResolver;

import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.io.IOException;
import java.util.*;

@Component
@Slf4j
public class JwtFilter extends OncePerRequestFilter {

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER_PREFIX = "Bearer ";
    private final JwtService jwtService;
    private final HandlerExceptionResolver resolver;
    private final AuthService authService;

    // didn't use requiredArgs here because using lombok with qualifier has some problems
    public JwtFilter(@Qualifier("handlerExceptionResolver") HandlerExceptionResolver resolver, JwtService jwtService, AuthService authService) {
        this.resolver = resolver;
        this.jwtService = jwtService;
        this.authService = authService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String authorizationHeader = request.getHeader(AUTHORIZATION_HEADER);
        if (authorizationHeader == null || !authorizationHeader.startsWith(BEARER_PREFIX)) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authorizationHeader.substring(BEARER_PREFIX.length());

        try {
            Claims claims = jwtService.validateToken(token);
            if (claims != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UsernamePasswordAuthenticationToken authToken =
                        authService.getUsernamePasswordAuthenticationToken(claims);

                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        } catch (InvalidTokenException | JwtException | IllegalArgumentException ex) {
            resolver.resolveException(request, response, null, ex);
            return;
        }

        filterChain.doFilter(request, response);
    }
}