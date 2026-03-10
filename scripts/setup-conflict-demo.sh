#!/usr/bin/env bash
# Cria duas branches com alterações conflitantes no mesmo arquivo
# para demonstrar o fluxo de resolução de conflitos.
#
# Ambas as branches são criadas a partir de main (não de dev),
# seguindo o workflow correto do projeto.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_step()    { echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

SERVICE_FILE="src/services/userService.js"

# --- Verificações ---

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo -e "${RED}[ERRO]${NC} Este diretório não é um repositório Git."
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo -e "${RED}[ERRO]${NC} Execute 'gh auth login' primeiro."
  exit 1
fi

# --- Passo 1: atualizar dev ---

log_step "PASSO 1 — Atualizando branch main"

git fetch origin
git checkout main
git pull origin main
log_success "Branch main atualizada."

# --- Passo 2: branch A — equipe de backend ---

log_step "PASSO 2 — Criando feat/seed-equipe-backend (a partir de main)"

git checkout -b feat/seed-equipe-backend

cat > "$SERVICE_FILE" << 'EOF'
let users = [
  { id: 1, name: 'Carlos Backend', email: 'carlos@example.com', createdAt: new Date('2025-01-01').toISOString() },
  { id: 2, name: 'Diana Dev', email: 'diana@example.com', createdAt: new Date('2025-01-15').toISOString() },
  { id: 3, name: 'Eduardo API', email: 'eduardo@example.com', createdAt: new Date('2025-02-01').toISOString() },
];

let nextId = 4;

function getAllUsers() {
  return users;
}

function getUserById(id) {
  return users.find((u) => u.id === id) || null;
}

function createUser({ name, email }) {
  if (!name || !email) {
    throw new Error('Os campos name e email são obrigatórios');
  }

  const emailExists = users.some((u) => u.email === email);
  if (emailExists) {
    throw new Error('E-mail já cadastrado');
  }

  const newUser = {
    id: nextId++,
    name,
    email,
    createdAt: new Date().toISOString(),
  };

  users.push(newUser);
  return newUser;
}

function resetUsers() {
  users = [
    { id: 1, name: 'Carlos Backend', email: 'carlos@example.com', createdAt: new Date('2025-01-01').toISOString() },
    { id: 2, name: 'Diana Dev', email: 'diana@example.com', createdAt: new Date('2025-01-15').toISOString() },
    { id: 3, name: 'Eduardo API', email: 'eduardo@example.com', createdAt: new Date('2025-02-01').toISOString() },
  ];
  nextId = 4;
}

module.exports = { getAllUsers, getUserById, createUser, resetUsers };
EOF

git add "$SERVICE_FILE"
git commit -m "feat(users): atualizar seed com equipe de backend"
git push origin feat/seed-equipe-backend

gh pr create \
  --base dev \
  --head feat/seed-equipe-backend \
  --title "feat(users): seed equipe de backend" \
  --body "$(cat <<'BODY'
## Descrição

Atualiza os dados de seed com usuários da equipe de backend.

## Alterações

- Substituiu Alice e Bob pelos membros do time de backend
- Adicionou terceiro usuário (Eduardo)

## Checklist

- [x] Testes passando
- [x] Lint sem erros
BODY
)"

log_success "PR da equipe de backend criado."

# --- Passo 3: voltar para main e criar branch B ---

log_step "PASSO 3 — Criando feat/seed-equipe-frontend (a partir de main)"

git checkout main

git checkout -b feat/seed-equipe-frontend

cat > "$SERVICE_FILE" << 'EOF'
let users = [
  { id: 1, name: 'Fernanda UI', email: 'fernanda@example.com', createdAt: new Date('2025-01-01').toISOString() },
  { id: 2, name: 'Gabriel UX', email: 'gabriel@example.com', createdAt: new Date('2025-01-15').toISOString() },
  { id: 3, name: 'Helena Design', email: 'helena@example.com', createdAt: new Date('2025-02-01').toISOString() },
];

let nextId = 4;

function getAllUsers() {
  return users;
}

function getUserById(id) {
  return users.find((u) => u.id === id) || null;
}

function createUser({ name, email }) {
  if (!name || !email) {
    throw new Error('Os campos name e email são obrigatórios');
  }

  const emailExists = users.some((u) => u.email === email);
  if (emailExists) {
    throw new Error('E-mail já cadastrado');
  }

  const newUser = {
    id: nextId++,
    name,
    email,
    createdAt: new Date().toISOString(),
  };

  users.push(newUser);
  return newUser;
}

function resetUsers() {
  users = [
    { id: 1, name: 'Fernanda UI', email: 'fernanda@example.com', createdAt: new Date('2025-01-01').toISOString() },
    { id: 2, name: 'Gabriel UX', email: 'gabriel@example.com', createdAt: new Date('2025-01-15').toISOString() },
    { id: 3, name: 'Helena Design', email: 'helena@example.com', createdAt: new Date('2025-02-01').toISOString() },
  ];
  nextId = 4;
}

module.exports = { getAllUsers, getUserById, createUser, resetUsers };
EOF

git add "$SERVICE_FILE"
git commit -m "feat(users): atualizar seed com equipe de frontend"
git push origin feat/seed-equipe-frontend

gh pr create \
  --base dev \
  --head feat/seed-equipe-frontend \
  --title "feat(users): seed equipe de frontend" \
  --body "$(cat <<'BODY'
## Descrição

Atualiza os dados de seed com usuários da equipe de frontend.

## Alterações

- Substituiu Alice e Bob pelos membros do time de frontend
- Adicionou terceira usuária (Helena)

## Checklist

- [x] Testes passando
- [x] Lint sem erros
BODY
)"

log_success "PR da equipe de frontend criado."

# --- Instruções finais ---

log_step "PRÓXIMOS PASSOS"

echo ""
echo -e "Dois PRs foram criados apontando para ${YELLOW}dev${NC}."
echo -e "Ambos modificam o mesmo arquivo: ${CYAN}${SERVICE_FILE}${NC}"
echo ""
echo -e "Para provocar o conflito:"
echo -e "  ${GREEN}1.${NC} Acesse o GitHub e faça o merge do PR ${YELLOW}feat/seed-equipe-backend${NC} → dev"
echo -e "  ${GREEN}2.${NC} O PR ${YELLOW}feat/seed-equipe-frontend${NC} passará a exibir conflito"
echo ""
echo -e "Para resolver o conflito localmente:"
echo -e "  ${CYAN}git checkout feat/seed-equipe-frontend${NC}"
echo -e "  ${CYAN}git fetch origin${NC}"
echo -e "  ${CYAN}git rebase origin/main${NC}"
echo -e "  ${CYAN}# edite o arquivo conflitante no Cursor${NC}"
echo -e "  ${CYAN}git add src/services/userService.js${NC}"
echo -e "  ${CYAN}git rebase --continue${NC}"
echo -e "  ${CYAN}git push origin feat/seed-equipe-frontend --force-with-lease${NC}"
echo ""
