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
* **Ambiente de Desenvolvimento:** Windows (desenvolvimento focado no PC durante os passos iniciais).
* **Plataformas-Alvo:** PC e Android.
* **Estratégia Mobile:** Desenvolvimento inicial no PC, implementação e mapeamento dos controles touch na Fase F1, e realização do primeiro teste em celular Android físico no encerramento da F1.

## Respostas do Criador
* Estrutura de produção solo orientada a vertical slice antes da expansão de conteúdo.
* Arte com IA assistida (AutoSprite + geradores de imagem para tilesets e cenários).
* GDScript tipado para robustez, legibilidade e suporte a autocompletar eficiente.

## Fase Atual
* **F0 - Preparação e Infraestrutura Básica** (Passo 2 concluído).

## Passos Concluídos
* [x] **F0.1:** Verificação da raiz do projeto, criação do `PROJETO.md` e configuração dos arquivos de versionamento (`.gitignore` e `.gitattributes`).
* [x] **F0.2:** Criação da estrutura de pastas padronizada com `.gitkeep`, ajustes de viewport, stretch e filtro de textura no `project.godot`, definição de diretrizes em `AGENTS.md` e atualização do `PROJETO.md`.

## Backlog (Depois / Talvez)
* **Depois:**
  * Implementação da vertical slice (movimentação, transição de mapa, combate por turnos).
  * Reavaliar `window/stretch/aspect` (keep vs expand) para telas de celular com proporções ultra-wide (ex: 19.5:9, 20:9) durante a Fase F1.
* **Talvez:**
  * Integração de elementos 3D com `Sprite3D` (HD-2D híbrido) — avaliar somente se o desempenho no celular Android físico permitir mantendo taxa de quadros estável.

## Problemas em Aberto
1. **Dispositivo móvel alvo:** Coletar o modelo exato e versão do Android do smartphone do criador no fim da Fase F1 para validar os testes.
2. **Consistência visual:** Monitorar e mitigar o risco de divergência de estilo nas artes geradas por IA (definição de pipeline e regras de estilo na Fase F2).
3. **Tamanho do tile:** Pendente de definição (recomendado 32 px; decidir antes da Fase F2).
4. **Exportação do AutoSprite:** Confirmar se o AutoSprite exporta os spritesheets em 48x64 px com filtro Nearest.
