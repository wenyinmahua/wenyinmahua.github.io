```
server:
  port: 8080
spring:
  application:
    name: hsbcdemo
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password:

  # JPA Settings
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    database-platform: org.hibernate.dialect.H2Dialect

  # H2 Console
  h2:
    console:
      enabled: true
      path: /h2-console
```