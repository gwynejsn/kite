package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.application.dto.CreateGroupConversationRequest;
import com.gwynejsn.kite.conversation.application.dto.UpdateGroupConversationInfoRequest;
import com.gwynejsn.kite.conversation.application.exceptions.ConversationAlreadyExistsException;
import com.gwynejsn.kite.conversation.application.exceptions.ConversationNotFoundException;
import com.gwynejsn.kite.conversation.application.exceptions.UserIsNotAMemberException;
import com.gwynejsn.kite.conversation.application.exceptions.UserIsNotAnAdminException;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.infrastructure.ConversationRepo;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.security.api.UserKeyServiceApi;
import com.gwynejsn.kite.security.api.UserServiceApi;
import com.gwynejsn.kite.shared.domain.ConversationId;
import com.gwynejsn.kite.shared.domain.UserId;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.time.Instant;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ConversationServiceTest {

    @Mock
    private ConversationRepo conversationRepo;

    @Mock
    private UserProfileServiceApi userProfileService;

    @Mock
    private UserKeyServiceApi userKeyService;

    @Mock
    private UserServiceApi userService;

    @Mock
    private SimpMessagingTemplate messagingTemplate;

    @InjectMocks
    private ConversationService conversationService;

    @Nested
    @DisplayName("getAllConversations")
    class GetAllConversationsTests {

        @Test
        @DisplayName("""
                GIVEN: User has conversations
                WHEN: getAllConversations is called
                THEN: List of ConversationResponse is returned
                """)
        void getAllConversations_success() {
            UserId currentId = new UserId(UUID.randomUUID());
            UserId otherId = new UserId(UUID.randomUUID());
            ConversationId conversationId = new ConversationId();

            Conversation directConv = Conversation.builder()
                    .id(conversationId)
                    .type(ConversationType.DIRECT)
                    .memberIds(new HashSet<>(Set.of(currentId, otherId)))
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();

            when(conversationRepo.findMyConversations(currentId)).thenReturn(Optional.of(List.of(directConv)));
            when(userKeyService.getPublicKeysByUserIds(directConv.getMemberIds())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(directConv.getMemberIds())).thenReturn(List.of(
                    new UserProfileResponse(
                            otherId.id().toString(),
                            "Bob",
                            "Smith",
                            "bobsmith",
                            "http://avatar.jpg",
                            "Bio",
                            null,
                            null,
                            "key"
                    )
            ));

            List<ConversationResponse> responses = conversationService.getAllConversations(currentId);

            assertThat(responses).hasSize(1);
            assertThat(responses.get(0).id()).isEqualTo(conversationId.id().toString());
            assertThat(responses.get(0).name()).isEqualTo("Bob Smith");
            assertThat(responses.get(0).conversationPhoto()).isEqualTo("http://avatar.jpg");
        }

        @Test
        @DisplayName("""
                GIVEN: User has no conversations
                WHEN: getAllConversations is called
                THEN: An empty list is returned
                """)
        void getAllConversations_empty() {
            UserId currentId = new UserId(UUID.randomUUID());
            when(conversationRepo.findMyConversations(currentId)).thenReturn(Optional.empty());

            List<ConversationResponse> responses = conversationService.getAllConversations(currentId);

            assertThat(responses).isEmpty();
        }
    }

    @Nested
    @DisplayName("validateMember")
    class ValidateMemberTests {

        @Test
        @DisplayName("""
                GIVEN: Conversation exists and user is a member
                WHEN: validateMember is called
                THEN: Conversation is returned
                """)
        void validateMember_success() {
            ConversationId convId = new ConversationId();
            UserId userId = new UserId(UUID.randomUUID());
            Conversation conv = Conversation.builder()
                    .id(convId)
                    .memberIds(Set.of(userId))
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));

            Conversation result = conversationService.validateMember(convId, userId);

            assertThat(result).isEqualTo(conv);
        }

        @Test
        @DisplayName("""
                GIVEN: Conversation does not exist
                WHEN: validateMember is called
                THEN: ConversationNotFoundException is thrown
                """)
        void validateMember_notFound() {
            ConversationId convId = new ConversationId();
            UserId userId = new UserId(UUID.randomUUID());

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> conversationService.validateMember(convId, userId))
                    .isInstanceOf(ConversationNotFoundException.class)
                    .hasMessage(convId.id().toString());
        }

        @Test
        @DisplayName("""
                GIVEN: Conversation exists but user is not a member
                WHEN: validateMember is called
                THEN: UserIsNotAMemberException is thrown
                """)
        void validateMember_notMember() {
            ConversationId convId = new ConversationId();
            UserId userId = new UserId(UUID.randomUUID());
            UserId otherUser = new UserId(UUID.randomUUID());
            Conversation conv = Conversation.builder()
                    .id(convId)
                    .memberIds(Set.of(otherUser))
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));

            assertThatThrownBy(() -> conversationService.validateMember(convId, userId))
                    .isInstanceOf(UserIsNotAMemberException.class)
                    .hasMessage("User is not a member of conversation");
        }
    }

    @Nested
    @DisplayName("updateGroupConversationInfo")
    class UpdateGroupConversationInfoTests {

        @Test
        @DisplayName("""
                GIVEN: Member updates group name and photo
                WHEN: updateGroupConversationInfo is called
                THEN: Conversation is saved with new details and response is returned
                """)
        void updateGroupConversationInfo_success() {
            ConversationId convId = new ConversationId();
            UserId currentId = new UserId(UUID.randomUUID());
            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .name("Old Name")
                    .conversationPhoto("old.png")
                    .memberIds(new HashSet<>(Set.of(currentId)))
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            UpdateGroupConversationInfoRequest request = new UpdateGroupConversationInfoRequest(
                    convId.id().toString(),
                    "New Group Name",
                    "new.png"
            );

            ConversationResponse response = conversationService.updateGroupConversationInfo(request, currentId);

            assertThat(conv.getName()).isEqualTo("New Group Name");
            assertThat(conv.getConversationPhoto()).isEqualTo("new.png");
            verify(conversationRepo).save(conv);
            assertThat(response.name()).isEqualTo("New Group Name");
            assertThat(response.conversationPhoto()).isEqualTo("new.png");
        }
    }

    @Nested
    @DisplayName("initializeConversation")
    class InitializeConversationTests {

        @Test
        @DisplayName("""
                GIVEN: No direct conversation exists between two users
                WHEN: initializeConversation is called
                THEN: A new direct conversation is saved and broadcast is triggered
                """)
        void initializeConversation_newConversation() {
            UserId userA = new UserId(UUID.randomUUID());
            UserId userB = new UserId(UUID.randomUUID());

            when(conversationRepo.findByDirectMembers(userA, userB)).thenReturn(Optional.empty());

            conversationService.initializeConversation(userA, userB);

            ArgumentCaptor<Conversation> captor = ArgumentCaptor.forClass(Conversation.class);
            verify(conversationRepo).save(captor.capture());
            Conversation saved = captor.getValue();
            assertThat(saved.getType()).isEqualTo(ConversationType.DIRECT);
            assertThat(saved.getMemberIds()).containsExactlyInAnyOrder(userA, userB);
        }

        @Test
        @DisplayName("""
                GIVEN: A direct conversation already exists
                WHEN: initializeConversation is called
                THEN: Existing conversation is reused and broadcast is triggered without creating a new one
                """)
        void initializeConversation_existingConversation() {
            UserId userA = new UserId(UUID.randomUUID());
            UserId userB = new UserId(UUID.randomUUID());
            ConversationId convId = new ConversationId();
            Conversation existing = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.DIRECT)
                    .memberIds(Set.of(userA, userB))
                    .build();

            when(conversationRepo.findByDirectMembers(userA, userB)).thenReturn(Optional.of(existing));

            conversationService.initializeConversation(userA, userB);

            verify(conversationRepo, never()).save(existing);
        }
    }

    @Nested
    @DisplayName("broadcastConversationUpdate")
    class BroadcastConversationUpdateTests {

        @Test
        @DisplayName("""
                GIVEN: Conversation exists
                WHEN: broadcastConversationUpdate is called
                THEN: STOMP messages are sent to each member topic
                """)
        void broadcastConversationUpdate_success() {
            ConversationId convId = new ConversationId();
            UserId userA = new UserId(UUID.randomUUID());
            UserId userB = new UserId(UUID.randomUUID());
            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .name("Team")
                    .memberIds(new HashSet<>(Set.of(userA, userB)))
                    .adminIds(new HashSet<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.broadcastConversationUpdate(convId);

            verify(messagingTemplate).convertAndSend(eq("/topic/user." + userA.id() + ".conversations"), any(ConversationResponse.class));
            verify(messagingTemplate).convertAndSend(eq("/topic/user." + userB.id() + ".conversations"), any(ConversationResponse.class));
        }

        @Test
        @DisplayName("""
                GIVEN: messagingTemplate throws an exception
                WHEN: broadcastConversationUpdate is called
                THEN: Exception is caught and handled gracefully without propagation
                """)
        void broadcastConversationUpdate_handlesException() {
            ConversationId convId = new ConversationId();
            when(conversationRepo.findConversationById(convId)).thenThrow(new RuntimeException("Simulated error"));

            conversationService.broadcastConversationUpdate(convId);
            // No exception thrown
        }
    }

    @Nested
    @DisplayName("setDirectConversationDisabled")
    class SetDirectConversationDisabledTests {

        @Test
        @DisplayName("""
                GIVEN: Existing direct conversation
                WHEN: setDirectConversationDisabled is called with true
                THEN: Disabled flag is updated and saved
                """)
        void setDirectConversationDisabled_success() {
            UserId userA = new UserId(UUID.randomUUID());
            UserId userB = new UserId(UUID.randomUUID());
            Conversation conv = Conversation.builder()
                    .id(new ConversationId())
                    .type(ConversationType.DIRECT)
                    .memberIds(new HashSet<>(Set.of(userA, userB)))
                    .disabled(false)
                    .build();

            when(conversationRepo.findByDirectMembers(userA, userB)).thenReturn(Optional.of(conv));

            conversationService.setDirectConversationDisabled(userA, userB, true);

            assertThat(conv.isDisabled()).isTrue();
            verify(conversationRepo).save(conv);
        }
    }

    @Nested
    @DisplayName("createGroupConversation")
    class CreateGroupConversationTests {

        @Test
        @DisplayName("""
                GIVEN: Valid request with distinct members and admins
                WHEN: createGroupConversation is called
                THEN: Group conversation is created, creator is added to members/admins, and saved
                """)
        void createGroupConversation_success() {
            UserId creatorId = new UserId(UUID.randomUUID());
            UserId member1 = new UserId(UUID.randomUUID());
            UserId admin1 = new UserId(UUID.randomUUID());

            CreateGroupConversationRequest request = new CreateGroupConversationRequest(
                    List.of(member1.id().toString()),
                    "Project Team",
                    "photo.png",
                    List.of(admin1.id().toString()),
                    Map.of("key1", "val1")
            );

            when(conversationRepo.existsByName("Project Team")).thenReturn(false);
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            ConversationResponse response = conversationService.createGroupConversation(request, creatorId);

            assertThat(response).isNotNull();
            assertThat(response.name()).isEqualTo("Project Team");

            ArgumentCaptor<Conversation> captor = ArgumentCaptor.forClass(Conversation.class);
            verify(conversationRepo).save(captor.capture());
            Conversation saved = captor.getValue();
            assertThat(saved.getType()).isEqualTo(ConversationType.GROUP);
            assertThat(saved.getMemberIds()).contains(creatorId, member1, admin1);
            assertThat(saved.getAdminIds()).contains(creatorId, admin1);
            verify(userService).usersExist(any());
        }

        @Test
        @DisplayName("""
                GIVEN: Conversation name already exists
                WHEN: createGroupConversation is called
                THEN: ConversationAlreadyExistsException is thrown
                """)
        void createGroupConversation_nameExists() {
            UserId creatorId = new UserId(UUID.randomUUID());
            CreateGroupConversationRequest request = new CreateGroupConversationRequest(
                    List.of(),
                    "Existing Group",
                    null,
                    List.of(),
                    null
            );

            when(conversationRepo.existsByName("Existing Group")).thenReturn(true);

            assertThatThrownBy(() -> conversationService.createGroupConversation(request, creatorId))
                    .isInstanceOf(ConversationAlreadyExistsException.class)
                    .hasMessage("Existing Group");

            verify(conversationRepo, never()).save(any());
        }
    }

    @Nested
    @DisplayName("addMembersToGroup")
    class AddMembersToGroupTests {

        @Test
        @DisplayName("""
                GIVEN: Current user is an admin of the group
                WHEN: addMembersToGroup is called with new members
                THEN: New members and group keys are added and conversation updated
                """)
        void addMembersToGroup_success() {
            ConversationId convId = new ConversationId();
            UserId adminId = new UserId(UUID.randomUUID());
            UserId newMember = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(adminId)))
                    .adminIds(new HashSet<>(Set.of(adminId)))
                    .groupKeyMap(new HashMap<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.addMembersToGroup(
                    convId,
                    List.of(newMember.id().toString()),
                    Map.of("keyA", "secretA"),
                    adminId
            );

            assertThat(conv.getMemberIds()).contains(newMember);
            assertThat(conv.getGroupKeyMap()).containsEntry("keyA", "secretA");
            verify(userService).usersExist(Set.of(newMember));
            verify(conversationRepo).save(conv);
        }

        @Test
        @DisplayName("""
                GIVEN: Current user is not an admin
                WHEN: addMembersToGroup is called
                THEN: UserIsNotAnAdminException is thrown
                """)
        void addMembersToGroup_notAdmin() {
            ConversationId convId = new ConversationId();
            UserId memberId = new UserId(UUID.randomUUID());
            UserId otherAdmin = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(memberId, otherAdmin)))
                    .adminIds(new HashSet<>(Set.of(otherAdmin)))
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));

            assertThatThrownBy(() -> conversationService.addMembersToGroup(convId, List.of(), Map.of(), memberId))
                    .isInstanceOf(UserIsNotAnAdminException.class);
        }
    }

    @Nested
    @DisplayName("kickMemberFromGroup")
    class KickMemberFromGroupTests {

        @Test
        @DisplayName("""
                GIVEN: Admin kicks a member from group
                WHEN: kickMemberFromGroup is called
                THEN: Member is removed from memberIds and adminIds
                """)
        void kickMemberFromGroup_success() {
            ConversationId convId = new ConversationId();
            UserId adminId = new UserId(UUID.randomUUID());
            UserId targetId = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(adminId, targetId)))
                    .adminIds(new HashSet<>(Set.of(adminId, targetId)))
                    .groupKeyMap(new HashMap<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.kickMemberFromGroup(convId, targetId, adminId);

            assertThat(conv.getMemberIds()).doesNotContain(targetId);
            assertThat(conv.getAdminIds()).doesNotContain(targetId);
            verify(conversationRepo).save(conv);
        }

        @Test
        @DisplayName("""
                GIVEN: Admin tries to kick themselves
                WHEN: kickMemberFromGroup is called
                THEN: IllegalArgumentException is thrown
                """)
        void kickMemberFromGroup_cannotKickSelf() {
            ConversationId convId = new ConversationId();
            UserId adminId = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(adminId)))
                    .adminIds(new HashSet<>(Set.of(adminId)))
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));

            assertThatThrownBy(() -> conversationService.kickMemberFromGroup(convId, adminId, adminId))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("Admins cannot do this action to themselves.");
        }
    }

    @Nested
    @DisplayName("leaveGroupConversation")
    class LeaveGroupConversationTests {

        @Test
        @DisplayName("""
                GIVEN: Admin leaves group with remaining members and remaining admin
                WHEN: leaveGroupConversation is called
                THEN: User is removed and updated conversation saved
                """)
        void leaveGroupConversation_success() {
            ConversationId convId = new ConversationId();
            UserId leavingUser = new UserId(UUID.randomUUID());
            UserId remainingAdmin = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(leavingUser, remainingAdmin)))
                    .adminIds(new HashSet<>(Set.of(leavingUser, remainingAdmin)))
                    .groupKeyMap(new HashMap<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.leaveGroupConversation(convId, leavingUser);

            assertThat(conv.getMemberIds()).containsExactly(remainingAdmin);
            assertThat(conv.getAdminIds()).containsExactly(remainingAdmin);
            verify(conversationRepo).save(conv);
        }

        @Test
        @DisplayName("""
                GIVEN: Sole admin leaves group with remaining member
                WHEN: leaveGroupConversation is called
                THEN: Next member is auto-promoted to admin
                """)
        void leaveGroupConversation_autoPromotesAdmin() {
            ConversationId convId = new ConversationId();
            UserId leavingAdmin = new UserId(UUID.randomUUID());
            UserId regularMember = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(leavingAdmin, regularMember)))
                    .adminIds(new HashSet<>(Set.of(leavingAdmin)))
                    .groupKeyMap(new HashMap<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.leaveGroupConversation(convId, leavingAdmin);

            assertThat(conv.getMemberIds()).containsExactly(regularMember);
            assertThat(conv.getAdminIds()).containsExactly(regularMember);
            verify(conversationRepo).save(conv);
        }

        @Test
        @DisplayName("""
                GIVEN: Last remaining member leaves group
                WHEN: leaveGroupConversation is called
                THEN: Conversation is deleted from repo
                """)
        void leaveGroupConversation_lastMemberDeletesConversation() {
            ConversationId convId = new ConversationId();
            UserId lastMember = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(lastMember)))
                    .adminIds(new HashSet<>(Set.of(lastMember)))
                    .groupKeyMap(new HashMap<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.leaveGroupConversation(convId, lastMember);

            verify(conversationRepo).delete(conv);
            verify(conversationRepo, never()).save(conv);
        }

        @Test
        @DisplayName("""
                GIVEN: User tries to leave a direct conversation
                WHEN: leaveGroupConversation is called
                THEN: IllegalArgumentException is thrown
                """)
        void leaveGroupConversation_directConversationThrows() {
            ConversationId convId = new ConversationId();
            UserId user = new UserId(UUID.randomUUID());

            Conversation directConv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.DIRECT)
                    .memberIds(new HashSet<>(Set.of(user)))
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(directConv));

            assertThatThrownBy(() -> conversationService.leaveGroupConversation(convId, user))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("Cannot leave a direct conversation");
        }
    }

    @Nested
    @DisplayName("promoteMember and demoteMember")
    class PromoteAndDemoteMemberTests {

        @Test
        @DisplayName("""
                GIVEN: Admin promotes a member
                WHEN: promoteMember is called
                THEN: Target member is added to adminIds
                """)
        void promoteMember_success() {
            ConversationId convId = new ConversationId();
            UserId adminId = new UserId(UUID.randomUUID());
            UserId memberId = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(adminId, memberId)))
                    .adminIds(new HashSet<>(Set.of(adminId)))
                    .groupKeyMap(new HashMap<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.promoteMember(convId, memberId, adminId);

            assertThat(conv.getAdminIds()).contains(memberId);
            verify(conversationRepo).save(conv);
        }

        @Test
        @DisplayName("""
                GIVEN: Admin demotes a fellow admin
                WHEN: demoteMember is called
                THEN: Target is removed from adminIds
                """)
        void demoteMember_success() {
            ConversationId convId = new ConversationId();
            UserId admin1 = new UserId(UUID.randomUUID());
            UserId admin2 = new UserId(UUID.randomUUID());

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(new HashSet<>(Set.of(admin1, admin2)))
                    .adminIds(new HashSet<>(Set.of(admin1, admin2)))
                    .groupKeyMap(new HashMap<>())
                    .build();

            when(conversationRepo.findConversationById(convId)).thenReturn(Optional.of(conv));
            when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of());
            when(userProfileService.getUserProfilesByUserIds(any())).thenReturn(List.of());

            conversationService.demoteMember(convId, admin2, admin1);

            assertThat(conv.getAdminIds()).doesNotContain(admin2);
            verify(conversationRepo).save(conv);
        }
    }
}
