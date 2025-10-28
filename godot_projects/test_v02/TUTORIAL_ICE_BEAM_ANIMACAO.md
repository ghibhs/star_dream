# 🎬 Tutorial Rápido: Adicionar Animação ao Ice Beam

## 📌 O Que Você Precisa Fazer

### 1️⃣ Abrir o arquivo ice_bolt.tres no Godot

**Caminho**: `res://resources/spells/ice_bolt.tres`

### 2️⃣ Criar SpriteFrames

1. **Localize a seção**: `Beam/Ray`
2. **Campo `Sprite Frames`**: Clique e selecione **"New SpriteFrames"**
3. **Clique no ícone de edição** (lápis) ao lado do campo

### 3️⃣ Adicionar Frames da Animação

Na janela do SpriteFrames:

1. **Renomeie "default"** para **"beam"**
2. Clique em **"Add Frames from Sprite Sheet"** (botão com ícone de grid)
3. **Selecione o arquivo**: `res://art/thunderice_64_sheet.png`
4. Configure a grid:
   - **Horizontal**: 4 (ou quantos frames tiver na imagem)
   - **Vertical**: 1
5. **Marque todos os frames** e clique **"Add Frame(s)"**
6. **Configure FPS**: 12-15
7. **Ative Loop**: ✅
8. **Feche o editor**

### 4️⃣ Configurar Animation Name

De volta no ice_bolt.tres:

- **Campo `Animation Name`**: Digite **"beam"** (mesmo nome que criou)

### 5️⃣ Salvar e Testar

**Salve** (Ctrl+S) e **rode o jogo** (F5)!

---

## 🎨 Resultado Esperado

### ❌ ANTES:
```
Jogador ----[linha azul estática]---- Inimigo
```

### ✅ DEPOIS:
```
Jogador ⚡🧊⚡🧊⚡ [raio animado!] ⚡🧊 Inimigo
        ↑ Frames alternando em loop
```

---

## 🔍 Como Verificar se Funcionou

Quando lançar o Ice Beam, no console você deve ver:

```
[ICE BEAM] 🎨 Usando AnimatedSprite2D com animação
[ICE BEAM] ⚡ Raio ativado!
```

Se ver isso, parabéns! 🎉 A animação está funcionando!

Se ver:
```
[ICE BEAM] 🎨 Usando Line2D como fallback
```

Significa que ainda não configurou o SpriteFrames corretamente.

---

## 📊 Estrutura Final do ice_bolt.tres

```
ice_bolt.tres
├── Basic Info
│   ├── spell_name: "Ice Bolt"
│   ├── icon: (ícone da spell)
│   
├── Spell Properties
│   ├── damage: 25.0
│   ├── mana_cost: 20.0
│   ├── cooldown: 1.2
│   ├── spell_range: 500.0
│   ├── speed_modifier: 0.5 (slow)
│   └── spell_color: Color(0.4, 0.7, 1, 1)
│
├── Beam/Ray ⭐ NOVO!
│   ├── sprite_frames: [SpriteFrames com animação "beam"]
│   └── animation_name: "beam"
│
└── Visual Effects
    └── cast_particle: (opcional)
```

---

## 🎯 Sprites Disponíveis

Você tem 2 opções na pasta `art/`:

### 1. thunderice_64_sheet.png ⭐ RECOMENDADO
- Cor: Azul/Branco (tema gelo)
- Tamanho: 64x64 por frame
- Estilo: Raio congelante

### 2. thunder_64_sheet.png
- Cor: Amarelo/Branco (tema elétrico)
- Tamanho: 64x64 por frame
- Estilo: Raio elétrico

**Escolha**: `thunderice_64_sheet.png` para combinar com Ice Beam!

---

## ⚡ Dica Extra: Ajustar Escala Vertical

Se o raio ficar muito grosso ou fino, ajuste no script:

```gdscript
# Em ice_beam.gd, linha ~37:
beam_sprite.scale.y = 0.5  # Deixa mais fino (50%)
# ou
beam_sprite.scale.y = 1.5  # Deixa mais grosso (150%)
```

---

## ✅ Checklist Final

- [ ] Abri `ice_bolt.tres` no Godot
- [ ] Criei novo SpriteFrames na seção "Beam/Ray"
- [ ] Adicionei frames de `thunderice_64_sheet.png`
- [ ] Renomeei animação para "beam"
- [ ] Configurei FPS (12-15) e Loop ativado
- [ ] Preenchi campo `animation_name` com "beam"
- [ ] Salvei o arquivo (Ctrl+S)
- [ ] Testei no jogo (F5)
- [ ] Vi mensagem "[ICE BEAM] 🎨 Usando AnimatedSprite2D"

**Tudo marcado?** Então seu Ice Beam está animado! 🎊
