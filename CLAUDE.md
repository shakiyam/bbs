# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby-based bulletin board system (BBS) built with Sinatra and MySQL. The application allows users to post messages with comprehensive security features, resource management, and production-ready deployment configuration.

**Technology Stack:**

- **Frontend**: Bootstrap 5, Vanilla JavaScript with real-time character counter
- **Backend**: Ruby (Sinatra framework) with security middleware
- **Database**: MySQL 8 with UTF-8 support and optimized healthchecks
- **Deployment**: Docker or Podman with Docker Compose, resource limits, and security hardening

**Architecture:**

- Single-page application with real-time validation
- CSRF protection with token rotation
- Content Security Policy (CSP) for XSS prevention
- Structured logging with container tagging
- Read-only containers with tmpfs for security
- Resource-constrained deployment for efficiency

## Common Development Commands

**Setup and Environment:**

```bash
./generate_env.sh                       # Create .env file and secret files under secrets/
```

`generate_env.sh` is idempotent: existing values are carried over from `.env` and `secrets/`, and only missing values are generated. Note that MySQL only picks up passwords during first initialization; changing a secret file after the database volume exists requires `ALTER USER` on the database side.

**Container Management:**

```bash
make start                              # Start containers and wait for health checks
make stop                               # Stop containers (includes backup)
make restart                            # Restart with backup
make clean                              # Stop and remove containers, networks, volumes, and images
make backup                             # Backup database and web access logs
```

**Development Workflow:**

```bash
make all                                # Check updates, format, lint, build, scan image, and test
make format                             # Format Dockerfile and shell scripts
make lint                               # Run all linting
make build                              # Build Docker image
make rspec                              # Test the application
```

**Security and Compliance:**

```bash
make dive                               # Analyze Docker image layers
make trivy                              # Scan Docker image for vulnerabilities
make license_finder                     # Check licenses of dependencies
```

**Dependency Updates:**

```bash
make check_for_updates                  # Check for updates to all dependencies
make check_for_image_updates            # Check for image updates
make check_for_library_updates          # Check for library updates
make check_for_action_updates           # Check for GitHub Actions updates
make check_for_new_release              # Check for new release
```

**Database Maintenance:**

```bash
make clean_db                           # Cleanup database by truncating posts table
```

**Individual Linting Commands:**

```bash
make hadolint                           # Lint Dockerfile
make dockerfmt                          # Lint Dockerfile formatting
make eslint                             # Lint JavaScript files
make markdownlint                       # Lint Markdown files
make rubocop                            # Lint Ruby scripts
make shellcheck                         # Lint shell scripts
make shfmt                              # Lint shell script formatting
```

**Debugging Tools:**

```bash
./mysql.sh                              # Connect to MySQL database interactively
./dev.sh                                # Run development container with live code reloading
```

## CI/CD and Automation

**GitHub Actions Workflows:**

- `.github/workflows/ci.yml`: Runs on push to main and on PR — hadolint, dockerfmt, eslint, markdownlint, rubocop, shellcheck, shfmt, license_finder, rspec, and trivy; on push to main, builds and publishes the Docker image after all checks pass
- `.github/workflows/check_for_updates.yml`: Runs daily (and on push to main, or manually) — checks for image, library, GitHub Actions, and new release updates

**Backup Strategy:**

- Automatic backups on container stop/restart via Makefile
- Manual backups available via `make backup`
- Backups stored in `backup/` directory with timestamp
- Includes MySQL dump and container logs (gzipped)

## Application Structure

**Key Files:**

- `app.rb`: Main Sinatra application with security, database, and routing
- `views/index.slim`: Single page template with DRY principles and internal JavaScript
- `public/js/character-counter.js`: Client-side validation and UI feedback
- `compose.yaml`: Production-ready Docker configuration with security and resource limits
- `Dockerfile`: Multi-stage build with security hardening and non-root user
- `Makefile`: Build automation and container orchestration

**Environment Variables:**

*Generated by `generate_env.sh` (`.env`):*

- `MYSQL_DATABASE`, `MYSQL_USER`
- `MYSQL_IMAGE`
- `SESSION_SECRET`

*Used by application (with defaults):*

- `APP_ENV` (set to `production` in `compose.yaml`; Sinatra defaults to `development` when unset)
- `DB_USER`, `DB_PASSWORD_FILE`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`
- `SESSION_SECRET` (generated at startup if not set; set explicitly in production so sessions survive restarts)
- `LOG_LEVEL` (defaults to INFO)

**Secrets:**

MySQL passwords are never passed as environment variables (they would remain visible in `docker inspect`). `generate_env.sh` writes them to `secrets/mysql_password.txt` and `secrets/mysql_root_password.txt` (directory 0700, files 0644 so the non-root web container uid 5501 can read them), and Compose mounts them at `/run/secrets/` via file secrets. The app user is created by `db/create_user.sh`, sourced by the MySQL image entrypoint during first initialization.

## Testing

**Test Coverage:**

- Integration tests with RSpec and Capybara
- CSRF protection testing (token validation, rotation, reuse prevention)
- Form submission and validation testing
- Security feature verification
- Cross-origin request blocking

**Run tests:**

```bash
make rspec                              # Test the application
```

**Security Testing:**

```bash
# These should all be blocked:
curl -X POST http://localhost:4567/ -d "body=attack"
curl -X POST http://localhost:4567/ -H "Referer: http://evil.com" -d "body=csrf"
```

## Code Quality Standards

**Critical Requirements:**

- Always run `make rubocop` after modifying Ruby code
- Always run `make shellcheck shfmt` after modifying shell scripts
- Maintain consistent code formatting and style
- Follow security best practices for all changes
- Do not add unnecessary comments unless they provide essential context

**Ruby Style Guidelines:**

- Follow RuboCop rules without exceptions
- Maintain proper indentation for multiline strings
- Use constant-time comparisons for security-sensitive operations

**Shell Script Guidelines:**

- Follow shellcheck recommendations
- Use long-format options for better readability
- Implement proper error handling with colored output

**Security Guidelines:**

- Never expose passwords in process lists or logs
- Pass passwords via Compose file secrets, never via container environment variables
- Implement proper input validation and sanitization
- Follow the principle of least privilege for containers
