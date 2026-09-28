package com.mycompany.saas.util.error;

import lombok.Getter;

@Getter
public class RestException extends RuntimeException {
    private final ErrorCode errorCode;

    public RestException(ErrorCode errorCode) {
        super(errorCode.getDefaultMessage());
        this.errorCode = errorCode;
    }

    public RestException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }
}
