# 🔍 Check-up Completo do Projeto test_v02

**Data**: 18 de outubro de 2025  
**Branch**: thirdversion  
**Engine**: Godot 4.5

---

## 📊 Status Geral

| Categoria | Status | Detalhes |
|-----------|--------|----------|
| **Erros Críticos** | ⚠️ 2 problemas | 1 shadowing, 1 expressão standalone |
| **Warnings** | ✅ Nenhum | - |
| **Estrutura** | ✅ OK | Arquivos organizados |
| **Recursos** | ⚠️ Incompleto | Armas básicas configuradas |
| **Funcionalidade** | ⚠️ Parcial | Sistema de armas básico funcional |

---

## 🚨 Problemas Encontrados (CRÍTICOS)

### 1. ❌ Expressão Standalone em `entidades.gd` (Linha 79)

**Arquivo**: `entidades.gd`  
**Linha**: 79  
**Erro**: `STANDALONE_EXPRESSION`

```gdscript
elif current_weapon_data and current_weapon_data.weapon_type == "melee": 
	weapon_marker.position  # ← ERRO: Não faz nada!
```

**Problema**: Esta linha lê `weapon_marker.position` mas não faz nada com o valor. Código inútil que será removido pelo compilador.

**Impacto**: 
- Não quebra o jogo, mas indica lógica incompleta
- Provavelmente era pra resetar posição ou rotação

**Solução Sugerida**:
```gdscript
elif current_weapon_data and current_weapon_data.weapon_type == "melee": 
	weapon_marker.rotation = 0.0  # Reseta rotação para melee
```

---

### 2. ❌ Shadowing de Identificador Global em `WeaponData.gd` (Linha 20)

**Arquivo**: `data_gd/WeaponData.gd`  
**Linha**: 20  
**Erro**: `SHADOWED_GLOBAL_IDENTIFIER`

```gdscript
@export var range: float = 100.0  # ← ERRO: "range" é função global do Godot!
```

**Problema**: `range()` é uma função built-in do GDScript. Usar como nome de variável causa conflito.

**Impacto**: 
- Pode causar bugs sutis ao tentar usar `range()` em loops
- Confusão para outros desenvolvedores
- Warning persistente do linter

**Solução Sugerida**:
```gdscript
@export var weapon_range: float = 100.0
```

**Arquivos Afetados**:
- `data_gd/WeaponData.gd`
- `ItemData/bow.tres` (linha com `range = 100.0`)
- `ItemData/sword.tres` (linha com `range = 100.0`)

---

## ⚠️ Problemas de Lógica/Design

### 3. 🐛 Sistema de Cooldown Inconsistente

**Arquivo**: `entidades.gd`

**Problema**: O cooldown de ataque está mal implementado:

```gdscript
# Linha 82-85 (_input)
if event.is_action_pressed("attack"):
	can_attack = true  # ← ERRO: Permite ataque IMEDIATAMENTE ao pressionar!
	if weapon_timer.is_stopped():
		perform_attack()
```

**Issue**: `can_attack` é setado como `true` no input, mas nunca é setado como `false` após atacar.

**Impacto**:
- Player pode atacar infinitamente sem cooldown
- `weapon_timer` é iniciado mas `can_attack` nunca é desabilitado
- `fire_rate` não tem efeito real

**Solução**:
```gdscript
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if can_attack and weapon_timer.is_stopped():
			perform_attack()

func perform_attack() -> void:
	if not current_weapon_data:
		return
	if not can_attack:
		return
	
	can_attack = false  # ← Desabilita ataque
	
	match current_weapon_data.weapon_type:
		"melee":
			melee_attack()
		"projectile":
			projectile_attack()
	
	# Inicia cooldown
	weapon_timer.wait_time = 1.0 / fire_rate
	weapon_timer.start()

func _on_weapon_timer_timeout() -> void:
	can_attack = true  # ← Reabilita após cooldown
```

**MISSING**: Não há `_on_weapon_timer_timeout()` conectado ao Timer!

---

### 4. 🔧 Timer Não Configurado em `_ready()`

**Arquivo**: `entidades.gd`

**Problema**: O `weapon_timer` nunca tem seu sinal conectado ou configurado em `_ready()`.

```gdscript
func _ready() -> void:
	add_to_group("player")
	# ← FALTA: Configurar weapon_timer aqui
```

