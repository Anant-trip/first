# Pre-Deployment Verification Script
# Run this before committing and pushing to Railway

Write-Host "🔍 Starting Pre-Deployment Security Verification..." -ForegroundColor Cyan
Write-Host ""

# Check 1: Verify .gitignore
Write-Host "✓ Check 1: Verifying .gitignore contains sensitive patterns..." -ForegroundColor Yellow
$gitignore = Get-Content '.gitignore' -ErrorAction SilentlyContinue
if ($gitignore -match "\.env") {
    Write-Host "  ✅ .env patterns are in .gitignore" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Add these to .gitignore:" -ForegroundColor Yellow
    Write-Host "     .env" -ForegroundColor Yellow
    Write-Host "     *.env" -ForegroundColor Yellow
}

# Check 2: Scan properties files for hardcoded secrets
Write-Host ""
Write-Host "✓ Check 2: Scanning property files for hardcoded credentials..." -ForegroundColor Yellow
$secrets_found = $false
Get-ChildItem -Path "src/main/resources" -Name "*.properties" -Recurse | ForEach-Object {
    $file_path = "src/main/resources/$_"
    $content = Get-Content $file_path
    
    if ($content -match "password\s*=\s*[^$\{]" -or `
        $content -match "username\s*=\s*localhost" -or `
        $content -match "jdbc:postgresql://localhost") {
        
        if ($_ -match "dev|local|test") {
            Write-Host "  ⚠️  $_ has hardcoded values (OK for dev)" -ForegroundColor Yellow
        } else {
            Write-Host "  ❌ $_ has potentially exposed credentials" -ForegroundColor Red
            $secrets_found = $true
        }
    } else {
        Write-Host "  ✅ $_ looks secure (uses environment variables)" -ForegroundColor Green
    }
}

# Check 3: Look for hardcoded secrets in Java files
Write-Host ""
Write-Host "✓ Check 3: Scanning Java files for hardcoded credentials..." -ForegroundColor Yellow
$java_secrets = Get-ChildItem -Path "src" -Name "*.java" -Recurse | Where-Object {
    $content = Get-Content (Join-Path "src" $_) -Raw
    $content -match "password\s*=\s*['\`"]" -or `
    $content -match "password\s*:\s*['\`"]" -or `
    $content -match "jdbc:postgresql://.*:.*@"
} | ForEach-Object { $_ }

if ($java_secrets) {
    Write-Host "  ⚠️  Check these Java files for hardcoded credentials:" -ForegroundColor Yellow
    $java_secrets | ForEach-Object { Write-Host "     $_" -ForegroundColor Yellow }
} else {
    Write-Host "  ✅ No obvious hardcoded credentials in Java files" -ForegroundColor Green
}

# Check 4: Verify Spring profiles exist
Write-Host ""
Write-Host "✓ Check 4: Verifying Spring profile files..." -ForegroundColor Yellow
$profiles = @("dev", "railway")
foreach ($profile in $profiles) {
    $profile_file = "src/main/resources/application-$profile.properties"
    if (Test-Path $profile_file) {
        Write-Host "  ✅ application-$profile.properties exists" -ForegroundColor Green
    } else {
        Write-Host "  ❌ application-$profile.properties NOT FOUND" -ForegroundColor Red
    }
}

# Check 5: Verify configuration files for Railway
Write-Host ""
Write-Host "✓ Check 5: Verifying Railway deployment files..." -ForegroundColor Yellow
$deployment_files = @("Dockerfile", "Procfile", ".railway.json")
foreach ($file in $deployment_files) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $file NOT FOUND (optional but recommended)" -ForegroundColor Yellow
    }
}

# Check 6: Check git status
Write-Host ""
Write-Host "✓ Check 6: Checking Git status..." -ForegroundColor Yellow
$uncommitted = git status --porcelain
Write-Host "  Changes to commit:" -ForegroundColor Cyan
if ($uncommitted) {
    $uncommitted | ForEach-Object { Write-Host "    $_" -ForegroundColor Cyan }
} else {
    Write-Host "    (no changes)" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
if ($secrets_found) {
    Write-Host "❌ VERIFICATION FAILED - Found exposed credentials!" -ForegroundColor Red
    Write-Host "   Do NOT commit until separated into environment variables" -ForegroundColor Red
} else {
    Write-Host "✅ PRE-DEPLOYMENT VERIFICATION PASSED" -ForegroundColor Green
    Write-Host "   Safe to commit and deploy to Railway" -ForegroundColor Green
}
Write-Host "================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "  1. git add ." -ForegroundColor White
Write-Host "  2. git commit -m 'feat: Add Spring profiles and Railway deployment'" -ForegroundColor White
Write-Host "  3. git push origin main" -ForegroundColor White
Write-Host "  4. Set SPRING_PROFILES_ACTIVE=railway in Railway Dashboard" -ForegroundColor White
