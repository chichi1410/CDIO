package com.mycompany.saas.domain.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PresignedSignatureRequest {
    private String folder;
    private String uploadPreset;
}
