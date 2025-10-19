# 🐛 BUG FIX: Sprite da Arma Não Rotaciona

**Data:** 19/10/2025  
**Problema:** Sprite da arma não rotaciona para o mouse, animações não funcionam corretamente

---

## 🔍 Diagnóstico

### Sintomas
```
✅ Coleta de itens funcionando
✅ Troca de armas funcionando  
✅ Ataques melee e projectile funcionando
❌ Sprite da arma não rotaciona para o mouse
❌ Animações de ataque não são visíveis
```

### Causa Raiz

#### Estrutura Atual (INCORRETA):
```
Entidades (CharacterBody2D)
├─ AnimatedSprite2D (player sprite) ✅
├─ WeaponMarker2D ← Rotaciona para o mouse
│  ├─ ProjectileSpawnMarker2D ✅
│  └─ Weapon_timer ✅
└─ WeaponAnimatedSprite2D ❌ FORA DO MARKER!
```

**Problema:** 
- `WeaponMarker2D.look_at(mouse)` rotaciona o marker
- Mas `WeaponAnimatedSprite2D` está **fora** do marker
- Resultado: Sprite não rotaciona!

#### Estrutura Correta (DEVERIA SER):
```
Entidades (CharacterBody2D)
├─ AnimatedSprite2D (player sprite) ✅
└─ WeaponMarker2D ← Rotaciona para o mouse
   ├─ WeaponAnimatedSprite2D ✅ Dentro do marker!
   ├─ ProjectileSpawnMarker2D ✅
   └─ Weapon_timer ✅
```

---

## ✅ Solução

### Opção 1: Corrigir no Editor Godot (RECOMENDADO)

1. **Abra** `scenes/player/entidades.tscn` no Godot
2. **Arraste** o node `WeaponAnimatedSprite2D` para **dentro** de `WeaponMarker2D`
3. **Salve** a cena
4. **Teste** no jogo

#### Antes:
```
WeaponMarker2D
  └─ ProjectileSpawnMarker2D
WeaponAnimatedSprite2D  ← fora!
```

#### Depois:
```
WeaponMarker2D
  ├─ WeaponAnimatedSprite2D  ← movido para dentro!
  └─ ProjectileSpawnMarker2D
```

---

### Opção 2: Modificar o Script (ALTERNATIVA)

Se não quiser mexer na cena, pode alterar o código para criar o sprite dinamicamente:

**Arquivo:** `scripts/player/entidades.gd`

```gdscript
# Linha ~103: Alterar @onready
# ANTES:
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponAnimatedSprite2D

# DEPOIS:
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponMarker2D/WeaponAnimatedSprite2D
```

**Mas isso só funciona se você mover o node na cena primeiro!**

---

## 🎯 Como Deve Funcionar (Após Fix)

### Durante o jogo:
1. **Player se move** → AnimatedSprite2D do player toca animações de movimento
2. **Mouse se move** → WeaponMarker2D rotaciona
3. **Sprite da arma rotaciona junto** (porque está dentro do marker)
4. **Ataque é pressionado** → Animação de ataque é tocada no sprite da arma
5. **Após ataque** → Volta para animação idle da arma

### Comportamento Esperado:
```
[PLAYER] 🗡️ Executando ataque melee...
[PLAYER]    Direção: DIREITA (mouse_x: 62.5)
[PLAYER]    ✅ Animação: attack_right    ← Deve tocar!
[PLAYER]    Hitbox ATIVADA
```

---

## 🧪 Teste Após Fix

### Checklist:
- [ ] Sprite da arma rotaciona suavemente para o mouse
- [ ] Ao atacar para direita, animação `attack_right` é tocada
- [ ] Ao atacar para esquerda, animação `attack_left` é tocada
- [ ] Após ataque, volta para animação idle/default
- [ ] Ao trocar de arma, sprite é atualizado corretamente

### Debug esperado:
```
[PLAYER] 🗡️ Executando ataque melee...
[PLAYER]    Direção: DIREITA (mouse_x: 69.4)
[PLAYER]    ✅ Animação: attack_right  ← Não mais "fallback"!
```

---

## 📝 Lições Aprendidas

1. **Hierarquia de nodes importa**: Se um node precisa rotacionar junto com outro, deve ser filho dele
2. **Marker2D serve para isso**: Grupo lógico de transformações (posição, rotação, escala)
3. **@onready paths devem refletir hierarquia**: `$WeaponMarker2D/WeaponAnimatedSprite2D`

---

## 🔧 Verificação Adicional

Depois de mover o sprite, verifique se os **recursos de arma** (`.tres`) têm:

### WeaponData deve ter:
- ✅ `sprite_frames` configurado
- ✅ `animation_name` = "default" ou "idle"
- ✅ Animações `attack_right` e `attack_left` criadas no SpriteFrames
- ✅ `Sprite_scale` ajustado (ex: Vector2(0.8, 0.8) para bow)

### No Editor do SpriteFrames:
```
Animações necessárias:
- default (ou idle) ← Loop
- attack_right ← Não loop, speed rápido
- attack_left ← Não loop, speed rápido
```

---

## ✅ Status

**IDENTIFICADO** - Sprite está fora do WeaponMarker2D na hierarquia da cena.

**Solução:** Mover `WeaponAnimatedSprite2D` para dentro de `WeaponMarker2D` no editor.

**Próximo Passo:** Abrir `scenes/player/entidades.tscn` e reorganizar a hierarquia.

---

## 🎓 Referências

- `scenes/player/entidades.tscn` - Cena do player
- `scripts/player/entidades.gd` - Lógica de armas e animação
- Godot Docs: [Node hierarchy and transforms](https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html)
