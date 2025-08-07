package com.jpms.example.domain.port;

import java.util.List;
import java.util.Optional;

import com.jpms.example.domain.model.Category;
import com.jpms.example.domain.model.Product;

public interface ProductService {

    Product create(Product product);

    Optional<Product> getById(Long id);

    Optional<Product> getBySku(String sku);

    List<Product> listAll();

    List<Product> listByCategorySlug(String slug);

    Product update(Long id, Product updated);

    void delete(Long id);

    Category createCategory(Category category);

    List<Category> listCategories();
}