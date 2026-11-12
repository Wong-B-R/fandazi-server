package com.szu.fandazi.controller;

import com.szu.fandazi.common.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HelloController {

	@GetMapping("/hello")
	public Result<String> hello() {
		return Result.ok("fandazi backend is running");
	}

}
