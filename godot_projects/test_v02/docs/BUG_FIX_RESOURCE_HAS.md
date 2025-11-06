# 🐛 BUG FIX: Resource.has() não existe

## ❌ Erro

```
Invalid call. Nonexistent function 'has' in base 'Resource (WeaponData)'.
```

## 🔍 Causa

O método `.has()` **não existe em Resources**. Ele só funciona em `Dictionary`.

### ❌ Código Errado (antes)

```gdscript
# ERRADO - Resource não tem método .has()
if weapon_data.has("damage"):
    return weapon_data.damage

if weapon_data.has("can_charge") and weapon_data.can_charge:
    return true
```

### ✅ Código Correto (depois)

```gdscript
# CORRETO - Usar operador 'in' para verificar propriedades
if "damage" in weapon_data:
    return weapon_data.damage

if "can_charge" in weapon_data and weapon_data.can_charge:
    return true
```

---

## 📋 Arquivos Corrigidos

### 1. **melee_attack_component.gd**

**Linhas 150, 165, 172**

```gdscript
# ❌ ANTES
if weapon_data.has("animation_name") and weapon_data.sprite_frames.has_animation(weapon_data.animation_name):
if weapon_data and weapon_data.has("attack_hitbox_duration"):
if weapon_data and weapon_data.has("damage"):

# ✅ DEPOIS
if "animation_name" in weapon_data and weapon_data.animation_name and weapon_data.sprite_frames.has_animation(weapon_data.animation_name):
if weapon_data and "attack_hitbox_duration" in weapon_data:
if weapon_data and "damage" in weapon_data:
```

### 2. **ranged_attack_component.gd**

**Linhas 123, 125**

```gdscript
# ❌ ANTES
if weapon_data.has("projectile_speed"):
if weapon_data.has("damage"):

# ✅ DEPOIS
if "projectile_speed" in weapon_data:
if "damage" in weapon_data:
```

### 3. **charge_attack_component.gd**

**Linhas 177, 182, 189**

```gdscript
# ❌ ANTES
return weapon_data.has("can_charge") and weapon_data.can_charge
if weapon_data and weapon_data.has("min_charge_time"):
if weapon_data and weapon_data.has("max_charge_time"):

# ✅ DEPOIS
return "can_charge" in weapon_data and weapon_data.can_charge
if weapon_data and "min_charge_time" in weapon_data:
if weapon_data and "max_charge_time" in weapon_data:
```

---

## 🎓 Lições Aprendidas

### Diferença entre Dictionary e Resource

| Método | Dictionary | Resource |
|--------|-----------|----------|
| `.has("key")` | ✅ Funciona | ❌ Não existe |
| `"key" in obj` | ✅ Funciona | ✅ Funciona |
| `.get("key", default)` | ✅ Funciona | ❌ Não existe |
| `.property` | ❌ Não existe | ✅ Funciona |

### Verificação de Propriedades

#### Em Dictionary:
```gdscript
var dict = {"damage": 10, "speed": 5}

# Método 1: .has()
if dict.has("damage"):
    print(dict["damage"])

# Método 2: in (recomendado)
if "damage" in dict:
    print(dict["damage"])

# Método 3: .get() com fallback
var damage = dict.get("damage", 0)
```

#### Em Resource:
```gdscript
var weapon: WeaponData = preload("res://resources/weapons/sword.tres")

# ❌ ERRADO
if weapon.has("damage"):  # ERRO!

# ✅ CORRETO - Usar 'in'
if "damage" in weapon:
    print(weapon.damage)

# ✅ CORRETO - Acesso direto (se garantido que existe)
print(weapon.damage)

# ✅ CORRETO - Verificar se não é null
if weapon.damage:
    print(weapon.damage)
```

---

## 🔧 Como Detectar Propriedades Dinamicamente

### Método 1: Operador `in`
```gdscript
if "propriedade" in resource:
    # Propriedade existe
    var valor = resource.propriedade
```

### Método 2: `get()` com reflection (avançado)
```gdscript
var valor = resource.get("propriedade")
if valor != null:
    print("Propriedade existe:", valor)
```

### Método 3: Try-catch (não recomendado)
```gdscript
# Não fazer! GDScript não tem try-catch tradicional
```

---

## ✅ Status da Correção

**Componentes de Ataque:**
- [x] melee_attack_component.gd - 3 ocorrências corrigidas
- [x] ranged_attack_component.gd - 2 ocorrências corrigidas
- [x] charge_attack_component.gd - 3 ocorrências corrigidas

**Scripts de Feitiços:**
- [x] magic_area.gd - 2 ocorrências corrigidas (SpellData)
- [x] magic_buff.gd - 3 ocorrências corrigidas (SpellData) + 5 ocorrências corrigidas (Node)
- [x] magic_heal.gd - 4 ocorrências corrigidas (SpellData) + 4 ocorrências corrigidas (Node)
- [x] ice_beam.gd - 4 ocorrências corrigidas (SpellData)

**Total:** 29 ocorrências corrigidas
- [x] 0 erros de compilação
- [x] Pronto para testar

---

## 🎮 Teste no Godot

Após a correção, o jogo deve rodar sem erros:

```
[MELEE] ⚔️ Componente configurado
   Arma: Sword
   Dano: 10.0
   ✅ Hitbox configurada
```

---

## 📚 Referências

- [GDScript Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)
- [GDScript Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html)
- [Operator 'in'](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#operators)

---

**Bug corrigido em 28/10/2025** 🎉
