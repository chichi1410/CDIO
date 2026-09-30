package com.mycompany.saas.service;

import java.util.List;

import com.mycompany.saas.domain.response.CategoryResponse;

public interface CategoryService {

    List<CategoryResponse> getAllActiveCategories();

    CategoryResponse getCategoryById(Long id);
}
