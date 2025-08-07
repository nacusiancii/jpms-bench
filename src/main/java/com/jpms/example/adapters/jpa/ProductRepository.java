package com.jpms.example.adapters.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.jpms.example.domain.model.Product;

/**
 * Flattened repository to avoid nested interface registration issues with Spring Data.
 */
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    @EntityGraph(attributePaths = {"variants", "attributes", "categories"})
    Optional<Product> findBySku(String sku);

    @Override
    @EntityGraph(attributePaths = {"variants", "attributes", "categories"})
    List<Product> findAll();

    @Query("""
        select p from Product p
          join p.categories c
         where c.slug = :slug
        """)
    @EntityGraph(attributePaths = {"variants", "attributes", "categories"})
    List<Product> listByCategorySlug(String slug);
}