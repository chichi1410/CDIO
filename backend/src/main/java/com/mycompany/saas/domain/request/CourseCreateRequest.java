package com.mycompany.saas.domain.request;

import java.math.BigDecimal;

import com.mycompany.saas.domain.CourseLevel;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CourseCreateRequest {

    @NotBlank(message = "Tiêu đề khóa học không được để trống")
    @Size(max = 255, message = "Tiêu đề khóa học tối đa 255 ký tự")
    private String title;

    @Size(max = 500, message = "Tiêu đề phụ tối đa 500 ký tự")
    private String subtitle;

    private String description;

    @NotNull(message = "Mã danh mục không được để trống")
    private Long categoryId;

    @NotNull(message = "Giá gốc không được để trống")
    @DecimalMin(value = "0.0", inclusive = true, message = "Giá gốc phải lớn hơn hoặc bằng 0")
    private BigDecimal originalPrice = BigDecimal.ZERO;

    @DecimalMin(value = "0.0", inclusive = true, message = "Giá khuyến mãi phải lớn hơn hoặc bằng 0")
    private BigDecimal salePrice = BigDecimal.ZERO;

    private CourseLevel level = CourseLevel.TAT_CA;

    private String language = "Tiếng Việt";

    private String thumbnailUrl;

    private String introVideoUrl;
}
