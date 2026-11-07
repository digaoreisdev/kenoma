# AGENTS.md - Regras de Desenvolvimento com IA (Kenoma)

Este documento define regras obrigatórias para qualquer agente de IA que atue no projeto **Kenoma**.

## 1. Consulta e Atualização Contínua
* Ler obrigatoriamente `PROJETO.md` antes de iniciar qualquer tarefa.
* Atualizar o `PROJETO.md` ao final de cada tarefa com os passos concluídos, novas decisões e pendências.

## 2. Padrões de Código e Versão do Godot
* **Exclusivo Godot 4.7+:** Nunca utilizar sintaxes legadas do Godot 3 (sem `yield`, sem `onready var` antigo, sem conexões de sinais por string como `connect("pressed", self, ...)`).
* **GDScript Estritamente Tipado:** Todas as variáveis, constantes, parâmetros e tipos de retorno de funções devem possuir tipagem estática declarada.
* **Honestidade Técnica:** Se não tiver certeza de uma API ou nome de nó do Godot 4.7, declarar explicitamente a incerteza em vez de inventar.

## 3. Arquitetura e Dados
* **Conteúdo Guiado por Dados (*Data-Driven*):** Itens, inimigos, falas de diálogo, atributos e missões devem ser definidos em recursos customizados (`.tres`) ou arquivos `JSON`, nunca fixos (*hardcoded*) no código.
* **Entrada Unificada:** Toda captura de comandos do jogador deve ser feita exclusivamente via `Input Map` (teclado, gamepad e touch).
* **Autoloads Globais Planejados:** `GameState`, `SceneManager`, `SaveManager`, `DialogueManager`.

## 4. Convenções e Estilo
* **Nomenclatura:** `snake_case` para arquivos, pastas, variáveis e funções; `PascalCase` para `class_name` e nós de cena.
* **Responsabilidade Única:** Um script por responsabilidade; evitar scripts monolíticos.
* **Integridade do Mundo:** Não inventar lore, nomes de lugares, personagens ou regras do mundo; se faltar informação, perguntar ao criador.
* **Escopo Estrito:** Fazer apenas o que a tarefa pede; não refatorar nem criar arquivos fora do escopo.
* **Arquivos Protegidos:** Não editar a pasta `.godot/` nem arquivos `.import`.

## 5. Performance e Versionamento
* **Atenção ao Android:** Avisar imediatamente quando uma decisão, shader, textura ou processamento contínuo puder prejudicar o desempenho no Android.
* **Commits:** Um passo concluído = um commit com mensagem curta e clara em inglês.

## 6. Fluxo Autônomo para Ordens de Tarefa (TASK ORDER)
* **Execução Autônoma de Ciclo Completo:** Ao receber uma "TASK ORDER", executar o ciclo completo de ponta a ponta autonomamente: alterações de código, validação de testes headless, commit e push remoto (`git push`).
* **Sem Interrupções para Aprovação:** Não pausar para pedir autorização ou aprovação antes de executar passos técnicos ou enviar commits ao remoto em uma TASK ORDER.
* **Diagnóstico e Correção Autônoma:** Em caso de falha nos testes, diagnosticar e corrigir o código autonomamente até obter 100% de sucesso.
* **Critério de Interrupção:** Formular perguntas apenas mediante conflito técnico bloqueante ou ambiguidade que não possa ser resolvida programaticamente.
* **Protocolo de Saída:** Responder estritamente através do formato de 4 linhas padronizado no `Engines.md` v0.25 (STATUS, FILES, ACTIONS, COMO TESTAR).

