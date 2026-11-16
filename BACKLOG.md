# Backlog de Desenvolvimento e Arte - Kenoma

## 1. Backlog de Correção e Preparação de Imagens (Canvas)

### 🌿 A. Recorte e Otimização da Vegetação (`res://assets/art/props/vegetation/`)
* [ ] **Recorte de Canal Alfa:**
  * Remover fundos sólidos dos 9 JPEGs gerados por IA (`apple_tree_01`, `dead_tree_01`, `golden_oak_01`, `green_oak_01`, `green_pine_01`, `tall_cypress_01`, `weeping_willow_01`, `flower_bush_01`, `grass_tuft_01`).
  * Aplicar descontaminação de bordas (*defringe* / 1px) para evitar halos brancos ou cinzas.
* [ ] **Redimensionamento Proporcional (VRAM / Performance):**
  * Árvores (`trees/`): Redimensionar de ~2800px para **512x512 px** ou **768x768 px**.
  * Arbustos (`bushes/`): Redimensionar para **256x256 px**.
  * Tufos de Grama (`grass/`): Redimensionar para **128x128 px**.
* [ ] **Pivô e Alinhamento no Canvas:**
  * Alinhar a base da raiz/tronco encostada na borda inferior central (*Bottom-Center*) do canvas, deixando 2px de margem transparente na base para encaixe natural no chão sem flutuação.
* [ ] **Formato de Exportação:**
  * Salvar exclusivamente como **PNG 32-bit (RGBA8)** com canal alfa transparente.

---

### 🎨 B. Cenografia de Fundo da Vila (`res://assets/art/battle_backgrounds/baltazar_village/`)
* [ ] **Pintura de Fundo (Horizonte / Céu e Montanhas):**
  * Pintura panorâmica em proporção 16:9 (**1920x1080 px**) representando o céu e as montanhas ao entardecer.
* [ ] **Texturas Seamless de Solo (Ladrilháveis):**
  * Textura seamless de calçamento/pedra rústica (**512x512 px** ou **1024x1024 px**).
  * Textura seamless de grama terrosa (**512x512 px** ou **1024x1024 px**).

---

### ⚔️ C. Spritesheets e Heróis Pendentes
* [ ] **Heroína Dai (`res://assets/art/characters/heroes/dai/`):**
  * Criar a pasta oficial de sprites da Dai.
  * Exportar spritesheets das animações direcionais e gerar o recurso `Dai_frames.tres` para integrar aos já existentes (`Lucas`, `Davi`, `Cassian`).

---

## 2. Backlog de Construção da Cena de Batalha (Do Zero)

* [ ] **Fase 1: Piso / Terreno Confiável:**
  * Configurar piso contínuo nivelado em `Y = 0` (via `terreno_batalha.gd` ou malha plana retilínea) garantindo que nenhum sprite ou modelo 3D afunde ou flutue.
* [ ] **Fase 2: Posicionamento dos Combatentes (Billboard HD-2D):**
  * Aliados (Lucas, Davi, Dai) posicionados no lado direito da praça olhando para a esquerda.
  * Inimigos (General Cassian e esquadrão) posicionados no lado esquerdo olhando para a direita.
  * Configurar `BillboardMode = BILLBOARD_FIXED_Y`, `TextureFilter = Nearest` e `Shaded = true` para projeção de sombras realistas.
* [ ] **Fase 3: Cenografia 3D e Vegetação em Profundidade (-Z):**
  * Dispor as construções 3D da vila (`casa_medieval1`, `casa_medieval2`, `casa_forja_medieval`) no plano de fundo (-Z) sobre patamar elevado.
  * Adicionar rochas 3D (`rocha_com_musgo1`, `rock_cluster`) e árvores 2D tratadas para enriquecer o horizonte.
* [ ] **Fase 4: Iluminação e Enquadramento de Câmera:**
  * Configurar `Camera3D` em perspectiva com FOV de 30° a 35° e inclinação de ~30° para baixo.
  * `DirectionalLight3D` com cor dourada suave (entardecer) e sombras suaves (*Soft Shadows*).
  * `WorldEnvironment` calibrado com névoa volumétrica sutil e glow moderado.

---

## 3. Catálogo de Modelos 3D Prontos para Uso (`res://assets/models/`)

Todos os modelos abaixo foram auditados, importados no Godot 4.7.2 e estão prontos para compor cenas:

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
