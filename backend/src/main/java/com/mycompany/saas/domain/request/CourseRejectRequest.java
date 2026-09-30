package com.mycompany.saas.domain.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CourseRejectRequest {

    @NotBlank(message = "Lý do từ chối không được để trống")
    private String reason;
}
