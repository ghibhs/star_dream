# 🏹 Sistema de Carregamento do Arco

## 📋 Visão Geral

Sistema completo de carregamento para arcos que permite ao jogador segurar o botão de ataque para aumentar o dano e velocidade do projétil.

---

## ⚙️ Como Funciona

### 1. **Mecânica de Carregamento**

```
Pressionar Botão → Iniciar Carregamento → Segurar para Carregar → Soltar para Disparar
```

- **Pressionar** o botão de ataque: Inicia o carregamento
- **Segurar** o botão: Acumula poder (até o máximo)
- **Soltar** o botão: Dispara com o poder acumulado

### 2. **Sistema de Poder**

#### Tempo de Carregamento
- **Tempo Mínimo** (`min_charge_time`): 0.2s
  - Carregamento mínimo necessário para disparar
  - Abaixo disso, o disparo é cancelado
  
- **Tempo Máximo** (`max_charge_time`): 2.0s
  - Tempo para atingir poder máximo
  - Após isso, mantém no máximo

#### Multiplicadores de Dano
- **Dano Mínimo** (`min_damage_multiplier`): 0.5x (50%)
  - Dano com carga mínima
  - Exemplo: 10 de dano base = 5 de dano mínimo
  
- **Dano Máximo** (`max_damage_multiplier`): 3.0x (300%)
  - Dano com carga completa
  - Exemplo: 10 de dano base = 30 de dano máximo

#### Velocidade do Projétil
- **Velocidade Base**: 300 unidades/s
- **Multiplicador** (`charge_speed_multiplier`): 1.5x
  - Com carga completa: 450 unidades/s
  - Projétil mais rápido quando carregado

---

## 🎨 Indicador Visual

### Feedback ao Jogador

1. **Anel de Carregamento**
   - Aparece ao redor do player
   - Cresce conforme a carga aumenta
   - Rotaciona durante o carregamento

2. **Cores Progressivas**
   ```
   Início: Amarelo (rgba(1, 0.8, 0, 0.8))
   Progresso: Gradiente Amarelo → Laranja
   Máximo: Vermelho Alaranjado
   ```

3. **Efeito de Pulso**
   - Quando atinge carga máxima
   - Brilho pulsante para indicar "pronto!"

4. **Escala Visual**
   - Escala de 1.0x a 2.0x
   - Dobra de tamanho quando totalmente carregado

---

## 🔧 Configuração no WeaponData

### Propriedades Adicionadas

```gdscript
# === SISTEMA DE CARREGAMENTO (para arcos) ===
@export_group("Charge System")
@export var can_charge: bool = false  # Se a arma pode ser carregada
@export var min_charge_time: float = 0.2  # Tempo mínimo para carregar
@export var max_charge_time: float = 2.0  # Tempo máximo de carregamento
@export var min_damage_multiplier: float = 0.5  # 50% do dano
@export var max_damage_multiplier: float = 3.0  # 300% do dano
@export var charge_speed_multiplier: float = 1.5  # 150% da velocidade
@export var charge_color: Color = Color(1, 0.8, 0, 0.8)  # Cor do indicador
```

### Exemplo de Configuração (bow.tres)

```ini
can_charge = true
min_charge_time = 0.2
max_charge_time = 2.0
min_damage_multiplier = 0.5
max_damage_multiplier = 3.0
charge_speed_multiplier = 1.5
charge_color = Color(1, 0.8, 0, 0.8)
```

---

## 💻 Implementação Técnica

### Variáveis no Player

```gdscript
var is_charging: bool = false
var charge_time: float = 0.0
var charge_indicator: Node2D = null
```

### Fluxo de Execução

#### 1. Input Handler (`_input`)
```gdscript
# Botão pressionado
if event.is_action_pressed("attack"):
    if current_weapon_data.can_charge:
        start_charging()
    else:
        perform_attack()

# Botão solto
elif event.is_action_released("attack"):
    if is_charging:
        release_charged_attack()
```

#### 2. Atualização por Frame (`_physics_process`)
```gdscript
if is_charging:
    update_charge(delta)
    update_charge_indicator()
```

#### 3. Cálculo do Multiplicador
```gdscript
var charge_ratio = (charge_time - min_charge_time) / (max_charge_time - min_charge_time)
charge_ratio = clamp(charge_ratio, 0.0, 1.0)

var damage_multiplier = lerp(min_damage_multiplier, max_damage_multiplier, charge_ratio)
var speed_multiplier = lerp(1.0, charge_speed_multiplier, charge_ratio)
```

