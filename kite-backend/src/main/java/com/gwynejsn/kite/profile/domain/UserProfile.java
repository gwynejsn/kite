package com.gwynejsn.kite.profile.domain;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Gender;
import com.gwynejsn.kite.shared.enums.PreferredTheme;
import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.UUID;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "user_profiles")
public class UserProfile {

    @Id
    private UserProfileId id;
    private UserId userId;
    private String firstName;
    private String lastName;
    private String username;
    private String profileImageLink;
    private String bio;
    private Gender gender;
    private PreferredTheme preferredTheme;
}