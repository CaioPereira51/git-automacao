# Git Workflow — Guia de Uso

Este documento descreve o fluxo de desenvolvimento adotado neste projeto,
desde a criação de uma branch até o merge em produção.

---

## Modelo de Branches

```
main       ← produção (protegida, aceita apenas PR de dev)
  └── dev  ← homologação (aceita PR de feat/*, fix/*, refactor/*)
        ├── feat/nome-da-funcionalidade
        ├── fix/descricao-do-bug
        └── refactor/area-refatorada
```

| Branch       | Propósito                           | Pode fazer push direto? |
|--------------|-------------------------------------|-------------------------|
| `main`       | Produção                            | Não — somente via PR    |
| `dev`        | Homologação / staging               | Não — somente via PR    |
| `feat/*`     | Nova funcionalidade                 | Sim                     |
| `fix/*`      | Correção de bug                     | Sim                     |
| `refactor/*` | Refatoração sem mudança de behavior | Sim                     |

---

## 1. Criando uma Branch de Desenvolvimento

Sempre crie sua branch a partir de `dev` (e nunca de `main` diretamente):

```bash
git checkout dev
git pull origin dev
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
   - _"Revise as mudanças nesta branch em relação a dev"_
   - _"Existe algum problema de segurança neste controller?"_
   - _"Esta implementação segue as boas práticas de Express?"_

**Fluxo recomendado antes de abrir PR:**

```
1. Terminar implementação na feat branch
2. git diff dev...HEAD  → ver todas as mudanças
3. Abrir Cursor Chat → @Branch → pedir revisão
4. Corrigir feedbacks
5. Rodar npm test && npm run lint
6. Abrir PR
```

---

## 4. Abrindo PR para dev (Feature → Dev)

### Opção A — Script automatizado

```bash
bash scripts/create-pr-dev.sh
```

O script irá:
- Validar o prefixo da branch
- Fazer push automaticamente
- Criar o PR com título e checklist gerados automaticamente

### Opção B — GitHub CLI manual

```bash
git push origin feat/sua-branch

gh pr create \
  --base dev \
  --head feat/sua-branch \
  --title "feat: descrição da funcionalidade" \
  --body "Descrição das mudanças"
```

### Opção C — Interface GitHub

1. Acesse o repositório no GitHub
2. Clique em **"Compare & pull request"**
3. Defina base como `dev`
4. Preencha o título e descrição
5. Clique em **"Create pull request"**

---

## 5. Fluxo dev → main (Homologação → Produção)

Após validação em `dev`, o merge para `main` segue o mesmo processo via PR,
mas com mais rigor:

```bash
gh pr create \
  --base main \
  --head dev \
  --title "release: versão X.Y.Z" \
  --body "## Changelog\n\n- feat: ...\n- fix: ..."
```

**Checklist obrigatório antes de fazer PR dev → main:**

- [ ] Todos os testes passando no CI
- [ ] Code review aprovado por pelo menos 1 pessoa
- [ ] Sem conflitos com `main`
- [ ] Testado em ambiente de homologação
- [ ] CHANGELOG atualizado (se aplicável)

---

## 6. Resolvendo Conflitos com o Cursor

Conflitos ocorrem quando duas branches modificam o mesmo trecho de código.

### Passo a passo para resolver conflitos:

```bash
# 1. Esteja na sua branch de feature
git checkout feat/minha-feature

# 2. Atualize a referência de dev
git fetch origin

# 3. Faça rebase ou merge de dev na sua branch
git rebase origin/dev
# ou, se preferir merge:
# git merge origin/dev
```

Se houver conflitos, o Git marcará os arquivos:

```
<<<<<<< HEAD (suas mudanças)
const users = [];
=======
const users = [{ id: 1, name: 'seed' }];
>>>>>>> origin/dev (mudanças de dev)
```

### Usando o Cursor para resolver conflitos:

1. Abra o arquivo com conflito no Cursor
2. O editor irá exibir os marcadores de conflito com destaque visual
3. Clique em **"Accept Current"**, **"Accept Incoming"** ou **"Accept Both"**
4. Para conflitos complexos, abra o Cursor Chat e pergunte:
   - _"Ajude-me a resolver este conflito mantendo ambas as funcionalidades"_
   - _"Qual versão deste código faz mais sentido para o contexto atual?"_
5. Após resolver todos os conflitos:

```bash
git add .
git rebase --continue
# ou, se usou merge:
# git commit
```

---

## 7. Referência Rápida de Comandos

| Ação                           | Comando                                        |
|--------------------------------|------------------------------------------------|
| Criar branch de feature        | `git checkout -b feat/nome`                    |
| Atualizar branch com dev       | `git rebase origin/dev`                        |
| Ver commits não merged         | `git log origin/dev..HEAD --oneline`           |
| Ver diff completo              | `git diff origin/dev...HEAD`                   |
| Criar PR para dev              | `bash scripts/create-pr-dev.sh`                |
| Listar PRs abertos             | `gh pr list`                                   |
| Ver status do PR               | `gh pr status`                                 |
| Fazer checkout de um PR        | `gh pr checkout <número>`                      |
| Aprovar PR                     | `gh pr review --approve`                       |
| Fazer merge de PR              | `gh pr merge --squash`                         |
