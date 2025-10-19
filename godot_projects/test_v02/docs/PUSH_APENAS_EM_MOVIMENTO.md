# 🏃 Push Apenas Durante Movimento do Player

## ✅ Mudança Implementada

O sistema de push/stun agora **só funciona quando o player está se movendo**. Se o player estiver parado, não empurra inimigos.

---

## 🔧 Modificação Técnica

### `scripts/player/entidades.gd` - `handle_enemy_push()`

#### ✅ AGORA (Correto):
```gdscript
func handle_enemy_push() -> void:
    # ✅ SÓ empurra se o PLAYER estiver se movendo
    if direction == Vector2.ZERO:
        return  # Player parado = sem push
    
    # ... resto do código
    
    # Usa a DIREÇÃO DO MOVIMENTO do player para empurrar
    var push_direction = direction.normalized()
    var push_power = (player_push_strength - enemy_push_resistance) * 0.5
    
    collider.apply_push(push_direction, push_power)
```

#### ❌ ANTES (Problemático):
```gdscript
func handle_enemy_push() -> void:
    # Empurrava mesmo com player parado
    
    # Usava direção relativa (enemy.pos - player.pos)
    var push_direction = (collider.global_position - global_position).normalized()
```

---

## 🎯 Diferenças de Comportamento

### 1. **Player Parado + Inimigo Encosta**

#### ❌ Antes:
- Inimigo seria empurrado para trás
- Push baseado na posição relativa
- Sem sentido físico (player parado não deveria empurrar)

#### ✅ Agora:
- **Nenhum push aplicado**
- Inimigo pode encostar livremente
- Inimigo pode atacar normalmente

---

### 2. **Player Movendo + Colide com Inimigo**

#### ❌ Antes:
- Push baseado em `(enemy.pos - player.pos)`
- Direção nem sempre correspondia ao movimento
- Podia empurrar para diagonal mesmo andando reto

#### ✅ Agora:
- **Push baseado na direção do movimento** (`direction.normalized()`)
- Se anda para direita → empurra inimigo para direita
- Se anda para cima → empurra inimigo para cima
- Se anda diagonal → empurra inimigo na diagonal

---

## 🎮 Comportamento no Jogo

### Cenário 1: Player Parado
```
1. Inimigo se aproxima
2. Inimigo encosta no player parado
3. ❌ Nenhum push aplicado
4. Inimigo entra em modo ATTACK normalmente
```

### Cenário 2: Player Andando para Direita
```
1. Player pressiona tecla →
2. Player colide com inimigo
3. ✅ Push aplicado na direção → (direita)
4. Inimigo é empurrado para direita + atordoado 300ms
5. Após stun, inimigo retoma comportamento
```

### Cenário 3: Player Andando Diagonal ↗
```
1. Player pressiona ↑ + →
2. Player colide com inimigo
3. ✅ Push aplicado na direção ↗ (diagonal)
4. Inimigo é empurrado diagonalmente + atordoado
```

---

## 💡 Por Que Isso é Melhor?

### 1. **Físico Realista**
- Player parado não tem momentum → não deveria empurrar
- Player movendo tem momentum → empurra na direção do movimento

### 2. **Gameplay Mais Tático**
- Player pode escolher **não empurrar** ficando parado
- Inimigos podem atacar se player não se mexer
- Player pode usar movimento estratégico para empurrar inimigos

### 3. **Direção Previsível**
- Push sempre na direção que você está andando
- Sem pushes inesperados em direções estranhas
- Mais controle para o player

### 4. **Evita Bugs**
- Sem push quando player está sendo atacado enquanto parado
- Sem confusão de direções
- Comportamento consistente

---

## 🔍 Verificação

### Como saber se está funcionando:

1. **Teste 1: Player Parado**
   - Fique parado perto do inimigo
   - Deixe o inimigo se aproximar e encostar
   - **Esperado:** Nenhum log de push no console
   - **Esperado:** Inimigo não é empurrado

2. **Teste 2: Player Andando**
   - Ande em direção ao inimigo
   - Colida com ele enquanto se move
   - **Esperado:** Log de push + stun no console
   - **Esperado:** Inimigo empurrado na direção do seu movimento

3. **Teste 3: Direção do Push**
   - Ande para cima e colida → Inimigo deve ir para cima
   - Ande para direita e colida → Inimigo deve ir para direita
   - Ande diagonal e colida → Inimigo deve ir na diagonal

---

## 📊 Logs Esperados

### Player Parado (sem push):
```
[ENEMY] 👁️ DetectionArea detectou ENTRADA: Entidades
[ENEMY] Estado: IDLE → CHASE
(Sem logs de push)
```

### Player Movendo (com push):
```
[ENEMY] 💨 Empurrado e ATORDOADO! Direção: (1.0, 0.0) Força: 40.0 Stun: 0.30s
[ENEMY] 🔓 Stun acabou! Voltando ao estado: CHASE
```

---

## ⚙️ Código de Verificação

### A direção usada para push:
```gdscript
# ✅ Usa a direção do INPUT do player
var push_direction = direction.normalized()

# direction vem de:
direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
```

### Exemplos de valores:
- Andando → : `direction = (1.0, 0.0)`
- Andando ← : `direction = (-1.0, 0.0)`
- Andando ↑ : `direction = (0.0, -1.0)`
- Andando ↓ : `direction = (0.0, 1.0)`
- Andando ↗ : `direction = (0.707, -0.707)` (normalizado)
- Parado: `direction = (0.0, 0.0)` → **Push não aplicado**

---

## 🎯 Resultado Final

### ✅ Benefícios:
- Push mais intuitivo e previsível
- Gameplay mais tático (escolher empurrar ou não)
- Física mais realista
- Sem pushes "fantasma" quando parado
- Direção do push = direção do movimento

### 🎮 Sensação no Jogo:
- Player se sente mais no controle
- Movimento tem peso e impacto
- Inimigos só são empurrados quando "atropelados"
- Parar = aceitar confronto direto

---

**Data:** 2025-10-19  
**Arquivos Modificados:** `scripts/player/entidades.gd`  
**Status:** ✅ Pronto para teste
