package com.gwynejsn.kite.conversation.infrastructure;

import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.shared.domain.ConversationId;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.config.MongoConfig;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.mongodb.test.autoconfigure.DataMongoTest;
import org.springframework.context.annotation.Import;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataMongoTest
@Import(MongoConfig.class)
class ConversationRepoTest {

    @Autowired
    private ConversationRepo repository;

    private final List<UUID> createdIds = new ArrayList<>();
    private UserId userA;
    private UserId userB;
    private UserId userC;

    @BeforeEach
    void setUp() {
        createdIds.clear();
        userA = new UserId(UUID.randomUUID());
        userB = new UserId(UUID.randomUUID());
        userC = new UserId(UUID.randomUUID());
    }

    @AfterEach
    void tearDown() {
        if (!createdIds.isEmpty()) {
            repository.deleteAllById(createdIds);
        }
    }

    @Test
    @DisplayName("""
            GIVEN: Direct conversation exists between userA and userB
            WHEN: findByDirectMembers is called
            THEN: Direct conversation is returned regardless of member order
            AND: no exception is thrown
            """)
    void findByDirectMembers_success() {
        Conversation directConvAB = Conversation.builder()
                .id(new ConversationId())
                .type(ConversationType.DIRECT)
                .memberIds(Set.of(userA, userB))
                .disabled(false)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        // we added groupConvAB to check if it will get the group or direct
        Conversation groupConvAB = Conversation.builder()
                .id(new ConversationId())
                .type(ConversationType.GROUP)
                .name("Group Chat")
                .memberIds(Set.of(userA, userB, userC))
                .disabled(false)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        repository.saveAll(List.of(directConvAB, groupConvAB));
        createdIds.add(directConvAB.getId().id());
        createdIds.add(groupConvAB.getId().id());

        Optional<Conversation> found = repository.findByDirectMembers(userA, userB);

        assertThat(found).isPresent();
        assertThat(found.get().getId()).isEqualTo(directConvAB.getId());
        assertThat(found.get().getType()).isEqualTo(ConversationType.DIRECT);

        // reverse argument order should also match
        Optional<Conversation> foundReverse = repository.findByDirectMembers(userB, userA);

        assertThat(foundReverse).isPresent();
        assertThat(foundReverse.get().getId()).isEqualTo(directConvAB.getId());
    }

    @Test
    @DisplayName("""
            GIVEN: Conversations exist with different members
            WHEN: findMyConversations is called for userA
            THEN: All conversations containing userA are returned
            AND: no exception is thrown
            """)
    void findMyConversations_success() {
        Conversation directConvAB = Conversation.builder()
                .id(new ConversationId())
                .type(ConversationType.DIRECT)
                .memberIds(Set.of(userA, userB))
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        Conversation groupConvAC = Conversation.builder()
                .id(new ConversationId())
                .type(ConversationType.GROUP)
                .name("Project Team")
                .memberIds(Set.of(userA, userC))
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        // this should not be returned since it does not have userA
        Conversation directConvBC = Conversation.builder()
                .id(new ConversationId())
                .type(ConversationType.DIRECT)
                .memberIds(Set.of(userB, userC))
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        repository.saveAll(List.of(directConvAB, groupConvAC, directConvBC));
        createdIds.add(directConvAB.getId().id());
        createdIds.add(groupConvAC.getId().id());
        createdIds.add(directConvBC.getId().id());

        Optional<List<Conversation>> userAConvs = repository.findMyConversations(userA);

        assertThat(userAConvs).isPresent();
        assertThat(userAConvs.get()).extracting("id")
                .contains(directConvAB.getId(), groupConvAC.getId());
    }
}
