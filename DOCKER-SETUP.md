# NAKick Microservices - Docker Setup

## Overview
This project contains a microservices architecture with the following services:

**Infrastructure Services:**
- **Eureka Server** (Port 8761) - Service Discovery

**Application Services:**
- **API Gateway** (Port 8080) - API Gateway
- **Auth Service** (Port 8081) - Authentication Service
- **User Service** (Port 8082) - User Management Service
- **Shoes Service** (Port 8083) - Shoes Management Service

**Database Services:**
- **PostgreSQL Auth DB** (Port 5432) - Database for Auth Service
- **PostgreSQL User DB** (Port 5433) - Database for User Service
- **PostgreSQL Shoes DB** (Port 5434) - Database for Shoes Service

## Prerequisites
- Docker Desktop installed and running
- Docker Compose installed (comes with Docker Desktop)

## Quick Start

**IMPORTANT: Make sure Docker Desktop is running before proceeding!**

### Option 1: Use the startup script (Recommended)
```bash
./start-services.sh
```

### Option 2: Manual Docker Compose commands

#### 1. Build and Start All Services
```bash
docker compose up --build
```

This will:
- Build Docker images for all services
- Start all containers in the correct order
- Wait for Eureka Server to be healthy before starting other services

#### 2. Start Services in Detached Mode (Background)
```bash
docker compose up -d --build
```

#### 3. View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f eureka-server
docker compose logs -f api-gateway
docker compose logs -f auth-service
```

#### 4. Stop All Services
```bash
docker compose down
# Or use the script
./stop-services.sh
```

#### 5. Stop and Remove All Data
```bash
docker compose down -v
```

## Access Points

Once all services are running:

- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8080
- **Auth Service**: http://localhost:8081
- **User Service**: http://localhost:8082
- **Shoes Service**: http://localhost:8083

## Service Architecture

```
┌─────────────────┐
│   API Gateway   │ :8080
│   (Port 8080)   │
└────────┬────────┘
         │
         ├──────────────────┬──────────────────┬──────────────────┐
         │                  │                  │                  │
         v                  v                  v                  v
┌────────────────┐ ┌────────────────┐ ┌────────────────┐ ┌────────────────┐
│  Auth Service  │ │  User Service  │ │ Shoes Service  │ │      ...       │
│   (Port 8081)  │ │   (Port 8082)  │ │   (Port 8083)  │ │                │
└────────┬───────┘ └────────┬───────┘ └────────┬───────┘ └────────────────┘
         │                  │                  │
         └──────────────────┴──────────────────┘
                            │
                            v
                   ┌────────────────┐
                   │ Eureka Server  │
                   │  (Port 8761)   │
                   └────────────────┘
```

## Troubleshooting

### Services not starting
```bash
# Check service status
docker-compose ps

# Check logs for errors
docker-compose logs
```

### Port conflicts
If you get port conflict errors, stop any locally running services:
```bash
# Kill processes on specific ports (macOS/Linux)
lsof -ti:8761 | xargs kill -9
lsof -ti:8080 | xargs kill -9
lsof -ti:8081 | xargs kill -9
```

### Rebuild specific service
```bash
docker-compose up --build eureka-server
docker-compose up --build api-gateway
```

### Clean build (remove all images and rebuild)
```bash
docker-compose down
docker system prune -a
docker-compose up --build
```

## Development Notes

- All services use **Java 21** with **Spring Boot 3.2.5**
- Services use **PostgreSQL databases** for data persistence
- Database data is persisted in Docker volumes
- Eureka Server is configured with health checks
- Services automatically restart on failure
- All services are on the same Docker network: `nakick-network`

## Database Access

You can connect to the PostgreSQL databases using any PostgreSQL client:

**Auth Service Database:**
- Host: `localhost`
- Port: `5435`
- Database: `authdb`
- Username: `authuser`
- Password: `authpass`

**User Service Database:**
- Host: `localhost`
- Port: `5433`
- Database: `userdb`
- Username: `useruser`
- Password: `userpass`

**Shoes Service Database:**
- Host: `localhost`
- Port: `5434`
- Database: `shoesdb`
- Username: `shoesuser`
- Password: `shoespass`

## Next Steps

To add PostgreSQL databases for production:
1. Add PostgreSQL service to docker-compose.yml
2. Update service configurations to use PostgreSQL
3. Add volume mounts for data persistence
