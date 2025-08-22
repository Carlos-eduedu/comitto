#!/usr/bin/env bash

gum log --time="TimeOnly" --level="info" "Iniciando Comitto..."


get_diff() {
  local DIFF
  DIFF=$(git diff --cached)

  if [[ -z "$DIFF" ]]; then
    gum log --time="TimeOnly" --level="warn" "Nenhuma mudança encontrada no staging. Use 'git add' para selecionar arquivos."
    return 1
  fi

  echo "$DIFF"
}

generate_commit_message() {
    local DIFF="$1"
    local PROMPT

    read -r -d '' PROMPT << 'EOF'
Você é um assistente especialista em gerar mensagens de commit conforme com o Conventional Commits v1.0.0, no contexto de um projeto de software.

Você receberá como entrada o resultado do comando 'git diff --cached'.

Sua tarefa é analisar o diff e gerar uma mensagem de commit precisa, concisa e descritiva, seguindo esta estrutura obrigatória:

<tipo>[escopo opcional][!]: <descrição curta>

[corpo opcional explicando o motivo das mudanças]

[rodapé(s) opcionais, como BREAKING CHANGE ou Refs: #issue]

Tipos válidos:
- feat: nova funcionalidade (semver: MINOR)
- fix: correção de bug (semver: PATCH)
- docs: apenas alterações na documentação
- style: mudanças puramente estéticas (ex: formatação)
- refactor: mudança de código que não corrige bug nem adiciona funcionalidade
- perf: melhorias de desempenho
- test: adição ou ajuste de testes
- chore: tarefas de manutenção (ex: scripts, configs)
- build: mudanças que afetam o processo de build ou dependências
- ci: mudanças na configuração de integração contínua
- revert: reversão de commit anterior

Regras obrigatórias:
1. A descrição deve ter no máximo 70 caracteres.
2. O escopo é opcional, mas se usado, deve ser um substantivo indicando a parte do sistema afetada (ex: api, db, auth, login, router).
3. O corpo (se necessário) deve explicar o que mudou e por quê, de forma clara e objetiva.
4. Se for uma alteração que quebra compatibilidade (breaking change), sinalize com '!' após o tipo ou com 'BREAKING CHANGE:' no rodapé.

Gere a mensagem com base no diff fornecido a seguir:
EOF
    gum log --time="TimeOnly" --level="info" "Gerando sugestão de commit com IA local..."
    echo -e "$PROMPT\n\n$DIFF" | ollama run mistral
}

DIFF=$(get_diff) || exit 1
MSG=$(generate_commit_message "$DIFF")

gum log --time="TimeOnly" --level="info" "Mensagem sugerida:"
echo
gum format --theme=dracula "$MSG"
echo

if gum confirm "Deseja usar essa mensagem para o commit?"; then
  git commit -m "$MSG"
  gum log --time="TimeOnly" --level="info" "Commit realizado com sucesso!"
else
  gum log --time="TimeOnly" --level="error" "Commit cancelado pelo usuário."
fi