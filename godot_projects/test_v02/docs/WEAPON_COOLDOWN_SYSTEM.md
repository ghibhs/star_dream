# Sistema de Cooldown Configurável por Arma

## 🎯 Funcionalidade

Agora cada arma pode ter seu próprio **tempo de cooldown** entre ataques, configurado diretamente no arquivo `.tres` da arma!

## ⚙️ Como Configurar

### No WeaponData.tres

1. Abra o arquivo `.tres` da sua arma no Godot
2. Encontre a propriedade `Attack Cooldown`
3. Configure o tempo em **segundos**

**Exemplos:**
- **Espada Rápida**: `0.3` (3 ataques por segundo)
- **Espada Normal**: `0.5` (2 ataques por segundo)
- **Arco**: `0.8` (1.25 ataques por segundo)
- **Martelo Pesado**: `1.5` (ataque lento e poderoso)

### Estrutura do WeaponData.gd

```gdscript
@export var weapon_type: String = "melee"  # "melee", "projectile"
@export var damage: float = 10
@export var attack_speed: float = 1.0
@export var attack_cooldown: float = 0.5  # ← NOVA PROPRIEDADE!
@export var weapon_range: float = 100.0
```

## 🔧 Como Funciona

### 1. **Valor Padrão**
Se não configurado, o cooldown padrão é **0.5 segundos** (definido no WeaponData.gd)

### 2. **Durante o Ataque**
Quando o player ataca, o código automaticamente usa o cooldown da arma atual:

```gdscript
# No perform_attack()
if weapon_timer:
    var cooldown_time = current_weapon_data.attack_cooldown
    weapon_timer.wait_time = cooldown_time
    weapon_timer.start()
```

### 3. **Troca de Arma**
Ao trocar de arma, o novo cooldown é aplicado automaticamente no próximo ataque!

## 📊 Balanceamento Sugerido

### Armas Melee

| Tipo de Arma | Cooldown | Ataques/seg | Característica |
|--------------|----------|-------------|----------------|
| Adaga | 0.25s | 4.0 | Muito rápida, baixo dano |
| Espada Curta | 0.4s | 2.5 | Rápida e balanceada |
| Espada Longa | 0.6s | 1.67 | Balanceada |
| Machado | 0.9s | 1.11 | Lento, alto dano |
| Martelo | 1.5s | 0.67 | Muito lento, dano massivo |

### Armas de Projétil

| Tipo de Arma | Cooldown | Ataques/seg | Característica |
|--------------|----------|-------------|----------------|
| Arco Rápido | 0.5s | 2.0 | Tiro rápido |
| Arco Normal | 0.8s | 1.25 | Balanceado |
| Besta | 1.2s | 0.83 | Lenta, alto dano |
| Cajado Mágico | 0.3s | 3.33 | Rajada rápida |

## 💡 Dicas de Design

### Combine Cooldown com Outros Atributos

**Arma de Alto DPS (Damage Per Second):**
```
damage: 5
attack_cooldown: 0.25
→ DPS = 5 / 0.25 = 20
```

**Arma de Burst Damage:**
```
damage: 30
attack_cooldown: 2.0
→ DPS = 30 / 2.0 = 15 (mas mata inimigos fracos em 1 hit)
```

### Relação com attack_speed

**NOTA:** A propriedade `attack_speed` ainda existe mas **não é usada** para o cooldown. Você pode:
- **Opção 1:** Remover `attack_speed` do WeaponData.gd (não é mais necessário)
- **Opção 2:** Usar `attack_speed` para velocidade de animação de ataque
- **Opção 3:** Manter para compatibilidade com código legado

Atualmente, apenas `attack_cooldown` controla o tempo entre ataques.

## 🧪 Testando

### 1. **Criar Duas Armas com Cooldowns Diferentes**

**arma_rapida.tres:**
```
attack_cooldown: 0.3
damage: 5
```

**arma_lenta.tres:**
```
attack_cooldown: 1.5
damage: 25
```

### 2. **Testar no Jogo**
1. Equipe a arma rápida
2. Pressione o botão de ataque rapidamente
3. Note que você ataca 3 vezes por segundo
4. Troque para arma lenta
5. Note que só consegue atacar a cada 1.5 segundos

### 3. **Verificar Console**
O jogo printa no console:
```
[PLAYER] ⚔️ ATACANDO com Espada Rápida
[PLAYER]    Cooldown iniciado: 0.30s (do WeaponData)
```

## 📝 Arquivos Modificados

### `resources/classes/WeaponData.gd`
- **Adicionado:** Propriedade `@export var attack_cooldown: float = 0.5`

### `scripts/player/player.gd`
- **Modificado:** `perform_attack()` - Usa `current_weapon_data.attack_cooldown`
- **Modificado:** `_ready()` - Comentário atualizado sobre cooldown

## 🎮 Exemplos Práticos

### Arco Básico (bow.tres)
```gdscript
item_name = "Arco Básico"
weapon_type = "projectile"
damage = 15.0
attack_cooldown = 0.8  # 1.25 tiros por segundo
projectile_speed = 400.0
```

### Espada Curta (short_sword.tres)
```gdscript
item_name = "Espada Curta"
weapon_type = "melee"
damage = 12.0
attack_cooldown = 0.4  # 2.5 golpes por segundo
```

### Martelo Pesado (heavy_hammer.tres)
```gdscript
item_name = "Martelo Pesado"
weapon_type = "melee"
damage = 40.0
attack_cooldown = 1.8  # 0.56 golpes por segundo (muito lento!)
attack_hitbox_duration = 0.3  # Golpe dura mais tempo
```

## ✅ Vantagens do Sistema

1. ✅ **Fácil de Balancear** - Basta editar o `.tres` sem mexer no código
2. ✅ **Individual por Arma** - Cada arma tem seu ritmo único
3. ✅ **Feedback Claro** - Console mostra o cooldown aplicado
4. ✅ **Flexível** - Permite desde ataques ultra-rápidos até golpes pesados
5. ✅ **Designer-Friendly** - Game designers podem ajustar sem programar

## 🔮 Possíveis Expansões Futuras

### 1. **Cooldown Variável por Combo**
```gdscript
@export var combo_cooldowns: Array[float] = [0.3, 0.4, 0.8]  # 1º, 2º, 3º ataque
```

### 2. **Cooldown que Diminui com Level**
```gdscript
var final_cooldown = attack_cooldown * (1.0 - (player_level * 0.05))
```

### 3. **Buffs Temporários**
```gdscript
var final_cooldown = attack_cooldown * attack_speed_buff  # Ex: 0.5 para 50% mais rápido
```

### 4. **Cooldown por Stamina**
```gdscript
if player.stamina < attack_stamina_cost:
    # Cooldown mais longo se sem stamina
    cooldown *= 2.0
```

---

**🎯 Agora suas armas têm personalidade própria através do cooldown configurável!**
