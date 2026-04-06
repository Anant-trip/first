# Architecture & Configuration Reference

## 🏗️ Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Student Management App                   │
│                                                              │
│  Spring Boot 4.0.5 • Java 17 • PostgreSQL • Spring Security│
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 Spring Application Context                  │
│                                                              │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────┐ │
│  │  Controllers    │  │     Services     │  │    Repos   │ │
│  │                 │  │                  │  │            │ │
│  │ • Auth          │→ │ • UserService    │→ │ • UserRepo │ │
│  │ • Student       │  │ • Security       │  │ • Student  │ │
│  │ • Course        │  │ • Validation     │  │ • Course   │ │
│  │ • Dashboard     │  │                  │  │            │ │
│  └─────────────────┘  └──────────────────┘  └────────────┘ │
│                                                              │
│  Configuration (Profiles: dev, railway)                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer (JPA/Hibernate)               │
│                                                              │
│  HikariCP Connection Pool ─→ PostgreSQL Database            │
│  • Connection pooling (5-10 connections)                    │
│  • Connection timeout: 30s                                  │
│  • Max lifetime: 30 minutes                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project File Structure

```
26-Student-Management/
│
├── src/main/
│   ├── java/com/tyss/
│   │   ├── Application.java
│   │   ├── config/
│   │   │   └── SecurityConfig.java
│   │   ├── controller/
│   │   │   ├── AuthController.java
│   │   │   ├── CourseController.java
│   │   │   ├── DashboardController.java
│   │   │   └── StudentController.java
│   │   ├── dto/
│   │   │   ├── CourseDTO.java
│   │   │   ├── StudentDTO.java
│   │   │   └── UserDto.java
│   │   ├── entity/
│   │   │   ├── Course.java
│   │   │   ├── Student.java
│   │   │   └── User.java
│   │   ├── repo/
│   │   │   ├── CourseRepo.java
│   │   │   ├── StudentRepo.java
│   │   │   └── UserRepo.java
│   │   └── service/
│   │       └── UserService.java
│   │
│   └── resources/
│       ├── application.properties              ← Base config (env var placeholders)
│       ├── application-dev.properties          ← Local development
│       └── application-railway.properties      ← Railway production
│
├── src/test/
│   └── java/com/tyss/
│       └── ApplicationTests.java
│
├── src/main/webapp/
│   └── WEB-INF/views/
│       ├── add-course.jsp
│       ├── add-student.jsp
│       ├── dashboard.jsp
│       ├── edit-course.jsp
│       ├── login.jsp
│       ├── register.jsp
│       ├── view-course.jsp
│       └── view-students.jsp
│
├── Dockerfile                                   ← Docker container config
├── .railway.json                                ← Railway platform config
├── Procfile                                     ← Railway startup command
│
├── pom.xml                                      ← Maven dependencies
├── .gitignore                                   ← Git ignore rules (secrets)
│
├── DEPLOYMENT_CHECKLIST.md                      ← Pre-deployment guide
├── RAILWAY_DEPLOYMENT_GUIDE.md                  ← Railway setup guide
├── SPRING_PROFILES_SETUP.md                     ← Spring profiles guide
├── ENCRYPTION_AND_SECRETS_GUIDE.md              ← Security guide
│
├── verify-before-commit.ps1                     ← Windows verification
├── verify-before-commit.sh                      ← Unix verification
│
├── mvnw / mvnw.cmd                              ← Maven wrapper
└── target/                                      ← Build output
    ├── classes/                                 ← Compiled classes
    ├── generated-sources/
    └── *.jar                                    ← Built JAR file
```

---

## 🔄 Configuration Flow

### Local Development (dev profile)
```
User starts app with:
  set SPRING_PROFILES_ACTIVE=dev
        ↓
Spring loads application.properties
        ↓
Merges with application-dev.properties
        ↓
application-dev.properties OVERRIDES base config
        ↓
Result:
  • Database: localhost:5432/student_app
  • User: postgres
  • Password: Root
  • Port: 8081
  • Logging: DEBUG
```

### Railway Production (railway profile)
```
Railway sets environment variables:
  PGHOST=railway-db-xxxx.railway.app
  PGPORT=5432
  PGDATABASE=railway
  PGUSER=postgres
  PGPASSWORD=(encrypted random password)
  SPRING_PROFILES_ACTIVE=railway
  PORT=8080 (auto-assigned)
        ↓
Spring loads application.properties
        ↓
Merges with application-railway.properties
        ↓
Environment variables OVERRIDE placeholders
        ↓
Result:
  • Database: railway-db-xxxx.railway.app:5432/railway
  • User: postgres (from Railway)
  • Password: (from Railway encrypted env var)
  • Port: 8080 (Railway assigned)
  • Logging: WARN
```

