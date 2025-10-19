# 🐛 Bug Fix: Inimigo Não Persegue Player

## 🔍 Problema Identificado

### Sintomas:
```
[ENEMY] Estado: HURT → CHASE (flash terminado)
[ENEMY] Estado: CHASE → IDLE (alvo perdido)
```
- ❌ Inimigo nunca detecta o player naturalmente
- ❌ Só muda para CHASE após receber dano
- ❌ Imediatamente perde o alvo e volta para IDLE

### Causa Raiz:

**No `process_hurt()`:**
```gdscript
await hit_flash_timer.timeout
if not is_dead:
    current_state = State.CHASE  # ← Muda para CHASE mas target ainda é null!
```

**No `process_chase()`:**
```gdscript
if not target or not is_instance_valid(target):
    current_state = State.IDLE  # ← Volta imediatamente para IDLE
    return
```

**Fluxo do bug:**
1. Inimigo recebe dano → muda para HURT
2. Flash termina → muda para CHASE
3. `process_chase()` vê que `target = null`
4. Volta imediatamente para IDLE

---

## ✅ Soluções Implementadas

### 1️⃣ Definir Target Após Receber Dano

**Modificação em `take_damage()`:**
```gdscript
func take_damage(amount: float) -> void:
    # ... aplicação de dano ...
    
    # Se for agressivo e não tiver alvo, procura o player
    if enemy_data.behavior == "Aggressive" and not target:
        var players = get_tree().get_nodes_in_group("player")
        if players.size() > 0:
            target = players[0]
            print("[ENEMY]    🎯 Alvo definido após dano: ", target.name)
    
    # ... resto do código ...
```

**O que faz:**
- Quando recebe dano, busca o player no grupo "player"
- Define como `target` automaticamente
- Agora pode perseguir após ser atacado!

---

### 2️⃣ Validar Target no process_hurt()

**Modificação em `process_hurt()`:**
```gdscript
func process_hurt() -> void:
    velocity = Vector2.ZERO
    await hit_flash_timer.timeout
    
    if not is_dead:
        # Só volta para chase se tiver alvo
        if target and is_instance_valid(target):
            print("[ENEMY] Estado: HURT → CHASE (flash terminado, alvo válido)")
            current_state = State.CHASE
        else:
            print("[ENEMY] Estado: HURT → IDLE (flash terminado, sem alvo)")
            current_state = State.IDLE
```

**O que faz:**
- Verifica se `target` existe E é válido
- Se sim → vai para CHASE
- Se não → vai para IDLE
- Evita mudar para CHASE sem alvo

---

### 3️⃣ Debug Melhorado da DetectionArea

**Adicionado:**
```gdscript
print("[ENEMY]    DetectionArea - Layer: %d, Mask: %d" % [detection_area.collision_layer, detection_area.collision_mask])
print("[ENEMY]    DetectionArea - Monitoring: %s" % detection_area.monitoring)
```

**Para verificar:**
- Se a DetectionArea está configurada corretamente
- Se o monitoring está ativo
- Se as collision layers/masks estão corretas

---

## 🎮 Comportamento Esperado Agora

### Cenário 1: Player Entra no Range Naturalmente
```
[ENEMY] 👁️ DetectionArea detectou: Player
[ENEMY]    ✅ É o player e sou agressivo! Definindo como alvo...
[ENEMY] Estado: IDLE → CHASE
(Inimigo persegue o player)
```

### Cenário 2: Inimigo Recebe Dano
```
[ENEMY] 💔 Lobo Veloz RECEBEU DANO!
[ENEMY]    🎯 Alvo definido após dano: Player
[ENEMY] Estado: IDLE → HURT
[ENEMY] Estado: HURT → CHASE (flash terminado, alvo válido)
(Inimigo persegue o player)
```

### Cenário 3: Player Sai do Range
```
[ENEMY] 👁️ DetectionArea saiu: Player
[ENEMY]    Era meu alvo! Perdendo alvo e voltando para IDLE
[ENEMY] Estado: CHASE → IDLE (alvo perdido)
```

---

## 🔧 Como Testar

1. **Execute o jogo**
2. **Fique longe do inimigo** primeiro
3. **Aproxime-se devagar** - Deve aparecer:
   ```
   [ENEMY] 👁️ DetectionArea detectou: Player
   [ENEMY] Estado: IDLE → CHASE
   ```

4. **Se não detectar naturalmente:**
   - Ataque o inimigo
   - Deve aparecer:
   ```
   [ENEMY]    🎯 Alvo definido após dano: Player
   [ENEMY] Estado: HURT → CHASE (flash terminado, alvo válido)
   ```

5. **Observe o inimigo perseguir você**

---

## ⚠️ Possível Problema Adicional

Se mesmo com a correção o inimigo não detectar naturalmente, pode ser problema de **collision layers** da DetectionArea:

### Verificar no console:
```
[ENEMY]    DetectionArea - Layer: 0, Mask: 2
[ENEMY]    DetectionArea - Monitoring: true
```

### Esperado:
- **Layer:** 0 (não colide fisicamente)
- **Mask:** 2 (detecta Layer 2 = Player)
- **Monitoring:** true (está ativo)

### Se Mask estiver errado:
O player tem `collision_layer = 2`, então a DetectionArea precisa ter `collision_mask = 2` para detectar.

---

## 📊 Resumo das Mudanças

| Arquivo | Função | O Que Mudou |
|---------|--------|-------------|
| enemy.gd | `take_damage()` | ✅ Define target automaticamente quando recebe dano |
| enemy.gd | `process_hurt()` | ✅ Valida target antes de ir para CHASE |
| enemy.gd | `setup_enemy()` | ✅ Debug melhorado da DetectionArea |

---

## 🎯 Status

- ✅ Inimigo define alvo quando recebe dano
- ✅ Inimigo só volta para CHASE se tiver alvo válido
- ✅ Debug melhorado para diagnosticar DetectionArea
- ⏳ Aguardando teste para confirmar detecção natural

**Se ainda não detectar naturalmente após o teste, o problema está na DetectionArea da scene!**
