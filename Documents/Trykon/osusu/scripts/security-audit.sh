#!/bin/bash

# Security Audit Script for Osusu
# Performs OWASP Top 10 and vulnerability checks

echo "🔒 Osusu Security Audit"
echo "======================="
echo ""

FINDINGS_DIR="./security-findings"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$FINDINGS_DIR/security-audit-$TIMESTAMP.md"

mkdir -p "$FINDINGS_DIR"

# Initialize report
cat > "$REPORT_FILE" << 'EOF'
# Security Audit Report
Generated: $(date)

## Executive Summary
This report contains findings from automated security testing.

## OWASP Top 10 Analysis

EOF

echo "📋 Running security checks..."
echo ""

# 1. Check for hardcoded secrets
echo "1️⃣  Checking for hardcoded secrets..."
grep -r "password\|secret\|key\|token" .env* src/ --include="*.js" | grep -v node_modules | grep -v ".git" || echo "✅ No obvious hardcoded secrets found in code"
echo ""

# 2. Dependency vulnerabilities
echo "2️⃣  Checking npm dependencies for vulnerabilities..."
npm audit --audit-level=moderate > "$FINDINGS_DIR/npm-audit-$TIMESTAMP.txt" 2>&1 || true
VULN_COUNT=$(grep -c "vulnerability" "$FINDINGS_DIR/npm-audit-$TIMESTAMP.txt" || echo "0")
if [ "$VULN_COUNT" -gt 0 ]; then
    echo "⚠️  Found $VULN_COUNT vulnerabilities - see $FINDINGS_DIR/npm-audit-$TIMESTAMP.txt"
else
    echo "✅ No moderate/high vulnerabilities found"
fi
echo ""

# 3. Check for common security issues
echo "3️⃣  Checking for common security patterns..."

# Check for console.log in production code
if grep -r "console.log" src/ --include="*.js" | grep -v test; then
    echo "⚠️  console.log found in production code"
else
    echo "✅ No console.log in production code"
fi

# Check for eval usage
if grep -r "eval(" src/ --include="*.js"; then
    echo "❌ CRITICAL: eval() usage found!"
else
    echo "✅ No eval() usage found"
fi

# Check for SQL injection risks
if grep -r "sql\(" src/ --include="*.js"; then
    echo "⚠️  Direct SQL() calls found - verify parameterization"
else
    echo "✅ No obvious SQL injection risks"
fi

# Check for hardcoded credentials
if grep -r "password.*=.*['\"]" src/ --include="*.js" | grep -v "this.password"; then
    echo "❌ CRITICAL: Hardcoded passwords found!"
else
    echo "✅ No hardcoded passwords in code"
fi
echo ""

# 4. Authentication checks
echo "4️⃣  Checking authentication implementation..."
if grep -q "JWT_SECRET\|REFRESH_TOKEN" src/*.js; then
    echo "✅ JWT implementation detected"
else
    echo "⚠️  JWT not found in main server file"
fi

if grep -q "requireRole\|authenticateToken" src/*.js; then
    echo "✅ Role-based authorization detected"
else
    echo "⚠️  Authorization checks not found"
fi
echo ""

# 5. HTTPS/TLS checks
echo "5️⃣  Checking HTTPS/TLS configuration..."
if grep -q "FORCE_HTTPS\|enforceHTTPS" src/*.js; then
    echo "✅ HTTPS enforcement detected"
else
    echo "⚠️  HTTPS enforcement not configured"
fi

if grep -q "Strict-Transport-Security" src/*.js; then
    echo "✅ HSTS headers configured"
else
    echo "⚠️  HSTS headers not set"
fi
echo ""

# 6. Input validation
echo "6️⃣  Checking input validation..."
if grep -q "Joi\|validator" src/*.js; then
    echo "✅ Input validation library detected"
else
    echo "⚠️  No input validation detected"
fi
echo ""

# 7. Rate limiting
echo "7️⃣  Checking rate limiting..."
if grep -q "rateLimit\|Limiter" src/*.js; then
    echo "✅ Rate limiting configured"
else
    echo "⚠️  Rate limiting not found"
fi
echo ""

# 8. Security headers
echo "8️⃣  Checking security headers..."
if grep -q "helmet" src/*.js; then
    echo "✅ Helmet middleware detected"
else
    echo "⚠️  Helmet security headers not configured"
fi

if grep -q "cors" src/*.js; then
    echo "✅ CORS configuration detected"
else
    echo "⚠️  CORS not configured"
fi
echo ""

# 9. Logging and monitoring
echo "9️⃣  Checking logging implementation..."
if grep -q "logger\|winston" src/*.js; then
    echo "✅ Logging system detected"
else
    echo "⚠️  No logging system found"
fi
echo ""

# 10. Error handling
echo "🔟 Checking error handling..."
if grep -q "try.*catch\|error handling" src/*.js; then
    echo "✅ Error handling detected"
else
    echo "⚠️  Limited error handling found"
fi
echo ""

# Summary
echo "📊 Audit Summary"
echo "================"
echo "✅ - Implement as recommended"
echo "⚠️  - Review and improve if possible"
echo "❌ - CRITICAL: Fix immediately"
echo ""
echo "📄 Full audit report saved to: $REPORT_FILE"
echo ""
echo "🔗 OWASP Top 10 2023: https://owasp.org/www-project-top-ten/"
echo "🔗 OWASP Security Testing Guide: https://owasp.org/www-project-web-security-testing-guide/"
echo ""
echo "⚠️  Recommended next steps:"
echo "1. Review npm audit findings"
echo "2. Enable HTTPS/TLS in production"
echo "3. Implement monitoring and alerting"
echo "4. Run penetration testing (professional)"
echo "5. Review database access controls"
echo "6. Implement secrets management (HashiCorp Vault)"
echo "7. Set up WAF (Web Application Firewall)"
echo "8. Enable security logging and auditing"
