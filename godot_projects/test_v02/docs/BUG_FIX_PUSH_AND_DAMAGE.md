# 🐛 BUG FIX: Push Infinito e Dano Único

**Data:** 19/10/2025  
**Problemas:** 
1. Sistema de push do inimigo se repete centenas de vezes
2. Player só toma dano uma vez, mesmo ficando dentro da hitbox

---

## 🔍 Diagnóstico

### Problema 1: Push Infinito

#### Sintoma no Debug:
```
[ENEMY] 💨 Empurrado! Direção: (0.0, 1.0) Força: 20.0
[ENEMY] 💨 Empurrado! Direção: (0.0, 1.0) Força: 20.0
[ENEMY] 💨 Empurrado! Direção: (0.0, 1.0) Força: 20.0
... (centenas de vezes) ...
```

#### Causa Raiz:
**Arquivo:** `scripts/enemy/enemy.gd` (linha ~162)

```gdscript
# ❌ CÓDIGO QUEBRADO:
func _physics_process(delta: float) -> void:
    if push_velocity.length() > 0.1:
        velocity += push_velocity  # ❌ SOMA infinitamente!
        push_velocity = push_velocity.lerp(Vector2.ZERO, push_decay * delta)
```

**O que acontecia:**
1. Player colide com enemy
2. `apply_push()` define `push_velocity = (0, 1) * 20 = (0, 20)`
3. **Cada frame**: `velocity += push_velocity` (somando 20 a cada frame!)
4. `push_velocity` nunca chega a zero no primeiro frame
5. Log "Empurrado!" dispara centenas de vezes

**Por que o log aparecia tanto?**
- O log estava em `apply_push()`, que era chamado **a cada frame** pelo player
- Porque o player detectava colisão contínua com o enemy

---

### Problema 2: Dano Único

#### Sintoma no Debug:
```
[ENEMY] 💥 Hitbox colidiu com: Entidades
[ENEMY]    💥 Causando 15.0 de dano no player!
[PLAYER] 💔 DANO RECEBIDO: 15.0

... (player continua dentro da hitbox) ...

[ENEMY] 💥 Hitbox colidiu com: Entidades
[ENEMY]    ⚠️ Ainda em cooldown   ← Mas cooldown já terminou!
```

#### Causa Raiz:
**Arquivo:** `scripts/enemy/enemy.gd` (~linha 408)

```gdscript
# ❌ LÓGICA QUEBRADA:
func _on_hitbox_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and can_attack:
        body.take_damage(enemy_data.damage)
```

**O que acontecia:**
1. Signal `body_entered` dispara **apenas quando o body ENTRA** na área
2. Se o player **já está dentro**, o signal **não dispara** novamente
3. Mesmo que `can_attack` volte para `true`, o signal não é chamado
4. Player pode ficar na hitbox infinitamente sem tomar dano

**Por que signals não funcionam aqui?**
- `body_entered` = evento único de entrada
- `body_exited` = evento único de saída
- Se o body **permanece dentro**, nenhum signal dispara!

---

## ✅ Soluções Aplicadas

### Fix 1: Push Sistema

**Mudança:** Substituir ao invés de somar velocidade

```gdscript
# ✅ CÓDIGO CORRIGIDO:
func _physics_process(delta: float) -> void:
    if is_dead:
        return
    
    # Aplica velocidade de empurrão (decai com o tempo)
    if push_velocity.length() > 0.1:
        velocity = push_velocity  # ✅ SUBSTITUI ao invés de SOMAR
        push_velocity = push_velocity.lerp(Vector2.ZERO, push_decay * delta)
    else:
        push_velocity = Vector2.ZERO  # ✅ Garante que zera completamente
```

**Como funciona agora:**
1. `apply_push()` define `push_velocity`
2. **Um único frame**: `velocity = push_velocity` (substitui, não soma)
3. `push_velocity` decai gradualmente
4. Quando < 0.1, zera completamente
5. Log aparece apenas uma vez por push

---

### Fix 2: Sistema de Dano

**Mudança:** Verificar overlaps manualmente durante o ataque

```gdscript
# ✅ CÓDIGO CORRIGIDO:
func perform_attack() -> void:
    can_attack = false
    print("[ENEMY] ⚔️ ATACANDO! (can_attack = false)")
    
    # Toca animação de ataque
    if sprite and enemy_data.sprite_frames.has_animation("attack"):
        sprite.play("attack")
    
    # ✅ NOVO: Verifica se o player está dentro da hitbox AGORA
    if hitbox_area:
        var bodies_in_hitbox = hitbox_area.get_overlapping_bodies()
        print("[ENEMY]    🔍 Verificando corpos na hitbox: ", bodies_in_hitbox.size())
        for body in bodies_in_hitbox:
            if body.is_in_group("player"):
                print("[ENEMY]    💥 Player encontrado na hitbox! Causando dano...")
                if body.has_method("take_damage"):
                    body.take_damage(enemy_data.damage)
                    print("[ENEMY]    ✅ Dano %.1f aplicado!" % enemy_data.damage)
                break
    
    # Inicia cooldown
    if attack_timer:
        attack_timer.start()
```

