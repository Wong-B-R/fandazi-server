package com.szu.fandazi.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(BizException.class)
	public Result<Void> handleBiz(BizException e) {
		return Result.fail(e.getCode(), e.getMessage());
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public Result<Void> handleValid(MethodArgumentNotValidException e) {
		String message = e.getBindingResult().getFieldError() == null
				? "参数不正确"
				: e.getBindingResult().getFieldError().getDefaultMessage();
		return Result.fail(400, message);
	}

	@ExceptionHandler(Exception.class)
	public Result<Void> handleOther(Exception e) {
		log.error("未处理异常", e);
		return Result.fail(500, "服务器内部错误");
	}

}
