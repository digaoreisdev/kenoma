# Backlog de Desenvolvimento e Arte - Kenoma

## 1. Backlog de Correção e Preparação de Imagens (Canvas)

### 🌿 A. Recorte e Otimização da Vegetação (`res://assets/art/props/vegetation/`)
* [x] **Arbustos (11 assets calibrados em 256x256 RGBA8):** Concluído (defringing, remoção de fundo branco, centralização com padding inferior Y=0).
* [x] **Árvores (7 assets calibrados em 512x512 / 768x768 RGBA8):** Concluído (transparência completa, proporções normalizadas).
* [x] **Tufos de Grama (`grass/`):**
  * `assets/art/props/vegetation/grass/grass_tuft_01.png`: Concluído (recortado, defringed, ancorado na base e salvo em 256x256 px PNG RGBA8).
* [ ] **Retratos com Fundo Branco:**
  * `assets/art/portraits/dai/dai_kind.png` e `dai_worried.png`: Remover fundo branco sólido, convertendo para RGBA8 transparente.

---

### 🎨 B. Cenografia de Fundo da Vila (`res://assets/art/battle_backgrounds/baltazar_village/`)
* [x] **Pintura de Fundo (Horizonte / Céu e Montanhas):**
  * Concluído: `battle_bg_forge_village.png` (1920x1080 px PNG) salvo em `res://assets/art/battle_backgrounds/baltazar_village/`.
* [x] **Texturas Seamless de Solo (Ladrilháveis):**
  * Texturas para `res://assets/art/textures/terrain/`: `grass_01.png`, `dirt_01.png`, `cobblestone_01.png`, `stone_slabs_01.png`, `grass_blades_01.png`, `grass_worn_01.png` calibradas em 1024x1024 px PNG com repetição sem costuras.

---

### ⚔️ C. Spritesheets e Heróis Pendentes
* [ ] **Heroína Dai (`res://assets/art/characters/heroes/dai/`):**
  * Criar a pasta oficial de sprites da Dai.
  * Exportar spritesheets das animações direcionais e gerar o recurso `Dai_frames.tres` para integrar aos já existentes (`Lucas`, `Davi`, `Cassian`).

---

## 2. Construção da Cena de Batalha 3D: Vila do Baltazar (`village_battle_3d.tscn`)

### 🎯 Visão Geral e Contexto
- **Gênero / Estilo:** RPG de turnos HD-2D para PC na Steam (Godot 4.x, renderer Forward+).
- **Referência Visual:** *Eiyuden Chronicle* (campo com relevo suave, pedras, grama alta, câmera alta e inclinada, personagens em alturas e posições escalonadas).
- **Arquitetura:** Camada de APRESENTAÇÃO pura (`village_battle_3d.tscn` / `village_battle_3d.gd`). Não altera o motor de turnos, lógica de dano ou dados existentes. Apenas escuta os sinais do `BattleManager` e orquestra animações, câmera, efeitos e HUD.
- **Roster do Confronto:** 2 Heróis Aliados (**Lucas** e **Davi**) contra 1 Inimigo Chefe (**General Cassian**).
- **Isolamento:** Cenas anteriores (`battle_scene.tscn`, `battle_scene_3d.tscn`, `BatalhaVila.tscn`) mantidas intactas como fallback e referência.

### 📐 Tabela de Componentes da Cena

