package com.gwynejsn.kite.profile.application;

import com.gwynejsn.kite.profile.application.dto.UpdateUserProfileRequest;
import com.gwynejsn.kite.profile.application.dto.UserProfileResponse;
import com.gwynejsn.kite.profile.application.exceptions.UserProfileNotFoundException;
import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.profile.infrastructure.UserProfileRepo;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;
import static com.gwynejsn.kite.profile.infrastructure.UserProfileMapper.INSTANCE;

@Service
@Slf4j
public class UserProfileService {
    private final UserProfileRepo userProfileRepo;

    public UserProfileService(UserProfileRepo userProfileRepo) {
        this.userProfileRepo = userProfileRepo;
    }

    public UserProfileResponse getUserProfile(UserId userId, AuthenticatedUser userDetails) {
        boolean isAdmin = userDetails.getAuthorities().stream()
                .anyMatch(auth -> auth.getAuthority().equals(Role.ADMIN.name()));

        UserId userToGet = userDetails.getUserId();

        if (userId != null && isAdmin) {
            userToGet = userId;
        }

        log.debug("Get user profile for {}", userToGet);

        UserProfile userProfileFound = userProfileRepo
                .findUserProfileByUserId(userToGet)
                .orElseThrow(() -> new UserProfileNotFoundException("User " + userId + " not found"));

        return INSTANCE.toUserProfileResponse(userProfileFound);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public List<UserProfileResponse> getUserProfiles() {
        return userProfileRepo
                .findAll()
                .stream()
                .map(INSTANCE::toUserProfileResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public UserProfileResponse updateUserProfile(UpdateUserProfileRequest newUserProfile, AuthenticatedUser userDetails) {
        UserProfile userProfileFound = userProfileRepo
                .findUserProfileByUserId(userDetails.getUserId())
                .orElseThrow(() -> new UserProfileNotFoundException("User " + userDetails.getUserId() + " not found"));
        INSTANCE.updateProfileFromDto(newUserProfile, userProfileFound);
        userProfileRepo.save(userProfileFound);
        return INSTANCE.toUserProfileResponse(userProfileFound);
    }
}
