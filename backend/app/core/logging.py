"""
Logging configuration for GitAlong Backend.

Provides structured logging setup with proper formatting and output handling.
"""

import logging
import sys
from typing import Any, Dict

import structlog
from structlog.stdlib import LoggerFactory


def setup_logging() -> None:
    """Setup structured logging configuration."""
    
    # Configure standard library logging
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=logging.INFO,
    )
    
    # Configure structlog
    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.processors.JSONRenderer(),
        ],
        context_class=dict,
        logger_factory=LoggerFactory(),
        wrapper_class=structlog.stdlib.BoundLogger,
        cache_logger_on_first_use=True,
    )


def get_logger(name: str = None) -> structlog.BoundLogger:
    """Get a structured logger instance."""
    return structlog.get_logger(name)


class LoggerMixin:
    """Mixin class to add logging capabilities to any class."""
    
    @property
    def logger(self) -> structlog.BoundLogger:
        """Get logger for this class."""
        return get_logger(self.__class__.__name__)


def log_function_call(func_name: str = None):
    """Decorator to log function calls with parameters and return values."""
    def decorator(func):
        def wrapper(*args, **kwargs):
            logger = get_logger(func.__module__)
            func_name_to_log = func_name or func.__name__
            
            # Log function call
            logger.info(
                "Function call started",
                function=func_name_to_log,
                args=args,
                kwargs=kwargs,
            )
            
            try:
                result = func(*args, **kwargs)
                
                # Log successful completion
                logger.info(
                    "Function call completed",
                    function=func_name_to_log,
                    result=result,
                )
                
                return result
                
            except Exception as e:
                # Log error
                logger.error(
                    "Function call failed",
                    function=func_name_to_log,
                    error=str(e),
                    error_type=type(e).__name__,
                    exc_info=True,
                )
                raise
        
        return wrapper
    return decorator


def log_async_function_call(func_name: str = None):
    """Decorator to log async function calls with parameters and return values."""
    def decorator(func):
        async def wrapper(*args, **kwargs):
            logger = get_logger(func.__module__)
            func_name_to_log = func_name or func.__name__
            
            # Log function call
            logger.info(
                "Async function call started",
                function=func_name_to_log,
                args=args,
                kwargs=kwargs,
            )
            
            try:
                result = await func(*args, **kwargs)
                
                # Log successful completion
                logger.info(
                    "Async function call completed",
                    function=func_name_to_log,
                    result=result,
                )
                
                return result
                
            except Exception as e:
                # Log error
                logger.error(
                    "Async function call failed",
                    function=func_name_to_log,
                    error=str(e),
                    error_type=type(e).__name__,
                    exc_info=True,
                )
                raise
        
        return wrapper
    return decorator


class PerformanceLogger:
    """Utility class for logging performance metrics."""
    
    def __init__(self, operation_name: str, logger: structlog.BoundLogger = None):
        self.operation_name = operation_name
        self.logger = logger or get_logger("performance")
        self.start_time = None
    
    def __enter__(self):
        """Start timing the operation."""
        import time
        self.start_time = time.time()
        self.logger.info(
            "Operation started",
            operation=self.operation_name,
        )
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """End timing and log the result."""
        import time
        if self.start_time:
            duration = time.time() - self.start_time
            
            if exc_type is None:
                self.logger.info(
                    "Operation completed",
                    operation=self.operation_name,
                    duration=duration,
                )
            else:
                self.logger.error(
                    "Operation failed",
                    operation=self.operation_name,
                    duration=duration,
                    error=str(exc_val),
                    error_type=exc_type.__name__,
                )


async def log_async_performance(operation_name: str, logger: structlog.BoundLogger = None):
    """Async context manager for logging performance metrics."""
    import time
    
    logger = logger or get_logger("performance")
    start_time = time.time()
    
    logger.info(
        "Async operation started",
        operation=operation_name,
    )
    
    try:
        yield
        duration = time.time() - start_time
        logger.info(
            "Async operation completed",
            operation=operation_name,
            duration=duration,
        )
    except Exception as e:
        duration = time.time() - start_time
        logger.error(
            "Async operation failed",
            operation=operation_name,
            duration=duration,
            error=str(e),
            error_type=type(e).__name__,
        )
        raise
