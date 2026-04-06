# Railway Deployment & Security Guide

## 🔒 Security Changes Made

Your project has been updated with the following security enhancements:

### 1. **Spring Profiles Implementation**
Spring Profiles allow you to have different configurations for different environments:
- **dev** - Local development (hardcoded values)
- **railway** - Railway production (environment variables)

### 2. **Environment Variables**
Sensitive data is now read from **environment variables** instead of being hardcoded:
- `DATABASE_URL` - PostgreSQL connection URL
- `DATABASE_USER` - Database username
- `DATABASE_PASSWORD` - Database password
- `PORT` - Server port (Railway sets this automatically)

### 3. **Files Created**

```
src/main/resources/
├── application.properties           (Base config with env var placeholders)
├── application-dev.properties       (Local development config)
└── application-railway.properties   (Railway production config)

Root project files:
├── Procfile                         (Railway deployment instructions)
├── Dockerfile                       (Container configuration)
├── .railway.json                    (Railway-specific config)
└── .gitignore (UPDATE: add *.env)
```

---

## 🚀 Railway Deployment Steps

### Step 1: Connect Repository to Railway
```bash
# Prerequisites:
# 1. Create a Railway project at: https://railway.app
# 2. Install Railway CLI: npm install -g @railway/cli
# 3. Login to Railway: railway login

# Deploy from your repo
railway init
```

### Step 2: Configure Railroad Database Plugin
```bash
# In Railway Dashboard:
# 1. Create a new PostgreSQL plugin for your project
# 2. Railway automatically sets PG environment variables:
#    - PGHOST
#    - PGPORT
#    - PGDATABASE
#    - PGUSER
#    - PGPASSWORD
```

### Step 3: Set Environment Variables
In your Railway project dashboard, set:

```
SPRING_PROFILES_ACTIVE=railway
DATABASE_URL=jdbc:postgresql://$PGHOST:$PGPORT/$PGDATABASE
DATABASE_USER=$PGUSER
DATABASE_PASSWORD=$PGPASSWORD
```

Or let Railway auto-inject (simpler):
```
SPRING_PROFILES_ACTIVE=railway
```

The `application-railway.properties` will use environment variables automatically.

### Step 4: Build & Deploy
```bash
# Using Railway CLI
railway up

# Or: Push to connected GitHub branch (Railway auto-deploys)
git push origin main
```

---

## 🔐 Encryption & Security Implementation

### Option A: Environment Variables (Recommended for Railway)
✅ **Already implemented in your configuration**

- No need to commit sensitive data to Git
- Railway's environment variables are encrypted
- Change configs without redeploying code

#### How it works:
```
application-railway.properties:
spring.datasource.password=${DATABASE_PASSWORD:}
↓
Railway Dashboard sets: DATABASE_PASSWORD=your_secure_password
↓
Spring automatically injects at runtime
```

### Option B: Spring Cloud Config Encryption (Optional)
If you want file-based encryption:

Create `bootstrap.properties`:
```properties
spring.cloud.config.server.encrypt.enabled=true
spring.config.import=classpath:application-encrypted.properties
```

Then encrypt sensitive values:
```bash
# Using Spring Cloud Config CLI
spring cloud config encrypt --value="your_password"
```

### Option C: Yamlcrypt or Vault (Advanced)
For additional security, integrate with:
- **Spring Cloud Vault** - Centralized secret management
- **HashiCorp Vault** - Enterprise secret store
- **Yamlcrypt** - YAML file encryption

---

## 📋 Pre-Deployment Checklist

Before committing, ensure:

### 1. Update .gitignore
```bash
# Add these lines to .gitignore
.env
.env.local
*.env
application-prod.properties
bootstrap.properties
```

### 2. Verify No Hardcoded Secrets
```bash
# Search for patterns in your code
grep -r "password" src/main/java/
grep -r "jdbc:postgresql" src/
grep -r "Root" src/
```

### 3. Configure pom.xml
✅ Already done - includes:
- Spring Cloud Config
- Spring Boot Actuator
- Webflux

### 4. Test Locally with Profiles
```bash
# Start with dev profile
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"

# Verify no secrets are logged
# Check console output - should show environment variable placeholders, not values
```

### 5. Update Application.java (If needed)
Ensure main class is properly configured:
```java
@SpringBootApplication
@EnableConfigurationProperties
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

---

## 🔧 Local Development Setup

### Running Locally (Dev Profile)
```bash
# Set active profile to dev
set SPRING_PROFILES_ACTIVE=dev  (Windows Command Prompt)
$env:SPRING_PROFILES_ACTIVE="dev"  (Windows PowerShell)
export SPRING_PROFILES_ACTIVE=dev  (Linux/Mac)

# Or in IDE:
# Run Configuration → VM options: -Dspring.profiles.active=dev
# Or in IDE: Edit Configurations → Environment Variables → SPRING_PROFILES_ACTIVE=dev

