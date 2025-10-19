# ⚔️ NOVO Sistema de Ataque do Inimigo

## 🎯 Mudança Implementada

Reimplementado o sistema de ataque do inimigo para funcionar **igual ao do player**: hitbox temporária que só está ativa durante o ataque.

---

## ❌ Sistema Antigo (Problemático)

### Como funcionava:
1. Hitbox **sempre ativa** (monitoring = true)
2. Inimigo verificava `get_overlapping_bodies()` ao atacar
3. Problema: Colisão física impedia inimigo de chegar perto o suficiente
4. `attack_range` tinha que ser maior que a soma dos collision_shapes

### Problemas:
- ❌ Hitbox sempre detectando colisões (desperdício)
- ❌ Dependente de distância física
- ❌ Conflito entre collision_shape e attack_range
- ❌ Dano só aplicado no momento exato do `perform_attack()`

---

## ✅ Sistema Novo (Como o Player)

### Como funciona agora:

#### 1. **Setup (_ready)**
```gdscript
// Hitbox começa DESATIVADA
hitbox_area.monitoring = false
```

#### 2. **Entra em Modo ATTACK**
```gdscript
// Quando distância <= attack_range
current_state = State.ATTACK
```

#### 3. **Executa perform_attack()**
```gdscript
func perform_attack() -> void:
    can_attack = false
    
    // ⚡ ATIVA hitbox temporariamente
    hitbox_area.monitoring = true
    
    // 🎬 Toca animação
    sprite.play("attack")
    
    // ⏳ Inicia cooldown
    attack_timer.start()
    
    // 🕐 Espera duração da animação
    await get_tree().create_timer(attack_duration).timeout
    
    // 🛑 DESATIVA hitbox
    hitbox_area.monitoring = false
```

#### 4. **Player Entra na Hitbox (Signal)**
```gdscript
func _on_hitbox_body_entered(body: Node2D) -> void:
    // Só funciona se hitbox estiver ATIVA
    if not hitbox_area.monitoring:
        return
    
    // Se for o player, aplica dano
    if body.is_in_group("player"):
        body.take_damage(enemy_data.damage)
```

---

## 🎮 Fluxo de Ataque

### Sequência Completa:

1. **Perseguição (CHASE)**
   ```
   [ENEMY] 🏃 CHASE - Distância: 85.0 / Attack Range: 80.0
   ```

2. **Entra em Modo ATTACK**
   ```
   [ENEMY] Estado: CHASE → ATTACK (distância: 78.5)
   ```

3. **Executa Ataque**
   ```
   [ENEMY] ⚔️ ATACANDO! (can_attack = false)
   [ENEMY]    ⚡ Hitbox ATIVADA para ataque
   [ENEMY]    🎬 Animação 'attack' tocando
   [ENEMY]    ⏳ Cooldown iniciado (0.80s)
   ```

4. **Player Entra na Hitbox (Se estiver próximo)**
   ```
   [ENEMY] 🔔 Hitbox detectou entrada: Entidades
   [ENEMY]    💥 Player detectado na hitbox ATIVA!
   [ENEMY]    ✅ Dano 15.0 aplicado ao player!
   [PLAYER] 💔 DANO RECEBIDO: 15.0
   [PLAYER]    HP atual: 85.0/100.0
   ```

5. **Hitbox Desativa (Após animação)**
   ```
   [ENEMY]    🛑 Hitbox DESATIVADA após ataque
   ```

6. **Cooldown Termina**
   ```
   [ENEMY] ⏱️ Cooldown terminado (can_attack = true)
   ```

7. **Próximo Ataque (Se player ainda estiver no range)**
   ```
   (Repete a partir do passo 3)
   ```

---

## 📊 Valores Configurados

```
collision_shape (física): radius = 35.0 pixels
hitbox_shape (ataque): radius = 50.0 pixels
attack_range: 80.0 pixels
```

### Por quê esses valores?

#### attack_range = 80.0
- Maior que (player_collision + enemy_collision) = 70.0
- Permite entrar em ATTACK antes da colisão física
- Margem de 10 pixels de segurança

#### hitbox_radius = 50.0
- Alcance médio de ataque melee
- Player precisa estar próximo mas não colado
- Permite esquiva se player se afastar rápido

---

## 🎯 Vantagens do Novo Sistema

### 1. **Performance**
- ✅ Hitbox só ativa durante ataque (~0.3s a cada 0.8s)
- ✅ Menos processamento de colisões
- ✅ Mais eficiente em cenas com muitos inimigos

