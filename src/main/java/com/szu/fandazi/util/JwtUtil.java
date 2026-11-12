package com.szu.fandazi.util;

import com.szu.fandazi.common.BizException;
import io.jsonwebtoken.Jwts;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;

@Component
public class JwtUtil {

	private static final long EXPIRE_MS = 7L * 24 * 60 * 60 * 1000;

	private final SecretKey key;

	public JwtUtil(@Value("${jwt.secret}") String secret) {
		this.key = hmacKey(secret);
	}

	public String createToken(Long userId) {
		Date now = new Date();
		return Jwts.builder()
				.subject(String.valueOf(userId))
				.issuedAt(now)
				.expiration(new Date(now.getTime() + EXPIRE_MS))
				.signWith(key)
				.compact();
	}

	public Long parseUserId(String token) {
		try {
			String subject = Jwts.parser()
					.verifyWith(key)
					.build()
					.parseSignedClaims(token)
					.getPayload()
					.getSubject();
			return Long.valueOf(subject);
		} catch (RuntimeException e) {
			throw new BizException(401, "登录已失效");
		}
	}

	private static SecretKey hmacKey(String secret) {
		try {
			byte[] hash = MessageDigest.getInstance("SHA-256")
					.digest(secret.getBytes(StandardCharsets.UTF_8));
			return new SecretKeySpec(hash, "HmacSHA256");
		} catch (NoSuchAlgorithmException e) {
			throw new IllegalStateException(e);
		}
	}

}
