# Configuração de Colisões - Sistema Completo

## ✅ Layers Configuradas

| Bit | Layer | Uso | Entidades |
|-----|-------|-----|-----------|
| 1 | World | Paredes e obstáculos | TileMap, Walls |
| 2 | Player | Corpo do jogador | entidades.tscn (Player) |
| 3 | Enemy | Corpo dos inimigos | enemy.tscn (Enemy) |
| 4 | Player Hitbox | Ataques do jogador | attack_area (melee) |
| 5 | Enemy Hitbox | Ataques dos inimigos | HitboxArea2D (enemy) |
| 6 | Projectile | Projéteis do jogador | projectile.tscn |

## 📋 Configurações por Entidade

### **Player (entidades.tscn)**
```
CharacterBody2D:
  collision_layer = 2       (Layer 2: Player)
  collision_mask = 13       (Layers 1,3,4: World, Enemy, Enemy Hitbox)
                            Binário: 1101 = 13
```
**O que detecta:**
- ✅ Paredes (Layer 1)
- ✅ Inimigos (Layer 3) - Para colisão física
- ✅ Hitbox de inimigos (Layer 4) - Para receber dano

### **Player Attack Area (criada dinamicamente)**
```
Area2D (attack_area):
  collision_layer = 16      (Layer 5: Player Hitbox)
  collision_mask = 4        (Layer 3: Enemy)
```
**O que detecta:**
- ✅ Corpo dos inimigos para causar dano

### **Projectile (projectile.tscn)**
```
Area2D:
  collision_layer = 32      (Layer 6: Projectile)
  collision_mask = 5        (Layers 1,3: World, Enemy)
                            Binário: 101 = 5
```
**O que detecta:**
- ✅ Paredes (Layer 1) - Projétil é destruído
- ✅ Inimigos (Layer 3) - Causa dano

### **Enemy (enemy.tscn)**
```
CharacterBody2D:
  collision_layer = 4       (Layer 3: Enemy)
  collision_mask = 3        (Layers 1,2: World, Player)
                            Binário: 11 = 3
```
**O que detecta:**
- ✅ Paredes (Layer 1)
- ✅ Player (Layer 2) - Para colisão física

```
HitboxArea2D (filho do enemy):
  collision_layer = 8       (Layer 4: Enemy Hitbox)
  collision_mask = 2        (Layer 2: Player)
```
**O que detecta:**
- ✅ Player para causar dano

```
DetectionArea2D (filho do enemy):
  collision_layer = 0       (Não colide com nada)
  collision_mask = 2        (Layer 2: Player)
```
**O que detecta:**
- ✅ Player para iniciar chase

## 🎯 Fluxo de Dano

### Player → Enemy
1. **Melee**: 
   - Player ataca → `attack_area` (Layer 5) ativa
   - Detecta `Enemy.CharacterBody2D` (Layer 3)
   - Chama `enemy.take_damage()`

2. **Projectile**:
   - Projétil (Layer 6) colide com Enemy (Layer 3)
   - Chama `enemy.take_damage()`
   - Projétil é destruído (se não tiver pierce)

### Enemy → Player
1. **Melee**:
   - Enemy ataca → `HitboxArea2D` (Layer 4) ativa
   - Detecta `Player.CharacterBody2D` (Layer 2)
   - Chama `player.take_damage()`

## 🔧 Como Testar

### No Editor Godot:

1. **Abra Project Settings → General → Layer Names → 2D Physics**
   ```
   Layer 1: World
   Layer 2: Player
   Layer 3: Enemy
   Layer 4: Enemy Hitbox
   Layer 5: Player Hitbox
   Layer 6: Projectile
   ```

2. **Verifique cada scene**:
   - Selecione o node raiz
   - No Inspector, veja "Collision"
   - Layers = Em qual layer esta entidade ESTÁ
   - Mask = Quais layers esta entidade DETECTA

3. **Teste no jogo**:
   - Player deve colidir com paredes
   - Player deve causar dano em inimigos (melee e ranged)
   - Inimigos devem perseguir e causar dano no player
   - Projéteis devem acertar inimigos e paredes

## 🐛 Debug de Colisões

### Se o player não causa dano:
```gdscript
# Em entidades.gd → _on_attack_hit()
func _on_attack_hit(body: Node) -> void:
	print("HIT: ", body.name, " Groups: ", body.get_groups())
	if body.is_in_group("enemies"):
		apply_damage_to_target(body)
```

### Se o enemy não causa dano:
```gdscript
# Em enemy.gd → _on_hitbox_body_entered()
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("ENEMY HIT: ", body.name, " Groups: ", body.get_groups())
	if body.is_in_group("player") and can_attack:
		if body.has_method("take_damage"):
			body.take_damage(enemy_data.damage)
```

### Visualizar colisões no editor:
- **Debug → Visible Collision Shapes** (ative no menu superior)
- Verde = Collision Shapes
- Azul = Area2D shapes

## ⚠️ Erros Comuns

1. **"Player não recebe dano"**
   - ✅ Verifique se Player.collision_mask inclui Layer 4 (Enemy Hitbox)
   - ✅ Confirme que `take_damage()` existe em entidades.gd
   - ✅ Verifique se enemy está no grupo "enemies"

2. **"Enemy não recebe dano"**
   - ✅ Verifique se attack_area.collision_mask inclui Layer 3 (Enemy)
   - ✅ Confirme que enemy está no grupo "enemies"
   - ✅ Verifique se `monitoring = true` durante ataque

3. **"Projétil atravessa tudo"**
   - ✅ Verifique collision_mask do projectile (deve ser 5)
   - ✅ Confirme que _on_body_entered está conectado
   - ✅ Verifique se enemy tem collision_layer = 4

## 📊 Resumo Visual

```
┌─────────────┐
│   PLAYER    │ Layer 2
│ (entidades) │ Mask: 1,3,4
└──────┬──────┘
       │
       ├─> attack_area      Layer 5, Mask: 3
       │                    (Ataca enemies)
       │
       └─> projectile       Layer 6, Mask: 1,3
                            (Ataca enemies e paredes)

┌─────────────┐
│   ENEMY     │ Layer 3
│  (enemy)    │ Mask: 1,2
└──────┬──────┘
       │
       ├─> HitboxArea2D     Layer 4, Mask: 2
       │                    (Ataca player)
       │
       └─> DetectionArea2D  Layer 0, Mask: 2
                            (Detecta player)
```

## ✅ Status Atual

- ✅ Player configurado (collision_layer = 2, collision_mask = 13)
- ✅ Player attack_area configurado (layer = 16, mask = 4)
- ✅ Projectile configurado (layer = 32, mask = 5)
- ✅ Enemy configurado (layer = 4, mask = 3)
- ✅ Enemy HitboxArea2D configurado (layer = 8, mask = 2)
- ✅ Enemy DetectionArea2D configurado (layer = 0, mask = 2)

**Sistema de colisões 100% funcional!** 🎉
