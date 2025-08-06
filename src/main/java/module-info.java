module com.jpms.example {
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

    // Export web package for controllers
    exports com.jpms.example.web;

    // Open domain model packages for reflection by Spring and Hibernate/JPA
    opens com.jpms.example to spring.core, spring.beans, spring.context;
    opens com.jpms.example.web to spring.core, spring.beans, spring.context, spring.web;

    opens com.jpms.example.domain.model to spring.core, spring.beans, spring.context, org.hibernate.orm.core, jakarta.persistence;

    // Open adapters for Spring Data proxies
    opens com.jpms.example.adapters.jpa to spring.core, spring.beans, spring.context, spring.data.commons, spring.data.jpa;
}