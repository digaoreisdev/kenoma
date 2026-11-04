# Engines.md - Governança de Engenharia e Sistema Anti-Bugs (Kenoma)

## 1. Metadados do Projeto
* **Projeto:** Kenoma
* **Engine:** Godot Engine 4.7.2 Standard (sem .NET / C#)
* **Renderizador:** `Compatibility` (otimizado para ampla compatibilidade e performance mobile)
* **Gênero:** JRPG 16-bit estilo *Final Fantasy VI* com estética HD-2D
* **Plataformas-Alvo:** PC (Steam / Windows) e Mobile (Android)
* **Resolução Base:** Viewport 1280x720 (16:9), Stretch Mode `canvas_items`, Aspect `keep`, Texture Filter `Nearest`
* **Framework de Testes:** GUT (*Godot Unit Testing*) planejado para `res://tests/`

---

## 2. Diretrizes Técnicas Obrigatórias
1. **Tipagem 100% Estática (GDScript):** Obrigatória em todas as variáveis, constantes, parâmetros e tipos de retorno de funções.
2. **Padrão de Comunicação de Nós:** *"Signals up, calls down"*. Nós ancestrais invocam métodos de nós filhos; nós filhos emitem sinais (`signal`) para notificar os pais, garantindo desacoplamento.
3. **Sem Código Solto em Nós:** Princípio da Responsabilidade Única (SRP). Funções limitadas a no máximo 30 linhas. Scripts pequenos e especializados acoplados estritamente ao papel do nó.
4. **Código Defensivo:** Uso ativo de asserções (`assert`) em tempo de desenvolvimento e checagens explícitas de nulidade antes de chamadas de métodos.
5. **Arquitetura Orientada a Dados (*Data-Driven*):** Itens, inimigos, diálogos, tabelas de experiência e atributos residem em arquivos de dados (`Resource` `.tres` ou `.json`), nunca fixos no código.
6. **Mapeamento Unificado de Entrada:** Leitura de ações exclusivamente via `Input Map` da engine (ações semânticas compatíveis com teclado, controle e touch).

---

## 3. Protocolo da Lei do Bug Registrado
Para qualquer defeito identificado ou relatado:
1. **Reprodução Automatizada:** Escrever previamente um teste automatizado no GUT que reproduza a falha.
2. **Correção Controlada:** Implementar a alteração no código até que o teste passe com 100% de sucesso.
3. **Registro na Matriz:** Preencher imediatamente a Matriz de Regressão Contínua abaixo.
4. **Validação de Regressão:** Executar a suíte completa de testes antes de cada entrega ou commit.

---

## 4. Matriz de Regressão Contínua

| ID | Data | Defeito / Causa Raiz | Solução Aplicada | Arquivo de Teste (GUT) | Status |
| :---: | :---: | :--- | :--- | :--- | :---: |
| *REG-000* | *2026-11-04* | *Template inicial de exemplo* | *N/A* | *res://tests/test_example.gd* | *PASS* |

---

## 5. Histórico de Versões de Engenharia
* **v0.1 (2026-11-04):** Formalização do documento `Engines.md`, matriz de regressão e diretrizes de conformidade estática.
* **v0.2 (2026-11-04):** Integração do addon AutoSprite (v1.0.0), ativação do plugin em project.godot e implementação da máquina de estados direcionais do Player com suporte a flip_h e fallback defensivo.