### 2. **Gameplay**
- ✅ Player pode ver animação de ataque
- ✅ Tempo para reagir e esquivar
- ✅ Mais justo e previsível
- ✅ Possibilita "dodge timing"

### 3. **Flexibilidade**
- ✅ Não depende de distância física
- ✅ Pode ter ataques com diferentes alcances
- ✅ Hitbox pode ter formato diferente (retângulo, cone, etc.)
- ✅ Facilita implementar ataques especiais

### 4. **Consistência**
- ✅ Sistema idêntico ao do player
- ✅ Fácil de entender e manter
- ✅ Reutilizável para outros inimigos

---

## 🔧 Arquivos Modificados

### `scripts/enemy/enemy.gd`

#### Mudanças:

1. **setup_enemy()** - Linha ~62
   ```gdscript
   // Hitbox começa desativada
   hitbox_area.monitoring = false
   ```

2. **perform_attack()** - Linha ~257
   ```gdscript
   // Ativa hitbox temporariamente
   hitbox_area.monitoring = true
   
   // ... animação ...
   
   await get_tree().create_timer(attack_duration).timeout
   
   // Desativa hitbox
   hitbox_area.monitoring = false
   ```

3. **_on_hitbox_body_entered()** - Linha ~402
   ```gdscript
   // Só aplica dano se hitbox estiver ativa
   if not hitbox_area.monitoring:
       return
   
   if body.is_in_group("player"):
       body.take_damage(enemy_data.damage)
   ```

### `EnemyData/wolf_fast.tres`

```gdscript
hitbox_shape radius: 75.0 → 50.0
attack_range: 25.0 → 80.0
```

---

## 🧪 Como Testar

### Teste 1: Aproximação
1. Execute o jogo
2. Deixe o inimigo se aproximar
3. **Observe logs:**
   ```
   [ENEMY] 🏃 CHASE - Distância: X.X / Attack Range: 80.0
   ```
4. Quando distância < 80.0 → Muda para ATTACK

### Teste 2: Ataque
1. Inimigo entra em modo ATTACK
2. **Observe logs:**
   ```
   [ENEMY] ⚔️ ATACANDO!
   [ENEMY]    ⚡ Hitbox ATIVADA
   [ENEMY]    🎬 Animação 'attack' tocando
   ```

### Teste 3: Dano
1. Fique próximo durante ataque
2. **Esperado:**
   ```
   [ENEMY] 🔔 Hitbox detectou entrada: Entidades
   [ENEMY]    💥 Player detectado na hitbox ATIVA!
   [ENEMY]    ✅ Dano 15.0 aplicado!
   [PLAYER] 💔 DANO RECEBIDO: 15.0
   ```

### Teste 4: Esquiva
1. Quando inimigo começar animação de ataque
2. **Afaste-se rapidamente**
3. **Esperado:** Não tomar dano (saiu da hitbox a tempo)

### Teste 5: Múltiplos Ataques
1. Fique perto do inimigo
2. **Esperado:** 
   - Ataque 1 → Dano 15.0 → HP 85.0
   - Cooldown 0.8s
   - Ataque 2 → Dano 15.0 → HP 70.0
   - etc.

---

## 🎯 Comportamento Esperado

### ✅ Funcionando Corretamente:
- Hitbox só ativa durante ataque
- Dano aplicado quando player entra na hitbox ativa
- Hitbox desativa após animação
- Múltiplos ataques com cooldown funcionando
- Player pode esquivar se afastar rápido

### ❌ Se Não Funcionar:
- Verificar se animação "attack" existe
- Verificar se attack_duration está correto
- Verificar se signal `body_entered` está conectado
- Verificar collision layers (hitbox mask = 2, player layer = 2)

---

## 📝 Notas Técnicas

### Duração do Ataque
```gdscript
var attack_duration = 0.3  // Padrão

// Ou calcula da animação:
attack_duration = sprite.sprite_frames.get_frame_count("attack") 
                  / sprite.sprite_frames.get_animation_speed("attack")
```

### Timing
- **Hitbox ativa:** Durante animação (~0.3s)
- **Cooldown:** 0.8s
- **Taxa de ataque:** ~1.25 ataques por segundo (máximo)
- **DPS:** 15.0 * 1.25 = 18.75 dano por segundo (se player não esquivar)

---

**Data:** 2025-10-19  
**Status:** ✅ Implementado, aguardando teste  
**Tipo:** Sistema de combate reimplementado
