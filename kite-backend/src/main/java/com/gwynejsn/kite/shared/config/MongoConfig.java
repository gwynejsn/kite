package com.gwynejsn.kite.shared.config;

import com.gwynejsn.kite.shared.domain.DomainId;
import org.bson.UuidRepresentation;
import org.springframework.boot.mongodb.autoconfigure.MongoClientSettingsBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.core.convert.converter.ConverterFactory;
import org.springframework.data.convert.ReadingConverter;
import org.springframework.data.convert.WritingConverter;
import org.springframework.data.mongodb.core.convert.MongoCustomConversions;

import java.util.Arrays;
import java.util.UUID;


@Configuration
public class MongoConfig {

    /**
     * We define here how mongodb will convert
     * a record of DomainId to a string and vice versa.
     * What is used here:
     *      https://docs.spring.io/spring-data/mongodb/reference/mongodb/mapping/custom-conversions.html
     * is based on the core type-conversion engine that the base Spring Framework already provides:
     *      https://docs.spring.io/spring-framework/reference/core/validation/convert.html
     */
    @Bean
    public MongoCustomConversions mongoCustomConversions() {
        return new MongoCustomConversions(Arrays.asList(
                new DomainIdWritingConverter(),
                new StringToDomainIdConverterFactory()
        ));
    }

    @WritingConverter
    public class DomainIdWritingConverter implements Converter<DomainId, String> {
        @Override
        public String convert(DomainId source) {
            return source.id().toString();
        }
    }

    @ReadingConverter
    public class StringToDomainIdConverterFactory implements ConverterFactory<String, DomainId> {

        @Override
        public <T extends DomainId> Converter<String, T> getConverter(Class<T> targetType) {
            return source -> {
                try {
                    UUID uuid = UUID.fromString(source);
                    return targetType.getConstructor(UUID.class).newInstance(uuid);
                } catch (Exception e) {
                    throw new IllegalArgumentException("Failed to convert " + source + " to " + targetType.getSimpleName(), e);
                }
            };
        }
    }


    @Bean
    public MongoClientSettingsBuilderCustomizer uuidCustomizer() {
        return builder -> builder.uuidRepresentation(UuidRepresentation.STANDARD);
    }
}
