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
Você é um assistente especializado em gerar mensagens de commit claras e úteis
a partir do diff do Git.

Instruções:
- A mensagem do commit deve ser escrita em português.
- Use o padrão Conventional Commits:
  tipo(scope): resumo no imperativo
- Tipos possíveis: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Resuma em até 72 caracteres no título (1ª linha)
- Pule uma linha
- No corpo, detalhe o que mudou e por quê, em parágrafos curtos
- Não copie código ou segredos do diff
- Se houver alteração incompatível, adicione seção "BREAKING CHANGE:"
- Se encontrar testes adicionados/alterados, mencione
- Se aplicável, adicione refs no final (ex: Fixes #123)

Entrada:
O diff completo vem logo abaixo. Gere apenas a mensagem de commit, nada mais.

===DIFF_START===
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