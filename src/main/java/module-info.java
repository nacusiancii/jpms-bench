open module com.jpms.example {
    requires java.base;
    requires java.management; // for MemoryMXBean and java.lang.management

    // Spring Boot core
    requires spring.boot;
    requires spring.boot.autoconfigure;
    requires spring.context;
    requires spring.web;

    // Spring Data JPA + JPA API
    requires spring.data.jpa;
    requires jakarta.persistence;

    // Transactions annotations
    requires spring.tx;
}