package com.gwynejsn.kite.social.domain;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.social.domain.enums.RelationStatus;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRelationRepository extends MongoRepository<UserRelation, RelationId> {

    @Query("{ '$or': [ { 'requesterId': ?0, 'addresseeId': ?1 }, { 'requesterId': ?1, 'addresseeId': ?0 } ] }")
    Optional<UserRelation> findRelationBetween(UserId userA, UserId userB);

    @Query("{ '$or': [ { 'requesterId': ?0 }, { 'addresseeId': ?0 } ] }")
    List<UserRelation> findAllRelationsForUser(UserId userId);

    @Query("{ '$or': [ { 'requesterId': ?0, 'status': ?1 }, { 'addresseeId': ?0, 'status': ?1 } ] }")
    List<UserRelation> findAllRelationsByUserIdAndStatus(UserId userId, RelationStatus status);

    List<UserRelation> findByAddresseeIdAndStatus(UserId addresseeId, RelationStatus status);

    List<UserRelation> findByRequesterIdAndStatus(UserId requesterId, RelationStatus status);
}
