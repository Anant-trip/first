# Spring Profiles Setup Guide

## What Are Spring Profiles?

Spring Profiles allow you to define different configurations for different environments (dev, testing, production). You can have separate property files that are loaded based on the active profile.

---

## 📁 Profile Files Structure

```
src/main/resources/
├── application.properties              # Base/default configuration
├── application-dev.properties          # Development environment
├── application-railway.properties      # Railway production environment
└── application-prod.properties         # (Optional) Other production env
```

---

## 🔄 How Spring Profiles Work

### 1. **Base Config (application.properties)**
- Loaded first
- Contains common settings
- Uses placeholders for environment-specific values

```properties
spring.profiles.active=${SPRING_PROFILES_ACTIVE:dev}
spring.datasource.url=${DATABASE_URL:jdbc:postgresql://localhost:5432/student_app}
```

### 2. **Profile-Specific Config (application-{profile}.properties)**
- Loaded AFTER base config
- Overrides matching properties from base config
- Named with pattern: `application-{profileName}.properties`

```
Profile name: dev  →  File: application-dev.properties
Profile name: railway  →  File: application-railway.properties
Profile name: prod  →  File: application-prod.properties
```

### 3. **Activation Order**
```
application.properties
         ↓
    [Spring reads SPRING_PROFILES_ACTIVE env var]
         ↓
Check application-{profile}.properties
         ↓
Override matching properties
         ↓
Application starts with merged configuration
```

---

## 🎯 Activation Methods

### Method 1: Environment Variable (Recommended for Railway)
```bash
# Windows Command Prompt
set SPRING_PROFILES_ACTIVE=railway

# Windows PowerShell
$env:SPRING_PROFILES_ACTIVE="railway"

# Linux/Mac
export SPRING_PROFILES_ACTIVE=railway

# Then run:
mvn spring-boot:run
```

### Method 2: JVM System Property
```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=railway"

# Or directly with java
java -Dspring.profiles.active=railway -jar target/app.jar
```

### Method 3: Command Line Argument
```bash
java -jar target/app.jar --spring.profiles.active=railway
```

### Method 4: In IDE (IntelliJ IDEA)
1. Run → Edit Configurations
2. Under "Environment variables", add:
   ```
   SPRING_PROFILES_ACTIVE=dev
   ```
3. Click OK → Run

### Method 5: .env File (Development)
Create `src/main/resources/.env`:
```
SPRING_PROFILES_ACTIVE=dev
DATABASE_URL=jdbc:postgresql://localhost:5432/student_app
DATABASE_USER=postgres
DATABASE_PASSWORD=Root
```

---

## 📊 Your Profile Configuration

### **Profile: dev (Development)**
File: `application-dev.properties`

- **Database**: Local PostgreSQL at `localhost:5432`
- **Credentials**: Hardcoded for convenience
- **Port**: `8081`
- **Logging**: DEBUG level for detailed logs
- **DDL**: `update` (auto-creates/updates tables)
- **Show SQL**: `true` (see all SQL queries)

**Use for**: Local development

```bash
set SPRING_PROFILES_ACTIVE=dev
mvn spring-boot:run
```

---

### **Profile: railway (Production)**
File: `application-railway.properties`

- **Database**: Uses railway.app PostgreSQL
- **Credentials**: From Railway environment variables
  - `PGHOST` - database hostname
  - `PGPORT` - database port
  - `PGDATABASE` - database name
  - `PGUSER` - username
  - `PGPASSWORD` - password
- **Port**: `${PORT:8080}` (Railway sets this)
- **Logging**: WARN level (minimal output)
- **DDL**: `update` (safe for production)
- **Show SQL**: `false` (performance)

**Use for**: Railway production deployment

```bash
# Railway automatically sets this
export SPRING_PROFILES_ACTIVE=railway
java -jar target/app.jar
```

---

## 🔐 How Environment Variables Work

### Variable Substitution Pattern
```properties
spring.datasource.password=${DATABASE_PASSWORD:}
```

Explanation:
- `${...}` - Variable placeholder syntax
- `DATABASE_PASSWORD` - Name of environment variable
- `:` - Separator (optional, used when no env var found)
- `` (nothing after colon) - Default value if env var not set

### Complete Example
```properties
# If DATABASE_URL is not set, use default
spring.datasource.url=${DATABASE_URL:jdbc:postgresql://localhost:5432/student_app}

# If DATABASE_USER is not set, use empty string
spring.datasource.username=${DATABASE_USER:}

# If PORT is not set, use 8080
server.port=${PORT:8080}
```

### In Railway
Railway automatically sets PostgreSQL variables:

```bash
# These are automatically available
echo $PGHOST
echo $PGPORT
echo $PGDATABASE
echo $PGUSER
echo $PGPASSWORD
```

