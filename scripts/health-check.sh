#!/bin/bash
# ============================================================
# Health Check Script
# ============================================================
# Quick validation that all services are up and responding.
# Used by: make test, make status
# ============================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
  local name=$1
  local url=$2
  local expected=$3

  response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")

  if [ "$response" = "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} $name (HTTP $response)"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗${NC} $name (expected $expected, got $response)"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "Running health checks..."
echo "─────────────────────────"

# Check backend directly
check "Backend healthcheck (direct)" "http://localhost:5050/healthcheck/" "200"
check "Backend readiness (direct)"   "http://localhost:5050/readyz/"      "200"
check "Backend records endpoint"     "http://localhost:5050/record/"      "200"

# Check frontend (Nginx)
check "Frontend (Nginx)"             "http://localhost:3000/"             "200"

# Check frontend API proxy (through Nginx → Backend)
check "API proxy (/api/healthcheck)" "http://localhost:3000/api/healthcheck/" "200"
check "API proxy (/api/readyz)"      "http://localhost:3000/api/readyz/"      "200"
check "API proxy (/api/record)"      "http://localhost:3000/api/record/"      "200"

echo "─────────────────────────"
echo -e "Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"

if [ $FAIL -gt 0 ]; then
  echo -e "${RED}Some checks failed. Run 'docker compose logs' to investigate.${NC}"
  exit 1
fi

echo -e "${GREEN}All systems operational.${NC}"
