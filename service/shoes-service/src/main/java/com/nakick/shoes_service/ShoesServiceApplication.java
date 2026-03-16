package com.nakick.shoes_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@SpringBootApplication
@EnableMongoRepositories
public class ShoesServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(ShoesServiceApplication.class, args);
	}

}
