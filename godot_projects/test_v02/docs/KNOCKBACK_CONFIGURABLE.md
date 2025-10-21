# Sistema de Knockback Configurável por Inimigo

## 🎯 Nova Funcionalidade

Agora cada inimigo pode ter seu próprio **knockback configurável** no arquivo `.tres`! Você pode controlar:
- ✅ Se o inimigo causa empurrão ou não
- ✅ A força do empurrão
- ✅ A duração do empurrão

## ⚙️ Como Configurar no Editor

### No Inspector (arquivo .tres do inimigo):

1. Abra o arquivo `.tres` do inimigo (ex: `lobo_veloz.tres`)
2. Procure a seção **"Knockback"**
3. Configure as propriedades:

```
┌─────────────────────────────────────┐
│ Knockback                           │
├─────────────────────────────────────┤
│ ☑ Applies Knockback                │  ← Marque para aplicar knockback
│ Knockback Force:     300.0          │  ← Força do empurrão
│ Knockback Duration:  0.2            │  ← Duração em segundos
└─────────────────────────────────────┘
```

## 📊 Exemplos de Configuração

### 1. **Inimigo Fraco (Slime, Rato)**
```
Applies Knockback: ☑ true
Knockback Force: 150.0
Knockback Duration: 0.15
```
**Resultado:** Empurrãozinho leve, mal atrapalha

---

### 2. **Inimigo Normal (Lobo, Goblin)**
```
Applies Knockback: ☑ true
Knockback Force: 300.0
Knockback Duration: 0.2
```
**Resultado:** Empurrão padrão, interrompe ações

---

### 3. **Inimigo Forte (Ogro, Troll)**
```
Applies Knockback: ☑ true
Knockback Force: 500.0
Knockback Duration: 0.3
```
**Resultado:** Empurrão pesado, joga longe

---

### 4. **Inimigo Boss (Dragão, Gigante)**
```
Applies Knockback: ☑ true
Knockback Force: 800.0
Knockback Duration: 0.5
```
**Resultado:** EMPURRÃO MASSIVO, player voa!

---

### 5. **Inimigo Rápido (Ninja, Assassino)**
```
Applies Knockback: ☐ false
Knockback Force: 0.0
Knockback Duration: 0.0
```
**Resultado:** Sem empurrão, dano direto e rápido

---

### 6. **Inimigo Tanque (Cavaleiro Pesado)**
```
Applies Knockback: ☑ true
Knockback Force: 400.0
Knockback Duration: 0.4
```
**Resultado:** Empurrão longo, te afasta bastante

## 🎮 Design de Inimigos

### Por Tipo de Ataque

| Tipo de Inimigo | Force | Duration | Aplica? | Razão |
|-----------------|-------|----------|---------|-------|
| Corpo-a-Corpo Rápido | 200 | 0.15s | ✅ Sim | Ataque leve |
| Corpo-a-Corpo Normal | 300 | 0.2s | ✅ Sim | Padrão balanceado |
| Corpo-a-Corpo Pesado | 600 | 0.4s | ✅ Sim | Impacto massivo |
| Mago/Arqueiro | 0 | 0s | ❌ Não | Já mantém distância |
| Assassino/Ninja | 0 | 0s | ❌ Não | Combo rápido |
| Boss | 800+ | 0.5s+ | ✅ Sim | Ataque especial |

### Por Comportamento

**Inimigos Agressivos:**
- **Com knockback**: Empurra player para longe (tático)
- **Sem knockback**: Permite combo de ataques (perigoso!)

**Inimigos Tanque:**
- **Alto knockback**: Controla espaço do campo de batalha
- **Longa duração**: Player fica longe por mais tempo

**Inimigos Rápidos:**
- **Sem knockback**: Atacam múltiplas vezes rapidamente
- **Baixo knockback**: Pequeno empurrão mas permite perseguir

## 🔧 Propriedades no EnemyData.gd

```gdscript
# === KNOCKBACK (EMPURRÃO AO ATACAR) ===
@export_group("Knockback")
@export var applies_knockback: bool = true        # Ativa/desativa knockback
@export var knockback_force: float = 300.0        # Força (0-1000+)
@export var knockback_duration: float = 0.2       # Duração em segundos
```

### Valores Padrão:
- `applies_knockback = true` (maioria dos inimigos causa knockback)
- `knockback_force = 300.0` (força média)
- `knockback_duration = 0.2` (duração padrão)

## 💡 Estratégias de Game Design

### 1. **Mistura de Inimigos**

**Onda Balanceada:**
```
2x Lobos (com knockback) + 1x Arqueiro (sem knockback)
```
- Lobos empurram player
- Arqueiro ataca de longe quando player está vulnerável

---

### 2. **Progressão de Dificuldade**

**Mundo 1 (Floresta):**
- Inimigos fracos: Force 150-200
- Knockback curto: 0.15s

**Mundo 2 (Montanhas):**
- Inimigos médios: Force 300-400
- Knockback normal: 0.2-0.3s

**Mundo 3 (Vulcão):**
- Inimigos fortes: Force 500-800
- Knockback longo: 0.4-0.5s

---

### 3. **Inimigos Especializados**