---

## 🔐 Secrets Management Flow

### ❌ Before (INSECURE - DON'T DO THIS)
```
application.properties:
  spring.datasource.password=Root
         ↓
  Visible in:
    ✗ Git commit history
    ✗ Application logs
    ✗ Docker image layers
    ✗ Process list
    ✗ Team repository
```

### ✅ After (SECURE - CURRENT SETUP)
```
application.properties:
  spring.datasource.password=${DATABASE_PASSWORD:}
         ↓
Railway Dashboard Environment:
  DATABASE_PASSWORD = (encrypted value)
         ↓
Spring reads at startup:
  ✓ Not in Git history
  ✓ Not in logs
  ✓ Not in Docker image
  ✓ Not in process list (Railway managed)
  ✓ Safe to share repository
```

---

## 📊 Environment Variables Mapping

### Development (Local)
```
Environment Variable          → Mapped To
(None - using dev properties) → spring.datasource.url
(None - using dev properties) → spring.datasource.username
(None - using dev properties) → spring.datasource.password
```

Properties used:
```
application.properties (base)
       ↓ (overridden by)
application-dev.properties
```

### Railway (Production)
```
Environment Variable          → Mapped To
PGHOST                        → spring.datasource.url (hostname)
PGPORT                        → spring.datasource.url (port)
PGDATABASE                    → spring.datasource.url (database)
PGUSER                        → spring.datasource.username
PGPASSWORD                    → spring.datasource.password
PORT                          → server.port
SPRING_PROFILES_ACTIVE        → spring.profiles.active
```

Properties used:
```
application.properties (base)
       ↓ (overridden by)
application-railway.properties
       ↓ (overridden by)
Environment Variables from Railway
```

---

## 🚀 Deployment Workflow

```
1. DEVELOP
   ├─ Write code locally
   ├─ Run with dev profile
   ├─ Test with local PostgreSQL
   └─ Commit changes

2. SECURE
   ├─ Verify no hardcoded secrets
   ├─ Run verification script
   ├─ Check .gitignore updated
   └─ Ready to push

3. PUSH
   ├─ Git add .
   ├─ Git commit
   ├─ Git push to GitHub
   └─ GitHub notifies Railway

4. RAILWAY DETECTS
   ├─ Receives push notification
   ├─ Clones repository
   ├─ Reads Procfile:
   │    web: java -Dspring.profiles.active=railway -jar target/*.jar
   └─ Starts build

5. BUILD
   ├─ Maven runs: mvn clean package
   ├─ Compiles Java code
   ├─ Creates target/*.jar
   └─ Build completes

6. DEPLOY
   ├─ Railway starts container
   ├─ Sets environment variables from Railway Dashboard
   ├─ JVM starts with spring.profiles.active=railway
   ├─ Spring loads application-railway.properties
   ├─ Reads ${PG*} environment variables
   ├─ Connects to Railway PostgreSQL
   └─ Application starts listening on port $PORT

7. RUNNING
   ├─ Application receives requests
   ├─ Controllers process requests
   ├─ Services handle business logic
   ├─ Repos query database via HikariCP
   └─ Uses encrypted password from Railway

8. MONITORING
   ├─ Health check: /actuator/health
   ├─ View logs: railway logs
   ├─ Monitor metrics (if configured)
   └─ Alert on failures
```

---

## 📋 Spring Profile Properties Comparison

| Property | Dev Profile | Railway Profile | Purpose |
|----------|------------|-----------------|---------|
| `server.port` | `8081` | `${PORT:8080}` | API listening port |
| `spring.datasource.url` | `localhost:5432` | `${PGHOST}:${PGPORT}` | Database host |
| `spring.datasource.username` | `postgres` | `${PGUSER}` | DB username |
| `spring.datasource.password` | `Root` | `${PGPASSWORD}` | DB password |
| `spring.jpa.hibernate.ddl-auto` | `update` | `update` | Schema management |
| `spring.jpa.show-sql` | `true` | `false` | Query logging |
| `logging.level.root` | `INFO` | `WARN` | Log verbosity |
| `logging.level.com.tyss` | `DEBUG` | `INFO` | App-specific logs |
| `spring.devtools.restart.enabled` | `true` | N/A | Hot reload |
| `spring.datasource.hikari.maximum-pool-size` | `5` | `10` | Connection pool size |

