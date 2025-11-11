# 🎬 Tutorial: Adicionando Animações aos Feitiços

## 📋 Visão Geral

Todos os feitiços agora suportam **AnimatedSprite2D** para executar animações quando são lançados! Este tutorial mostra como configurar animações para cada tipo de feitiço.

---

## ✅ Sistemas Atualizados

| Tipo de Feitiço | AnimatedSprite2D | Sistema de Fallback |
|------------------|------------------|---------------------|
| **Projectile** (Fireball) | ✅ Configurado | Line2D/Sprite estático |
| **Area** (Explosão) | ✅ NOVO | Sprite2D estático |
| **Beam** (Ice Beam) | ✅ Configurado | Line2D |
| **Buff** (Speed Boost) | ✅ NOVO | Partículas apenas |
| **Heal** (Cura) | ✅ NOVO | Partículas apenas |

---

## 🎨 Como Funciona

### Sistema Híbrido

Cada feitiço agora verifica se há um **SpriteFrames** configurado:

1. **Se houver SpriteFrames** → Toca a animação do AnimatedSprite2D
2. **Se NÃO houver** → Usa sistema de fallback (Line2D, Sprite2D estático ou partículas)

---

## 🔧 Configurando Animações

### 1️⃣ Projectile (Fireball, Ice Bolt)

#### SpellData (fireball.tres):
```gdscript
[resource]
spell_name = "Fireball"
spell_type = PROJECTILE

# Animação
projectile_sprite_frames = preload("res://art/animations/fireball_frames.tres")
projectile_animation = "fly"  # Nome da animação
```

#### Criando SpriteFrames:
1. Crie um novo recurso **SpriteFrames**
2. Adicione frames da animação (ex: `fireball_1.png`, `fireball_2.png`, etc)
3. Configure FPS (frames por segundo)
4. Salve como `.tres`

**Exemplo de estrutura:**
```
Animação "fly":
- Frame 0: fireball_1.png (0.1s)
- Frame 1: fireball_2.png (0.1s)
- Frame 2: fireball_3.png (0.1s)
- Frame 3: fireball_4.png (0.1s)
Loop: true
```

#### Resultado:
```gdscript
# magic_projectile.gd automaticamente faz:
if spell.projectile_sprite_frames:
    animated_sprite.sprite_frames = spell.projectile_sprite_frames
    animated_sprite.play(spell.projectile_animation)  # Toca "fly"
```

---

### 2️⃣ Area (Explosão)

#### SpellData (explosion.tres):
```gdscript
[resource]
spell_name = "Explosão Flamejante"
spell_type = AREA

# Animação
area_sprite_frames = preload("res://art/animations/explosion_frames.tres")
area_animation = "explode"
area_radius = 150.0
area_duration = 1.0
```

#### Criando Animação de Explosão:
```
Animação "explode":
- Frame 0: explosion_start.png (0.05s)
- Frame 1: explosion_mid1.png (0.05s)
- Frame 2: explosion_mid2.png (0.05s)
- Frame 3: explosion_mid3.png (0.05s)
- Frame 4: explosion_end.png (0.1s)
Loop: false (explosão acontece uma vez)
```

#### Código executado:
```gdscript
# magic_area.gd
if spell.area_sprite_frames:
    animated_sprite.sprite_frames = spell.area_sprite_frames
    animated_sprite.play(spell.area_animation)  # Toca "explode"
    animated_sprite.scale = Vector2.ONE * (spell.area_radius / 50.0)
```

---

### 3️⃣ Beam (Ice Beam)

#### SpellData (ice_beam.tres):
```gdscript
[resource]
spell_name = "Ice Beam"
spell_type = BEAM

# Animação
sprite_frames = preload("res://art/animations/ice_beam_frames.tres")
animation_name = "beam"
spell_range = 500.0
```

#### Criando Animação de Raio:
```
Animação "beam":
- Frame 0: ice_beam_loop1.png (0.1s)
- Frame 1: ice_beam_loop2.png (0.1s)
- Frame 2: ice_beam_loop3.png (0.1s)
Loop: true (raio contínuo)
```