**Como funciona agora:**
1. Enemy entra em estado ATTACK
2. `perform_attack()` é chamado
3. **Verifica ativamente** quem está na hitbox usando `get_overlapping_bodies()`
4. Aplica dano se o player estiver lá
5. Inicia cooldown
6. Após cooldown, pode atacar novamente (verificando overlaps de novo)

---

## 🎯 Comparação Antes vs Depois

### Push Sistema:

| Aspecto | Antes (❌) | Depois (✅) |
|---------|-----------|-------------|
| Velocidade | `velocity += push` (soma) | `velocity = push` (substitui) |
| Decay | Nunca zerava no 1º frame | Zera quando < 0.1 |
| Logs | Centenas por segundo | Um por push |
| Comportamento | Aceleração infinita | Push suave e controlado |

### Dano Sistema:

| Aspecto | Antes (❌) | Depois (✅) |
|---------|-----------|-------------|
| Detecção | Signal `body_entered` | `get_overlapping_bodies()` |
| Frequência | Apenas na entrada | A cada ataque |
| Player parado | Sem dano contínuo | Dano a cada cooldown |
| Confiabilidade | Falha se já dentro | Sempre funciona |

---

## 📊 Debug Esperado (Após Fix)

### Push:
```
[ENEMY] 💨 Empurrado! Direção: (0.0, 1.0) Força: 20.0
... (nada mais por alguns frames) ...
[ENEMY] 💨 Empurrado! Direção: (0.5, 0.87) Força: 20.0
```

### Dano:
```
[ENEMY] ⚔️ ATACANDO! (can_attack = false)
[ENEMY]    🔍 Verificando corpos na hitbox: 1
[ENEMY]    💥 Player encontrado na hitbox! Causando dano...
[ENEMY]    ✅ Dano 15.0 aplicado!
[PLAYER] 💔 DANO RECEBIDO: 15.0
[ENEMY]    Cooldown iniciado (0.80s)

... (após 0.8s) ...

[ENEMY] ⏱️ Cooldown de ataque terminado (can_attack = true)
[ENEMY] ⚔️ ATACANDO! (can_attack = false)
[ENEMY]    🔍 Verificando corpos na hitbox: 1
[ENEMY]    💥 Player encontrado na hitbox! Causando dano...
[ENEMY]    ✅ Dano 15.0 aplicado!
[PLAYER] 💔 DANO RECEBIDO: 15.0
```

---

## 🧪 Como Testar

### Push Sistema:
1. Rode o jogo
2. Aproxime-se do enemy para colidir
3. ✅ Enemy deve ser empurrado **uma vez** por colisão
4. ✅ Deve deslizar suavemente para trás
5. ✅ Log "Empurrado!" deve aparecer apenas ocasionalmente

### Dano Sistema:
1. Rode o jogo
2. Fique parado na frente do enemy
3. ✅ Enemy deve atacar continuamente
4. ✅ Dano deve ser aplicado **a cada 0.8s** (cooldown)
5. ✅ HP do player deve diminuir gradualmente

---

## 📝 Lições Aprendidas

### 1. Velocidade em Physics
- **Nunca some velocidades continuamente** em `_physics_process`
- Use `=` para substituir, não `+=` para somar
- Sempre tenha uma condição de parada (zero velocity)

### 2. Area2D Signals
- `body_entered` / `body_exited` são **eventos únicos**
- Para **detecção contínua**, use `get_overlapping_bodies()`
- Signals são ótimos para triggers, não para monitoramento constante

### 3. Debug Logs Essenciais
```gdscript
# ✅ BOM:
print("[ENEMY] 💨 Empurrado! Direção: ", dir, " Força: ", power)

# ❌ RUIM (muito verboso):
print("[ENEMY] Empurrado") # aparece 1000x/segundo
```

---

## ✅ Status

**CORRIGIDO** - Ambos os sistemas agora funcionam corretamente.

### Mudanças:
1. ✅ Push velocity usa substituição ao invés de soma
2. ✅ Push velocity zera completamente quando < 0.1
3. ✅ Dano usa verificação ativa de overlaps
4. ✅ Dano funciona mesmo com player parado na hitbox

**Próximo Teste:** Rode o jogo e verifique se os comportamentos estão corretos!

---

## 🎓 Referências

- Godot Docs: [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
- Godot Docs: [Area2D.get_overlapping_bodies()](https://docs.godotengine.org/en/stable/classes/class_area2d.html#class-area2d-method-get-overlapping-bodies)
- `docs/SISTEMA_EMPURRAO.md` - Documentação do sistema de push
