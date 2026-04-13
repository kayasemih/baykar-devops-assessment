#!/bin/bash
# ============================================================
# Seed Database Script
# ============================================================
# Inserts sample records into MongoDB so the app isn't empty.
# Usage: make seed (or bash scripts/seed-db.sh)
# ============================================================

GREEN='\033[0;32m'
NC='\033[0m'
API_URL="http://localhost:5050/record"

echo "Seeding database with sample records..."

# Sample data — employee records
records=(
  '{"name":"Ahmet Yilmaz","position":"Backend Developer","level":"Senior"}'
  '{"name":"Elif Kaya","position":"DevOps Engineer","level":"Junior"}'
  '{"name":"Mehmet Can","position":"Frontend Developer","level":"Intern"}'
  '{"name":"Ayse Demir","position":"SRE","level":"Senior"}'
  '{"name":"Burak Ozturk","position":"Cloud Architect","level":"Senior"}'
)

for record in "${records[@]}"; do
  name=$(echo "$record" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
  response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "$record")

  if [ "$response" = "200" ] || [ "$response" = "204" ]; then
    echo -e "  ${GREEN}✓${NC} Added: $name"
  else
    echo "  ✗ Failed to add: $name (HTTP $response)"
  fi
done

echo -e "\n${GREEN}Done! Visit http://localhost:3000/records to see the data.${NC}"
