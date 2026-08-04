package com.gwynejsn.kite;

import io.flamingock.api.annotations.EnableFlamingock;
import io.flamingock.api.annotations.Stage;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableFlamingock(
        stages = {
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.security.changes"),
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.profile.changes"),
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.conversation.changes"),
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.social.changes"),
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.presence.changes"),
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.media.changes"),
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.notification.changes")
        }
)
@SpringBootApplication
public class KiteBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(KiteBackendApplication.class, args);
    }

}
