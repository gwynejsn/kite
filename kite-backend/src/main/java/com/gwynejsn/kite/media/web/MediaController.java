package com.gwynejsn.kite.media.web;

import com.gwynejsn.kite.media.application.MediaService;
import com.gwynejsn.kite.media.application.dto.ConversationMediaResponse;
import com.gwynejsn.kite.media.application.dto.UploadRequest;
import com.gwynejsn.kite.media.application.dto.UploadResponse;
import com.gwynejsn.kite.shared.domain.ConversationId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.data.mongodb.gridfs.GridFsResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import org.springframework.http.MediaTypeFactory;

import java.io.IOException;

@RestController
@RequestMapping("/media")
@Slf4j
@RequiredArgsConstructor
public class MediaController {
    private final MediaService mediaService;

    @PostMapping("/upload")
    public ResponseEntity<UploadResponse> uploadMedia(
            @RequestPart("file") MultipartFile file,
            @RequestPart("uploadRequest") UploadRequest uploadRequest
    ) {
        log.info("Upload request: {}", uploadRequest);
        log.info("Upload file: {}", file);
        return ResponseEntity.ok(mediaService.upload(file, uploadRequest));
    }

    @GetMapping("/{conversationId}")
    public ResponseEntity<ConversationMediaResponse> allMedia(@PathVariable String conversationId) {
        return ResponseEntity.ok(mediaService.getAllMediaInConversation(new ConversationId(conversationId)));
    }

    @GetMapping("/download/{filename}")
    public ResponseEntity<Resource> downloadMedia(@PathVariable String filename) throws IOException {
        GridFsResource resource = mediaService.getMedia(filename);
        String contentType = resource.getContentType();
        if (contentType == null || contentType.isEmpty() || "application/octet-stream".equals(contentType)) {
            contentType = MediaTypeFactory.getMediaType(filename)
                    .map(Object::toString)
                    .orElse("application/octet-stream");
        }
        return ResponseEntity
                .ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                .header(HttpHeaders.CONTENT_TYPE, contentType)
                .body(resource);
    }
}