| Peça | Nó / Tipo | Fonte / Recurso | Status |
| :--- | :--- | :--- | :--- |
| **Terreno** | `Node3D "Terrain"` + `TerrenoBatalha` | `res://scripts/battle/terreno_batalha.gd` | Existe (calibrar relevo) |
| **Grama em Tufos** | `MultiMeshInstance3D "Grass"` + `CampoGrama` | `campo_grama.gd` (filho do Terrain) + tufo PNG | **A criar** (`campo_grama.gd`) |
| **Iluminação** | `DirectionalLight3D` dourada + sombras PSSM 4 divisões | Cor `#FFD9A0`, rotação `(-45, 35, 0)` | A criar |
| **Ambiente** | `WorldEnvironment` | Forward+ (Glow, ACES tonemap, SSAO, Névoa volumétrica quente) | A criar |
| **Fundo Distante** | Quad 3D `"Backdrop"` (céu e montanhas) | `battle_bg_forge_village.png` ou céu procedural | A criar / placeholder |
| **Casas e Forja** | `Node3D "Buildings"` | `casa_forja_medieval.glb`, `casa_medieval1.glb`, `casa_medieval2.glb` | A instanciar |
| **Props 3D** | `Node3D "Props"` | `bau_madeira_aberto.glb`, rochas clusters | A instanciar |
| **Pedra Plana Elevada** | Modelo de rocha com topo plano + `StaticBody3D` | Canto inferior direito da praça | A criar / placeholder |
| **Árvores e Moitas** | `Sprite3D` billboard em `"Vegetation"` | 11 arbustos e 7 árvores RGBA8 em `props/vegetation/` | A instanciar |
| **Slots de Combate** | `Node3D "Slots"` com `Marker3D` | 6 aliados (`ally_1..6`) e 6 inimigos (`enemy_1..6`) + slots elevados | A criar |
| **Combatentes** | `AnimatedSprite3D` billboard em `"Combatants"` | `player_frames.tres`, `Davi_Reis_frames.tres`, `General_Cassian_frames.tres` | A instanciar |
| **Sombras dos Sprites** | `Decal` ou disco escuro sob cada sprite | Acompanhando altura do solo/slot | A criar |
| **Câmera** | `Node3D "CameraRig"` > `Camera3D` | FOV 28-38, funções `focus_on`, `reset_view`, `shake`, `orbit`, DOF | A criar |
| **Anel de Alvo / Turno** | `Decal` ou quad emissivo | Rotação suave e pulso sob o ator ativo / alvo selecionado | A criar |
| **Impacto e Golpes** | `GPUParticles3D` / sprite aditivo | Faíscas laranja/brancas, flash, arco de corte | A criar |
| **Números de Dano** | `Label3D` animado billboard | Movimento ascendente + fade out, cores para dano/cura/crítico | A criar |
| **Fogo e Luz da Forja** | Quad emissivo + `OmniLight3D` com flicker | Fogo na forja + luz pulsante | A criar |
| **Fumaça da Chaminé** | `GPUParticles3D` | Fumaça cinza subindo suavemente | A criar |
| **UI de Combate** | `CanvasLayer` | Reutilizar HUD e ActionCommandPanel da UI existente | A integrar |
| **Configurações Gráficas** | Autoload `GraphicsSettings` | Presets Baixo, Médio, Alto (Steam Deck / PCs fracos) | A criar |

---

### 🚀 Fases de Implementação e Checkpoints

#### Fase 0: Leitura e Auditoria de Dependências (CONCLUÍDO)
* [x] Mapeamento dos sinais do `BattleManager`: `battle_state_changed`, `battle_initialized`, `combatant_ready_for_action`, `action_executed`, `rupture_triggered`, `spell_interrupted`, `acao_concluida`, `battle_finished`.
* [x] Identificação da cena ativa do jogo: `res://scenes/maps/test_map.tscn` (com `SceneManagerSingleton` chamando `res://scenes/battle/battle_scene.tscn`).
* [x] Auditoria de modelos 3D (10 GLBs) e vegetação 2D (18 sprites RGBA8).
* [x] Diagnóstico de scripts ausentes: `campo_grama.gd` e pasta `textures/terrain/`.

#### Fase 1: Cenário Estático (CHECKPOINT A - CONCLUÍDO)
* [x] Criar `res://scenes/battle/village_battle_3d.tscn` e `res://scripts/battle/village_battle_3d.gd`.
* [x] Câmera de referência: FOV 32, posição `(0, 9, 24)`, rotação `(-24, 0, 0)`.
* [x] Terreno via `TerrenoBatalha`: praça plana na frente, subida suave ao fundo, ondulação sutil (`celula = 0.25`, `altura_subida = 5.2`, `amp_ondulacao = 0.9`).
* [x] Iluminação dourada (`#FFD9A0`) com sombras PSSM 4 splits e `WorldEnvironment` (Glow, Tonemap ACES, SSAO, névoa leve).
* [x] Backdrop / Céu distante com `battle_bg_forge_village.png` (unshaded a 95m ao fundo).
* [x] Posicionamento de casas e forja ao longo da rua com `posicionar_no_chao()` e verificação de inclinação (< 6°).
* [x] Dispersão de props 3D (baú, rochas) e pedra plana elevada (`ElevatedRock`) com colisão cilíndrica uniforme Jolt.
* [x] Vegetação 2D (árvores e arbustos em `Sprite3D` com `BILLBOARD_FIXED_Y`, `shaded = true`).
* [x] Implementação de `campo_grama.gd` e `MultiMeshInstance3D` para tufos de grama fora da praça de combate.
* [x] Validação visual e teste headless do Godot (0 erros).

