package com.gwynejsn.kite.media.application;

import com.gwynejsn.kite.media.application.dto.ConversationMediaResponse;
import com.gwynejsn.kite.media.application.dto.PathResponse;
import com.gwynejsn.kite.media.application.dto.UploadRequest;
import com.gwynejsn.kite.media.application.dto.UploadResponse;
import com.gwynejsn.kite.media.application.exceptions.NoFileFoundException;
import com.gwynejsn.kite.media.application.exceptions.NoFileParameterException;
import com.gwynejsn.kite.media.application.exceptions.UploadingFileIOException;
import com.gwynejsn.kite.shared.domain.ConversationId;
import com.mongodb.client.gridfs.model.GridFSFile;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.gridfs.GridFsOperations;
import org.springframework.data.mongodb.gridfs.GridFsResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class MediaService {
    private final GridFsOperations gridFsOperations;

    @Transactional
    public UploadResponse upload(MultipartFile file, UploadRequest uploadRequest) {
        if (file.isEmpty()) {
            throw new NoFileParameterException("File is empty");
        }
        String rawFilename = file.getOriginalFilename();
        if (uploadRequest.fileName() != null && !uploadRequest.fileName().trim().isEmpty()) {
            rawFilename = uploadRequest.fileName();
        }
        if (rawFilename == null || rawFilename.trim().isEmpty()) {
            rawFilename = "file";
        }
        String filename = generateUniqueFilename(rawFilename);

        Document metadata = new Document();
        metadata.put("filename", filename);
        metadata.put("contentType", file.getContentType());
        metadata.put("size", file.getSize());
        metadata.put("mimeType", file.getContentType());
        metadata.put("uploader", uploadRequest.uploaderId());
        metadata.put("conversationId", uploadRequest.conversationId());
        metadata.put("uploadedAt", Instant.now());
        metadata.put("mediaType", uploadRequest.mediaType().toString());
        try {
            gridFsOperations.store(file.getInputStream(), filename, file.getContentType(), metadata);
            log.info("Media uploaded successfully with filename: {}", filename);
        } catch (IOException e) {
            log.error("Failed to store file", e);
            throw new UploadingFileIOException("Failed to store file");
        }
        return UploadResponse.builder().path(getMediaPath(filename)).build();
    }

    private String generateUniqueFilename(String originalFilename) {
        String baseName = originalFilename;
        String extension = "";

        int dotIndex = originalFilename.lastIndexOf('.');
        if (dotIndex > 0) {
            baseName = originalFilename.substring(0, dotIndex);
            extension = originalFilename.substring(dotIndex);
        }

        String candidateFilename = originalFilename;
        int counter = 1;

        while (gridFsOperations.find(Query.query(Criteria.where("filename").is(candidateFilename))).first() != null) {
            candidateFilename = baseName + " (" + counter + ")" + extension;
            counter++;
        }

        return candidateFilename;
    }

    private String getMediaPath(String filename) {
        return ServletUriComponentsBuilder.fromCurrentContextPath() // http://localhost:8080/context-path
                .path("/media/download/")
                .path(filename)
                .toUriString(); // Returns http://localhost:8080/context-path/media/filename
    }


    /**
     * returns the list of path for all the media,
     * then the client will call it as they need
     * @param conversationId
     * @return
     */
    public ConversationMediaResponse getAllMediaInConversation(ConversationId conversationId) {
        String conversationIdStr = conversationId != null ? conversationId.id().toString() : null;
        Criteria query = Criteria.where("metadata.conversationId").is(conversationIdStr);
        List<PathResponse> mediaList = new ArrayList<>();
        gridFsOperations.find(
                Query.query(query)
        ).forEach(
                media -> {
                    log.info("Media found: {}", media);
                    mediaList.add(
                            PathResponse
                                    .builder()
                                    .path(getMediaPath(media.getFilename()))
                                    .build()
                    );
                }
        );
        return ConversationMediaResponse
                .builder()
                .conversationId(conversationIdStr)
                .media(mediaList)
                .build();
    }

    public GridFsResource getMedia(String filename) {
        Criteria query = Criteria.where("filename").is(filename);
        GridFSFile gridFsFile = gridFsOperations.find(Query.query(query)).first();

        if (gridFsFile == null) {
            throw new NoFileFoundException(filename);
        }

        return gridFsOperations.getResource(gridFsFile);
    }
}
