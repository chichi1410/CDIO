package com.mycompany.saas.service.impl;

import java.util.List;

import com.mycompany.saas.domain.response.CategoryResponse;
import com.mycompany.saas.repository.CategoryRepository;
import com.mycompany.saas.service.CategoryService;
import com.mycompany.saas.util.error.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    public List<CategoryResponse> getAllActiveCategories() {
        return categoryRepository.findByActiveTrueOrderByCreatedAtAsc()
                .stream()
                .map(CategoryResponse::fromEntity)
                .toList();
    }

    @Override
    public CategoryResponse getCategoryById(Long id) {
        return categoryRepository.findById(id)
                .map(CategoryResponse::fromEntity)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy danh mục với ID: " + id));
    }
}
