package com.gwynejsn.kite;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;


class ApplicationTests {

    @Test
    void writeDocumentationSnippets() {

        ApplicationModules.of(KiteBackendApplication.class).verify();
    }
}
