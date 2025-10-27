# Fix: Sprite das Armas Não Rotaciona com o Mouse

## 🐛 Problema Identificado

O sprite das armas não estava conseguindo:
1. Mudar de posição quando trocado
2. Apontar/rotacionar seguindo o mouse

## 🔍 Causas Raiz

### 1. **Conflito de Hierarquia de Nós**
Na cena `scenes/player/player.tscn`, existe um nó `WeaponAnimatedSprite2D` como **filho direto do Player**:
```
Player (CharacterBody2D)
├── CollisionShape2D
├── AnimatedSprite2D (sprite do personagem)
├── WeaponMarker2D (Marker2D) ← Controla rotação para o mouse
│   ├── ProjectileSpawnMarker2D
│   └── Weapon_timer
└── WeaponAnimatedSprite2D ← ❌ PROBLEMA: Está aqui ao invés de ser filho do WeaponMarker2D
```

**Por que isso causa problemas?**
- O `WeaponMarker2D` rotaciona para apontar ao mouse usando `look_at()`
- O `WeaponAnimatedSprite2D` deveria ser **filho** do `WeaponMarker2D` para rotacionar junto
- Como está filho direto do Player, ele não herda a rotação do marker

### 2. **Código Tentando Corrigir Manualmente**
No `player.gd` (linhas 59-73), havia código tentando rotacionar o sprite manualmente:
```gdscript
if current_weapon_sprite.get_parent() != weapon_marker:
    # Sprite está fora do marker, rotaciona manualmente
    current_weapon_sprite.global_rotation = weapon_marker.global_rotation
    current_weapon_sprite.global_position = weapon_marker.global_position
```

Isso causava:
- Duplicação de rotação em alguns casos
- Posicionamento incorreto
- Conflitos entre hierarquia da cena e código dinâmico

### 3. **Referência @onready Incorreta**
```gdscript
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponAnimatedSprite2D
```

Isso referenciava um nó que estava no lugar errado na hierarquia.

## ✅ Solução Implementada

### 1. **Removido @onready e Tornado Dinâmico**
Mudança em `player.gd`:
```gdscript
# ANTES:
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponAnimatedSprite2D

# DEPOIS:
var current_weapon_sprite: AnimatedSprite2D = null  # Será criado dinamicamente
```

### 2. **Sprite Criado Como Filho do WeaponMarker2D**
Função `create_or_update_weapon_sprite()` atualizada:
```gdscript
func create_or_update_weapon_sprite() -> void:
    # Remove sprite antigo
    if current_weapon_sprite != null and is_instance_valid(current_weapon_sprite):
        current_weapon_sprite.queue_free()
        current_weapon_sprite = null
    
    # Cria novo sprite como FILHO DO WEAPON_MARKER
    if weapon_marker:
        current_weapon_sprite = AnimatedSprite2D.new()
        weapon_marker.add_child(current_weapon_sprite)  # ← Hierarquia correta!
        
        # Configura sprite
        current_weapon_sprite.sprite_frames = current_weapon_data.sprite_frames
        current_weapon_sprite.play(current_weapon_data.animation_name)
        current_weapon_sprite.scale = current_weapon_data.Sprite_scale
        current_weapon_sprite.position = current_weapon_data.sprite_position
        
        # IMPORTANTE: Rotação local sempre 0
        current_weapon_sprite.rotation = 0.0  # O marker controla a rotação
```

### 3. **Simplificado Código de Rotação**
No `_physics_process()`:
```gdscript
# Arma aponta pro mouse
if current_weapon_data and weapon_marker:
    weapon_marker.look_at(get_global_mouse_position())
    
    # O sprite rotaciona automaticamente por ser filho do marker
    if current_weapon_sprite and is_instance_valid(current_weapon_sprite):
        # Apenas garante que está na hierarquia correta
        if current_weapon_sprite.get_parent() != weapon_marker:
            current_weapon_sprite.reparent(weapon_marker)
        # Mantém rotação local = 0
        current_weapon_sprite.rotation = 0.0
```

## 🛠️ Ações Necessárias no Editor Godot

### **IMPORTANTE: Remover Nó da Cena**

Abra a cena `scenes/player/player.tscn` no Godot e:

1. Selecione o nó `WeaponAnimatedSprite2D` (filho do Player)
2. Delete-o (Del ou botão direito → Delete)
3. Salve a cena (Ctrl+S)

**Por quê?**
- O sprite agora é criado dinamicamente pelo código
- O nó vazio na cena pode causar conflitos
- A hierarquia correta é: Player → WeaponMarker2D → (sprite criado em runtime)

## 🎯 Como Funciona Agora

### **Hierarquia em Runtime**
```
Player (CharacterBody2D)
├── CollisionShape2D
├── AnimatedSprite2D (personagem)
└── WeaponMarker2D (rotaciona para o mouse)
    ├── ProjectileSpawnMarker2D
    ├── Weapon_timer
    └── AnimatedSprite2D (sprite da arma) ← Criado dinamicamente!
```

### **Fluxo de Rotação**
1. `weapon_marker.look_at(get_global_mouse_position())` → Marker rotaciona
2. Sprite da arma (filho do marker) → **Rotaciona automaticamente** por herança
3. `current_weapon_sprite.rotation = 0.0` → Mantém rotação **local** zerada
4. Resultado: Arma aponta exatamente para o mouse! 🎯

### **Configuração no WeaponData.tres**
Agora você pode configurar no `.tres`:
- `sprite_position: Vector2` - Offset relativo ao marker
- `Sprite_scale: Vector2` - Escala do sprite
- `attack_hitbox_offset: Vector2` - Posição da hitbox
- `weapon_marker_position: Vector2` - Posição do marker no player

Todas essas propriedades funcionam corretamente pois o sprite está na hierarquia certa!

## 🧪 Testando

1. Delete o nó `WeaponAnimatedSprite2D` da cena do player
2. Salve a cena
3. Execute o jogo
4. Colete uma arma
5. Mova o mouse → A arma deve apontar para ele! ✅
6. Troque de arma → Nova arma aparece na posição correta! ✅

## 📝 Arquivos Modificados

- `scripts/player/player.gd`:
  - Linha ~243: Removido `@onready` do `current_weapon_sprite`
  - Linhas 59-73: Simplificado código de rotação
  - Linhas 251-285: Recriada função `create_or_update_weapon_sprite()`

- `scenes/player/player.tscn`:
  - **A FAZER**: Remover nó `WeaponAnimatedSprite2D`
