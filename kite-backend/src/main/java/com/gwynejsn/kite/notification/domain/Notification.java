package com.gwynejsn.kite.notification.domain;

import com.gwynejsn.kite.notification.domain.enums.NotificationType;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "notifications")
public class Notification {

    @Id
    private NotificationId id;
    private UserId recipientId;
    private UserId actorId;
    private NotificationType type;
    private String title;
    private String content;
    private String targetUrl;
    private boolean read;
    private Instant createdAt;
}
