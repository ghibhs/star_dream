# 🧊 Ice Beam - Sistema de Animação

## 📋 Resumo das Mudanças

O Ice Beam agora suporta **AnimatedSprite2D** com animações ao invés de apenas Line2D!

### ✅ O que foi implementado:

1. **Variável `beam_sprite`**: AnimatedSprite2D para exibir animação do raio
2. **Sistema híbrido**: Usa sprite animado SE configurado no SpellData, caso contrário fallback para Line2D
3. **Escala dinâmica**: O sprite se estica automaticamente para alcançar o alcance máximo ou até bater em uma parede
4. **Integração com SpellData**: Lê `sprite_frames` e `animation_name` do arquivo .tres

---

## 🎨 Como Configurar a Animação do Ice Beam

### Passo 1: Criar SpriteFrames no Godot

1. **No Godot, vá até** `res://resources/spells/ice_bolt.tres`
2. **Adicione as propriedades** (se ainda não existirem):
   ```gdscript
   @export var sprite_frames: SpriteFrames
   @export var animation_name: String = "default"
   ```

3. **Crie um novo SpriteFrames**:
   - Clique no campo `sprite_frames`
   - Selecione "New SpriteFrames"
   - Clique no ícone de lápis para editar

### Passo 2: Importar Sprites de Raio

Você tem 2 opções de sprites disponíveis:

#### Opção A: Thunder (Raio elétrico)
- **Arquivo**: `res://art/thunder_64_sheet.png`
- **Aparência**: Raio amarelo/elétrico
- **Uso**: Bom para spell de eletricidade

#### Opção B: Thunder Ice (Raio de gelo) ⭐ RECOMENDADO
- **Arquivo**: `res://art/thunderice_64_sheet.png`
- **Aparência**: Raio azul/gelo
- **Uso**: Perfeito para Ice Beam!

### Passo 3: Configurar Frames da Animação

No editor de SpriteFrames:

1. **Renomeie a animação** para "cast" ou "beam"
2. **Clique em "Add Frames from Strip"**
3. **Selecione**: `res://art/thunderice_64_sheet.png`
4. **Configure**:
   - **Horizontal**: Número de frames na horizontal (veja a spritesheet)
   - **Vertical**: 1 (se for uma linha única)
   - **FPS**: 10-15 (velocidade da animação)
   - **Loop**: ✅ Ativado

5. **Clique em OK**

### Passo 4: Atualizar ice_bolt.tres

No arquivo `res://resources/spells/ice_bolt.tres`:

```gdscript
[gd_resource type="Resource" load_steps=3 format=3 uid="uid://..."]

[ext_resource type="Script" path="res://resources/classes/SpellData.gd" id="1_..."]

[sub_resource type="SpriteFrames" id="SpriteFrames_ice_beam"]
animations = [{
"frames": [{
"duration": 1.0,
"texture": ExtResource("2_..._thunderice_64_sheet")
}, {
"duration": 1.0,
"texture": ExtResource("2_..._frame2")
}],
"loop": true,
"name": &"beam",
"speed": 12.0
}]

[resource]
script = ExtResource("1_...")
spell_name = "Ice Bolt"
damage = 25.0
mana_cost = 20.0
cooldown = 1.2
spell_type = 2
spell_range = 500.0
speed_modifier = 0.5
spell_color = Color(0.4, 0.7, 1, 1)
sprite_frames = SubResource("SpriteFrames_ice_beam")  # ← NOVO!
animation_name = "beam"  # ← NOVO!
```

---

## 🔧 Como Funciona Tecnicamente

### Sistema de Escala Dinâmica

O script `ice_beam.gd` agora ajusta automaticamente a escala do sprite:

```gdscript
# Calcula comprimento do raio
var beam_length = end_point.length()

# Pega largura original do sprite
var sprite_texture = beam_sprite.sprite_frames.get_frame_texture(animation, frame)
var original_width = sprite_texture.get_width()

# Escala X = comprimento necessário / largura original
beam_sprite.scale.x = beam_length / original_width
```

**Resultado**: O raio se estica desde a origem até:
- ✅ A parede/obstáculo mais próximo (se houver)
- ✅ O alcance máximo da spell (500 pixels padrão)

### Sistema de Fallback

Se `sprite_frames` não for configurado, o Ice Beam usa Line2D:

```gdscript
if beam_sprite.sprite_frames:
    beam_sprite.visible = true  # Usa sprite animado
else:
    beam_line.visible = true    # Usa Line2D
```

---

## 🎯 Ajustes Visuais

### Ajustar Largura do Raio

No SpellData ou script:
```gdscript
@export var beam_width: float = 20.0  # Ajuste aqui
```

### Ajustar Offset Vertical

O sprite é centralizado verticalmente automaticamente:
```gdscript
beam_sprite.offset = Vector2(0, -beam_width / 2)
```

### Ajustar Cor do Raio

Adicione modulate no SpellData:
```gdscript
spell_color = Color(0.5, 0.9, 1.0, 1.0)  # Azul claro gelo
```

---

## 🐛 Troubleshooting

### Problema: Sprite não aparece
**Solução**: Verifique se:
1. `sprite_frames` está configurado no .tres
2. `animation_name` existe no SpriteFrames
3. O sprite tem frames válidos

### Problema: Sprite está esticado errado
**Solução**: Ajuste `centered = false` e `offset`:
```gdscript
beam_sprite.centered = false
beam_sprite.offset = Vector2(0, -beam_width / 2)
```

### Problema: Animação não toca
**Solução**: Certifique-se que:
1. Loop está ativado no SpriteFrames
2. FPS é maior que 0
3. `beam_sprite.play()` é chamado em `activate()`

---

## 📊 Comparação Visual

### ANTES (Line2D):
```
Player -----(linha azul simples)-----> Inimigo
```

### DEPOIS (AnimatedSprite2D):
```
Player ~~~⚡🧊⚡🧊⚡~~~ (raio animado)~~> Inimigo
        (frames alternando)
```

---

## 🎮 Resultado Final

✅ Ice Beam com animação fluida  
✅ Raio se estica dinamicamente até o alvo  
✅ Partículas de gelo no ponto de impacto  
✅ Slow effect nos inimigos atingidos  
✅ Som e visual profissional  

**Aproveite seu Ice Beam animado!** 🧊⚡