**Impacto**:
- Timer existe mas nunca dispara callback
- Cooldown nunca reativa `can_attack`

**Solução**:
```gdscript
func _ready() -> void:
	add_to_group("player")
	
	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate
		weapon_timer.one_shot = true
		weapon_timer.timeout.connect(_on_weapon_timer_timeout)

func _on_weapon_timer_timeout() -> void:
	can_attack = true
```

---

### 5. 🎯 Melee Attack Muito Simples

**Arquivo**: `entidades.gd` (linha 173-178)

**Problema**: O ataque melee só liga a hitbox por 0.2 segundos fixos:

```gdscript
func melee_attack() -> void:
	if not attack_area:
		print("no attack area")
		return
	attack_area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false
```

**Limitações**:
- Não tem animação visual
- Hitbox fica parada (não move com o swing)
- Tempo fixo não usa `attack_speed` do recurso
- Não considera direção do ataque

**Sugestão de Melhoria**:
- Adicionar tween para mover a hitbox (start → end)
- Usar direção do movimento para posicionar hitbox
- Tocar animação de ataque no sprite da arma
- Usar `attack_speed` do `WeaponData`

---

### 6. 🔄 Rotação da Arma Duplicada

**Arquivo**: `entidades.gd`

**Problema**: A rotação da arma é feita em DOIS lugares:

```gdscript
# _physics_process (linhas 20-25)
if current_weapon_data and weapon_marker:
	weapon_marker.look_at(get_global_mouse_position())
	if weapon_angle_offset_deg != 0.0:
		weapon_marker.rotation += deg_to_rad(weapon_angle_offset_deg)

# _process (linhas 75-77)
if current_weapon_data and current_weapon_data.weapon_type == "projectile":
	weapon_marker.look_at(get_global_mouse_position())
	if weapon_angle_offset_deg != 0.0:
		weapon_marker.rotation += deg_to_rad(weapon_angle_offset_deg)
```

**Impacto**:
- Código duplicado (DRY violation)
- Armas melee TAMBÉM rotacionam no `_physics_process` (não diferencia tipo)
- Confusão sobre qual função faz o quê

**Solução**: Unificar em um único lugar e diferenciar melee/projectile.

---

## 📁 Estrutura de Arquivos

```
test_v02/
├── 📜 Scripts
│   ├── entidades.gd          ✅ Player (com problemas)
│   ├── projectile.gd         ✅ OK
│   ├── the_game.gd           ⚠️ Vazio (apenas extends Node2D)
│   ├── area_2d.gd            ❓ Não verificado
│   └── data_gd/
│       ├── WeaponData.gd     ⚠️ Shadowing de 'range'
│       └── ItemData.gd       ❓ Não encontrado
│
├── 🎨 Recursos
│   ├── ItemData/
│   │   ├── bow.tres          ✅ Configurado
│   │   └── sword.tres        ⚠️ item_name vazio
│   └── art/                  ✅ 20+ texturas
│
├── 🎬 Cenas
│   ├── entidades.tscn        ✅ Player scene
│   ├── projectile.tscn       ✅ Projectile scene
│   ├── bow.tscn              ❓ Propósito desconhecido
│   └── the_game.tscn         ✅ Cena principal
│
└── ⚙️ Config
	└── project.godot         ✅ Inputs configurados
```

---

## ✅ Pontos Positivos

### Sistema de Input Configurado
```gdscript
[input]
ui_left/right/up/down = WASD + Arrows
attack = Mouse Left (Button 1)
shoot = Mouse Right (Button 2)  # ← Não usado no código!
```

### Recursos de Arma
- ✅ Bow configurado para projectile
- ✅ Sword configurado para melee
- ✅ SpriteFrames definidos
- ✅ Collision shapes criados

### Código Base Funcional
- ✅ Movimento 8-direções
- ✅ Animações do player (8 direções)
- ✅ Sistema de weapon swap via `receive_weapon_data()`
- ✅ Projectile voa e causa dano
- ✅ Detecção de colisão (enemies, walls)

---

## 🎯 Funcionalidades Faltando

### Sistema de Inimigos
- ❌ Não há script de inimigo (`enemies` group usado mas não implementado)
- ❌ Método `take_damage()` não verificado em nenhum script

### Sistema de Itens Coletáveis
- ❌ Não há script para pickup de armas
- ❌ `receive_weapon_data()` existe mas nenhum item chama

