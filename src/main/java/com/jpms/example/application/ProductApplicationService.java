package com.jpms.example.application;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jpms.example.adapters.jpa.CategoryRepository;
import com.jpms.example.adapters.jpa.ProductRepository;
import com.jpms.example.domain.model.Category;
import com.jpms.example.domain.model.Product;
import com.jpms.example.domain.model.ProductAttribute;
import com.jpms.example.domain.model.ProductVariant;
import com.jpms.example.domain.port.ProductService;

@Service
@Transactional
public class ProductApplicationService implements ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    public ProductApplicationService(ProductRepository productRepository,
                                     CategoryRepository categoryRepository) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
    }

    @Override
    public Product create(Product product) {
        // Ensure bidirectional links for children and categories
        if (product.getVariants() != null) {
            for (ProductVariant v : product.getVariants()) {
                v.setProduct(product);
            }
        }
        if (product.getAttributes() != null) {
            for (ProductAttribute a : product.getAttributes()) {
                a.setProduct(product);
            }
        }
        if (product.getCategories() != null) {
            for (Category c : product.getCategories()) {
                c.getProducts().add(product);
            }
        }
        return productRepository.save(product);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Product> getById(Long id) {
        return productRepository.findById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Product> getBySku(String sku) {
        return productRepository.findBySku(sku);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> listAll() {
        return productRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> listByCategorySlug(String slug) {
        return productRepository.listByCategorySlug(slug);
    }

    @Override
    public Product update(Long id, Product updated) {
        return productRepository.findById(id)
                .map(existing -> {
                    existing.setSku(updated.getSku());
                    existing.setName(updated.getName());
                    existing.setDescription(updated.getDescription());
                    existing.setPrice(updated.getPrice());
                    existing.setCurrency(updated.getCurrency());

                    // Replace children collections
                    existing.getVariants().clear();
                    if (updated.getVariants() != null) {
                        for (ProductVariant v : updated.getVariants()) {
                            v.setProduct(existing);
                            existing.getVariants().add(v);
                        }
                    }

                    existing.getAttributes().clear();
                    if (updated.getAttributes() != null) {
                        for (ProductAttribute a : updated.getAttributes()) {
                            a.setProduct(existing);
                            existing.getAttributes().add(a);
                        }
                    }

                    existing.getCategories().clear();
                    if (updated.getCategories() != null) {
                        for (Category c : updated.getCategories()) {
                            c.getProducts().add(existing);
                            existing.getCategories().add(c);
                        }
                    }

                    return productRepository.save(existing);
                })
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + id));
    }

    @Override
    public void delete(Long id) {
        productRepository.deleteById(id);
    }

    @Override
    public Category createCategory(Category category) {
        return categoryRepository.save(category);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Category> listCategories() {
        return categoryRepository.findAll();
    }
}