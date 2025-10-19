# 🛡️ Sistema de STUN ao Empurrar Inimigos

## 📋 Visão Geral

Implementado sistema de **atordoamento (stun)** quando o inimigo é empurrado pelo jogador. Isso resolve o conflito entre a velocidade de perseguição do inimigo e o push, eliminando o bug de empurrões repetidos infinitamente.

---

## 🎯 Como Funciona

### 1. **Quando o Push é Aplicado**

Quando `apply_push()` é chamado:

1. **Verifica se já está em stun** → Se sim, ignora (evita spam)
2. **Guarda o estado atual** → Salvo em `state_before_stun`
3. **Aplica o stun**:
   - Muda estado para `STUNNED`
   - Define `is_stunned = true`
   - Inicia timer de 0.3 segundos
4. **Aplica o push velocity** → Impulsiona o inimigo

### 2. **Durante o Stun (300ms)**

No `_physics_process()`:

```gdscript
if is_stunned:
    # Atualiza timer
    stun_timer -= delta
    
    # Aplica APENAS o push velocity (sem IA)
    velocity = push_velocity
    push_velocity = push_velocity.lerp(Vector2.ZERO, push_decay * delta)
    
    # Verifica se stun acabou
    if stun_timer <= 0.0:
        is_stunned = false
        current_state = state_before_stun  # Volta ao estado anterior
    
    move_and_slide()
    return  # NÃO processa IA
```

**Comportamentos bloqueados durante stun:**
- ❌ Perseguição (CHASE)
- ❌ Ataque (ATTACK)
- ❌ Qualquer lógica de IA
- ✅ Apenas aceita o impulso do push

### 3. **Após o Stun**

- Inimigo volta ao estado anterior (`state_before_stun`)
- Retoma comportamento normal (IDLE, CHASE, ATTACK, etc.)
- Pode receber novo push

---

## 🔧 Variáveis Adicionadas

### Em `enemy.gd`

```gdscript
# Novo estado no enum
enum State { IDLE, CHASE, ATTACK, HURT, DEAD, STUNNED }

# Variáveis de controle de stun
var is_stunned: bool = false
var stun_timer: float = 0.0
const STUN_DURATION: float = 0.3  # 300ms de stun

# Guarda estado antes do stun para restaurar depois
var state_before_stun: State = State.IDLE
```

---

## 🐛 Problema Resolvido

### ❌ ANTES (BUG):
```
[ENEMY] 💨 Empurrado! (chamado 500x por segundo)
[ENEMY] 💨 Empurrado!
[ENEMY] 💨 Empurrado!
[ENEMY] 💨 Empurrado!
... (infinito)
```

**Causa:** `apply_push()` era chamado a cada frame pelo `move_and_slide()` do player, enquanto o inimigo tentava se mover na direção do player, criando conflito de velocidades.

### ✅ AGORA (CORRIGIDO):
```
[ENEMY] 💨 Empurrado e ATORDOADO! Direção: (0.0, 1.0) Força: 20.0 Stun: 0.30s
... (300ms depois)
[ENEMY] 🔓 Stun acabou! Voltando ao estado: CHASE
```

**Por quê funciona:**
1. **Primeiro push** → Aplica stun de 300ms
2. **Durante stun** → Ignora novos pushes (`if is_stunned: return`)
3. **Sem conflito** → Inimigo não tenta se mover durante stun
4. **Push aplicado limpo** → Apenas a velocidade do push é processada

---

## 🎮 Comportamento no Jogo

### Colisão Player → Enemy

1. **Player encosta no inimigo**
2. **`handle_enemy_push()` chama `apply_push()`** (apenas 1 vez)
3. **Inimigo é empurrado para trás + atordoado**
4. **Durante 300ms:**
   - Inimigo desliza para trás (decaindo)
   - Não persegue o player
   - Não ataca
5. **Após 300ms:**
   - Inimigo "acorda"
   - Retoma perseguição se player ainda estiver no range
   - Ou volta para IDLE

### Visual esperado:
- 💥 Player encosta → Inimigo é "socado" para trás
- 😵 Inimigo fica atordoado brevemente
- 🏃 Inimigo retoma perseguição

---

## 📊 Parâmetros Ajustáveis

### Duração do Stun
```gdscript
const STUN_DURATION: float = 0.3  # Ajuste aqui (em segundos)
```

**Valores recomendados:**
- `0.2s` → Stun rápido, mais desafiador
- `0.3s` → **Padrão**, equilibrado
- `0.5s` → Stun longo, mais fácil para player

### Decay do Push
```gdscript
var push_decay: float = 5.0  # Maior = decai mais rápido
```

**Valores recomendados:**
- `3.0` → Push dura mais (inimigo desliza mais longe)
- `5.0` → **Padrão**, equilibrado
- `8.0` → Push dura menos (inimigo para rápido)

---

## 🔍 Debug Logs

### Push aplicado com sucesso:
```
[ENEMY] 💨 Empurrado e ATORDOADO! Direção: (0.707, 0.707) Força: 30.0 Stun: 0.30s
```

### Stun terminou:
```
[ENEMY] 🔓 Stun acabou! Voltando ao estado: CHASE
```

### Push ignorado (já em stun):
```
(nenhum log - retorna silenciosamente)
```

---

## 🔗 Arquivos Modificados

- **`scripts/enemy/enemy.gd`**:
  - Adicionado estado `STUNNED` ao enum
  - Variáveis `is_stunned`, `stun_timer`, `state_before_stun`
  - Lógica de stun em `_physics_process()`
  - Proteção contra spam em `apply_push()`

---

## ✅ Testes Recomendados

1. **Empurrar inimigo parado (IDLE)**
   - Deve ser empurrado para trás
   - Deve ficar atordoado 300ms
   - Deve voltar para IDLE

2. **Empurrar inimigo perseguindo (CHASE)**
   - Deve interromper perseguição
   - Deve ser empurrado para trás
   - Deve voltar a perseguir após stun

3. **Empurrar inimigo atacando (ATTACK)**
   - Deve interromper ataque
   - Deve ser empurrado
   - Deve retomar comportamento apropriado após stun

4. **Empurrar repetidamente**
   - Primeiro push: Aplica stun + push
   - Pushes durante stun: Ignorados
   - Após stun: Aceita novo push

---

## 🎯 Resultado Esperado

- ✅ **Um único log** de push por colisão
- ✅ Inimigo empurrado de forma suave
- ✅ Sem conflito entre velocidades
- ✅ Gameplay mais polido e responsivo
- ✅ Stun visual claro para o jogador

---

**Data:** 2025-10-19  
**Versão:** Godot 4.5.dev4
