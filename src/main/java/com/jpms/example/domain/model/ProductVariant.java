package com.jpms.example.domain.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

@Entity
@Table(name = "product_variants", indexes = {
        @Index(name = "ux_product_variants_sku", columnList = "sku", unique = true),
        @Index(name = "ix_product_variants_product_id", columnList = "product_id")
})
public class ProductVariant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Redundant reference for clarity in SQL indexes; mapped by @ManyToOne join
    @Column(name = "product_id", insertable = false, updatable = false)
    private Long productId;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false, length = 64, unique = true)
    private String sku;

    @Column(nullable = false, length = 256)
    private String name;

    // Price delta to be added to Product.base price for this variant
    @Column(nullable = false, precision = 16, scale = 2)
    private BigDecimal priceDelta = BigDecimal.ZERO;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getPriceDelta() { return priceDelta; }
    public void setPriceDelta(BigDecimal priceDelta) { this.priceDelta = priceDelta; }
}