#### Fase 2: Combatentes e Câmera (CHECKPOINT B)
* [ ] Criação dos slots de combate (`ally_1..6`, `enemy_1..6`) e slots na rocha elevada com ajuste de altura via Raycast.
* [ ] Instanciação dos combatentes em `AnimatedSprite3D` (Lucas, Davi, Cassian) com alinhamento pé no chão e sombra (Decal).
* [ ] Criação do `CameraRig`: interpolação suave (Tween) para `focus_on`, `reset_view`, `shake`, `orbit` e modo respiração.
* [ ] Configuração do DOF (`CameraAttributesPractical`) mantendo a praça nítida e desfocando primeiro plano e fundo.
* [ ] Teclas de atalho para debug de câmera e foco.

#### Fase 3: Efeitos e Integração com Lógica de Batalha (CHECKPOINT C)
* [ ] Anel de seleção de alvo e anel de turno ativo pulsante.
* [ ] Partículas e efeitos de impacto (faíscas, corte em arco, shake de câmera no impacto).
* [ ] Labels de dano e cura flutuantes em `Label3D`.
* [ ] Efeitos visuais na forja do Baltazar: luz oscilante (`OmniLight3D` flicker) e fumaça na chaminé.
* [ ] Conexão aos sinais do `BattleManager` orquestrando o fluxo sem alterar a lógica.
* [ ] Integração do HUD 2D (`CanvasLayer`) com menus de ação, barras de HP/MP e timeline.

#### Fase 4: Qualidade, Otimização e Limpeza
* [ ] Autoload `GraphicsSettings` com presets (Baixo, Médio, Alto) controlando sombras, grama, SSAO, DOF e névoa.
* [ ] Otimização de draw calls com `MultiMesh` e desativação de projeção de sombra em grama.
* [ ] Relatório final de entrega e atualização do `Engines.md`.

---

## 3. Catálogo de Modelos 3D Prontos para Uso (`res://assets/models/`)

| Categoria | Modelo | Arquivo GLB | Materiais / Texturas |
| :--- | :--- | :--- | :--- |
| **Animais** | Labrador Companion | `models/animals/labrador/Labrador_AllAnimations.glb` | PBR Completo (BaseColor, Normal, Roughness) + Rigs e Animações |
| **Casas** | Forja Medieval | `models/houses/casa_forja_medieval/casa_forja_medieval.glb` | Textura UV aplicada |
| **Casas** | Casa Medieval 1 | `models/houses/casa_medieval1/casa_medieval1.glb` | PBR (BaseColor, Normal, RM) |
| **Casas** | Casa Medieval 2 | `models/houses/casa_medieval2/casa_medieval2.glb` | Textura UV aplicada |
| **Props** | Baú de Madeira Aberto | `models/props/bau_madeira_aberto/bau_madeira_aberto.glb` | PBR (BaseColor, Normal, RM) em todas as peças |
| **Props** | Tufo de Grama Neve | `models/props/vegetation/grass/snow_grass_tuft_01/snow_grass_tuft_01.glb` | Malha 3D estilizada |
| **Rochas** | Rocha com Musgo | `models/rocks/rocha_com_musgo1/rocha_com_musgo1.glb` | PBR (BaseColor, Normal, RM) |
| **Rochas** | Formação Rochosa 1 | `models/rocks/rock_cluster_01/rock_cluster_01.glb` | Malha 3D estilizada |
| **Rochas** | Formação Rochosa 2 | `models/rocks/rock_cluster_02/rock_cluster_02.glb` | Malha 3D estilizada |
| **Rochas** | Formação Rochosa 3 | `models/rocks/rock_cluster_03/rock_cluster_03.glb` | Malha 3D estilizada |
