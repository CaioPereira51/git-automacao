# Como Analisar um Pull Request

Este guia explica o que observar ao revisar um PR neste projeto,
em qual ordem analisar e quais erros evitar.

---

## Visão geral de um PR

Quando você abre um PR no GitHub, as informações estão divididas em abas:

```
[Conversation] [Commits] [Checks] [Files changed]
      │              │        │           │
   Discussão    Histórico   CI/CD     Diff do código
```

Analise sempre nessa ordem: **Checks → Commits → Files changed → Conversation**

---

## 1. Checks (CI) — primeiro a ver

Antes de ler uma linha de código, verifique se o pipeline passou.

**Onde fica:** aba **Checks** ou o bloco de status no final da aba Conversation.

| Status | Significado | O que fazer |
|--------|-------------|-------------|
| ✅ All checks passing | Lint e testes passaram | Pode continuar a revisão |
| ❌ All checks failing | Algo quebrou no CI | Não aprove — peça correção primeiro |
| ⏳ Checks pending | CI ainda rodando | Aguarde antes de revisar o código |
| ⚠️ Some checks failed | Parte falhou | Verifique qual etapa falhou (lint? teste?) |

**Como ver o detalhe da falha:**
1. Clique em **Details** ao lado do check com falha
2. Expanda o step com ❌ no log
3. Leia a mensagem de erro — geralmente indica arquivo e linha

**Erros comuns de CI neste projeto:**

```
FAIL src/tests/users.test.js
  ● deve retornar os usuários padrão do seed
    Expected: "Alice Silva"
    Received: "Carlos Backend"
```
→ O seed do `userService.js` foi alterado mas os testes não foram atualizados (ou vice-versa).

```
error  'variavel' is assigned a value but never used  no-unused-vars
```
→ Variável declarada e não usada. Lint falhou.

---

## 2. Commits — entenda a intenção

**Onde fica:** aba **Commits**

Cada commit deve responder: *"O que foi feito e por quê?"*

### Boas práticas de commit neste projeto

```
feat(users): adicionar validação de e-mail duplicado   ✅ claro e específico
fix(health): corrigir cálculo de uptime                ✅ indica o problema resolvido
docs: atualizar guia de workflow                       ✅ escopo bem definido

fix stuff                                              ❌ vago
wip                                                    ❌ work-in-progress não deve ir para PR
ajustes finais                                         ❌ sem contexto
```

### O que verificar nos commits

- **Quantidade:** muitos commits pequenos demais podem indicar falta de organização.
  Um PR ideal tem commits atômicos — cada um representa uma mudança lógica completa.
- **Ordem:** os commits devem contar uma história coerente de cima para baixo.
- **Mensagens:** seguem o padrão `tipo(escopo): descrição`?
- **Commits fora do escopo:** ex: um PR de `fix/` que tem commit `feat:` — sinal de alerta.

---

## 3. Files Changed — o diff do código

**Onde fica:** aba **Files changed**

Esta é a parte mais importante da revisão. Analise arquivo por arquivo.

### Como ler o diff

```diff
- linha removida (vermelho)
+ linha adicionada (verde)
  linha sem alteração (branco)
```

### Checklist por tipo de arquivo

#### `src/services/*.js` — Lógica de negócio
- [ ] A lógica está correta para todos os casos (não apenas o caminho feliz)?
- [ ] Validações estão presentes (campos obrigatórios, tipos, limites)?
- [ ] Nenhum dado sensível hardcoded (senhas, tokens, chaves)?
- [ ] O `resetUsers()` foi atualizado se o seed foi alterado?

#### `src/controllers/*.js` — Handlers HTTP
- [ ] Os status codes HTTP estão corretos?
  - `200` para GET com sucesso
  - `201` para POST que criou recurso
  - `400` para erro de validação do cliente
  - `404` para recurso não encontrado
  - `500` para erro interno
- [ ] Erros estão sendo capturados com `try/catch`?
- [ ] A resposta segue o padrão `{ data: ... }` ou `{ error: ... }`?

#### `src/tests/*.test.js` — Testes
- [ ] Há testes para o caminho feliz E para os casos de erro?
- [ ] Os testes cobrem as novas funcionalidades adicionadas no PR?
- [ ] `beforeEach(() => resetUsers())` está presente para isolar os testes?
- [ ] Os `expect` testam valores concretos, não apenas "truthy"?

#### `src/routes/*.js` — Rotas
- [ ] Os métodos HTTP estão corretos (`GET`, `POST`, `PUT`, `DELETE`)?
- [ ] O controller correto está sendo chamado?

#### Arquivos de configuração (`.eslintrc.json`, `package.json`)
- [ ] Nenhuma regra de lint foi desabilitada sem justificativa?
- [ ] Dependências novas foram adicionadas? São necessárias? São confiáveis?