**Importante:** O sprite é **esticado dinamicamente** para cobrir a distância do raio!

#### Código executado:
```gdscript
# ice_beam.gd
if spell.sprite_frames:
    beam_sprite.sprite_frames = spell.sprite_frames
    beam_sprite.play(spell.animation_name)  # Toca "beam"
    
    # Escala dinamicamente durante _process()
    beam_sprite.scale.x = beam_length / texture_width
```

---

### 4️⃣ Buff (Speed Boost)

#### SpellData (speed_boost.tres):
```gdscript
[resource]
spell_name = "Speed Boost"
spell_type = BUFF

# Animação
buff_sprite_frames = preload("res://art/animations/speed_buff_frames.tres")
buff_animation = "boost"
duration = 5.0
speed_modifier = 1.5  # +50% velocidade
```

#### Criando Animação de Buff:
```
Animação "boost":
- Frame 0: speed_icon1.png (0.2s)
- Frame 1: speed_icon2.png (0.2s)
- Frame 2: speed_icon3.png (0.2s)
Loop: true (enquanto buff estiver ativo)
```

**Posicionamento:** AnimatedSprite2D aparece **acima do jogador** (`offset = Vector2(0, -30)`)

#### Código executado:
```gdscript
# magic_buff.gd
if spell.buff_sprite_frames:
    animated_sprite.sprite_frames = spell.buff_sprite_frames
    animated_sprite.play(spell.buff_animation)  # Toca "boost"
    # Sprite acompanha o player durante a duração
```

---

### 5️⃣ Heal (Cura)

#### SpellData (heal.tres):
```gdscript
[resource]
spell_name = "Cura Divina"
spell_type = HEAL

# Animação
heal_sprite_frames = preload("res://art/animations/heal_frames.tres")
heal_animation = "heal"
heal_amount = 50.0
```

#### Criando Animação de Cura:
```
Animação "heal":
- Frame 0: heal_glow1.png (0.15s)
- Frame 1: heal_glow2.png (0.15s)
- Frame 2: heal_glow3.png (0.15s)
- Frame 3: heal_glow4.png (0.15s)
- Frame 4: heal_fade.png (0.2s)
Loop: false (cura acontece uma vez)
```

**Posicionamento:** AnimatedSprite2D aparece **acima do jogador** (`offset = Vector2(0, -40)`)

#### Código executado:
```gdscript
# magic_heal.gd
if spell.heal_sprite_frames:
    animated_sprite.sprite_frames = spell.heal_sprite_frames
    animated_sprite.play(spell.heal_animation)  # Toca "heal"
```

---

## 🎯 Workflow Completo

### Passo 1: Criar Arte
1. Desenhe os frames da animação no **Aseprite** ou **Photoshop**
2. Exporte cada frame como PNG individual
3. Coloque na pasta `res://art/animations/`

### Passo 2: Criar SpriteFrames no Godot
1. **Project → New Resource → SpriteFrames**
2. Clique em "New Animation"
3. Nomeie (ex: "fly", "explode", "beam")
4. Arraste os frames PNG para a timeline
5. Configure FPS (ex: 10 FPS)
6. Configure Loop (true/false)
7. **Salve** como `.tres`

### Passo 3: Configurar SpellData
1. Abra o arquivo `.tres` da magia
2. No Inspector, configure:
   - **projectile_sprite_frames** (para projectile)
   - **area_sprite_frames** (para area)
   - **sprite_frames** (para beam)
   - **buff_sprite_frames** (para buff)
   - **heal_sprite_frames** (para heal)
3. Configure o nome da animação (ex: "fly")
4. **Salve**

### Passo 4: Testar no Jogo
1. Lance o feitiço
2. Veja a animação executar! 🎉

---

## 📊 Propriedades do SpellData

