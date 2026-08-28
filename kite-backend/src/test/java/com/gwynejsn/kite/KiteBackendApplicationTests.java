package com.gwynejsn.kite;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
    "SECRET_KEY=default_secret_key_for_testing_purposes_only_1234567890",
    "GEMINI_KEY=demo_key"
})
class KiteBackendApplicationTests {

    @Test
    void contextLoads() {
    }

}