Your `application-railway.properties` uses them:
```properties
spring.datasource.url=jdbc:postgresql://${PGHOST}:${PGPORT}/${PGDATABASE}
spring.datasource.username=${PGUSER}
spring.datasource.password=${PGPASSWORD}
```

---

## 🚀 Profile Usage Scenarios

### Scenario 1: Local Development
```bash
# Terminal
$env:SPRING_PROFILES_ACTIVE="dev"
mvn clean package
mvn spring-boot:run

# OR in Java code test
@ActiveProfiles("dev")
public class ApplicationTests { }
```

**Result**: Loads `application-dev.properties`
```
Port: 8081
DB: localhost:5432/student_app
User: postgres
Password: Root
Logs: DEBUG
```

---

### Scenario 2: Railway Production Deploy
```bash
# In Railway Dashboard:
# Environment Variables → Add:
# SPRING_PROFILES_ACTIVE = railway

# Or in Procfile:
web: java -Dspring.profiles.active=railway -jar target/*.jar
```

**Result**: Loads `application-railway.properties`
```
Port: 8080 (from Railway)
DB: PostgreSQL from Railway
User: ${PGUSER} (from Railway)
Password: ${PGPASSWORD} (from Railway)
Logs: WARN
```

---

### Scenario 3: Docker Deployment
```dockerfile
ENV SPRING_PROFILES_ACTIVE=railway

ENTRYPOINT ["java", "-Dspring.profiles.active=railway", "-jar", "app.jar"]
```

---

## 🧪 Testing with Profiles

### Unit Test with Specific Profile
```java
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("dev")
public class ApplicationTests {
    
    @Autowired
    private Environment environment;
    
    @Test
    public void testDevProfile() {
        String profile = environment.getActiveProfiles()[0];
        assertEquals("dev", profile);
    }
}
```

### Multiple Active Profiles
```properties
# application.properties
spring.profiles.active=dev,h2
```

Loads:
1. `application.properties`
2. `application-dev.properties`
3. `application-h2.properties`

---

## 📋 Property Priority (Highest to Lowest)

1. Command line arguments: `--spring.datasource.url=...`
2. Environment variables: `export DATABASE_URL=...`
3. System properties: `-Dspring.datasource.url=...`
4. Profile-specific file: `application-{profile}.properties`
5. Base file: `application.properties`
6. Default values in property keys: `${VAR:default}`

---

## 🔍 Debugging Profile Issues

### Check Which Profile Is Active
```bash
# Add this to your application
mvn spring-boot:run -Dlogging.level.org.springframework=DEBUG

# Look for in console:
# "The following profiles are active: dev,h2"
```

### Verify Property Values
Create a REST controller to see active properties:
```java
@RestController
public class ConfigController {
    
    @Autowired
    private Environment env;
    
    @GetMapping("/config/db-url")
    public String getDbUrl() {
        return env.getProperty("spring.datasource.url");
    }
    
    @GetMapping("/config/active-profiles")
    public String[] getActiveProfiles() {
        return env.getActiveProfiles();
    }
}
```

Then access:
```
http://localhost:8081/config/db-url
http://localhost:8081/config/active-profiles
```

---

## ⚠️ Common Mistakes

| Mistake | Problem | Solution |
|---------|---------|----------|
| File named `application_dev.properties` | Spring won't find it | Use hyphen: `application-dev.properties` |
| Typo in env var name | Property gets default value | Double-check env var spelling |
| Committing secrets in profile files | Security breach | Use env vars, add to .gitignore |
| Forgetting to set `SPRING_PROFILES_ACTIVE` | Uses default profile | Always explicitly set profile |
| Profile file in wrong location | Not found by Spring | Must be in `src/main/resources/` |

---

## ✅ Final Checklist

- [ ] `application.properties` has `spring.profiles.active=${SPRING_PROFILES_ACTIVE:dev}`
- [ ] `application-dev.properties` exists with local dev settings
- [ ] `application-railway.properties` exists with Railway settings
- [ ] All sensitive values use `${ENV_VAR:default}` format
- [ ] `.gitignore` includes `.env` and `*.env`
- [ ] No hardcoded secrets in profile files
- [ ] Tested locally with `--spring.profiles.active=dev`
- [ ] Ready to deploy to Railway with `SPRING_PROFILES_ACTIVE=railway` set

---

## 📚 Additional Info

- Spring profiles can be used for different features, not just configuration
- Use `@ConditionalOnProfile("dev")` to conditionally load beans
- Profiles are case-insensitive
- Multiple profiles can be active: `spring.profiles.active=dev,h2,custom`

**Your Spring profiles are now ready to use!** ✨
