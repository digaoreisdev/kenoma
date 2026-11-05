# Kenoma — Guia de Direção de Arte e Personagens (Art Bible)

## 1. Diretrizes Técnicas Globais
* **Direção de Arte Geral:** HD-2D JRPG (inspiração em *Octopath Traveler*, *Bravely Default* e *Final Fantasy VI Pixel Remaster*).
* **Sprites de Exploração:** 16 direções/animações de alta definição pixel art com contorno escuro legível.
* **Retratos de Diálogo (Portraits / Facesets):**
  * **Dimensões:** 256x256 px (proporção 1:1).
  * **Fundo:** 100% Transparente (formato PNG-24).
  * **Enquadramento:** Plano busto (cabeça até a clavícula/fecho da capa), ângulo de 3/4 voltado para a direita.
  * **Estilo de Render:** Pintura digital com sombreamento em aquarela/óleo, olhos expressivos de anime clássico e linhas limpas.

---

## 2. Ficha de Personagem: Lucas Reis (Protagonista)

### Dados Visuais Canônicos
* **Idade Visual:** 18 anos (jovem adulto, semblante heróico, feições suaves, sem barba ou marcas senis).
* **Cabelo:** Branco-prateado brilhante, corte espetado rebelde com franja frontal.
* **Olhos:** Azul-elétrico expressivos, íris detalhada com ponto de brilho superior.
* **Vestuário Superior:** Capa azul-índigo com gola estruturada e fechos redondos de metal prateado; correias de couro marrom cruzando o peito sobre túnica cinza acolchoada.
* **Expressões Base (`res://assets/art/portraits/lucas/`):**
  * `lucas_neutral.png`: Postura serena, lábios cerrados, olhar frontal/3/4 equilibrado.
  * `lucas_serious.png`: Sobrancelhas arqueadas em concentração, semblante de combate.
  * `lucas_shock.png`: Olhos arregalados, boca entreaberta, surpresa/alerta.
  * `lucas_confident.png`: Sorriso sutil de canto, olhar amigável de determinação.

---

## 3. Template para Novos Personagens (DNA Visual)
Ao conceber novos NPCs ou membros da equipe, preencher:
1. **Nome / Função Narrativa:** (Ex: Guardião, Ferreiro, Curandeira).
2. **Silhueta Principal:** (Triangular/Pesada, Retangular/Esguia ou Redonda/Acolhedora).
3. **Cor Primária e Secundária:** Definir o contraste cromático contra o cenário.
4. **Conjunto Mínimo de Assets:**
   * **Sprite de mapa:** Idle nas 4 direções cardinais.
   * **Retrato:** Expressão Neutra (256x256 px) obrigatória; variações opcionais conforme relevância narrativa.

---

## 4. Fórmula Padrão de Prompt para IAs Visuais
> `HD-2D JRPG dialogue portrait, bust shot, character face, [IDADE E TIPO DO PERSONAGEM], [TRAÇOS FACIAIS E CABELO], [EXPRESSÃO], [VESTIMENTAS E ACESSÓRIOS], three-quarter angle looking slightly right, clean refined line art, Octopath Traveler and Bravely Default portrait art style, digital watercolor shading, solid neutral light background, high resolution illustration.`