### Para Projectile:
```gdscript
@export_group("Visual - Projectile")
@export var projectile_sprite_frames: SpriteFrames
@export var projectile_animation: String = "default"
@export var projectile_scale: Vector2 = Vector2.ONE
```

### Para Area:
```gdscript
@export_group("Visual - Area")
@export var area_sprite_frames: SpriteFrames
@export var area_animation: String = "default"
```

### Para Beam:
```gdscript
@export_group("Visual - Beam")
@export var sprite_frames: SpriteFrames
@export var animation_name: String = "beam"
```

### Para Buff:
```gdscript
@export_group("Visual - Buff")
@export var buff_sprite_frames: SpriteFrames
@export var buff_animation: String = "default"
```

### Para Heal:
```gdscript
@export_group("Visual - Heal")
@export var heal_sprite_frames: SpriteFrames
@export var heal_animation: String = "default"
```

---

## ⚡ Sistema de Fallback

### O que acontece se NÃO configurar SpriteFrames?

| Tipo | Fallback |
|------|----------|
| **Projectile** | Círculo colorido com `spell_color` |
| **Area** | Sprite2D estático circular |
| **Beam** | Line2D azul gelo |
| **Buff** | Apenas partículas (sem sprite) |
| **Heal** | Apenas partículas (sem sprite) |

**Exemplo:**
```gdscript
# Se fireball.tres NÃO tiver projectile_sprite_frames
animated_sprite.modulate = spell.spell_color  # Círculo vermelho
```

---

## 🎨 Dicas de Design

### Projectile (Fireball):
- **4-8 frames** de animação loop
- Efeito de rotação/pulsação
- Cor vibrante (vermelho/laranja para fogo)

### Area (Explosão):
- **5-10 frames** one-shot (sem loop)
- Começa pequeno, expande, some
- Efeito de flash no frame do meio

### Beam (Ice Beam):
- **3-5 frames** loop contínuo
- Textura horizontal que será esticada
- Efeito de fluxo/ondulação

### Buff (Speed Boost):
- **3-4 frames** loop
- Ícone pequeno (32x32 ou 48x48)
- Efeito sutil acima do personagem

### Heal (Cura):
- **5-7 frames** one-shot
- Efeito de brilho/pulso
- Verde/dourado para cura

---

## 🐛 Troubleshooting

### Animação não aparece:
1. **Verifique se SpriteFrames está configurado** no SpellData
2. **Verifique se o nome da animação existe** no SpriteFrames
3. **Console debug:** Procure mensagens `[TIPO] 🎨 Tocando animação`

### Animação não faz loop:
1. No SpriteFrames, verifique se **Loop está ativado**
2. Para explosões/curas, loop deve estar **desativado**

### Animação está muito rápida/lenta:
1. No SpriteFrames, ajuste **FPS** (frames por segundo)
2. Teste com valores entre 5-15 FPS

### Sprite está no tamanho errado:
1. Para **Projectile**: Configure `projectile_scale` no SpellData
2. Para **Area**: O tamanho é automático baseado em `area_radius`
3. Para **Beam**: O comprimento é dinâmico

---

## ✅ Checklist de Implementação

Para cada feitiço:
- [ ] Arte dos frames criada
- [ ] SpriteFrames criado no Godot
- [ ] Animação configurada (nome, FPS, loop)
- [ ] SpellData atualizado com SpriteFrames
- [ ] Nome da animação configurado
- [ ] Testado no jogo
- [ ] Animação executa corretamente
- [ ] Fallback funciona se remover SpriteFrames

---

## 🎉 Resultado Final

**Agora todos os feitiços têm suporte completo a animações!**

- ✅ **Fireball** → Animação de chamas girando
- ✅ **Explosão** → Animação de explosão crescente
- ✅ **Ice Beam** → Animação de raio ondulante
- ✅ **Speed Boost** → Ícone animado acima do player
- ✅ **Heal** → Efeito de brilho de cura

**Sistema profissional e escalável!** 🚀

---

**Atualizado em 28/10/2025** ✨
