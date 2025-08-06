package com.jpms.example.domain.model;

import jakarta.persistence.*;

@Entity
@Table(name = "product_attributes", indexes = {
        @Index(name = "ix_product_attributes_product_id", columnList = "product_id"),
        @Index(name = "ix_product_attributes_key", columnList = "attr_key")
})
public class ProductAttribute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Redundant column for indexing and querying convenience
    @Column(name = "product_id", insertable = false, updatable = false)
    private Long productId;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "attr_key", nullable = false, length = 128)
    private String key;

    @Column(name = "attr_value", nullable = false, length = 2048)
    private String value;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public String getKey() { return key; }
    public void setKey(String key) { this.key = key; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}