package com.gwynejsn.kite.social.infrastructure;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.social.domain.RelationId;
import com.gwynejsn.kite.social.domain.UserRelation;
import com.gwynejsn.kite.social.domain.UserRelationRepository;
import com.gwynejsn.kite.social.domain.enums.RelationStatus;
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
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataMongoTest
@Import(MongoConfig.class)
class UserRelationRepositoryTest {

    @Autowired
    private UserRelationRepository repository;

    private final List<RelationId> createdIds = new ArrayList<>();
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
            GIVEN: Relation exists between userA and userB
            WHEN: findRelationBetween is called with userA and userB or reverse order
            THEN: Relation is returned successfully
            AND: no exception is thrown
            """)
    void findRelationBetween_success() {
        UserRelation relationAB = UserRelation.builder()
                .id(new RelationId())
                .requesterId(userA)
                .addresseeId(userB)
                .status(RelationStatus.ACCEPTED)
                .blocked(false)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        repository.save(relationAB);
        createdIds.add(relationAB.getId());

        // A -> B
        Optional<UserRelation> foundAB = repository.findRelationBetween(userA, userB);
        assertThat(foundAB).isPresent();
        assertThat(foundAB.get().getRequesterId()).isEqualTo(userA);
        assertThat(foundAB.get().getAddresseeId()).isEqualTo(userB);

        // B -> A (reverse)
        Optional<UserRelation> foundBA = repository.findRelationBetween(userB, userA);
        assertThat(foundBA).isPresent();
        assertThat(foundBA.get().getId()).isEqualTo(relationAB.getId());
    }

    @Test
    @DisplayName("""
            GIVEN: Relations exist for userA as requester or addressee
            WHEN: findAllRelationsForUser is called
            THEN: All relations involving userA are returned
            AND: no exception is thrown
            """)
    void findAllRelationsForUser_success() {
        UserRelation relationAB = UserRelation.builder()
                .id(new RelationId())
                .requesterId(userA)
                .addresseeId(userB)
                .status(RelationStatus.ACCEPTED)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        UserRelation relationCA = UserRelation.builder()
                .id(new RelationId())
                .requesterId(userC)
                .addresseeId(userA)
                .status(RelationStatus.PENDING)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        repository.saveAll(List.of(relationAB, relationCA));
        createdIds.add(relationAB.getId());
        createdIds.add(relationCA.getId());

        List<UserRelation> userARelations = repository.findAllRelationsForUser(userA);

        assertThat(userARelations).extracting("id").contains(relationAB.getId(), relationCA.getId());
    }

    @Test
    @DisplayName("""
            GIVEN: Relations exist with different statuses
            WHEN: findAllRelationsByUserIdAndStatus is called with specific status
            THEN: Only relations matching user and status are returned
            AND: no exception is thrown
            """)
    void findAllRelationsByUserIdAndStatus_success() {
        UserRelation acceptedAB = UserRelation.builder()
                .id(new RelationId())
                .requesterId(userA)
                .addresseeId(userB)
                .status(RelationStatus.ACCEPTED)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        UserRelation pendingCA = UserRelation.builder()
                .id(new RelationId())
                .requesterId(userC)
                .addresseeId(userA)
                .status(RelationStatus.PENDING)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        UserRelation acceptedAC = UserRelation.builder()
                .id(new RelationId())
                .requesterId(userA)
                .addresseeId(userC)
                .status(RelationStatus.ACCEPTED)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        repository.saveAll(List.of(acceptedAB, pendingCA, acceptedAC));
        createdIds.add(acceptedAB.getId());
        createdIds.add(pendingCA.getId());
        createdIds.add(acceptedAC.getId());

        List<UserRelation> acceptedForUserA = repository.findAllRelationsByUserIdAndStatus(userA, RelationStatus.ACCEPTED);

        assertThat(acceptedForUserA).extracting("id").contains(acceptedAB.getId(), acceptedAC.getId());

        List<UserRelation> pendingForUserA = repository.findAllRelationsByUserIdAndStatus(userA, RelationStatus.PENDING);

        assertThat(pendingForUserA).extracting("id").contains(pendingCA.getId());
    }
}
