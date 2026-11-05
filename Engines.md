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
7. **Mandatory Bilingual Output Contract:** Every task response MUST strictly follow this bilingual, low-token structure:
   - `### Task Report`
     - `- **1) Core Actions Taken (English):** [Concise bullet points]`
     - `- **2) Modified/Created Files:** [List of paths]`
     - `- **3) Status:** [PASS / FAIL]`
   - `### Resumo Rápido para o Diretor (Português)`
     - `- **O que foi feito:** [Resumo direto em 2 a 3 linhas]`
     - `- **Como testar:** [Instrução simples passo a passo para testar no Godot]`

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
| REG-001 | 2026-11-04 | Trepidação (jitter) ao empurrar caixa para Cima/Laterais por histerese de contato e micro-separação | Adicionado buffer de persistência (0.15s), extensão do InteractionRay (+6px) e acoplamento de alvo empurrável | res://tests/test_push_physics.gd | PASS |
| REG-002 | 2026-11-04 | Ciclo incompleto de animação de empurrão (stutter/reset a frame 0) ao empurrar Cima/Laterais por dupla movimentação da caixa e chamadas repetidas de play() | Inclusão de trava _is_being_pushed no PushCrate, proteção em _play_push_animation (sem reinício de frame se mesma animação), registro de push_side e retenção de alvo por proximidade | res://tests/test_push_physics.gd | PASS |
| REG-003 | 2026-11-05 | Sobreposição/clipping de sprite do NPC e necessidade de colar no colisor para conversar | Ajustada colisão dos pés do NPC para 24x16 px em (0, -4), ativado y_sort_enabled em entidades e salas, e estendido InteractionRay do Player para 32px (cardinais) / 24px (diagonais) | res://tests/test_dialogue_system.gd | PASS |
| REG-004 | 2026-11-05 | Personagem caminhando parado durante conversa com NPC caso setas continuem pressionadas | Implementado force_idle() com transição imediata para State.IDLE, zeramento de velocidade, atualização da animação para idle_* e sincronização com DialogueManager.dialogue_started | res://tests/test_dialogue_system.gd | PASS |

---

