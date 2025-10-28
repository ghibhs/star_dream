# 🔍 DEBUG: Player Não Toma Dano

## 🎯 Problema Reportado

O personagem (player) não está tomando dano quando atacado pelo inimigo.

---

## 🛠️ Debug Implementado

### Logs Adicionados em `perform_attack()`

Adicionei logs extensivos para diagnosticar onde o sistema está falhando:

```gdscript
func perform_attack() -> void:
    can_attack = false
    print("[ENEMY] ⚔️ ATACANDO! (can_attack = false)")
    
    # Verifica se hitbox existe
    if hitbox_area:
        print("[ENEMY]    🔍 HitboxArea existe: ", hitbox_area)
        print("[ENEMY]    🔍 HitboxArea.monitoring: ", hitbox_area.monitoring)
        print("[ENEMY]    🔍 HitboxArea.monitorable: ", hitbox_area.monitorable)
        
        # Verifica corpos na hitbox
        var bodies_in_hitbox = hitbox_area.get_overlapping_bodies()
        print("[ENEMY]    🔍 Verificando corpos na hitbox: ", bodies_in_hitbox.size())
        
        # Lista todos os corpos encontrados
        if bodies_in_hitbox.size() > 0:
            for body in bodies_in_hitbox:
                print("[ENEMY]       - Corpo encontrado: ", body.name)
                print("[ENEMY]       - Tipo: ", body.get_class())
                print("[ENEMY]       - Grupos: ", body.get_groups())
                print("[ENEMY]       - Está no grupo 'player'? ", body.is_in_group("player"))
                
                if body.is_in_group("player"):
                    # Tenta aplicar dano
                    if body.has_method("take_damage"):
                        body.take_damage(enemy_data.damage)
                    else:
                        print("[ENEMY]    ❌ ERRO: Corpo não tem método take_damage!")
        else:
            print("[ENEMY]    ⚠️ Nenhum corpo na hitbox durante ataque!")
    else:
        print("[ENEMY]    ❌ ERRO: hitbox_area é null!")
```

---

## 🔍 Possíveis Causas

### 1. **Hitbox Não Detectando Player**

**Sintoma no log:**
```
[ENEMY] ⚔️ ATACANDO!
[ENEMY]    🔍 Verificando corpos na hitbox: 0
[ENEMY]    ⚠️ Nenhum corpo na hitbox durante ataque!
```

**Causas Possíveis:**
- Collision layers incorretas
- Hitbox muito pequena
- Player fora do range quando ataque é executado

**Solução:**
- Verificar `HitboxArea2D` collision_mask deve incluir layer do player (layer 2)
- Aumentar tamanho da hitbox se necessário
- Ajustar `attack_range` no enemy_data

---

### 2. **Player Sem Grupo "player"**

**Sintoma no log:**
```
[ENEMY]       - Corpo encontrado: Entidades
[ENEMY]       - Está no grupo 'player'? false
```

**Solução:**
- Verificar se `_ready()` do player está sendo chamado
- Confirmar que `add_to_group("player")` está executando

---

### 3. **Player Sem Método take_damage**

**Sintoma no log:**
```
[ENEMY]    💥 Player encontrado na hitbox!
[ENEMY]    ❌ ERRO: Corpo não tem método take_damage!
```

**Solução:**
- Improvável, pois o método existe no código
- Mas pode haver problemas de herança ou script não anexado

---

### 4. **HitboxArea2D Null**

**Sintoma no log:**
```
[ENEMY]    ❌ ERRO: hitbox_area é null!
```

**Causas:**
- Node `HitboxArea2D` não existe na cena do inimigo
- Nome do node diferente do esperado

**Solução:**
- Verificar estrutura da cena do inimigo
- Confirmar que existe um node chamado `HitboxArea2D`

---

### 5. **Monitoring Desativado**

**Sintoma no log:**
```
[ENEMY]    🔍 HitboxArea.monitoring: false
```

**Solução:**
- Ativar `monitoring` no HitboxArea2D
- Verificar se não está sendo desativado por código

---

## 📋 Como Diagnosticar

