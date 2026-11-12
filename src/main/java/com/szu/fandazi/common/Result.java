package com.szu.fandazi.common;

import lombok.Data;

@Data
public class Result<T> {

	private int code;
	private String message;
	private T data;

	public static <T> Result<T> ok(T data) {
		Result<T> result = new Result<>();
		result.code = 0;
		result.message = "ok";
		result.data = data;
		return result;
	}

	public static Result<Void> ok() {
		return ok(null);
	}

	public static <T> Result<T> fail(int code, String message) {
		Result<T> result = new Result<>();
		result.code = code;
		result.message = message;
		return result;
	}

	public static <T> Result<T> fail(String message) {
		return fail(400, message);
	}

}