---

## 🐳 Docker Build Flow

```
Dockerfile (Multi-stage build)
    ↓
┌─────────────────────────┐
│  BUILD STAGE (Maven)    │
├─────────────────────────┤
│ FROM maven:3.9          │
│ COPY pom.xml            │
│ COPY src/               │
│ RUN mvn clean package   │ ← Creates target/*.jar
└─────────────────────────┘
    ↓
    ✓ Java source compiled
    ✓ Tests run
    ✓ JAR packaged
    ↓ Only JAR goes to next stage (optimized!)
    ↓
┌─────────────────────────┐
│  RUNTIME STAGE (JRE)    │
├─────────────────────────┤
│ FROM eclipse-temurin:17 │
│ COPY app.jar            │
│ ENTRYPOINT java ...     │
└─────────────────────────┘
    ↓
    ✓ Lightweight container (~300MB)
    ✓ Only runtime needed
    ✓ Code not exposed
    ↓
CONTAINER IMAGE READY FOR RAILWAY
```

---

## 🔍 Configuration Layers (Priority Order)

1. **Highest**: Command line arguments
   ```bash
   mvn spring-boot:run --spring.datasource.url=...
   ```

2. **High**: System properties
   ```bash
   java -Dspring.datasource.url=... app.jar
   ```

3. **Medium**: Environment variables
   ```bash
   export DATABASE_URL=...
   ```

4. **Low**: application-{profile}.properties
   ```properties
   application-dev.properties
   application-railway.properties
   ```

5. **Lowest**: application.properties (base)
   ```properties
   spring.datasource.url=${DATABASE_URL:default}
   ```

---

## 📈 Horizontal Scaling Architecture (Future)

```
┌─────────────────────────────────┐
│      Railway PostgreSQL         │
│  (Shared database instance)     │
└────────────┬─────────────────────┘
             ▲
             │ (All instances read/write same DB)
        ┌────┴────┐
        │          │
   ┌────▼─────┐  ┌─▼────────┐
   │ Instance │  │ Instance │  ← Railway load balancer distributes
   │    1     │  │    2     │    traffic between instances
   │ (Scaled) │  │ (Scaled) │
   └──────────┘  └──────────┘
   
   Each instance:
   • Uses spring-railway profile
   • Connects to same PostgreSQL
   • Independent JVM process
   • Auto-scales based on metrics
```

---

## 🎯 Key Concepts

### Spring Profiles
- Mechanism to activate different configurations
- `spring.profiles.active` determines which profile loads
- Files: `application-{profile}.properties`
- Allows same code to work in different environments

### Environment Variables
- Set by operating system or container platform
- Accessed in Java: `System.getenv("VAR_NAME")`
- Spring uses: `${VAR_NAME:default_value}` syntax
- Railway securely manages these

### Connection Pooling (HikariCP)
- Maintains pool of reusable database connections
- Dev: 5 connections (small, local development)
- Prod: 10 connections (handles more traffic)
- Improves performance, reduces database load

### Docker Multi-stage Build
- Build stage: Create JAR (large, with Maven)
- Runtime stage: Run app (small, only needs JRE)
- Optimization: Final image doesn't include build tools

---

## ✅ Verification Checklist Matrix

| Check | Local Dev | Railway | How to Verify |
|-------|-----------|---------|--------------|
| Profile active | dev | railway | Logs show "active: dev/railway" |
| DB connection | localhost | railway.app | App starts without connection errors |
| Credentials hidden | ${VAR} | ${VAR} | grep password shows ${VAR} syntax |
| Port correct | 8081 | 8080/$PORT | App listens on correct port |
| Logging level | DEBUG | WARN | Check console verbose output |
| Secrets not exposed | Safe | Safe | git grep password returns only ${} |
| Health endpoint | /actuator/health | /actuator/health | curl returns {"status":"UP"} |

---

## 🚀 Quick Reference Commands

```bash
# Local Development
mvn spring-boot:run                              # Uses dev profile
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"

# Build JAR
mvn clean package

# Docker
docker build -t student-app .
docker run -p 8080:8080 student-app

# Railway
railway init
railway up
railway logs
railway shell

# Git Operations
git add .
git commit -m "feat: Spring profiles and Railway config"
git push origin main

# Verification
./verify-before-commit.ps1    # Windows
bash verify-before-commit.sh  # Unix
```

---

**This reference provides the complete visual overview of your application architecture and configuration.** 📊
