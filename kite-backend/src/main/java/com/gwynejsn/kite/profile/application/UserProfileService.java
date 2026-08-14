package com.gwynejsn.kite.profile.application;

import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.profile.application.dto.UpdateUserProfileRequest;
import com.gwynejsn.kite.profile.application.exceptions.UserProfileNotFoundException;
import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.profile.infrastructure.UserProfileRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

import static com.gwynejsn.kite.profile.infrastructure.UserProfileMapper.INSTANCE;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserProfileService implements UserProfileServiceApi {
    private final UserProfileRepo userProfileRepo;

    public UserProfileResponse getUserProfile(UserId userId) {
        log.debug("Get user profile for {}", userId);

        return userProfileRepo
                .findUserProfileByUserId(userId)
                .map(INSTANCE::toUserProfileResponse)
                .orElseThrow(() -> new UserProfileNotFoundException("User " + userId + " not found"));
    }

    @Override
    public List<UserProfileResponse> getUserProfiles(UserId currentId) {
        return userProfileRepo
                .findAll()
                .stream()
                .map(INSTANCE::toUserProfileResponse)
                .toList();
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

    public void createUserProfile(UserProfile userProfile) {
        userProfileRepo.save(userProfile);
    }

    @Transactional
    public void deleteUserProfile(UserId userId) {
        log.info("Deleting user profile for userId: {}", userId);
        userProfileRepo.deleteUserProfileByUserId(userId);
    }
}