## 5. Histórico de Versões de Engenharia
* **v0.1 (2026-11-04):** Formalização do documento `Engines.md`, matriz de regressão e diretrizes de conformidade estática.
* **v0.2 (2026-11-04):** Integração do addon AutoSprite (v1.0.0), ativação do plugin em project.godot e implementação da máquina de estados direcionais do Player com suporte a flip_h e fallback defensivo.
* **v0.3 (2026-11-04):** Configuração dos spritesheets importados do AutoSprite (Lucas Reis) em player_frames.tres com animações idle e walk em 4 direções e vinculação com AnimatedSprite2D no Player.
* **v0.4 (2026-11-04):** Evolução para movimentação e locomoção animada em 8 direções (cardinais e diagonais) com 18 animações em player_frames.tres, fatiamento angular por fposmod e fallback defensivo.
* **v0.5 (2026-11-04):** Mapeamento do conjunto completo de 88 animações em 8 direções (walk, idle, attack_axe, crouch, die, dodge, hurt, pull, push, sit, sleep), estruturação dos estados do jogador (IDLE, WALK, INTERACTING, ATTACKING, HURT, DEAD, RESTING), controle de dano/morte e bloqueio de locomoção em ações.
* **v0.6 (2026-11-04):** Implementação de limites dinâmicos de Camera2D (set_camera_limits), criação da AttackHitbox no Player e objeto interativo PushCrate com reação a dano de machado e empurrão físico.
* **v0.7 (2026-11-04):** Remoção de ataque da exploração, adição do RayCast2D de interação, refatoração da física de empurrão (requer segurar ação) e ajuste da colisão de base da caixa com prompt visual sutil.
* **v0.8 (2026-11-04):** Atualização do contrato de governança para estrutura de saída bilíngue e concisa (Task Report em inglês + Resumo Rápido para o Diretor em português).
* **v0.9 (2026-11-04):** Correção do bug REG-001 (eliminação de trepidação ao empurrar para Cima e Laterais via buffer de histerese de 0.15s e extensão de alcance do InteractionRay).
* **v0.10 (2026-11-04):** Correção do bug REG-002 (proteção contra reinício da animação de empurrão a frame 0, sincronização estrita de física da caixa com _is_being_pushed e garantia de loop completo de 16 passos).
* **v0.11 (2026-11-05):** Implementação da mecânica de puxar caixas interativas (F1.10 - Step 8): bloqueio de direção de visualização voltada para a caixa (facing lock sem inversão de 180°), sincronização física em pull_by, animações direcionais pull_* com proteção contra reset de frames e testes unitários em test_push_physics.gd.
* **v0.12 (2026-11-05):** Refinamento da animação de puxar para postura apoiada reversa (F1.11 - Step 8.1 - Option 2): reprodução reversa de push_<dir> com speed_scale proporcional (-pull_speed / 45.0), eliminação do efeito de remada solta, restauração estrita de speed_scale = 1.0 ao interromper e teste automatizado em test_push_physics.gd.
* **v0.13 (2026-11-05):** Sincronização de impulso rítmico com animação original pull_* (F1.12 - Step 8.1): preservação das animações originais de esforço intenso pull_* nas 8 direções, acoplamento de velocidade via curva de impulso (_get_pull_impulse_multiplier) com pico de tração nos frames de força e desaceleração nos frames de alcance dos braços, e testes unitários em test_push_physics.gd.
* **v0.14 (2026-11-05):** Implementação do SceneManager e pipeline de transição de salas (F1.13 - Step 9): singleton global com transição de fade preto (Tween 0.35s), bloqueio de inputs durante a transição, gatilho Doorway (Area2D), componente SpawnPoint (Marker2D), ambiente de testes dual com test_map e test_room_b, e suíte de testes em test_scene_manager.gd.
* **v0.15 (2026-11-05):** Início da Fase F2 - Sistema de Diálogos Clássico e NPC de Teste (F2.1 - Step 1): singleton global DialogueManager, caixa de diálogos inferior DialogueBox com máquina de escrever e suporte a retrato/speaker, estrutura DialogueLine, NPC interativo com orientação de olhar voltada para o jogador e suíte de testes em test_dialogue_system.gd.
* **v0.16 (2026-11-05):** Correção de colisão e distância de conversa do NPC (F2.2 - Step 1.1 / REG-003): expansão do colisor dos pés do NPC (24x16 px em 0, -4), ativação de y_sort_enabled (Player, NPC, TestRoomB, TestMap), extensão do InteractionRay para 32px cardinais / 24px diagonais para conversa a distância natural e testes em test_dialogue_system.gd.
* **v0.17 (2026-11-05):** Bloqueio de locomoção em diálogos (REG-004): implementação de `force_idle()` com transição de estado para `IDLE`, zeramento de velocidade, atualização imediata da animação para `idle_*` e desacoplamento de passos quando `not _can_walk()`, impedindo o efeito de caminhar parado ao segurar direcionais.
* **v0.19 (2026-11-05):** Integração de retratos HD-2D e expressões faciais no sistema de diálogo (F2.3 - Step 1.3): importação dos retratos de Lucas Reis (neutral, serious, shock, confident) em `res://assets/art/portraits/lucas/`, criação do `PortraitFrame` dedicado com borda e background no `DialogueBox`, suporte a proporção preservada (keep aspect centered) e renderização nítida sem blur, resolução dinâmica por tag de expressão, auto-colapso do painel para linhas sem retrato, textos narrativos padronizados em PT-BR e expansão dos testes em `test_dialogue_system.gd`.
* **v0.20 (2026-11-05):** Formalização do Guia de Direção de Arte e Personagens (*Art Bible*) em `res://docs/art_bible.md`: especificações técnicas para retratos de diálogo HD-2D (256x256 px, PNG transparente, enquadramento busto 3/4), ficha canônica e paleta de Lucas Reis, template de DNA visual para novos NPCs e fórmula padronizada de prompt para geração consistente de assets via IA.
* **v0.22 (2026-11-05):** Implementação do Menu de Pausa HD-2D para 4 heróis, Habilidades e Primordiais (F2.6 - Step 2.1): arquitetura de dados com `CharacterData` e singleton `PartyManager` (Lucas Reis nível 1 em slot 0 e slots 1..3 vazios reservados), interface de pausa expandida em `res://scenes/ui/pause_menu.tscn` com barras de PV/PM, comandos 100% em PT-BR (Itens, Habilidades, Primordiais, Equipamento, Status, Formação, Configurações, Salvar), seleção de personagens com banners informativos, rodapé com mapa, tempo e moedas, e suíte de testes em `res://tests/test_pause_menu.gd`.

