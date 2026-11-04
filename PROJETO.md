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
* **Limites de Câmera 2D:** Método `set_camera_limits()` no jogador vincula os limites da `Camera2D` às dimensões reais do mapa atual, eliminando a visão do vazio além das bordas.
* **Hitbox e Objetos Interativos:** `AttackHitbox` (`Area2D` na camada de colisão 2) ativada exclusivamente na janela de impacto do machado. Cena interativa `PushCrate` reage a dano e empurrão físico.

## Respostas do Criador
* Estrutura de produção solo orientada a vertical slice antes da expansão de conteúdo.
* Arte com IA assistida (AutoSprite + geradores de imagem para tilesets e cenários).
* GDScript tipado para robustez, legibilidade e suporte a autocompletar eficiente.

## Fase Atual
* **F1 - Fundação de Gameplay & Movimentação** (Passo 6 concluído).

## Passos Concluídos
* [x] **F0.1:** Verificação da raiz do projeto, criação do `PROJETO.md` e configuração dos arquivos de versionamento (`.gitignore` e `.gitattributes`).
* [x] **F0.2:** Criação da estrutura de pastas padronizada com `.gitkeep`, ajustes de viewport, stretch e filtro de textura no `project.godot`, definição de diretrizes em `AGENTS.md` e atualização do `PROJETO.md`.
* [x] **F1.1:** Configuração do `Input Map` semântico no `project.godot` (teclado e gamepad), implementação do singleton `GameState`, desenvolvimento da cena e script `CharacterBody2D` do Player (com colisão nos pés, ColorRect temporário e Camera2D 3x), e construção do mapa de testes sandbox (`test_map.tscn`) definido como cena principal.
* [x] **F1.2:** Integração do addon oficial AutoSprite em `addons/autosprite/` e ativação no `project.godot`, criação da pasta de assets para sprites do jogador (`res://assets/art/characters/player/`), implementação da máquina de direções e animações no `player.gd` com `AnimatedSprite2D` e fallback defensivo visual.
* [x] **F1.3:** Organização dos assets gerados pelo AutoSprite em `res://assets/art/characters/player/`, criação do recurso `SpriteFrames` (`player_frames.tres`) com `walk_down`, `walk_up`, `walk_side` e seus respectivos idles, e vinculação com `AnimatedSprite2D` no `player.tscn` com ocultamento do placeholder visual.
* [x] **F1.4:** Evolução para locomoção e animações completas em 8 direções no `player.gd` (cálculo de 8 ângulos via `fposmod`/`round`), geração de 18 animações dedicadas em `player_frames.tres` utilizando spritesheets diagonais e cardinais reais do AutoSprite, com fallback defensivo para direções cardinais.
* [x] **F1.5:** Mapeamento completo de 88 animações nas 8 direções no `player_frames.tres` (11 ações x 8 orientações: walk, idle, attack_axe, crouch, die, dodge, hurt, pull, push, sit, sleep), expansão da máquina de estados do Player (IDLE, WALK, INTERACTING, ATTACKING, HURT, DEAD, RESTING), vinculação do ataque com machado ao botão de interação (Espaço/Enter/Gamepad A), bloqueio de locomoção em ações e emissão de sinais de vida e estado.
* [x] **F1.6:** Implementação de limites dinâmicos da `Camera2D` vinculados ao mapa sandbox, inclusão da `AttackHitbox` direcional no Player, criação da cena de objeto interativo `PushCrate` (reação a dano de machado com flash e física de empurrão), e posicionamento de 2 caixas no `test_map.tscn`.

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
