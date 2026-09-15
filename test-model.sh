#!/bin/bash
#
# Test an LLM model for "content:null" (reasoning-only) responses.
# Sends the same prompt N times and reports how often the model
# returns actual content vs. empty/null content.
#
# Usage:
#   ./test-model.sh                          # test default model
#   ./test-model.sh deepseek-r1-distill-qwen-14b
#   ./test-model.sh llama-scout-17b
#   LLM_API_BASE_URL=https://my-endpoint/v1 LLM_API_KEY=sk-xxx ./test-model.sh my-model

# ── Configuration (override with env vars) ─────────────────────────
LLM_API_BASE_URL="${LLM_API_BASE_URL:-https://maas-rhdp.apps.maas.redhatworkshops.io/v1}"
LLM_API_KEY="${LLM_API_KEY:-sk-pEOJDCDZq66ohu3qQTTZ0Q}"
MODEL="${1:-gpt-oss-120b}"
RUNS="${2:-10}"
MAX_TOKENS=100
PROMPT="Write a hello world function in Python. Just the code, no explanation."

# ── Colors ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  LLM Model Reliability Tester${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Endpoint:  ${LLM_API_BASE_URL}"
echo -e "  Model:     ${BOLD}${MODEL}${NC}"
echo -e "  Runs:      ${RUNS}"
echo -e "  Prompt:    \"${PROMPT}\""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Preflight: list available models ────────────────────────────────
echo -e "${YELLOW}Checking endpoint...${NC}"
MODELS_RESPONSE=$(curl -sS --max-time 10 \
  -H "Authorization: Bearer ${LLM_API_KEY}" \
  "${LLM_API_BASE_URL}/models" 2>&1)

if echo "$MODELS_RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = [m['id'] for m in data.get('data', [])]
print(f'Available models: {len(models)}')
for m in sorted(models):
    print(f'  - {m}')
" 2>/dev/null; then
  echo ""
else
  echo -e "${RED}Failed to list models. Check your endpoint and API key.${NC}"
  echo "$MODELS_RESPONSE"
  exit 1
fi

# ── Run tests ───────────────────────────────────────────────────────
SUCCESS=0
FAIL_NULL=0
FAIL_EMPTY=0
FAIL_ERROR=0
TOTAL_TIME=0

for i in $(seq 1 "$RUNS"); do
  printf "  Test %2d/%d ... " "$i" "$RUNS"

  START=$(date +%s%N)
  RESPONSE=$(curl -sS --max-time 60 \
    -H "Authorization: Bearer ${LLM_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"${MODEL}\",
      \"messages\": [{\"role\": \"user\", \"content\": \"${PROMPT}\"}],
      \"max_tokens\": ${MAX_TOKENS}
    }" \
    "${LLM_API_BASE_URL}/chat/completions" 2>&1)
  END=$(date +%s%N)
  ELAPSED=$(( (END - START) / 1000000 ))
  TOTAL_TIME=$((TOTAL_TIME + ELAPSED))

  RESULT=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'error' in data:
        print(f'ERROR|{data[\"error\"].get(\"message\", str(data[\"error\"]))}')
        sys.exit(0)
    choice = data['choices'][0]['message']
    content = choice.get('content')
    reasoning = choice.get('reasoning_content', '')
    finish = data['choices'][0].get('finish_reason', '?')
    has_reasoning = bool(reasoning and len(str(reasoning)) > 0)
    if content is None:
        print(f'NULL|reasoning={has_reasoning}|finish={finish}')
    elif content.strip() == '':
        print(f'EMPTY|reasoning={has_reasoning}|finish={finish}')
    else:
        preview = content.strip().replace(chr(10), ' ')[:80]
        print(f'OK|{preview}|finish={finish}')
except Exception as e:
    print(f'PARSE_ERROR|{str(e)}')
" 2>/dev/null)

  STATUS=$(echo "$RESULT" | cut -d'|' -f1)
  DETAIL=$(echo "$RESULT" | cut -d'|' -f2-)

  case "$STATUS" in
    OK)
      echo -e "${GREEN}✓${NC} ${ELAPSED}ms | ${DETAIL}"
      SUCCESS=$((SUCCESS + 1))
      ;;
    NULL)
      echo -e "${RED}✗ content:null${NC} ${ELAPSED}ms | ${DETAIL}"
      FAIL_NULL=$((FAIL_NULL + 1))
      ;;
    EMPTY)
      echo -e "${RED}✗ content:empty${NC} ${ELAPSED}ms | ${DETAIL}"
      FAIL_EMPTY=$((FAIL_EMPTY + 1))
      ;;
    ERROR)
      echo -e "${RED}✗ API error${NC} ${ELAPSED}ms | ${DETAIL}"
      FAIL_ERROR=$((FAIL_ERROR + 1))
      ;;
    *)
      echo -e "${RED}✗ parse error${NC} ${ELAPSED}ms | ${RESULT}"
      FAIL_ERROR=$((FAIL_ERROR + 1))
      ;;
  esac
done

# ── Summary ─────────────────────────────────────────────────────────
FAIL_TOTAL=$((FAIL_NULL + FAIL_EMPTY + FAIL_ERROR))
AVG_TIME=$((TOTAL_TIME / RUNS))
PASS_RATE=$((SUCCESS * 100 / RUNS))

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Results: ${MODEL}${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ✓ Success (has content):   ${GREEN}${SUCCESS}/${RUNS}${NC}"
if [ "$FAIL_NULL" -gt 0 ]; then
  echo -e "  ✗ content: null:           ${RED}${FAIL_NULL}/${RUNS}${NC}"
fi
if [ "$FAIL_EMPTY" -gt 0 ]; then
  echo -e "  ✗ content: empty:          ${RED}${FAIL_EMPTY}/${RUNS}${NC}"
fi
if [ "$FAIL_ERROR" -gt 0 ]; then
  echo -e "  ✗ API/parse errors:        ${RED}${FAIL_ERROR}/${RUNS}${NC}"
fi
echo -e "  Avg response time:         ${AVG_TIME}ms"
echo ""

if [ "$PASS_RATE" -ge 90 ]; then
  echo -e "  ${GREEN}${BOLD}Pass rate: ${PASS_RATE}% — Excellent ✓${NC}"
elif [ "$PASS_RATE" -ge 70 ]; then
  echo -e "  ${YELLOW}${BOLD}Pass rate: ${PASS_RATE}% — Acceptable, but flaky${NC}"
else
  echo -e "  ${RED}${BOLD}Pass rate: ${PASS_RATE}% — Unreliable, not recommended${NC}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
