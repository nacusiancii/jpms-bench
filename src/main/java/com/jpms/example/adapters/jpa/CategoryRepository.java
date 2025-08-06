package com.jpms.example.adapters.jpa;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.jpms.example.domain.model.Category;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    Optional<Category> findBySlug(String slug);
}