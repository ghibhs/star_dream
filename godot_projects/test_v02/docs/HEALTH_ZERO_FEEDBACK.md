# Sistema de Feedback Visual de Vida Zerada

## 🎯 Funcionalidade

Agora quando a vida de um inimigo ou do player chegar a **zero**, o console mostra um **alerta visual claro** para facilitar o debug e acompanhamento do jogo.

## 📊 Exemplos de Output

### 🔴 Quando o Inimigo Zera a Vida

```
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    Dano bruto: 25.0 | Defesa: 2.0 | Dano real: 23.0
[ENEMY]    HP: 15.0 → -8.0 (0.0%)
[ENEMY] ══════════════════════════════════════
[ENEMY] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️
[ENEMY] HP FINAL: -8.0 / 100.0
[ENEMY] ══════════════════════════════════════

[ENEMY] ══════════════════════════════════════
[ENEMY] ☠️☠️☠️  Lobo Negro MORREU!  ☠️☠️☠️
[ENEMY] ══════════════════════════════════════
[ENEMY]    HP Final: -8.0 / 100.0
[ENEMY]    Exp drop: 50 | Coins drop: 10
[ENEMY] ══════════════════════════════════════
```

### 🔵 Quando o Player Zera a Vida

```
[PLAYER] 💔 DANO RECEBIDO: 30.0
[PLAYER]    HP: 15.0 → -15.0 (0.0%)
[PLAYER] ══════════════════════════════════════
[PLAYER] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️
[PLAYER] HP FINAL: -15.0 / 100.0
[PLAYER] ══════════════════════════════════════

[PLAYER] ══════════════════════════════════════
[PLAYER] ☠️☠️☠️  PLAYER MORREU!  ☠️☠️☠️
[PLAYER] ══════════════════════════════════════
[PLAYER]    HP Final: -15.0 / 100.0
[PLAYER]    Physics desativado
[PLAYER] ══════════════════════════════════════
```

## 🎨 Elementos Visuais

### 1. **Barra Separadora**
```
══════════════════════════════════════
```
Torna fácil encontrar visualmente no console.

### 2. **Emoji de Alerta**
```
⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️
```
Chama atenção imediatamente.

### 3. **HP Final Detalhado**
```
HP FINAL: -8.0 / 100.0
```
Mostra exatamente quanto de "overkill" houve.

### 4. **Antes/Depois**
```
HP: 15.0 → -8.0 (0.0%)
```
Mostra a transição clara de vida positiva para zero/negativa.

## 🔧 Como Funciona

### No Enemy (`enemy.gd`)

```gdscript
func take_damage(amount: float) -> void:
    var previous_health = current_health
    current_health -= damage_taken
    
    print("[ENEMY]    HP: %.1f → %.1f (%.1f%%)" % 
          [previous_health, current_health, (current_health/max_health)*100])
    
    # ⚠️ ALERTA quando vida zera
    if current_health <= 0:
        print("[ENEMY] ══════════════════════════════════════")
        print("[ENEMY] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️")
        print("[ENEMY] HP FINAL: %.1f / %.1f" % [current_health, max_health])
        print("[ENEMY] ══════════════════════════════════════")
```

### No Player (`player.gd`)

```gdscript
func take_damage(amount: float) -> void:
    var previous_health = current_health
    current_health -= amount
    
    print("[PLAYER]    HP: %.1f → %.1f (%.1f%%)" % 
          [previous_health, current_health, (current_health/max_health)*100])
    
    # ⚠️ ALERTA quando vida zera
    if current_health <= 0:
        print("[PLAYER] ══════════════════════════════════════")
        print("[PLAYER] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️")
        print("[PLAYER] HP FINAL: %.1f / %.1f" % [current_health, max_health])
        print("[PLAYER] ══════════════════════════════════════")
```

## 💡 Benefícios para Debug