---

## 🎮 Controles

| Ação | Controle | Descrição |
|------|----------|-----------|
| **Iniciar Carga** | Pressionar Ataque | Começa a carregar o arco |
| **Carregar** | Segurar Ataque | Aumenta o poder progressivamente |
| **Disparar** | Soltar Ataque | Dispara com o poder acumulado |
| **Cancelar** | Soltar antes do mínimo | Cancela o disparo |

---

## 📊 Exemplos de Dano

### Dano Base: 10

| Tempo | Carga | Multiplicador | Dano Final | Velocidade |
|-------|-------|---------------|------------|------------|
| 0.0s  | ❌ | N/A | Cancelado | N/A |
| 0.2s  | 0% | 0.5x | 5 | 300 |
| 0.5s  | 15% | 0.875x | 8.75 | 330 |
| 1.0s  | 40% | 1.5x | 15 | 375 |
| 1.5s  | 65% | 2.125x | 21.25 | 420 |
| 2.0s  | 100% | 3.0x | **30** | **450** |

---

## ✨ Características

### Vantagens
- ✅ Dano escalável (até 3x)
- ✅ Velocidade aumentada
- ✅ Feedback visual claro
- ✅ Controle fino do jogador
- ✅ Risco vs Recompensa (tempo para carregar)

### Balanceamento
- ⚖️ Tempo mínimo evita spam
- ⚖️ Tempo máximo limita poder
- ⚖️ Cooldown normal após disparo
- ⚖️ Vulnerável durante carregamento

---

## 🐛 Debug

### Logs do Sistema

```
[PLAYER] 🏹 Carregamento INICIADO
[PLAYER]    Tempo mínimo: 0.20s
[PLAYER]    Tempo máximo: 2.00s
[PLAYER]    ✅ Indicador de carga criado

[PLAYER] ⚡ CARGA MÁXIMA ATINGIDA!

[PLAYER] 🎯 LIBERANDO ATAQUE CARREGADO
[PLAYER]    Tempo carregado: 2.00s
[PLAYER]    Porcentagem de carga: 100.0%
[PLAYER]    Multiplicador de dano: 3.00x
[PLAYER]    Multiplicador de velocidade: 1.50x
[PLAYER]    Dano modificado: 30.0 (base: 10.0)
[PLAYER]    Velocidade modificada: 450.0 (base: 300.0)
```

---

## 🔮 Possíveis Melhorias Futuras

1. **Som de Carregamento**
   - Som crescente conforme carga aumenta
   - Som especial ao atingir máximo

2. **Partículas**
   - Efeito de energia acumulando
   - Explosão ao disparar totalmente carregado

3. **Vibração (se suportado)**
   - Feedback tátil durante carregamento
   - Pulso ao atingir máximo

4. **Câmera**
   - Zoom leve ao carregar completamente
   - Shake ao disparar carga máxima

5. **Diferentes Níveis de Carga**
   - Tier 1: 0.2-0.7s (1x dano)
   - Tier 2: 0.7-1.5s (2x dano)
   - Tier 3: 1.5-2.0s (3x dano)

6. **Penalidades por Segurar Demais**
   - Após 3s, começa a perder carga
   - Ou: travamento por "fadiga"

---

## 📝 Notas Técnicas

- Sistema funciona apenas para `weapon_type = "projectile"`
- Compatível com sistema de cooldown existente
- Não interfere com armas melee (espadas)
- Pode ser ativado/desativado por arma individualmente
- Duplicação do WeaponData evita modificar o recurso original

---

## 🎯 Exemplo de Uso

```gdscript
# Criar nova arma com carregamento
var bow_data = WeaponData.new()
bow_data.item_name = "Arco Longo"
bow_data.weapon_type = "projectile"
bow_data.damage = 15.0
bow_data.can_charge = true
bow_data.min_charge_time = 0.3
bow_data.max_charge_time = 2.5
bow_data.max_damage_multiplier = 4.0  # 4x dano máximo!
```

---

**Criado por:** GitHub Copilot  
**Data:** 23 de Outubro de 2025  
**Versão:** 1.0  
**Status:** ✅ Implementado e Funcional
