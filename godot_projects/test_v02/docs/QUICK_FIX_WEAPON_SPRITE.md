# 🎯 GUIA RÁPIDO: Corrigir Rotação da Arma

## 📋 Problema
Sprite da arma não rotaciona para o mouse porque está fora do `WeaponMarker2D`.

---

## ✅ Solução (5 minutos)

### Passo 1: Abrir a Cena
1. No Godot, abra: `scenes/player/entidades.tscn`
2. Na árvore de cena (Scene Tree), você verá:

```
Entidades
├─ CollisionShape2D
├─ AnimatedSprite2D
├─ WeaponMarker2D
│  ├─ ProjectileSpawnMarker2D
│  └─ Weapon_timer
└─ WeaponAnimatedSprite2D  ← ESTE ESTÁ NO LUGAR ERRADO!
```

---

### Passo 2: Mover o Sprite
1. **Selecione** o node `WeaponAnimatedSprite2D`
2. **Arraste** e **solte** dentro de `WeaponMarker2D`
3. A hierarquia deve ficar:

```
Entidades
├─ CollisionShape2D
├─ AnimatedSprite2D
└─ WeaponMarker2D
   ├─ WeaponAnimatedSprite2D  ← AGORA ESTÁ AQUI!
   ├─ ProjectileSpawnMarker2D
   └─ Weapon_timer
```

---

### Passo 3: Ajustar a Posição (Opcional)
1. Com `WeaponAnimatedSprite2D` selecionado
2. Na propriedade **Position**, configure:
   - X: `0` (ou ajuste conforme desejado)
   - Y: `0`
3. Isso centraliza o sprite em relação ao marker

---

### Passo 4: Salvar e Testar
1. **Pressione Ctrl+S** para salvar a cena
2. **Rode o jogo** (F5)
3. **Colete uma arma**
4. **Mova o mouse** → Arma deve rotacionar! ✅

---

## 🎬 O Que Esperar

### Antes do Fix:
- ❌ Arma não rotaciona
- ❌ Sprite fica parado

### Depois do Fix:
- ✅ Arma aponta para o mouse
- ✅ Rotaciona suavemente
- ✅ Animações de ataque funcionam

---

## 🔧 Se Ainda Não Funcionar

### Verificar o Script
Abra `scripts/player/entidades.gd` e procure (linha ~103):

```gdscript
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponAnimatedSprite2D
```

**Deve ser alterado para:**
```gdscript
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponMarker2D/WeaponAnimatedSprite2D
```

---

## 📸 Referência Visual

```
HIERARQUIA CORRETA:

Entidades (CharacterBody2D)
  │
  ├─ AnimatedSprite2D
  │    └─ Animação do player (andar, idle)
  │
  └─ WeaponMarker2D ← Rotaciona para o mouse
       │
       ├─ WeaponAnimatedSprite2D ← Sprite da arma (AQUI!)
       │    └─ Rotaciona junto com o marker
       │
       ├─ ProjectileSpawnMarker2D
       └─ Weapon_timer
```

---

## ✅ Resultado Final

Após essa mudança simples, a arma vai:
- ✅ Rotacionar para o mouse
- ✅ Tocar animações de ataque
- ✅ Ser visível na posição correta
- ✅ Escalar corretamente (bow = 0.8, sword = 0.1)

**Tempo estimado:** 2 minutos  
**Dificuldade:** ⭐ Muito fácil