#### `docs/` e `README.md`
- [ ] A documentação reflete as mudanças feitas no código?
- [ ] Exemplos de código na documentação ainda funcionam?

### Sinais de alerta no diff

```javascript
// ❌ Console.log esquecido — vaza informação, causa falha no lint
console.log(users);

// ❌ Código comentado — deve ser removido antes do merge
// const oldFunction = () => { ... }

// ❌ TODO sem issue — indica trabalho incompleto
// TODO: tratar esse erro

// ❌ Seed de dados de teste chegando em produção
let users = [{ id: 1, name: 'teste123', email: 'abc@abc.com' }];
```

---

## 4. Conversation — contexto e discussão

**Onde fica:** aba **Conversation**

### O que ler

- **Descrição do PR:** o autor explicou o que foi feito e por quê?
- **Checklist:** todos os itens foram marcados?
- **Comentários anteriores:** houve revisão anterior? Os pontos foram corrigidos?
- **Labels:** o PR tem label correto (`feat`, `fix`, `docs`)?

### O que verificar na descrição

Um bom PR tem:
```markdown
## Descrição
O que foi feito e a motivação da mudança.

## Commits incluídos
Lista clara dos commits.

## Checklist
- [x] Testes passando
- [x] Lint sem erros
- [x] Branch criada a partir de main
```

Um PR problemático tem:
```markdown
Correções diversas.
```

---

## 5. Verificação da branch base

**Muito importante:** confirme que a branch alvo está correta.

| PR de | Para | Correto? |
|-------|------|----------|
| `feat/*` | `dev` | ✅ |
| `fix/*` | `dev` | ✅ |
| `feat/*` | `main` | ✅ (após validação em dev) |
| `dev` | `main` | ❌ nunca — viola o workflow |
| `feat/*` criada de `dev` | qualquer | ⚠️ revisar com cuidado |

Para verificar de onde a branch foi criada:

```bash
git log --oneline origin/main..origin/feat/nome-da-branch
```

Se listar commits que não deveriam estar ali (de outras features), a branch foi criada no lugar errado.

---

## 6. Tamanho do PR — sinal importante

| Linhas alteradas | Avaliação |
|-----------------|-----------|
| < 200 linhas | ✅ Ideal para revisar com qualidade |
| 200–500 linhas | ⚠️ Aceitável, exige mais atenção |
| > 500 linhas | ❌ Difícil de revisar — peça para quebrar em PRs menores |

PRs grandes aumentam a chance de erros passarem despercebidos.

---

## 7. Fluxo completo de revisão

```
1. Abrir o PR no GitHub

2. Verificar branch base
   └── feat/* ou fix/* → dev?  ✅
   └── Branch criada de main?  ✅

3. Verificar Checks (CI)
   └── Todos passando?  ✅  → continuar
   └── Algum falhando?  ❌  → parar, pedir correção

4. Ler os Commits
   └── Mensagens claras?
   └── Escopo correto?

5. Analisar Files Changed
   └── Lógica correta?
   └── Testes cobrem as mudanças?
   └── Nenhum console.log / código comentado / TODO?
   └── Status codes HTTP corretos?

6. Ler a Conversation
   └── Descrição faz sentido?
   └── Checklist completo?

7. Aprovar ou Solicitar mudanças
   └── gh pr review --approve         (aprovação)
   └── gh pr review --request-changes (solicitar correções)
   └── gh pr review --comment         (comentário sem bloquear)
```

---

## 8. Comandos úteis durante a revisão

```bash
# Ver o PR no terminal com detalhes
gh pr view 4

# Fazer checkout local para testar
gh pr checkout 4

# Rodar os testes localmente no código do PR
npm test

# Rodar o lint
npm run lint

# Ver o diff do PR em relação à branch base
git diff origin/dev...HEAD

# Ver commits do PR
git log origin/dev..HEAD --oneline

# Aprovar
gh pr review 4 --approve

# Solicitar mudanças com comentário
gh pr review 4 --request-changes --body "Testes falhando e console.log esquecido na linha 12"
```

---

## 9. Erros frequentes para não cometer

| Erro | Consequência | Como evitar |
|------|-------------|-------------|
| Aprovar PR com CI falhando | Bug entra em produção | Nunca aprove com ❌ no CI |
| Não testar localmente | Problemas não detectados na revisão | Sempre rodar `npm test` no código do PR |
| Ignorar mudanças no `userService.js` sem verificar os testes | Testes passam localmente mas quebram em prod | Sempre verificar se seed e testes estão sincronizados |
| Fazer merge em `main` diretamente de `feat/*` sem passar por `dev` | Código não validado em homologação | Respeitar o fluxo: feat → dev → main |
| Aprovar PR com `TODO` não resolvidos | Código incompleto em produção | Solicitar que TODOs virem issues antes do merge |
