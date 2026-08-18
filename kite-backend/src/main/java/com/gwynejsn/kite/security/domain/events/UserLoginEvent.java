package com.gwynejsn.kite.security.domain.events;

import com.gwynejsn.kite.shared.domain.UserId;
import lombok.Builder;

@Builder
public record UserLoginEvent (UserId userId)
{ }
