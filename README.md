# git-automacao

Projeto de exemplo para testar workflow de Git automatizado com CI/CD.
API REST em Node.js + Express com pipeline de integração contínua via GitHub Actions.

---

## Requisitos

- [Node.js](https://nodejs.org/) 18+
- [npm](https://www.npmjs.com/) 9+
- [Git](https://git-scm.com/)
- [GitHub CLI](https://cli.github.com/) *(para automação de PRs)*
- [Docker](https://www.docker.com/) *(opcional)*

---

## Instalação e execução

```bash
# 1. Instalar dependências
npm install

# 2. Iniciar em modo desenvolvimento (com hot reload via nodemon)
npm run dev

# 3. Ou iniciar em modo produção
npm start
```

O servidor sobe em `http://localhost:3000`.

---

## Endpoints disponíveis

| Método | Rota      | Descrição                     |
|--------|-----------|-------------------------------|
| GET    | /health   | Status da aplicação           |
| GET    | /users    | Listar todos os usuários      |
| POST   | /users    | Criar novo usuário            |

**Exemplo — criar usuário:**

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name": "João Silva", "email": "joao@example.com"}'
```

---

## Testes

```bash
# Rodar todos os testes com cobertura
npm test
```

Os testes ficam em `src/tests/` e cobrem:
- `GET /health` — status, timestamp, uptime
- `GET /users` — listagem, total
- `POST /users` — criação, validação, duplicidade

O relatório de cobertura é gerado em `coverage/`.

---

## Lint

```bash
# Verificar e reportar problemas de estilo/qualidade
npm run lint
```

Configurado via `.eslintrc.json` com regras para Node.js.

---

## Docker

```bash
# Build da imagem
docker build -t git-automacao .

# Rodar o container
docker run -p 3000:3000 git-automacao

# Rodar em background
docker run -d -p 3000:3000 --name api git-automacao
```

---

## CI/CD com GitHub Actions

O pipeline é definido em `.github/workflows/ci.yml` e executa automaticamente
em **todo Pull Request**, para qualquer branch.

**Passos do pipeline:**

1. Checkout do código
2. Configurar Node.js 20
3. `npm ci` — instalar dependências
4. `npm run lint` — verificar qualidade do código
5. `npm test` — rodar testes com cobertura
6. Upload do relatório de cobertura como artefato

Se qualquer etapa falhar, o PR fica bloqueado.

**Para testar o pipeline:**

1. Crie uma branch: `git checkout -b feat/meu-teste`
2. Faça uma alteração e commit
3. Abra um PR para `dev`
4. O GitHub Actions dispara automaticamente

---

## Workflow de Branches

```
main  ←── produção (fonte de verdade)
 │
 ├── feat/* ──► PR para dev (validação) ──► PR para main (produção)
 ├── fix/*  ──► PR para dev (validação) ──► PR para main (produção)
 └── refactor/* ► PR para dev (validação) ──► PR para main (produção)

dev  ←── homologação (nunca vai direto para main)
```

As branches sempre são criadas a partir de `main`. Após desenvolvimento,
a branch entra em `dev` para validação e, depois de aprovada, a **mesma branch**
faz merge diretamente em `main` — nunca `dev → main`.

**Iniciar nova funcionalidade:**

```bash
git checkout main
git pull origin main
git checkout -b feat/nome-da-funcionalidade
```

**Abrir PR para dev (validação em homologação):**

```bash
bash scripts/create-pr-dev.sh
```

**Abrir PR para main (após validação):**

```bash
bash scripts/create-pr-main.sh
```

> Consulte o guia completo em [docs/git-workflow.md](docs/git-workflow.md).

---

## Estrutura do projeto

```
git-automacao/
├── .github/
│   └── workflows/
│       └── ci.yml              # Pipeline GitHub Actions
├── docs/
│   └── git-workflow.md         # Guia completo do workflow
├── scripts/
│   └── create-pr-dev.sh        # Script de automação de PRs
├── src/
│   ├── controllers/
│   │   └── userController.js   # Handler HTTP de usuários
│   ├── routes/
│   │   ├── healthRoutes.js     # Rota GET /health
│   │   └── userRoutes.js       # Rotas GET e POST /users
│   ├── services/
│   │   └── userService.js      # Lógica de negócio e dados em memória
│   ├── tests/
│   │   ├── health.test.js      # Testes do endpoint /health
│   │   └── users.test.js       # Testes do endpoint /users
│   ├── app.js                  # Configuração do Express
│   └── server.js               # Ponto de entrada do servidor
├── .dockerignore
├── .eslintrc.json              # Configuração ESLint
├── .gitignore
├── Dockerfile
└── package.json
```

---

## Scripts disponíveis

| Comando         | Descrição                            |
|-----------------|--------------------------------------|
| `npm start`     | Inicia o servidor em produção        |
| `npm run dev`   | Inicia com hot reload (nodemon)      |
| `npm test`      | Roda os testes com cobertura         |
| `npm run lint`  | Verifica qualidade do código         |