# Build and run
mvn clean package
mvn spring-boot:run
```

### Or Create .env File (Development Only)
```bash
# Create src/main/resources/.env
DATABASE_URL=jdbc:postgresql://localhost:5432/student_app
DATABASE_USER=postgres
DATABASE_PASSWORD=Root
SPRING_PROFILES_ACTIVE=dev
```

Load with dotenv-maven-plugin (optional).

---

## 🌐 Railway PostgreSQL Database Setup

### First Time Setup in Railway:

1. **Create PostgreSQL Plugin**
   - Go to Railway Dashboard
   - Click "New" → Select "PostgreSQL"
   - Auto-generates credentials

2. **Get Connection Info**
   - Railway Dashboard → PostgreSQL → Variables
   - Copy these variables (Railway auto-provides):
     ```
     PGHOST=your-railway-db-host.railway.app
     PGPORT=5432
     PGDATABASE=railway
     PGUSER=postgres
     PGPASSWORD=your_secure_password_here
     ```

3. **Connection URL Format**
   ```
   jdbc:postgresql://PGHOST:PGPORT/PGDATABASE
   ```

4. **Test Connection Locally** (Optional)
   ```bash
   # Using psql
   psql -h PGHOST -U PGUSER -d PGDATABASE
   # Enter password when prompted
   ```

---

## 🐳 Docker Deployment Info

The provided `Dockerfile`:
- ✅ Multi-stage build (optimized image size)
- ✅ Alpine Linux (smaller footprint)
- ✅ Health checks included
- ✅ Spring profile set to railway
- ✅ JVM memory tuning included

### Build Docker Image Locally (Optional)
```bash
# Build
docker build -t student-app:latest .

# Run (for testing)
docker run -p 8080:8080 \
  -e PGHOST=your-railway-db \
  -e PGPORT=5432 \
  -e PGDATABASE=railway \
  -e PGUSER=postgres \
  -e PGPASSWORD=your_password \
  -e SPRING_PROFILES_ACTIVE=railway \
  student-app:latest
```

---

## 🔍 Monitoring & Troubleshooting

### View Railway Logs
```bash
# Using Railway CLI
railway logs

# Or in Dashboard: click your app → Logs tab
```

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `Connection refused` | Check PGHOST, PGPORT are correct |
| `Authentication failed` | Verify PGUSER, PGPASSWORD match Railway |
| `Hibernate DDL errors` | Check `spring.jpa.hibernate.ddl-auto=update` in application-railway.properties |
| `Port already in use` | Railway automatically handles via `$PORT` env var |
| `Secrets showing in logs` | ✅ application-railway.properties hides sensitive data |

### Health Check Endpoint
```
POST https://your-railway-app/actuator/health
Returns: { "status": "UP" }
```

### Database Connection Verification
```bash
# SSH into Railway container and test
psql -h $PGHOST -U $PGUSER -d $PGDATABASE
```

---

## 📝 Summary of Changes

| File | Change | Purpose |
|------|--------|---------|
| `application.properties` | Uses `${ENV_VAR:default}` syntax | Environment variable injection |
| `application-dev.properties` | ✨ NEW | Local development with hardcoded values |
| `application-railway.properties` | ✨ NEW | Production config using Railway env vars |
| `Procfile` | ✨ NEW | Tells Railway how to start app |
| `Dockerfile` | ✨ NEW | Container configuration for Railway |
| `.railway.json` | ✨ NEW | Railway-specific settings |
| `pom.xml` | Added dependencies | Spring Cloud Config, Actuator |

---

## ✅ Ready to Commit

Before final commit:

```bash
# 1. Ensure .gitignore is updated
echo ".env" >> .gitignore
echo "*.env" >> .gitignore

# 2. Remove any old sensitive data
git rm --cached src/main/resources/application.properties (if previously committed with secrets)

# 3. Verify no secrets in git
git grep "password\|username" -- '*.properties' '*.java'

# 4. Stage changes
git add .

# 5. Commit
git commit -m "feat: Add Spring profiles and secure Railway deployment config

- Implement Spring profiles (dev, railway)
- Use environment variables for sensitive data
- Add Dockerfile for container deployment
- Add .railway.json configuration
- Add Procfile for Railway deployment
- Update pom.xml with security dependencies
- Configure connection pooling for production
- Add health check endpoint"

# 6. Deploy to Railway
git push origin main
```

---

## 🚨 IMPORTANT SECURITY REMINDERS

1. **Never commit passwords** - Use environment variables
2. **Circle CI/CD systems** - Set secrets in platform dashboard, not in code
3. **Review committed history** - `git log -p` to ensure no secrets were committed
4. **Rotate credentials** - If ever committed, immediately rotate passwords in Railway
5. **Use SSL/TLS** - Railway provides HTTPS automatically ✅

---

## 📚 Additional Resources

- [Railway Deployment Docs](https://docs.railway.app/)
- [Spring Boot Profiles](https://spring.io/blog/2015/02/13/developing-spring-boot-applications-with-docker)
- [Spring Cloud Config](https://spring.io/projects/spring-cloud-config)
- [PostgreSQL JDBC Connection](https://jdbc.postgresql.org/)

---

**Your application is now ready for secure deployment to Railway!** 🚀