**Tank Pusher:**
```
Applies Knockback: true
Force: 600.0
Duration: 0.5
```
→ Especialista em controle de espaço

**Rapid Striker:**
```
Applies Knockback: false
Force: 0.0
Duration: 0.0
```
→ Especialista em DPS (dano por segundo)

**Stunner:**
```
Applies Knockback: true
Force: 300.0
Duration: 0.8  ← Muito longo!
```
→ Especialista em imobilizar

## 🧪 Testes Sugeridos

### Teste 1: Lobo Normal
```tres
applies_knockback = true
knockback_force = 300.0
knockback_duration = 0.2
```
**Resultado Esperado:** Empurrão médio, interrompe movimento

---

### Teste 2: Ogro Forte
```tres
applies_knockback = true
knockback_force = 600.0
knockback_duration = 0.4
```
**Resultado Esperado:** Player é jogado longe e fica sem controle por mais tempo

---

### Teste 3: Ninja Rápido
```tres
applies_knockback = false
knockback_force = 0.0
knockback_duration = 0.0
```
**Resultado Esperado:** Dano sem empurrão, ninja pode atacar novamente rapidamente

---

### Teste 4: Slime Fraco
```tres
applies_knockback = true
knockback_force = 100.0
knockback_duration = 0.1
```
**Resultado Esperado:** Empurrãozinho quase imperceptível

## 📊 Console Output

### Com Knockback:
```
[ENEMY]    💥 Player detectado na hitbox ATIVA!
[ENEMY]    ✅ Dano 15.0 aplicado (knockback: 300.0 força, 0.20s duração)!
[PLAYER] 💔 DANO RECEBIDO: 15.0
[PLAYER]    💥 Knockback aplicado!
[PLAYER]       Força: 300.0
[PLAYER]       Duração: 0.20s
```

### Sem Knockback:
```
[ENEMY]    💥 Player detectado na hitbox ATIVA!
[ENEMY]    ✅ Dano 15.0 aplicado (sem knockback)!
[PLAYER] 💔 DANO RECEBIDO: 15.0
[PLAYER]    (sem knockback)
```

## 🎨 Casos de Uso Criativos

### 1. **Boss com Ataques Variados**

```gdscript
# Ataque Leve (golpe rápido):
# applies_knockback = false
# Permite combo de 3 golpes

# Ataque Pesado (golpe carregado):
# applies_knockback = true
# knockback_force = 800.0
# knockback_duration = 0.6
# Joga player longe, mas tem tempo de charge
```

---

### 2. **Inimigo "Grabber"**

```tres
applies_knockback = true
knockback_force = -200.0  ← Força NEGATIVA!
duration = 0.3
```
**Resultado:** Puxa player para PERTO ao invés de empurrar!
(Requer modificação no código para suportar)

---

### 3. **Ataque de Área com Knockback Radial**

Todos os inimigos próximos aplicam knockback ao mesmo tempo:
→ Player é empurrado em múltiplas direções
→ Resulta em movimento caótico!

## 📝 Arquivos Modificados

### `resources/classes/EnemyData.gd`
- **Adicionado grupo "Knockback":**
  - `applies_knockback: bool`
  - `knockback_force: float`
  - `knockback_duration: float`

### `scripts/enemy/enemy.gd`
- **Modificado `_on_hitbox_body_entered()`:**
  - Lê configurações do `enemy_data`
  - Passa parâmetros para `take_damage()`
  - Logs diferentes para com/sem knockback

### `scripts/player/player.gd`
- **Modificado `take_damage()`:**
  - Aceita parâmetros: `kb_force`, `kb_duration`, `apply_kb`
  - Valores padrão se não especificados
  
- **Modificado `apply_knockback()`:**
  - Aceita `force` e `duration` opcionais
  - Usa valores do inimigo ou valores padrão do player

## ✅ Resultado Final

### Flexibilidade Total:
```
Inimigo 1: Empurrão leve   (Force: 150)
Inimigo 2: Empurrão médio  (Force: 300)
Inimigo 3: Empurrão forte  (Force: 600)
Inimigo 4: SEM empurrão    (Applies: false)
```

### Tudo configurável no Inspector!
```
Sem tocar no código ✅
Ajuste em tempo real ✅
Balanceamento fácil ✅
Design por iteração ✅
```

## 🚀 Próximas Melhorias

### 1. **Knockback Direcional Customizado**
```gdscript
@export var knockback_direction_override: Vector2 = Vector2.ZERO
# Se != ZERO, usa esta direção ao invés de calcular
```

### 2. **Knockback com Curva**
```gdscript
@export var knockback_curve: Curve
# Força varia ao longo do tempo (começa forte, diminui)
```

### 3. **Imunidade a Knockback**
```gdscript
# No player:
@export var knockback_resistance: float = 0.0  # 0.0 a 1.0
# 0.5 = 50% de redução na força
```

### 4. **Knockback com Efeitos Especiais**
```gdscript
@export var knockback_particle_effect: PackedScene
@export var knockback_sound: AudioStream
@export var knockback_screen_shake: float = 0.0
```

---

**🎯 Agora cada inimigo tem sua própria personalidade de knockback!** 💥✨
