# 🔍 DEBUG - Sistema de Detecção de Inimigos

## 🐛 Problema Relatado

**Sintoma:** Inimigo não detecta o personagem antes do primeiro dano, só funciona depois de levar hit.

---

## ✅ Verificações Feitas

### 1. Player no grupo correto
```gdscript
// entidades.gd:78
add_to_group("player")  ✅ OK
```

### 2. Collision Layers
```gdscript
// entidades.tscn
Player CharacterBody2D: collision_layer = 2  ✅ OK

// enemy.tscn  
Enemy CharacterBody2D: collision_layer = 4
DetectionArea2D: collision_mask = 2  ✅ OK (detecta layer 2)
```

### 3. Behavior dos Inimigos
```gdscript
// wolf_fast.tres
behavior = "Aggressive"  ✅ OK
```

### 4. Lógica de Detecção
```gdscript
// enemy.gd:_on_detection_body_entered()
if body.is_in_group("player") and enemy_data.behavior == "Aggressive":
    target = body
    current_state = State.CHASE
✅ Lógica correta
```

---

## 🔬 Debug Adicionado

### No setup_enemy() (_ready):
```gdscript
# Após configurar DetectionArea, verifica corpos já presentes
await get_tree().process_frame
var bodies_in_area = detection_area.get_overlapping_bodies()
print("[ENEMY]    🔍 Corpos já na área de detecção: ", bodies_in_area.size())
for body in bodies_in_area:
    print("[ENEMY]       - ", body.name, " (grupos: ", body.get_groups(), ")")
    if body.is_in_group("player"):
        print("[ENEMY]       ✅ PLAYER DETECTADO no _ready()!")
        target = body
        if current_state == State.IDLE:
            current_state = State.CHASE
```

**O que isso faz:**
- Espera 1 frame após criar a CollisionShape
- Verifica se o player já está dentro da área de detecção
- Se estiver, define como alvo imediatamente

### No _on_detection_body_entered():
```gdscript
print("[ENEMY] 👁️ DetectionArea detectou ENTRADA: ", body.name)
print("[ENEMY]    Tipo do node: ", body.get_class())
print("[ENEMY]    Grupos: ", body.get_groups())
print("[ENEMY]    Behavior do enemy: ", enemy_data.behavior)
print("[ENEMY]    Estado atual: ", State.keys()[current_state])
print("[ENEMY]    Tem alvo atual? ", target != null)
```

**O que isso mostra:**
- Todas as informações necessárias para debug
- Facilita identificar onde está o problema

---

## 🧪 Como Testar

### Teste 1: Inimigo LONGE do player ao iniciar
1. Execute o jogo
2. Player spawna longe do inimigo
3. Aproxime-se do inimigo
4. **Resultado esperado:**
   ```
   [ENEMY] 👁️ DetectionArea detectou ENTRADA: Entidades
   [ENEMY]    ✅ Confirmado: É o PLAYER!
   [ENEMY]    ✅ Sou AGRESSIVO! Definindo como alvo...
   [ENEMY]    Estado: IDLE → CHASE
   [ENEMY] Estado: IDLE → CHASE (alvo detectado)
   ```

### Teste 2: Inimigo JÁ PRÓXIMO do player ao iniciar
1. Execute o jogo
2. Player spawna perto do inimigo (dentro do chase_range)
3. **Resultado esperado:**
   ```
   [ENEMY]    🔍 Corpos já na área de detecção: 1
   [ENEMY]       - Entidades (grupos: ["player"])
   [ENEMY]       ✅ PLAYER DETECTADO no _ready()!
   [ENEMY]       Estado: IDLE → CHASE
   ```

### Teste 3: Após tomar dano
1. Não mexa o player
2. Deixe o inimigo em IDLE
3. Ataque o inimigo
4. **Resultado esperado:**
   ```
   [ENEMY] 💔 Lobo Veloz RECEBEU DANO!
   [ENEMY]    🎯 Alvo definido após dano: Entidades
   [ENEMY] Estado: HURT → CHASE
   ```

---

## 🎯 Possíveis Causas do Bug

### Causa 1: Timing do CollisionShape
**Problema:** CollisionShape criado dinamicamente pode não estar pronto imediatamente  
**Solução:** Adicionado `await get_tree().process_frame` antes de verificar overlaps

### Causa 2: DetectionArea não está em Monitoring
**Verificação:** 
```gdscript
print("[ENEMY]    DetectionArea - Monitoring: ", detection_area.monitoring)
```
**Deve mostrar:** `true`

### Causa 3: Collision Mask incorreta
**Verificação:**
```gdscript
print("[ENEMY]    DetectionArea - Mask: ", detection_area.collision_mask)
```
**Deve mostrar:** `2` (detecta layer 2 = player)

### Causa 4: Player não tem CollisionShape
**Verificação:** Player (CharacterBody2D) deve ter um CollisionShape2D filho

---

## 📊 Mensagens de Debug para Monitorar

### Ao iniciar o jogo:
```
[PLAYER] Inicializado e adicionado ao grupo 'player'
[ENEMY] Carregando dados: Lobo Veloz
[ENEMY]    DetectionArea configurada (radius: 300.0)
[ENEMY]    DetectionArea - Layer: 0, Mask: 2
[ENEMY]    DetectionArea - Monitoring: true
[ENEMY]    DetectionArea - Monitorable: false
[ENEMY]    🔍 Corpos já na área de detecção: X
```

### Quando player entra no range:
```
[ENEMY] 👁️ DetectionArea detectou ENTRADA: Entidades
[ENEMY]    Tipo do node: CharacterBody2D
[ENEMY]    Grupos: ["player"]
[ENEMY]    Behavior do enemy: Aggressive
[ENEMY]    Estado atual: IDLE
[ENEMY]    Tem alvo atual? false
[ENEMY]    ✅ Confirmado: É o PLAYER!
[ENEMY]    ✅ Sou AGRESSIVO! Definindo como alvo...
[ENEMY]    Estado: IDLE → CHASE
```

### Quando inimigo persegue:
```
[ENEMY] Estado: IDLE → CHASE (alvo detectado)
# A cada frame enquanto persegue, sem print (performance)
```

---

## 🔧 Checklist de Troubleshooting

- [ ] Player está no grupo "player"?
- [ ] Player tem collision_layer = 2?
- [ ] DetectionArea tem collision_mask = 2?
- [ ] DetectionArea.monitoring = true?
- [ ] enemy_data.behavior = "Aggressive"?
- [ ] enemy_data.chase_range está adequado (ex: 300)?
- [ ] Signal body_entered está conectado?
- [ ] CollisionShape foi adicionado à DetectionArea?
- [ ] O círculo de detecção tem radius > 0?

---

## 🚀 Próximos Passos

1. **Execute o jogo** e observe os logs
2. **Identifique** qual mensagem de debug NÃO aparece
3. **Relate** qual teste falhou:
   - Teste 1 (aproximar depois)?
   - Teste 2 (já próximo ao spawnar)?
   - Teste 3 (após tomar dano)?
4. **Compare** os logs esperados vs obtidos

---

**Com esses debugs, conseguiremos identificar exatamente onde o sistema de detecção está falhando!** 🎯
