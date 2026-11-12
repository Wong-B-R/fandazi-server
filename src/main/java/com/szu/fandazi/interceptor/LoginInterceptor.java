package com.szu.fandazi.interceptor;

import com.szu.fandazi.common.BizException;
import com.szu.fandazi.common.UserContext;
import com.szu.fandazi.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
@RequiredArgsConstructor
public class LoginInterceptor implements HandlerInterceptor {

	private final JwtUtil jwtUtil;

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
		if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
			return true;
		}
		String header = request.getHeader("Authorization");
		if (header == null || header.isBlank()) {
			throw new BizException(401, "未登录");
		}
		String token = header.startsWith("Bearer ") ? header.substring(7).trim() : header.trim();
		if (token.isEmpty()) {
			throw new BizException(401, "未登录");
		}
		UserContext.set(jwtUtil.parseUserId(token));
		return true;
	}

	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
		UserContext.clear();
	}

}
