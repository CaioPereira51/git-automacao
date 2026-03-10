# Git Workflow — Guia de Uso

Este documento descreve o fluxo de desenvolvimento adotado neste projeto,
desde a criação de uma branch até o merge em produção.

---

## Modelo de Branches

```
main  ←── produção (fonte de verdade)
 │
 ├── feat/nome-da-funcionalidade
 │     ├── PR #1 → dev   (validação em homologação)
 │     └── PR #2 → main  (promoção para produção, após validação)
 │
 ├── fix/descricao-do-bug
 │     ├── PR #1 → dev
 │     └── PR #2 → main
 │
 └── refactor/area-refatorada
       ├── PR #1 → dev
       └── PR #2 → main

dev  ←── homologação (recebe PRs para validação, nunca vai direto para main)
```

### Regras fundamentais

| Branch       | Propósito                               | Criada a partir de | Merge para       |
|--------------|-----------------------------------------|--------------------|------------------|
| `main`       | Produção — código estável               | —                  | —                |
| `dev`        | Homologação — validação antes de produção | —                | —                |
| `feat/*`     | Nova funcionalidade                     | `main`             | `dev` → `main`   |
| `fix/*`      | Correção de bug                         | `main`             | `dev` → `main`   |
| `refactor/*` | Refatoração sem mudança de comportamento | `main`            | `dev` → `main`   |

### Por que criar a branch a partir de main?

- A `main` sempre contém o código mais estável (produção)
- Garante que a feature foi desenvolvida sobre uma base sólida
- A `dev` acumula múltiplas features em paralelo; partir dela pode incluir código inacabado de outras branches
- O merge final para `main` é feito pela **mesma branch de feature**, não por `dev` — isso impede que bugs acumulados em `dev` cheguem à produção

---

## 1. Criando uma Branch de Desenvolvimento

Sempre crie a branch a partir de `main`:

```bash
git checkout main
git pull origin main
git checkout -b feat/nome-da-funcionalidade
```

**Convenções de nomenclatura:**

```
feat/adicionar-endpoint-produtos
fix/corrigir-validacao-email
refactor/extrair-logica-usuario
```

Use letras minúsculas e hífens. Evite espaços ou caracteres especiais.

---

## 2. Desenvolvendo e Commitando

Faça commits pequenos e descritivos seguindo o padrão **Conventional Commits**:

```
<tipo>(escopo opcional): descrição curta no imperativo
```

Tipos válidos: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`, `ci`

**Exemplos:**

```bash
git commit -m "feat(users): adicionar validação de e-mail duplicado"
git commit -m "fix(health): corrigir cálculo de uptime"
git commit -m "test(users): adicionar teste para POST /users"
git commit -m "docs: atualizar guia de workflow"
```

---

## 3. Usando o Cursor para Code Review com @Branch

O Cursor permite referenciar branches diretamente no chat para análise de código.

**Como fazer code review com o Cursor:**

1. Abra o painel de chat do Cursor (`Ctrl+L` ou `Cmd+L`)
2. Digite `@` e selecione a branch ou arquivo que deseja revisar
3. Faça perguntas como:
   - _"Revise as mudanças nesta branch em relação a main"_
   - _"Existe algum problema de segurança neste controller?"_
   - _"Esta implementação segue as boas práticas de Express?"_

**Fluxo recomendado antes de abrir PR:**

```
1. Terminar implementação na feat branch
2. git diff main...HEAD  → ver todas as mudanças
3. Abrir Cursor Chat → @Branch → pedir revisão
4. Corrigir feedbacks
5. Rodar npm test && npm run lint
6. Abrir PR para dev
```

---

## 4. Fluxo completo: feature → dev → main

```
main ──────────────────────────────────────────────────► main
  │                                                        ▲
  └── feat/minha-feature                                   │
            │                                              │
            ├── PR #1 ──► dev  (CI roda, time valida)      │
            │                                              │
            └── PR #2 ──────────────────────────────────► main
                         (mesma branch, após validação em dev)
```

### Passo a passo

**1. Criar branch a partir de main:**

```bash
git checkout main
git pull origin main
git checkout -b feat/minha-feature
```

**2. Desenvolver, commitar e abrir PR para dev:**

```bash
# ... desenvolvimento ...
git add .
git commit -m "feat: descrição da mudança"
bash scripts/create-pr-dev.sh
```

**3. Validar em dev** — o CI roda, o time testa em homologação.

**4. Abrir PR da mesma branch para main:**

```bash
bash scripts/create-pr-main.sh
```

**5. Aprovação e merge em main** — deploy para produção.

---

## 5. Abrindo PR para dev

### Opção A — Script automatizado

```bash
bash scripts/create-pr-dev.sh
```

### Opção B — GitHub CLI manual

```bash
git push origin feat/sua-branch

gh pr create \
  --base dev \
  --head feat/sua-branch \
  --title "feat: descrição da funcionalidade"
```

---

## 6. Abrindo PR para main (após validação em dev)

### Opção A — Script automatizado

```bash
bash scripts/create-pr-main.sh
```

### Opção B — GitHub CLI manual

```bash
gh pr create \
  --base main \
  --head feat/sua-branch \
  --title "feat: descrição da funcionalidade"
```

**Checklist obrigatório antes de fazer PR para main:**

- [ ] CI passou no PR para dev
- [ ] Testado e validado em homologação
- [ ] Code review aprovado por pelo menos 1 pessoa
- [ ] Sem conflitos com `main`

---

## 7. Resolvendo Conflitos com o Cursor

Conflitos ocorrem quando duas branches modificam o mesmo trecho de código.

### Passo a passo para resolver conflitos:

```bash
# 1. Esteja na sua branch de feature
git checkout feat/minha-feature

# 2. Atualize a referência de main
git fetch origin

# 3. Faça rebase de main na sua branch
git rebase origin/main
```

Se houver conflitos, o Git marcará os arquivos:

```
<<<<<<< HEAD (código atual de main)
const users = [];
=======
const users = [{ id: 1, name: 'seed' }];
>>>>>>> origin/main
```

### Usando o Cursor para resolver conflitos:

1. Abra o arquivo com conflito no Cursor
2. O editor exibe os marcadores com destaque visual
3. Clique em **"Accept Current"**, **"Accept Incoming"** ou **"Accept Both"**
4. Para conflitos complexos, abra o Cursor Chat e pergunte:
   - _"Ajude-me a resolver este conflito mantendo ambas as funcionalidades"_
5. Após resolver todos os conflitos:

```bash
git add .
git rebase --continue
git push origin feat/minha-feature --force-with-lease
```

---

## 8. Referência Rápida de Comandos

| Ação                           | Comando                                        |
|--------------------------------|------------------------------------------------|
| Criar branch de feature        | `git checkout main && git checkout -b feat/nome` |
| Atualizar branch com main      | `git rebase origin/main`                       |
| Ver commits não merged         | `git log origin/main..HEAD --oneline`          |
| Ver diff completo              | `git diff origin/main...HEAD`                  |
| Criar PR para dev              | `bash scripts/create-pr-dev.sh`                |
| Criar PR para main             | `bash scripts/create-pr-main.sh`               |
| Listar PRs abertos             | `gh pr list`                                   |
| Ver status do PR               | `gh pr status`                                 |
| Fazer checkout de um PR        | `gh pr checkout <número>`                      |
| Aprovar PR                     | `gh pr review --approve`                       |
| Fazer merge de PR              | `gh pr merge --squash`                         |
