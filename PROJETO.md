# Kenoma - Documento de Projeto

## Visão Geral
* **Gênero:** RPG 2D top-down (estilo *Final Fantasy VI*, com visual HD-2D).
* **Escopo-alvo:** Jogo completo (20h+ de campanha), desenvolvido primeiramente através de uma *vertical slice* jogável.
* **Equipe:** Criador solo.
* **Arte:** Gerada por Inteligência Artificial (personagens animados via AutoSprite; tiles, tilesets, mapas e cenários a partir de imagens de IA).
* **Código:** Desenvolvido em conjunto com IA no Antigravity.
* **Caminho do Projeto:** `C:\Users\rodrigo.reis\Projetos\Kenoma`
* **Repositório Remoto:** `https://github.com/digaoreisdev/kenoma.git`

## Decisões Técnicas
* **Engine:** Godot Engine 4.7.2 Standard (sem runtime .NET/C#).
* **Linguagem:** GDScript estritamente tipado.
* **Renderizador:** `Compatibility` (otimizado para compatibilidade ampla e desempenho em dispositivos móveis; será reavaliado na Fase F8 se houver necessidade de shaders avançados).
* **Resolução Base:** Viewport 1280x720 (16:9).
* **Modo de Stretch:** `canvas_items` com aspect `keep`.
* **Filtro de Textura 2D:** `Nearest` (`textures/canvas_textures/default_texture_filter=0`) para preservar a nitidez da pixel art.
* **Dimensões de Sprites de Personagem:** Quadro de 48x64 px (largura x altura). Origem de desenho no ponto dos pés (a confirmar).
* **Velocidade Base do Jogador:** 120.0 px/s com normalização vetorial e `move_and_slide()`.
* **Câmera de Exploração:** `Camera2D` centrada no jogador com zoom 3x e suavização ativa.
* **Ciclo de Vida Global:** Gerenciado pelo singleton `GameState` com estados `EXPLORATION`, `DIALOGUE`, `BATTLE`, `PAUSE`.
* **Addon AutoSprite:** Plugin instalado em `res://addons/autosprite/` e ativado em `project.godot` para importação e geração de `SpriteFrames`.
* **Animações e Direções do Personagem:** Locomoção e posturas completas em 8 direções (`DOWN`, `UP`, `LEFT`, `RIGHT`, `DOWN_RIGHT`, `DOWN_LEFT`, `UP_RIGHT`, `UP_LEFT`) e 2 modos (`IDLE`, `WALK`), mapeadas para 18 animações dedicadas no `SpriteFrames` (`idle_*`, `walk_*`) com cálculo angular normalizado e fallback defensivo para direções cardinais.
* **Suíte Completa de Ações do Personagem:** 88 animações em 8 direções cadastradas em `player_frames.tres` cobrindo `walk`, `idle`, `attack_axe`, `crouch`, `die`, `dodge`, `hurt`, `pull`, `push`, `sit` e `sleep`. A máquina de estados do jogador gerencia `IDLE`, `WALK`, `INTERACTING`, `ATTACKING`, `HURT`, `DEAD` e `RESTING`, com bloqueio automático da física de caminhada durante execuções de ação.
* **Ambiente de Desenvolvimento:** Windows (desenvolvimento focado no PC durante os passos iniciais).
* **Plataformas-Alvo:** Foco estrito em PC (Steam / Desktop) com suporte total a Teclado e Gamepad.
* **Interação e Exploração JRPG:** Exploração sem ataque direto com machado. O jogador utiliza um `RayCast2D` de interação direcional e aciona empurrão físico exclusivamente ao segurar a tecla de ação (`action_interact`).
* **Limites de Câmera 2D:** Método `set_camera_limits()` no jogador vincula os limites da `Camera2D` às dimensões reais do mapa atual, eliminando a visão do vazio além das bordas.

## Respostas do Criador
* Estrutura de produção solo orientada a vertical slice antes da expansão de conteúdo.
* Arte com IA assistida (AutoSprite + geradores de imagem para tilesets e cenários).
* GDScript tipado para robustez, legibilidade e suporte a autocompletar eficiente.

## Fase Atual
* **F2 - Narrativa & UI** (Passo 1 concluído).

## Passos Concluídos
* [x] **F0.1:** Verificação da raiz do projeto, criação do `PROJETO.md` e configuração dos arquivos de versionamento (`.gitignore` e `.gitattributes`).
* [x] **F0.2:** Criação da estrutura de pastas padronizada com `.gitkeep`, ajustes de viewport, stretch e filtro de textura no `project.godot`, definição de diretrizes em `AGENTS.md` e atualização do `PROJETO.md`.
* [x] **F1.1:** Configuração do `Input Map` semântico no `project.godot` (teclado e gamepad), implementação do singleton `GameState`, desenvolvimento da cena e script `CharacterBody2D` do Player (com colisão nos pés, ColorRect temporário e Camera2D 3x), e construção do mapa de testes sandbox (`test_map.tscn`) definido como cena principal.
* [x] **F1.2:** Integração do addon oficial AutoSprite em `addons/autosprite/` e ativação no `project.godot`, criação da pasta de assets para sprites do jogador (`res://assets/art/characters/player/`), implementação da máquina de direções e animações no `player.gd` com `AnimatedSprite2D` e fallback defensivo visual.
* [x] **F1.3:** Organização dos assets gerados pelo AutoSprite em `res://assets/art/characters/player/`, criação do recurso `SpriteFrames` (`player_frames.tres`) com `walk_down`, `walk_up`, `walk_side` e seus respectivos idles, e vinculação com `AnimatedSprite2D` no `player.tscn` com ocultamento do placeholder visual.
* [x] **F1.4:** Evolução para locomoção e animações completas em 8 direções no `player.gd` (cálculo de 8 ângulos via `fposmod`/`round`), geração de 18 animações dedicadas em `player_frames.tres` utilizando spritesheets diagonais e cardinais reais do AutoSprite, com fallback defensivo para direções cardinais.
* [x] **F1.5:** Mapeamento completo de 88 animações nas 8 direções no `player_frames.tres` (11 ações x 8 orientações: walk, idle, attack_axe, crouch, die, dodge, hurt, pull, push, sit, sleep), expansão da máquina de estados do Player (IDLE, WALK, INTERACTING, ATTACKING, HURT, DEAD, RESTING), vinculação do ataque com machado ao botão de interação (Espaço/Enter/Gamepad A), bloqueio de locomoção em ações e emissão de sinais de vida e estado.
* [x] **F1.6:** Implementação de limites dinâmicos da `Camera2D` vinculados ao mapa sandbox, inclusão da `AttackHitbox` direcional no Player, criação da cena de objeto interativo `PushCrate` (reação a dano de machado com flash e física de empurrão), e posicionamento de 2 caixas no `test_map.tscn`.
* [x] **F1.7:** Remoção do ataque com machado na exploração, inclusão de `InteractionRay` no Player com detecção de proximidade, refatoração da física de empurrão (requer segurar `action_interact`), ajuste da colisão de base da caixa (`Vector2(24, 10)`) e prompt visual sutil com fade in/out.
* [x] **F1.8 (Bugfix):** Correção de trepidação (jitter) no empurrão nas direções Cima e Laterais (REG-001) com extensão de 6px no InteractionRay, buffer de persistência de 0.15s e teste unitário automatizado em test_push_physics.gd.
* [x] **F1.9 (Bugfix):** Resolução do ciclo incompleto de animação de empurrão (REG-002): sincronização de movimentação física única no PushCrate (_is_being_pushed), proteção contra reinício de frame em _play_push_animation, cadastro de push_side (16 frames, loop) e ampliação de testes em test_push_physics.gd.
* [x] **F1.10 (Passo 8):** Implementação da mecânica de puxar objetos interativos (Pull): bloqueio direcional com facing lock ao se afastar da caixa segurando ação, execução de animações pull_* nas 8 direções com proteção de ciclo completo, sincronização de movimentação pull_by no PushCrate e testes automatizados em test_push_physics.gd.
* [x] **F1.11 (Passo 8.1 - Opção 2):** Refinamento da animação de puxar para postura apoiada reversa: reprodução reversa de push_<dir> com speed_scale proporcional (-pull_speed / 45.0), mantendo as mãos firmemente apoiadas na caixa ao recuar, restauração garantida de speed_scale = 1.0 ao soltar e testes automatizados em test_push_physics.gd.
* [x] **F1.12 (Passo 8.1 - Sincronização Rítmica):** Preservação do conjunto original de animações pull_* com sincronização física rítmica por frame (_get_pull_impulse_multiplier): alta tração no golpe de puxar e desaceleração na extensão dos braços, eliminando o deslizamento constante com esforço pesado convincente.
* [x] **F1.13 (Passo 9):** Implementação do singleton global SceneManager com transições suaves em fade out/in (Tween preto 0.35s), bloqueio de inputs durante a transição, criação dos componentes Doorway (Area2D) e SpawnPoint (Marker2D), ambiente de testes dual com test_map e test_room_b, e testes em test_scene_manager.gd.
* [x] **F2.1 (Passo 1):** Implementação do sistema de diálogos clássico JRPG: singleton global DialogueManager, caixa de diálogos DialogueBox com máquina de escrever e suporte a retratos, estrutura de dados DialogueLine, NPC interativo com orientação de olhar voltada para o jogador e suíte de testes automatizados em test_dialogue_system.gd.
* [x] **F2.2 (Passo 1.1):** Correção de colisão e distância de conversa do NPC (REG-003): ampliação da caixa de colisão dos pés do NPC para 24x16 px em (0, -4), ativação de renderização em profundidade vertical (y_sort_enabled) nas entidades e cenários de teste, extensão do alcance do InteractionRay para 32 px (cardinais) e 24 px (diagonais) viabilizando interação sem contato físico excessivo e novos testes em test_dialogue_system.gd.

## Backlog (Depois / Talvez)
* **Depois:**
  * Implementação da vertical slice (transição de mapa, combate por turnos).
  * Reavaliar `window/stretch/aspect` (keep vs expand) para telas de celular com proporções ultra-wide (ex: 19.5:9, 20:9) durante a Fase F1.
  * Criação dos controles virtuais na tela (D-pad virtual / touch) para mobile no fim da Fase F1.
* **Talvez:**
  * Integração de elementos 3D com `Sprite3D` (HD-2D híbrido) — avaliar somente se o desempenho no celular Android físico permitir mantendo taxa de quadros estável.

## Problemas em Aberto
1. **Dispositivo móvel alvo:** Coletar o modelo exato e versão do Android do smartphone do criador no fim da Fase F1 para validar os testes.
2. **Consistência visual:** Monitorar e mitigar o risco de divergência de estilo nas artes geradas por IA (definição de pipeline e regras de estilo na Fase F2).
3. **Tamanho do tile:** Pendente de definição (recomendado 32 px; decidir antes da Fase F2).
4. **Exportação do AutoSprite:** Confirmar se o AutoSprite exporta os spritesheets em 48x64 px com filtro Nearest.
