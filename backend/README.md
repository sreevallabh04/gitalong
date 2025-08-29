# GitAlong Backend

A production-ready FastAPI backend for GitAlong - the GitHub-powered developer matching platform designed for Y Combinator and investor readiness.

## 🚀 Features

### Core Functionality
- **🔐 Authentication & Authorization** - JWT-based authentication with GitHub OAuth integration
- **👥 User Management** - Comprehensive user profiles with GitHub data integration
- **🤝 Matching System** - ML-powered developer matching and recommendations
- **💬 Real-time Messaging** - WebSocket-based chat and communication
- **📊 Analytics & Insights** - GitHub activity tracking and performance metrics
- **🚀 Project Management** - Project creation, collaboration, and discovery tools

### Production Features
- **🛡️ Security** - Rate limiting, CORS, input validation, and secure headers
- **📈 Monitoring** - Structured logging, Sentry integration, and health checks
- **⚡ Performance** - Async/await, connection pooling, and caching
- **🔧 Scalability** - Microservices-ready architecture with proper separation of concerns
- **🧪 Testing** - Comprehensive test suite with coverage reporting
- **📚 Documentation** - Auto-generated API documentation with OpenAPI/Swagger

## 🏗️ Architecture

```
backend/
├── app/
│   ├── api/                    # API routes and endpoints
│   │   └── v1/
│   │       ├── endpoints/      # Individual endpoint modules
│   │       └── api.py         # Main API router
│   ├── core/                   # Core application modules
│   │   ├── config.py          # Configuration management
│   │   ├── database.py        # Database setup and session management
│   │   ├── security.py        # Authentication and security utilities
│   │   └── logging.py         # Structured logging configuration
│   ├── models/                 # SQLAlchemy database models
│   ├── services/               # Business logic and external integrations
│   ├── schemas/                # Pydantic models for request/response validation
│   └── main.py                # FastAPI application entry point
├── tests/                      # Test suite
├── alembic/                    # Database migrations
├── requirements.txt            # Python dependencies
├── pyproject.toml             # Project configuration
└── README.md                  # This file
```

## 🛠️ Technology Stack

### Backend Framework
- **FastAPI** - Modern, fast web framework for building APIs
- **SQLAlchemy** - SQL toolkit and ORM
- **Alembic** - Database migration tool
- **Pydantic** - Data validation using Python type annotations

### Database
- **PostgreSQL** - Primary database
- **Redis** - Caching and session storage
- **AsyncPG** - Async PostgreSQL driver

### Authentication & Security
- **JWT** - JSON Web Tokens for authentication
- **Passlib** - Password hashing
- **Python-Jose** - JWT encoding/decoding
- **GitHub OAuth** - Social authentication

### Monitoring & Logging
- **Structlog** - Structured logging
- **Sentry** - Error tracking and monitoring
- **Prometheus** - Metrics collection

### Development Tools
- **Black** - Code formatting
- **isort** - Import sorting
- **Flake8** - Linting
- **MyPy** - Type checking
- **Pytest** - Testing framework

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- PostgreSQL 13+
- Redis 6+
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Initialize database**
   ```bash
   # Create database
   createdb gitalong_backend
   
   # Run migrations
   alembic upgrade head
   ```

6. **Start the application**
   ```bash
   # Development
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   
   # Production
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
   ```

### Environment Variables

Create a `.env` file with the following variables:

```env
# Application
DEBUG=false
ENVIRONMENT=production
SECRET_KEY=your-super-secret-key-here

# Database
DATABASE_URL=postgresql+asyncpg://user:password@localhost/gitalong_backend
REDIS_URL=redis://localhost:6379

# GitHub OAuth
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
GITHUB_CALLBACK_URL=http://localhost:8000/api/v1/auth/github/callback

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# CORS
BACKEND_CORS_ORIGINS=["http://localhost:3000", "https://yourdomain.com"]

# Monitoring
SENTRY_DSN=your-sentry-dsn
LOG_LEVEL=INFO
```

## 📚 API Documentation

Once the application is running, you can access:

- **Interactive API Docs (Swagger UI)**: http://localhost:8000/docs
- **ReDoc Documentation**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/api/v1/openapi.json

## 🧪 Testing

### Run Tests
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_auth.py

# Run with verbose output
pytest -v
```

### Test Structure
```
tests/
├── conftest.py              # Test configuration and fixtures
├── test_auth.py            # Authentication tests
├── test_users.py           # User management tests
├── test_projects.py        # Project management tests
├── test_matches.py         # Matching system tests
├── test_messages.py        # Messaging tests
├── test_github.py          # GitHub integration tests
└── test_analytics.py       # Analytics tests
```

## 🚀 Deployment

### Docker Deployment

1. **Build the image**
   ```bash
   docker build -t gitalong-backend .
   ```

2. **Run with Docker Compose**
   ```bash
   docker-compose up -d
   ```

### Production Deployment

1. **Set up production environment**
   ```bash
   export ENVIRONMENT=production
   export DEBUG=false
   ```

2. **Run database migrations**
   ```bash
   alembic upgrade head
   ```

3. **Start with Gunicorn**
   ```bash
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
   ```

### Environment-Specific Configurations

#### Development
- Debug mode enabled
- Detailed error messages
- Hot reload
- Local database

#### Production
- Debug mode disabled
- Error tracking with Sentry
- Rate limiting
- CORS protection
- Trusted host validation

## 📊 Monitoring & Health Checks

### Health Check Endpoint
```bash
curl http://localhost:8000/health
```

Response:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "environment": "production",
  "timestamp": 1640995200.0
}
```

### Metrics Endpoint
```bash
curl http://localhost:8000/metrics
```

## 🔧 Development

### Code Quality

1. **Format code**
   ```bash
   black app/ tests/
   isort app/ tests/
   ```

2. **Lint code**
   ```bash
   flake8 app/ tests/
   mypy app/
   ```

3. **Run pre-commit hooks**
   ```bash
   pre-commit run --all-files
   ```

### Database Migrations

1. **Create a new migration**
   ```bash
   alembic revision --autogenerate -m "Description of changes"
   ```

2. **Apply migrations**
   ```bash
   alembic upgrade head
   ```

3. **Rollback migration**
   ```bash
   alembic downgrade -1
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow PEP 8 style guidelines
- Write comprehensive tests for new features
- Update documentation for API changes
- Use type hints for all functions
- Write clear commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

- **Documentation**: Check the API docs at `/docs`
- **Issues**: Create an issue on GitHub
- **Email**: team@gitalong.com

## 🏆 Y Combinator Ready

This backend is designed to meet Y Combinator's high standards:

- ✅ **Scalable Architecture** - Microservices-ready with proper separation of concerns
- ✅ **Production Security** - Comprehensive security measures and best practices
- ✅ **Monitoring & Observability** - Full logging, metrics, and error tracking
- ✅ **Performance Optimized** - Async operations, caching, and connection pooling
- ✅ **Comprehensive Testing** - High test coverage with automated testing
- ✅ **Documentation** - Complete API documentation and deployment guides
- ✅ **CI/CD Ready** - Automated testing, linting, and deployment pipelines
- ✅ **Investor Friendly** - Clean codebase, proper architecture, and scalability

---

**Built with ❤️ for the developer community**
