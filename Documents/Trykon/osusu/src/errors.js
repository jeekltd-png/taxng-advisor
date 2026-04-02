// Error handling utilities and custom error classes

class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.timestamp = new Date().toISOString();
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message, details = null) {
    super(message, 400, 'VALIDATION_ERROR');
    this.details = details;
  }
}

class AuthenticationError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 401, 'AUTHENTICATION_ERROR');
  }
}

class AuthorizationError extends AppError {
  constructor(message = 'Insufficient permissions') {
    super(message, 403, 'AUTHORIZATION_ERROR');
  }
}

class NotFoundError extends AppError {
  constructor(message = 'Resource not found') {
    super(message, 404, 'NOT_FOUND');
  }
}

class ConflictError extends AppError {
  constructor(message = 'Resource already exists') {
    super(message, 409, 'CONFLICT');
  }
}

class RateLimitError extends AppError {
  constructor(message = 'Too many requests') {
    super(message, 429, 'RATE_LIMIT_EXCEEDED');
  }
}

class DatabaseError extends AppError {
  constructor(message = 'Database operation failed', originalError = null) {
    super(message, 500, 'DATABASE_ERROR');
    this.originalError = originalError;
  }
}

// Async error wrapper for express routes
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Validation error formatter
const formatValidationError = (err) => {
  if (err.details) {
    return err.details.map(detail => ({
      field: detail.context.key,
      message: detail.message,
      type: detail.type
    }));
  }
  return null;
};

// Error response formatter
const formatErrorResponse = (error, isDevelopment = false) => {
  const response = {
    error: {
      code: error.code || 'INTERNAL_ERROR',
      message: error.message,
      timestamp: error.timestamp || new Date().toISOString()
    }
  };

  if (error.details) {
    response.error.details = formatValidationError(error);
  }

  if (isDevelopment && error.stack) {
    response.error.stack = error.stack;
    if (error.originalError) {
      response.error.originalError = error.originalError.message;
    }
  }

  return response;
};

module.exports = {
  AppError,
  ValidationError,
  AuthenticationError,
  AuthorizationError,
  NotFoundError,
  ConflictError,
  RateLimitError,
  DatabaseError,
  asyncHandler,
  formatErrorResponse,
  formatValidationError
};
