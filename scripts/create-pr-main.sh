#!/usr/bin/env bash
# Cria automaticamente um Pull Request para main (produção) usando o GitHub CLI.
#
# Fluxo esperado:
#   1. Branch criada a partir de main
#   2. PR para dev já foi criado e validado (create-pr-dev.sh)
#   3. Este script promove a mesma branch para produção via PR para main
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
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
TARGET_BRANCH="main"

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
  exit 1
fi

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "dev" ]; then
  log_error "Não é possível criar PR a partir da branch '${CURRENT_BRANCH}'."
  exit 1
fi

# --- Verificar se já existe PR aberto para dev ---

log_info "Verificando PR existente para dev..."

PR_DEV=$(gh pr list --head "$CURRENT_BRANCH" --base dev --state merged --json number,url --jq '.[0].url' 2>/dev/null || true)

if [ -z "$PR_DEV" ]; then
  PR_DEV_OPEN=$(gh pr list --head "$CURRENT_BRANCH" --base dev --state open --json number,url --jq '.[0].url' 2>/dev/null || true)
  if [ -n "$PR_DEV_OPEN" ]; then
    echo -e "${YELLOW}[AVISO]${NC} Existe um PR aberto para dev que ainda não foi mergeado:"
    echo -e "  ${PR_DEV_OPEN}"
    echo ""
    read -r -p "Deseja continuar mesmo assim? (s/N) " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
      log_info "Operação cancelada."
      exit 0
    fi
  else
    echo -e "${YELLOW}[AVISO]${NC} Nenhum PR mergeado para dev encontrado nesta branch."
    echo ""
    read -r -p "Deseja continuar sem validação em dev? (s/N) " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
      log_info "Execute primeiro: bash scripts/create-pr-dev.sh"
      exit 0
    fi
  fi
else
  log_success "PR para dev encontrado e mergeado: ${PR_DEV}"
fi

# --- Push da branch ---

log_info "Fazendo push da branch para o repositório remoto..."

if git push origin "$CURRENT_BRANCH" 2>&1; then
  log_success "Push realizado com sucesso."
else
  log_error "Falha ao fazer push."
  exit 1
fi

# --- Geração do título e corpo do PR ---

COMMITS=$(git log "origin/main..HEAD" --oneline 2>/dev/null || echo "Sem commits listados")

PR_TITLE="$(echo "${CURRENT_BRANCH}" | sed 's/\// /') → ${TARGET_BRANCH}"

PR_BODY="## Descrição

Branch: \`${CURRENT_BRANCH}\`
Alvo: \`${TARGET_BRANCH}\` (produção)

## Commits incluídos

\`\`\`
${COMMITS}
\`\`\`

## Checklist de produção

- [ ] PR para \`dev\` foi mergeado e validado em homologação
- [ ] CI passou (lint + testes)
- [ ] Code review aprovado
- [ ] Sem conflitos com \`main\`
- [ ] CHANGELOG atualizado (se aplicável)
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
  log_success "Pull Request para produção criado com sucesso!"
  echo -e "${GREEN}${PR_URL}${NC}"
else
  log_error "Falha ao criar o Pull Request."
  echo "$PR_URL"
  exit 1
fi
