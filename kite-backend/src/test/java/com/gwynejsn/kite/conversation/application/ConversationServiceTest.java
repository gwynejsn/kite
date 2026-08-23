package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.application.dto.CreateGroupConversationRequest;
import com.gwynejsn.kite.conversation.application.exceptions.ConversationAlreadyExistsException;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.infrastructure.ConversationRepo;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.security.api.UserKeyServiceApi;
import com.gwynejsn.kite.security.api.UserServiceApi;
import com.gwynejsn.kite.shared.domain.UserId;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

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

    @InjectMocks
    private ConversationService conversationService;

    private UserId creatorId;
    private UserId otherMemberId;

    @BeforeEach
    void setUp() {
        creatorId = new UserId(UUID.randomUUID().toString());
        otherMemberId = new UserId(UUID.randomUUID().toString());
    }

    @Test
    @DisplayName("Should create group conversation successfully and include creator as member and admin")
    void createGroupConversation_success() {
        // Arrange
        String groupName = "Dev Team";
        CreateGroupConversationRequest request = new CreateGroupConversationRequest(
                List.of(otherMemberId.id().toString()),
                groupName,
                "photo.png",
                List.of(),
                Map.of()
        );

        when(conversationRepo.existsByName(groupName)).thenReturn(false);
        when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of(
                creatorId.id().toString(), "key1",
                otherMemberId.id().toString(), "key2"
        ));

        // Act
        ConversationResponse response = conversationService.createGroupConversation(request, creatorId);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.name()).isEqualTo(groupName);
        assertThat(response.type()).isEqualTo(ConversationType.GROUP);
        assertThat(response.memberIds()).contains(creatorId.id().toString(), otherMemberId.id().toString());
        assertThat(response.adminIds()).contains(creatorId.id().toString());
        assertThat(response.memberPublicKeys()).containsEntry(creatorId.id().toString(), "key1");

        verify(userService).usersExist(argThat(set -> set.contains(creatorId) && set.contains(otherMemberId)));
        
        ArgumentCaptor<Conversation> captor = ArgumentCaptor.forClass(Conversation.class);
        verify(conversationRepo).save(captor.capture());
        Conversation saved = captor.getValue();
        assertThat(saved.getName()).isEqualTo(groupName);
        assertThat(saved.getMemberIds()).contains(creatorId, otherMemberId);
    }

    @Test
    @DisplayName("Should throw ConversationAlreadyExistsException when group name exists")
    void createGroupConversation_duplicateName() {
        // Arrange
        String groupName = "Dev Team";
        CreateGroupConversationRequest request = new CreateGroupConversationRequest(
                List.of(otherMemberId.id().toString()),
                groupName,
                "photo.png",
                List.of(),
                Map.of()
        );

        when(conversationRepo.existsByName(groupName)).thenReturn(true);

        // Act & Assert
        assertThatThrownBy(() -> conversationService.createGroupConversation(request, creatorId))
                .isInstanceOf(ConversationAlreadyExistsException.class)
                .hasMessage(groupName);

        verify(conversationRepo, never()).save(any());
    }

    @Test
    @DisplayName("Should handle null member list gracefully and ensure creator is member and admin")
    void createGroupConversation_nullMembersAndAdmins() {
        // Arrange
        String groupName = "Solo Group";
        CreateGroupConversationRequest request = new CreateGroupConversationRequest(
                null,
                groupName,
                null,
                null,
                null
        );

        when(conversationRepo.existsByName(groupName)).thenReturn(false);
        when(userKeyService.getPublicKeysByUserIds(any())).thenReturn(Map.of(
                creatorId.id().toString(), "key1"
        ));

        // Act
        ConversationResponse response = conversationService.createGroupConversation(request, creatorId);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.memberIds()).containsExactly(creatorId.id().toString());
        assertThat(response.adminIds()).containsExactly(creatorId.id().toString());
    }
}
