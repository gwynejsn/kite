package com.gwynejsn.kite.presence.web;

import com.gwynejsn.kite.presence.application.UserPresenceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/presence")
@RequiredArgsConstructor
@Slf4j
public class UserPresenceController {
    private final UserPresenceService userPresenceService;

}