### Passo 1: Execute o Jogo
Rode o jogo no Godot e deixe o inimigo atacar o player.

### Passo 2: Observe o Console
Procure pelos logs com `[ENEMY] ⚔️ ATACANDO!`

### Passo 3: Identifique o Problema

Compare os logs com os cenários acima:

#### ✅ Funcionando Corretamente:
```
[ENEMY] ⚔️ ATACANDO! (can_attack = false)
[ENEMY]    🔍 HitboxArea existe: [Area2D:...]
[ENEMY]    🔍 HitboxArea.monitoring: true
[ENEMY]    🔍 HitboxArea.monitorable: true
[ENEMY]    🔍 Verificando corpos na hitbox: 1
[ENEMY]       - Corpo encontrado: Entidades
[ENEMY]       - Tipo: CharacterBody2D
[ENEMY]       - Grupos: [..., player]
[ENEMY]       - Está no grupo 'player'? true
[ENEMY]    💥 Player encontrado na hitbox! Causando dano...
[ENEMY]    ✅ Método take_damage existe! Aplicando dano...
[ENEMY]    ✅ Dano 15.0 aplicado!
[PLAYER] 💔 DANO RECEBIDO: 15.0
[PLAYER]    HP atual: 85.0/100.0 (85.0%)
```

#### ❌ Problema: Hitbox Vazia
```
[ENEMY] ⚔️ ATACANDO!
[ENEMY]    🔍 Verificando corpos na hitbox: 0
[ENEMY]    ⚠️ Nenhum corpo na hitbox durante ataque!
```
**→ Collision layers/masks incorretas ou hitbox muito pequena**

#### ❌ Problema: Player Não Detectado
```
[ENEMY]    🔍 Verificando corpos na hitbox: 1
[ENEMY]       - Corpo encontrado: TileMap
[ENEMY]       - Está no grupo 'player'? false
```
**→ Detectando outro objeto, não o player**

---

## 🔧 Verificações Necessárias

### 1. Collision Layers do HitboxArea2D

**Deve ser:**
- `collision_layer = 8` (Enemy Hitbox layer)
- `collision_mask = 2` (Player layer)

### 2. Collision Layers do Player

**Deve ser:**
- `collision_layer = 2` (Player layer)
- `collision_mask = 13` (World + Enemy + Enemy Hitbox)

### 3. Tamanho da Hitbox

A `CircleShape2D` da hitbox deve ter radius igual ou maior que `attack_range`:

```gdscript
# No setup_enemy():
if hitbox_shape:
    hitbox_shape.radius = enemy_data.attack_range
```

### 4. Monitoring Ativado

```gdscript
hitbox_area.monitoring = true
hitbox_area.monitorable = true
```

---

## 🧪 Como Testar

1. **Inicie o jogo**
2. **Aproxime-se do inimigo**
3. **Observe os logs quando o estado mudar para ATTACK**
4. **Verifique se o log mostra:**
   - `⚔️ ATACANDO!`
   - Quantidade de corpos na hitbox
   - Se player foi detectado
   - Se dano foi aplicado
5. **No lado do player, verifique:**
   - `💔 DANO RECEBIDO`
   - HP atual diminuindo

---

## 📊 Checklist de Validação

- [ ] Log `[ENEMY] ⚔️ ATACANDO!` aparece
- [ ] `HitboxArea existe` = sim
- [ ] `monitoring` = true
- [ ] `Verificando corpos na hitbox` > 0
- [ ] Player detectado nos grupos
- [ ] `Está no grupo 'player'?` = true
- [ ] `Método take_damage existe` = sim
- [ ] `Dano aplicado` aparece
- [ ] `[PLAYER] 💔 DANO RECEBIDO` aparece
- [ ] HP do player diminui

---

## 🎯 Próximos Passos

1. **Execute o jogo** e capture os logs
2. **Cole os logs** para análise
3. **Identifique** qual cenário se aplica
4. **Aplique a correção** apropriada

---

**Data:** 2025-10-19  
**Arquivo Modificado:** `scripts/enemy/enemy.gd`  
**Status:** 🔍 Debug implementado, aguardando teste
