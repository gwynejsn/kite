package com.gwynejsn.kite.profile.application;

import com.gwynejsn.kite.profile.application.dto.UserProfileResponse;
import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.profile.infrastructure.UserProfileRepo;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import org.springframework.stereotype.Service;

@Service
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

        UserProfile userProfileFound = userProfileRepo.findUserProfileByUserId(userToGet);

        return UserProfileResponse
                .builder()
                .bio(userProfileFound.getBio())
                .firstName(userProfileFound.getFirstName())
                .lastName(userProfileFound.getLastName())
                .username(userProfileFound.getUsername())
                .profileImageLink(userProfileFound.getProfileImageLink())
                .gender(userProfileFound.getGender())
                .preferredTheme(userProfileFound.getPreferredTheme())
                .build();
    }
}
