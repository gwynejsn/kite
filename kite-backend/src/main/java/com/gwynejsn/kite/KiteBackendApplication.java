package com.gwynejsn.kite;

import io.flamingock.api.annotations.EnableFlamingock;
import io.flamingock.api.annotations.Stage;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableFlamingock(
        stages = {
                @Stage(name = "mongodb-kite", location = "com.gwynejsn.kite.changes")
        }
)
@SpringBootApplication
public class KiteBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(KiteBackendApplication.class, args);
    }

}
