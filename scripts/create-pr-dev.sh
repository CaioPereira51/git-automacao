#!/usr/bin/env bash
# Cria automaticamente um Pull Request para a branch dev usando o GitHub CLI.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_error()   { echo -e "${RED}[ERRO]${NC}  $1"; }

# --- Verificações de ambiente ---

if ! command -v gh &> /dev/null; then
  log_error "GitHub CLI (gh) não está instalado."
  log_info  "Instale em: https://cli.github.com/"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  log_error "Você não está autenticado no GitHub CLI."
  log_info  "Execute: gh auth login"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  log_error "Este diretório não é um repositório Git."
  exit 1
fi

# --- Detecção da branch ---

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARGET_BRANCH="dev"

log_info "Branch atual: ${CURRENT_BRANCH}"
log_info "Branch alvo:  ${TARGET_BRANCH}"

VALID_PREFIXES=("feat/" "fix/" "refactor/")
VALID=false

for prefix in "${VALID_PREFIXES[@]}"; do
  if [[ "$CURRENT_BRANCH" == ${prefix}* ]]; then
    VALID=true
    break
  fi
done

if [ "$VALID" = false ]; then
  log_error "Branch '${CURRENT_BRANCH}' não tem um prefixo válido."
  log_info  "Prefixos aceitos: feat/, fix/, refactor/"
  log_info  "Exemplo: feat/adicionar-endpoint-produtos"
  exit 1
fi

if [ "$CURRENT_BRANCH" = "$TARGET_BRANCH" ] || [ "$CURRENT_BRANCH" = "main" ]; then
  log_error "Não é possível criar PR a partir da branch '${CURRENT_BRANCH}'."
  exit 1
fi

# --- Push da branch ---

log_info "Fazendo push da branch para o repositório remoto..."

if git push origin "$CURRENT_BRANCH" 2>&1; then
  log_success "Push realizado com sucesso."
else
  log_error "Falha ao fazer push. Verifique sua conexão e permissões."
  exit 1
fi

# --- Geração automática do título e corpo do PR ---

BRANCH_DESCRIPTION="${CURRENT_BRANCH#*/}"
BRANCH_DESCRIPTION="${BRANCH_DESCRIPTION//-/ }"

COMMITS=$(git log "origin/${TARGET_BRANCH}..HEAD" --oneline 2>/dev/null || echo "Sem commits listados")

PR_TITLE="$(echo "${CURRENT_BRANCH}" | sed 's/\// /') → ${TARGET_BRANCH}"

PR_BODY="## Descrição

Branch: \`${CURRENT_BRANCH}\`
Alvo: \`${TARGET_BRANCH}\`

## Commits incluídos

\`\`\`
${COMMITS}
\`\`\`

## Checklist

- [ ] Código revisado
- [ ] Testes passando localmente (\`npm test\`)
- [ ] Lint sem erros (\`npm run lint\`)
- [ ] Sem conflitos com \`${TARGET_BRANCH}\`
"

# --- Criação do PR ---

log_info "Criando Pull Request para '${TARGET_BRANCH}'..."

PR_URL=$(gh pr create \
  --base "$TARGET_BRANCH" \
  --head "$CURRENT_BRANCH" \
  --title "$PR_TITLE" \
  --body "$PR_BODY" \
  2>&1)

if [ $? -eq 0 ]; then
  log_success "Pull Request criado com sucesso!"
  echo -e "${GREEN}${PR_URL}${NC}"
else
  log_error "Falha ao criar o Pull Request."
  echo "$PR_URL"
  exit 1
fi