### 1. **Fácil de Encontrar**
As barras separadoras fazem os eventos de morte se destacarem no console.

### 2. **Informação Completa**
Mostra:
- HP antes e depois do dano
- HP final exato (incluindo valores negativos)
- Porcentagem de vida restante
- Para inimigos: Exp e coins dropados

### 3. **Sequência Clara**
```
1. Dano recebido
2. ⚠️ VIDA ZEROU!
3. ☠️ MORREU!
4. Informações de morte
```

### 4. **Identifica Overkill**
Exemplo:
```
HP FINAL: -25.0 / 100.0
```
Significa que o dano excedeu a vida em 25 pontos.

## 🎮 Casos de Uso

### Balanceamento de Combate
```
[ENEMY]    HP: 5.0 → -20.0 (0.0%)
```
→ "Estou causando muito dano! Preciso reduzir o dano da arma."

### Bug de Imortalidade
Se você nunca vê a mensagem de vida zerada:
→ "O inimigo não está recebendo dano corretamente!"

### Timing de Morte
```
[ENEMY] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️
... (tempo passa)
[ENEMY] ☠️☠️☠️  Lobo Negro MORREU!  ☠️☠️☠️
```
→ Mostra o delay entre vida zerada e animação de morte.

## 📊 Exemplo de Sequência Completa

### Combate até a Morte do Inimigo

```
[PLAYER] ⚔️ ATACANDO com Espada
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    HP: 100.0 → 85.0 (85.0%)

[PLAYER] ⚔️ ATACANDO com Espada
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    HP: 85.0 → 70.0 (70.0%)

[PLAYER] ⚔️ ATACANDO com Espada
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    HP: 70.0 → 55.0 (55.0%)

[PLAYER] ⚔️ ATACANDO com Espada
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    HP: 55.0 → 40.0 (40.0%)

[PLAYER] ⚔️ ATACANDO com Espada
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    HP: 40.0 → 25.0 (25.0%)

[PLAYER] ⚔️ ATACANDO com Espada
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    HP: 25.0 → 10.0 (10.0%)

[PLAYER] ⚔️ ATACANDO com Espada
[ENEMY] 💔 Lobo Negro RECEBEU DANO!
[ENEMY]    HP: 10.0 → -5.0 (0.0%)
[ENEMY] ══════════════════════════════════════
[ENEMY] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️
[ENEMY] HP FINAL: -5.0 / 100.0
[ENEMY] ══════════════════════════════════════

[ENEMY] ══════════════════════════════════════
[ENEMY] ☠️☠️☠️  Lobo Negro MORREU!  ☠️☠️☠️
[ENEMY] ══════════════════════════════════════
[ENEMY]    HP Final: -5.0 / 100.0
[ENEMY]    Exp drop: 50 | Coins drop: 10
[ENEMY] ══════════════════════════════════════
```

## 🎯 Possíveis Expansões

### 1. **Sistema de Health Bar no Mundo**
Adicionar barra de vida visual acima dos inimigos que pisca em vermelho quando < 20%.

### 2. **Som de "Low Health"**
Tocar um som de alerta quando vida está baixa (< 20%).

### 3. **Slow Motion na Morte**
```gdscript
if current_health <= 0:
    Engine.time_scale = 0.3  # Slow motion
    await get_tree().create_timer(0.5).timeout
    Engine.time_scale = 1.0
```

### 4. **Estatísticas de Overkill**
Contar quantos inimigos foram mortos com overkill e por quanto.

## 📝 Arquivos Modificados

- `scripts/enemy/enemy.gd`:
  - `take_damage()` - Adicionado alerta visual quando vida zera
  - `die()` - Melhorado formato de saída no console

- `scripts/player/player.gd`:
  - `take_damage()` - Adicionado alerta visual quando vida zera
  - `die()` - Melhorado formato de saída no console

---

**🎯 Agora é impossível não notar quando a vida zera no console!** 💀⚠️