### UI/HUD
- ❌ Sem sistema de vida/stamina
- ❌ Sem indicador de arma equipada
- ❌ Sem cooldown visual

### Efeitos
- ❌ Sem partículas
- ❌ Sem som
- ❌ Sem feedback visual de dano
- ❌ Sem screenshake

---

## 🔧 Correções Prioritárias (Ordem de Importância)

### 🔴 Prioridade ALTA (Quebram gameplay)

1. **Corrigir cooldown de ataque**
   - Adicionar `_on_weapon_timer_timeout()`
   - Conectar timer em `_ready()`
   - Setar `can_attack = false` após atacar

2. **Remover expressão standalone (linha 79)**
   - Substituir por `weapon_marker.rotation = 0.0`

3. **Corrigir shadowing de `range`**
   - Renomear para `weapon_range`
   - Atualizar bow.tres e sword.tres

### 🟡 Prioridade MÉDIA (Melhoram qualidade)

4. **Unificar rotação da arma**
   - Remover duplicação entre `_physics_process` e `_process`
   - Diferenciar melee/projectile

5. **Melhorar melee attack**
   - Adicionar animação visual
   - Implementar movimento da hitbox
   - Usar `attack_speed` do recurso

6. **Preencher sword.tres**
   - `item_name = "Sword"`

### 🟢 Prioridade BAIXA (Polimento)

7. **Adicionar comentários**
   - Explicar lógica do cooldown
   - Documentar weapon types

8. **Validar recursos null**
   - Checar se `current_weapon_data` existe antes de acessar

9. **Implementar `shoot` action**
   - Input existe mas não é usado

---

## 📊 Métricas do Código

| Métrica | Valor | Comentário |
|---------|-------|------------|
| Linhas de código | ~220 | entidades.gd |
| Funções | 13 | entidades.gd |
| Erros críticos | 2 | Ambos fáceis de corrigir |
| TODOs no código | 0 | Nenhum encontrado |
| Comentários | ~10 | Maioria em seções |
| Complexidade | Média | Lógica direta, falta organização |

---

## 🎮 Como Testar Depois das Correções

### Setup
1. Abra Godot 4.5
2. Carregue `project.godot`
3. Abra `the_game.tscn`
4. Adicione temporariamente em `the_game.gd`:
```gdscript
extends Node2D

@onready var player = $entidades  # ajuste path

func _ready():
	var bow_data = preload("res://ItemData/bow.tres")
	player.receive_weapon_data(bow_data)
```

### Testes Básicos
- [ ] Player move com WASD em 8 direções
- [ ] Arco aponta para o mouse
- [ ] Click esquerdo dispara flecha
- [ ] Flecha voa na direção do mouse
- [ ] Cooldown de ~0.33s entre tiros (fire_rate = 3.0)
- [ ] Flecha desaparece ao sair da tela

### Testes de Melee
- [ ] Trocar para sword.tres
- [ ] Click esquerdo ativa hitbox
- [ ] Hitbox detecta "enemies" (se existirem)
- [ ] Cooldown funciona

---

## 💡 Recomendações Futuras

### Arquitetura
- Separar lógica de arma em `WeaponController.gd`
- Criar State Machine para player (IDLE, MOVING, ATTACKING)
- Usar signals para desacoplar sistemas

### Performance
- Pool de projéteis (em vez de instantiate toda vez)
- Limitar ataque rápido (evitar spam)

### Qualidade de Vida
- Debug visual (mostrar hitboxes com F3)
- Console de comandos (spawnar armas, dar dano)
- Save/load de arma equipada

---

## 📝 Checklist de Correção

```markdown
- [ ] Corrigir linha 79 de entidades.gd (standalone expression)
- [ ] Renomear `range` para `weapon_range` em WeaponData.gd
- [ ] Atualizar bow.tres e sword.tres (range → weapon_range)
- [ ] Adicionar _on_weapon_timer_timeout()
- [ ] Conectar weapon_timer em _ready()
- [ ] Setar can_attack = false após atacar
- [ ] Remover duplicação de rotação de arma
- [ ] Preencher item_name em sword.tres
- [ ] Testar no Godot
```

---

**Status**: ⚠️ **PRECISA DE CORREÇÕES** antes de ser considerado funcional.

O sistema está ~70% completo. Com as 3 correções prioritárias, chegaria a ~90% funcional.
