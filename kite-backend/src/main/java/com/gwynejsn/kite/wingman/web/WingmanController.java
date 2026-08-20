package com.gwynejsn.kite.wingman.web;

import com.gwynejsn.kite.wingman.application.WingmanService;
import com.gwynejsn.kite.wingman.application.dto.WingmanRequest;
import com.gwynejsn.kite.wingman.application.dto.WingmanResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/wingman")
@RequiredArgsConstructor
public class WingmanController {

    private final WingmanService wingmanService;


    @PostMapping("/ask")
    public ResponseEntity<WingmanResponse> generateReplies(@RequestBody WingmanRequest request) {
        String resolvedPrompt = buildPrompt(request);

        WingmanResponse replies = wingmanService.generateResponse(resolvedPrompt);

        return ResponseEntity.ok(replies);
    }

    private String buildPrompt(WingmanRequest request) {
        StringBuilder sb = new StringBuilder();
        sb.append("User's Desired Goal: ").append(request.goal()).append("\n\n");
        sb.append("User's Situation: ").append(request.situation()).append("\n\n");
        return sb.toString();
    }
}