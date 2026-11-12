package com.szu.fandazi.controller;

import com.szu.fandazi.common.BizException;
import com.szu.fandazi.common.Result;
import com.szu.fandazi.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/dev")
@RequiredArgsConstructor
public class DevController {

	private final JwtUtil jwtUtil;

	@GetMapping("/token")
	public Result<Map<String, String>> token(@RequestParam Long userId) {
		if (userId == null || userId <= 0) {
			throw new BizException("userId 必须大于 0");
		}
		return Result.ok(Map.of("token", jwtUtil.createToken(userId)));
	}

}
