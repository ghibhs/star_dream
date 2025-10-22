# 🎨 GUIA DE SPRITES PARA ITENS

## 📍 Localização dos Arquivos

Coloque os sprites de itens na pasta:
```
art/items/
```

## 🖼️ Itens Criados e Seus Sprites

### 1. **Poção de Vida** (health_potion.tres)
- **Arquivo atual**: `art/moeda_game1.png` (temporário)
- **Sprite recomendado**: Frasco vermelho/rosa
- **Nome sugerido**: `health_potion.png`
- **Tamanho**: 32x32 ou 64x64 pixels

### 2. **Poção de Mana** (mana_potion.tres)
- **Arquivo atual**: `art/icon.svg` (ícone padrão Godot)
- **Sprite recomendado**: Frasco azul/ciano
- **Nome sugerido**: `mana_potion.png`
- **Tamanho**: 32x32 ou 64x64 pixels

### 3. **Poção de Stamina** (stamina_potion.tres)
- **Arquivo atual**: `art/icon.svg`
- **Sprite recomendado**: Frasco verde/amarelo
- **Nome sugerido**: `stamina_potion.png`
- **Tamanho**: 32x32 ou 64x64 pixels

### 4. **Elixir de Velocidade** (speed_elixir.tres)
- **Arquivo atual**: `art/icon.svg`
- **Sprite recomendado**: Frasco com símbolo de raio/vento
- **Nome sugerido**: `speed_elixir.png`
- **Tamanho**: 32x32 ou 64x64 pixels

### 5. **Poção de Força** (strength_potion.tres)
- **Arquivo atual**: `art/icon.svg`
- **Sprite recomendado**: Frasco laranja/roxo com símbolo de punho
- **Nome sugerido**: `strength_potion.png`
- **Tamanho**: 32x32 ou 64x64 pixels

### 6. **Mega Poção de Vida** (mega_health_potion.tres)
- **Arquivo atual**: `art/icon.svg`
- **Sprite recomendado**: Frasco vermelho grande/brilhante
- **Nome sugerido**: `mega_health_potion.png`
- **Tamanho**: 32x32 ou 64x64 pixels

---

## 🔧 Como Atualizar os Sprites

### Método 1: Editar Diretamente o .tres (mais rápido)
1. Coloque o sprite em `art/items/nome_do_sprite.png`
2. Abra o arquivo `.tres` correspondente
3. Localize a linha: `[ext_resource type="Texture2D" path="res://art/icon.svg" id="2_icon"]`
4. Substitua por: `[ext_resource type="Texture2D" path="res://art/items/nome_do_sprite.png" id="2_icon"]`

### Método 2: Pelo Godot Editor
1. Abra o Godot
2. Navegue até `resources/items/`
3. Clique duas vezes no arquivo `.tres`
4. No inspetor, localize a propriedade `Icon`
5. Arraste o sprite da pasta `art/items/` para o campo

---

## 📦 Estrutura de Pastas Recomendada

```
test_v02/
├── art/
│   ├── items/              ← CRIAR ESTA PASTA
│   │   ├── health_potion.png
│   │   ├── mana_potion.png
│   │   ├── stamina_potion.png
│   │   ├── speed_elixir.png
│   │   ├── strength_potion.png
│   │   └── mega_health_potion.png
│   ├── weapons/            ← Para sprites de armas
│   └── enemies/            ← Para sprites de inimigos
└── resources/
    └── items/
        ├── health_potion.tres
        ├── mana_potion.tres
        ├── stamina_potion.tres
        ├── speed_elixir.tres
        ├── strength_potion.tres
        └── mega_health_potion.tres
```

---

## 🎨 Recomendações de Design

### Cores Sugeridas:
- **Vida**: Vermelho/Rosa (#FF0000)
- **Mana**: Azul/Ciano (#0080FF)
- **Stamina**: Verde/Amarelo (#00FF00 / #FFFF00)
- **Velocidade**: Branco/Azul claro com raios
- **Força**: Laranja/Roxo (#FF8000 / #8000FF)
- **Mega Vida**: Vermelho intenso com brilho

### Estilo:
- Frascos com líquidos coloridos
- Bordas escuras para contraste
- Brilho/reflexos para indicar qualidade
- Símbolos opcionais (cruz para vida, gota para mana, etc.)

---

## 🔍 Onde Encontrar Sprites Gratuitos

1. **OpenGameArt.org** - https://opengameart.org/
2. **Itch.io Assets** - https://itch.io/game-assets/free
3. **Kenney.nl** - https://kenney.nl/assets (diversos packs gratuitos)
4. **Craftpix.net** - https://craftpix.net/freebies/

### Busca Recomendada:
- "potion pixel art"
- "RPG items 32x32"
- "consumables sprite sheet"

---

## ✅ Checklist de Implementação

- [x] Arquivos `.tres` criados
- [x] Items adicionados ao teste do player
- [ ] Criar pasta `art/items/`
- [ ] Baixar/criar sprites dos items
- [ ] Atualizar referências nos arquivos `.tres`
- [ ] Testar no jogo

---

## 🚀 Próximos Passos

Depois de adicionar os sprites:
1. Rode o jogo e abra o inventário (TAB)
2. Você verá 17 items no total (5+3+4+2+2+1)
3. Double-click em qualquer item para usá-lo
4. Poções de buff (velocidade/força) aplicarão efeitos temporários
5. Poções de restauração aumentarão vida/mana/stamina

---

## 🎮 Testando os Items

**Poção de Vida**: Restaura 50 HP
**Mega Poção**: Restaura 100 HP
**Elixir de Velocidade**: +50% velocidade por 10s
**Poção de Força**: +30% dano por 15s

Pressione **1-5** para usar items da hotbar rapidamente!
