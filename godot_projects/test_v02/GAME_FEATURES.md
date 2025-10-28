# 🎮 DOCUMENTAÇÃO COMPLETA - FUNCIONALIDADES DO JOGO

**Projeto:** Star Dream - Test v02  
**Engine:** Godot 4.5.dev4  
**Branch:** thirdversion  
**Data:** 27 de Outubro de 2025

---

## 📋 ÍNDICE

1. [Sistema de Player](#sistema-de-player)
2. [Sistema de Combate](#sistema-de-combate)
3. [Sistema de Magias](#sistema-de-magias)
4. [Sistema de Inimigos](#sistema-de-inimigos)
5. [Sistema de Inventário](#sistema-de-inventário)
6. [Sistema de Equipamentos](#sistema-de-equipamentos)
7. [Sistema de UI](#sistema-de-ui)
8. [Sistema de Spawning](#sistema-de-spawning)
9. [Sistema de Estatísticas](#sistema-de-estatísticas)
10. [Sistema de Menu](#sistema-de-menu)
11. [Arquitetura de Dados](#arquitetura-de-dados)

---

## 1. SISTEMA DE PLAYER

### 1.1 Movimento
- **Movimentação 8 direções**: WASD para movimento fluido
- **Velocidade base**: 150 pixels/segundo
- **Sistema de Dash**:
  - Tecla: SHIFT
  - Cooldown: 2 segundos
  - Distância: calculada dinamicamente
  - Velocidade aumentada durante dash
  - Feedback visual e de cooldown

### 1.2 Rotação e Direcionamento
- **Rotação automática**: Sprite sempre aponta para o cursor do mouse
- **Marcador de arma (weapon_marker)**:
  - Posição dinâmica na frente do player
  - Rotaciona junto com o player
  - Ponto de origem para projéteis e ataques

### 1.3 Atributos do Player
- **Vida (HP)**:
  - HP máximo: 100
  - HP atual: gerenciado dinamicamente
  - Sistema de dano e regeneração
  - Sinais: `health_changed`, `max_health_changed`, `died`

- **Mana**:
  - Mana máxima: 100
  - Mana atual: gerenciada dinamicamente
  - Regeneração passiva: 0.1 por frame
  - Consumo por magias
  - Sinais: `mana_changed`, `max_mana_changed`

- **Stamina** (planejado, não totalmente implementado)

### 1.4 Camadas de Colisão
- **Collision Layer**: 2 (binário: 10)
- **Collision Mask**: 13 (binário: 1101)
  - Detecta: mundo, inimigos, itens

### 1.5 Estados e Buffs
- **Sistema de Buffs Temporários**:
  - Buff de velocidade (multiplica velocidade base)
  - Timer automático para expiração
  - Restauração de stats ao término
  - Suporte para múltiplos tipos de buff

---

## 2. SISTEMA DE COMBATE

### 2.1 Ataque Corpo a Corpo
- **Ativação**: Botão esquerdo do mouse (clique)
- **Sistema de Cooldown**:
  - Cooldown definido pela arma equipada
  - Timer visual na UI
  - Bloqueio de spam

- **Mecânicas de Ataque**:
  - Hitbox posicionada no weapon_marker
  - Rotação da hitbox para direção do mouse
  - Delay de aviso antes do golpe (0.1s padrão)
  - Duração do golpe (0.15s padrão)
  - Desativação automática da hitbox após golpe

- **Dano**:
  - Baseado na arma equipada
  - Cálculo: `dano_arma + bônus_força`
  - Aplicado apenas a inimigos na hitbox

### 2.2 Sistema de Projéteis
- **Tipos Implementados**:
  - Fireball (Bola de Fogo)
  - Ice Bolt (Raio de Gelo - contínuo)

- **Comportamento de Projétil**:
  - Direção: do player para o mouse
  - Velocidade configurável por spell
  - Alcance máximo
  - Pierce (atravessa inimigos)
  - Max targets (número máximo de alvos)
  - Knockback (empurrão)
  - Auto-destruição ao atingir parede ou alcance máximo

### 2.3 Sistema de Dano
- **Cálculo de Dano**:
  ```
  dano_real = max(dano_base - defesa_inimigo, 1.0)
  ```
- **Efeitos Visuais**:
  - Flash vermelho no inimigo atingido
  - Indicadores de dano (planejado)

---

## 3. SISTEMA DE MAGIAS

### 3.1 Magias Disponíveis

#### 3.1.1 Fireball (Bola de Fogo)
- **Tipo**: Projétil
- **Dano**: 35
- **Custo de Mana**: 12
- **Cooldown**: 1.5s
- **Alcance**: 350 pixels
- **Velocidade**: 300
- **Características**:
  - Não atravessa inimigos (pierce: false)
  - Atinge 1 alvo
  - Knockback de 50
  - Cor: Laranja/Vermelho

#### 3.1.2 Ice Bolt (Raio Gélido)
- **Tipo**: Raio Contínuo (Laser)
- **Dano**: 25 DPS (2.5 por tick a cada 0.1s)
- **Custo de Mana**: 10 mana/segundo
- **Cooldown**: 2.0s
- **Alcance**: 500 pixels
- **Características**:
  - **Raio laser contínuo**
  - Segue o cursor do mouse em tempo real
  - Aplica slow de 50% nos inimigos
  - Atravessa inimigos (pierce: true)
  - Atinge até 10 alvos simultaneamente
  - Sem knockback
  - **NÃO causa stun** (inimigos continuam se movendo devagar)
  - Cor: Azul gélido
  - Visual: Line2D + Partículas de impacto
  - Detecção: RayCast2D para paredes + Area2D para inimigos

#### 3.1.3 Heal (Cura Divina)
- **Tipo**: Auto-cura
- **Cura**: 30 HP
- **Custo de Mana**: 25
- **Cooldown**: 3.0s
- **Características**:
  - Cura instantânea
  - Não ultrapassa HP máximo
  - Efeito visual de cura
  - Cor: Verde

#### 3.1.4 Speed Boost (Impulso Veloz)
- **Tipo**: Buff
- **Efeito**: +50% velocidade
- **Custo de Mana**: 20
- **Cooldown**: 5.0s
- **Duração**: 5.0s
- **Características**:
  - Buff temporário
  - Multiplica velocidade base
  - Auto-expira
  - Cor: Amarelo

### 3.2 Sistema de Cooldown de Magias
- **Mecânica**:
  - Dictionary tracking: `{spell_id: tempo_restante}`
  - Atualização por frame em `_physics_process`
  - Verificação pré-cast
  - Bloqueio durante cooldown
  - Mensagem de confirmação quando pronto

- **Funções**:
  - `start_spell_cooldown(spell_id, cooldown_time)`
  - `is_spell_on_cooldown(spell_id)` → bool
  - `get_spell_cooldown_remaining(spell_id)` → float
  - `update_spell_cooldowns(delta)` → atualiza todos

### 3.3 Seleção de Magias
- **Navegação**: Teclas Q/E para ciclar entre magias
- **Visual**: UI mostra magia atual e disponíveis
- **Hold-to-cast**: Ice Bolt requer segurar botão direito
- **Cast instantâneo**: Outras magias ativam ao clicar

### 3.4 Sistema de Mana
- **Consumo**:
  - Instantâneo para magias normais
  - Contínuo para Ice Bolt (10 mana/s)
- **Verificação pré-cast**:
  - Bloqueia cast se mana insuficiente
  - Feedback visual/sonoro (planejado)
- **Auto-cancelamento**:
  - Ice Bolt cancela se mana zerar durante uso

---

## 4. SISTEMA DE INIMIGOS

### 4.1 Tipos de Inimigos

#### 4.1.1 Lobo Veloz
- **HP**: 30
- **Dano**: 15
- **Defesa**: 0
- **Velocidade**: 50
- **Chase Range**: 300 pixels
- **Attack Range**: 80 pixels
- **Cooldown de Ataque**: 0.20s
- **Flash Duration**: 0.10s
- **Comportamento**: Agressivo
- **Escala do Sprite**: (2.0, 2.0)
- **Recompensas**: 20 XP, 8 moedas

#### 4.1.2 Lobo Cinza
- **HP**: 60
- **Dano**: 8
- **Defesa**: 2
- **Velocidade**: 90
- **Chase Range**: 250 pixels
- **Attack Range**: 35 pixels
- **Cooldown de Ataque**: 1.80s
- **Flash Duration**: 0.10s
- **Comportamento**: Agressivo
- **Escala do Sprite**: (1.2, 1.2)
- **Recompensas**: 25 XP, 12 moedas

#### 4.1.3 Lobo Alfa
- **HP**: 120
- **Dano**: 15
- **Defesa**: 8
- **Velocidade**: 60
- **Chase Range**: 300 pixels
- **Attack Range**: 40 pixels
- **Cooldown de Ataque**: 2.50s
- **Flash Duration**: 0.15s
- **Comportamento**: Agressivo
- **Escala do Sprite**: (1.5, 1.5)
- **Recompensas**: 50 XP, 25 moedas

### 4.2 Sistema de Estados (State Machine)

#### Estados Disponíveis:
1. **IDLE** (Parado)
   - Inimigo não faz nada
   - Aguarda detecção do player

2. **CHASE** (Perseguição)
   - Move-se em direção ao player
   - Velocidade: `get_current_speed()` (considera slow)
   - Muda para ATTACK ao entrar no attack range
   - Volta para IDLE se player sair do chase range

3. **ATTACK** (Atacando)
   - Para de se mover
   - Rotaciona hitbox para o player
   - Delay de aviso configurável
   - Ativa hitbox por duração específica
   - Aplica cooldown após ataque
   - Volta para CHASE após ataque

4. **HURT** (Recebendo Dano)
   - **Apenas para dano com stun**
   - Para de se mover
   - Flash visual vermelho
   - Duração do flash configurável
   - Retorna ao estado anterior após flash
   - **Ice Bolt NÃO causa este estado**

5. **DEAD** (Morto)
   - Estado final
   - Executa lógica de morte
   - Dropa recompensas
   - Remove da cena

### 4.3 Sistema de Detecção
- **DetectionArea**:
  - CircleShape2D com radius = chase_range
  - Collision Layer: 0
  - Collision Mask: 2 (detecta player)
  - Monitoring: true
  - Signals: `body_entered`, `body_exited`

- **Lógica de Detecção**:
  - Detecção automática via signal
  - Verificação manual de distância no `_ready()`
  - Confirmação de grupo "player"
  - Define alvo e muda estado para CHASE

### 4.4 Sistema de Ataque
- **Attack Hitbox**:
  - Area2D com RectangleShape2D
  - Collision Layer: 8
  - Collision Mask: 2 (atinge player)
  - Monitoring: false (ativa apenas durante golpe)
  - Rotação dinâmica para direção do player

- **Sequência de Ataque**:
  1. Entra em ATTACK ao player estar no range
  2. Rotaciona hitbox para o player
  3. Delay de aviso (visual telegraphing)
  4. Ativa hitbox por duração específica
  5. Detecta colisão com player
  6. Aplica dano
  7. Desativa hitbox
  8. Inicia cooldown
  9. Volta para CHASE/IDLE

### 4.5 Sistema de Slow (Ice Bolt)
- **Variáveis**:
  - `is_slowed: bool` - Flag de slow ativo
  - `slow_multiplier: float` - Multiplicador (0.5 = 50% velocidade)
  - `slow_timer: Timer` - Auto-remove slow

- **Funções**:
  - `apply_slow(slow_percent, duration)` - Aplica slow
  - `remove_slow()` - Remove slow e restaura velocidade
  - `get_current_speed()` - Retorna velocidade com slow aplicado

- **Comportamento**:
  - Ice Bolt aplica slow contínuo (renova a cada 0.5s)
  - Inimigo continua se movendo (não trava)
  - Velocidade reduzida para 50%
  - Slow auto-expira se não renovado
  - Visual: inimigo move mais devagar

### 4.6 Sistema de Dano no Inimigo
- **Função**: `take_damage(amount: float, apply_stun: bool = true)`
- **Parâmetros**:
  - `amount`: Quantidade de dano
  - `apply_stun`: Se true, causa flash e estado HURT; se false, apenas dano

- **Cálculo**:
  ```gdscript
  dano_real = max(amount - defesa, 1.0)
  ```

- **Comportamento**:
  - Aplica defesa
  - Reduz HP
  - Se `apply_stun = true`:
    - Aplica flash vermelho
    - Muda para estado HURT
  - Se `apply_stun = false`:
    - Apenas dano, sem stun (usado pelo Ice Bolt)
  - Verifica morte (HP <= 0)
  - Busca player se não tinha alvo

### 4.7 Sistema de Morte
- **Sequência**:
  1. HP chega a zero
  2. Aguarda flash visual (0.1s)
  3. Executa função `die()`
  4. Muda estado para DEAD
  5. Dropa recompensas (XP e moedas)
  6. Atualiza estatísticas do jogo
  7. Remove da cena (`queue_free()`)

### 4.8 Camadas de Colisão (Inimigo)
- **Body**:
  - Collision Layer: 4 (binário: 100)
  - Collision Mask: 3 (binário: 11) - detecta mundo e player

- **Attack Hitbox**:
  - Collision Layer: 8 (binário: 1000)
  - Collision Mask: 2 (binário: 10) - atinge player

- **Detection Area**:
  - Collision Layer: 0
  - Collision Mask: 2 (binário: 10) - detecta player

---

## 5. SISTEMA DE INVENTÁRIO

### 5.1 Estrutura
- **Capacidade**: 30 slots
- **Classe**: `Inventory` (Resource)
- **Armazenamento**: Array de `InventorySlot`

### 5.2 InventorySlot
- **item_data**: ItemData (referência ao item)
- **quantity**: int (quantidade no slot)
- **Limite por slot**: 99 unidades

### 5.3 Funcionalidades

#### 5.3.1 Adicionar Item
- **Função**: `add_item(item: ItemData, amount: int = 1) → bool`
- **Lógica**:
  - Se item empilhável, tenta empilhar em slots existentes
  - Se não couber, cria novos slots
  - Retorna false se inventário cheio
  - Emite signal `inventory_changed`

#### 5.3.2 Remover Item
- **Função**: `remove_item(item: ItemData, amount: int = 1) → bool`
- **Lógica**:
  - Remove quantidade especificada
  - Se slot ficar vazio, limpa o slot
  - Emite signal `inventory_changed`

#### 5.3.3 Usar Item
- **Função**: `use_item(slot_index: int) → bool`
- **Lógica**:
  - Verifica se item é consumível
  - Emite signal `item_used(item_data)`
  - Remove 1 unidade do slot
  - Player processa efeito do item

#### 5.3.4 Trocar Slots
- **Função**: `swap_slots(from_index: int, to_index: int)`
- **Lógica**:
  - Troca conteúdo entre dois slots
  - Usado para reorganização
  - Emite signal `inventory_changed`

#### 5.3.5 Verificações
- `has_item(item: ItemData) → bool`
- `get_item_quantity(item: ItemData) → int`
- `is_full() → bool`
- `get_first_empty_slot() → int`

### 5.4 Sinais
- `inventory_changed` - Emitido quando inventário muda
- `item_used(item_data: ItemData)` - Emitido ao usar item

---

## 6. SISTEMA DE EQUIPAMENTOS

### 6.1 Slots de Equipamento
- **Arma Principal**: Uma arma por vez
- **Arma Secundária**: (planejado)
- **Armadura**: (planejado)
- **Acessórios**: (planejado)

### 6.2 Equipar Arma
- **Função**: `equip_weapon(weapon_data: WeaponData)`
- **Comportamento**:
  - Define arma atual
  - Atualiza dano de ataque
  - Atualiza cooldown de ataque
  - Atualiza sprite da arma (planejado)
  - Emite signal `weapon_equipped`

### 6.3 Tipos de Armas Disponíveis

#### 6.3.1 Arco (Bow)
- **Dano**: 10
- **Cooldown**: 0.8s
- **Tipo**: Arma à distância
- **Sprite**: arco1.png - arco4.png
- **Características**: Rápido, dano moderado

#### 6.3.2 Espada (Sword)
- **Dano**: 25
- **Cooldown**: 1.2s
- **Tipo**: Arma corpo a corpo
- **Sprite**: Sprite-0004.png
- **Características**: Dano alto, cooldown maior

#### 6.3.3 Lança (Spear) - Planejado
- **Arquivo**: lanca.png
- **Status**: Sprite disponível, dados não implementados

### 6.4 Coleta de Armas
- **Itens no mundo**: Area2D detectáveis
- **Interação**: Colisão automática
- **Adição**: Item vai para inventário
- **Feedback**: Mensagem de coleta

---

## 7. SISTEMA DE UI

### 7.1 HUD (Player HUD)

#### 7.1.1 Barra de Vida
- **Tipo**: ProgressBar
- **Range**: 0 a max_health
- **Cor**: Vermelho
- **Posição**: Superior esquerdo
- **Atualização**: Via signal `health_changed`
- **Texto**: "HP: X/Y"

#### 7.1.2 Barra de Mana
- **Tipo**: ProgressBar
- **Range**: 0 a max_mana
- **Cor**: Azul
- **Posição**: Abaixo da barra de vida
- **Atualização**: Via signal `mana_changed`
- **Texto**: "Mana: X/Y"

#### 7.1.3 Barra de Stamina (Planejado)
- **Status**: UI preparada, sistema não implementado

### 7.2 Spell Selector UI

#### 7.2.1 Estrutura
- **Container**: HBoxContainer
- **Slots**: 5 visíveis
- **Slot atual**: Destacado com borda
- **Posição**: Canto inferior esquerdo

#### 7.2.2 Slot de Magia
- **Ícone**: Sprite da magia
- **Nome**: Label com nome da magia
- **Cooldown**: Overlay de cooldown (planejado)
- **Teclas**: Q/E para navegação

### 7.3 Hotbar

#### 7.3.1 Estrutura
- **Slots**: 9 slots (1-9)
- **Sincronização**: Auto-sync com primeiros 9 slots do inventário
- **Teclas**: 1-9 para uso rápido
- **Posição**: Centro inferior da tela

#### 7.3.2 Funcionalidades
- **Exibição**: Mostra ícone e quantidade
- **Uso rápido**: Pressionar tecla usa item
- **Drag & Drop**: (planejado)
- **Atualização**: Automática ao mudar inventário

### 7.4 Inventory UI

#### 7.4.1 Estrutura
- **Layout**: GridContainer 6x5 (30 slots)
- **Posição**: Centro da tela
- **Abertura**: Tecla TAB
- **CanvasLayer**: 100 (sempre no topo)

#### 7.4.2 Slot UI
- **Ícone**: TextureRect do item
- **Quantidade**: Label
- **Background**: Panel com cor
- **Mouse Filter**: STOP (captura eventos)
- **Tamanho**: 64x64 pixels

#### 7.4.3 Interações
- **Clique Esquerdo**: Selecionar/Usar item
- **Clique Direito**: Menu de contexto (planejado)
- **Drag & Drop**: Entre slots (planejado)
- **Hover**: Tooltip com info (planejado)

### 7.5 Menu de Pausa

#### 7.5.1 Estrutura
- **Abertura**: Tecla ESC
- **Process Mode**: ALWAYS (funciona quando pausado)
- **Overlay**: Escurece tela de fundo

#### 7.5.2 Opções
- **Retomar**: Volta ao jogo
- **Configurações**: (planejado)
- **Sair para Menu**: Volta ao menu principal
- **Sair do Jogo**: Fecha aplicação

### 7.6 Menu Principal

#### 7.6.1 Estrutura
- **Navegação**: SETAS do teclado
- **Seleção**: ENTER ou clique
- **Background**: Imagem de fundo

#### 7.6.2 Opções
- **Iniciar Jogo**: Carrega cena de jogo
- **Configurações**: (planejado)
- **Créditos**: (planejado)
- **Sair**: Fecha aplicação

---

## 8. SISTEMA DE SPAWNING

### 8.1 Enemy Spawner

#### 8.1.1 Configuração
- **Intervalo Inicial**: 3.0 segundos
- **Limite de Inimigos**: 20 simultâneos
- **Área de Spawn**: Círculo ao redor do player
- **Distância Mínima**: Fora da tela
- **Distância Máxima**: Configurável

#### 8.1.2 Tipos de Spawn
- **Aleatório**: Escolhe tipo aleatório da lista
- **Pesado**: Prioriza tipos mais fortes (planejado)
- **Ondas**: Sistema de waves (planejado)

#### 8.1.3 Processo de Spawn
1. Timer expira
2. Verifica limite de inimigos ativos
3. Escolhe tipo aleatório
4. Calcula posição ao redor do player
5. Instancia inimigo
6. Adiciona à cena
7. Incrementa contador
8. Reseta timer

#### 8.1.4 Escalabilidade
- **Dificuldade progressiva**: (planejado)
- **Redução de intervalo**: (planejado)
- **Tipos mais fortes**: (planejado)

---

## 9. SISTEMA DE ESTATÍSTICAS

### 9.1 Game Stats (Singleton)

#### 9.1.1 Estatísticas Rastreadas
- **enemies_killed**: int - Inimigos mortos
- **damage_dealt**: float - Dano total causado
- **damage_taken**: float - Dano total recebido
- **playtime**: float - Tempo de jogo em segundos
- **coins_collected**: int - Moedas coletadas
- **items_collected**: int - Itens coletados
- **spells_cast**: int - Magias lançadas

#### 9.1.2 Funções
- `start_new_game()` - Reseta estatísticas
- `record_enemy_kill()` - Registra morte de inimigo
- `record_damage_dealt(amount)` - Registra dano causado
- `record_damage_taken(amount)` - Registra dano recebido
- `record_coin_collected(amount)` - Registra moedas
- `get_formatted_playtime() → String` - Retorna tempo formatado

#### 9.1.3 Persistência
- **Salvar em arquivo**: (planejado)
- **Leaderboards**: (planejado)
- **Achievements**: (planejado)

---

## 10. SISTEMA DE MENU

### 10.1 Fluxo de Telas
1. **Menu Principal** → Iniciar Jogo → **Cena de Jogo**
2. **Cena de Jogo** → ESC → **Menu de Pausa**
3. **Menu de Pausa** → Retomar → **Cena de Jogo**
4. **Menu de Pausa** → Sair → **Menu Principal**

### 10.2 Transições
- **Fade In/Out**: (planejado)
- **Loading Screen**: (planejado)
- **Animações**: (planejado)

---

## 11. ARQUITETURA DE DADOS

### 11.1 Resources (Godot)

#### 11.1.1 ItemData (Base)
```gdscript
class_name ItemData
extends Resource

@export var item_id: String
@export var item_name: String
@export var description: String
@export var icon: Texture2D
@export var item_type: ItemType
@export var max_stack: int = 1
@export var is_stackable: bool = false

enum ItemType {
    WEAPON,
    CONSUMABLE,
    MATERIAL,
    QUEST
}
```

#### 11.1.2 WeaponData
```gdscript
class_name WeaponData
extends ItemData

@export var damage: float
@export var attack_speed: float  # Cooldown em segundos
@export var weapon_type: WeaponType
@export var sprite_frames: SpriteFrames

enum WeaponType {
    MELEE,
    RANGED,
    MAGIC
}
```

#### 11.1.3 ConsumableData
```gdscript
class_name ConsumableData
extends ItemData

@export var restore_health: float
@export var restore_mana: float
@export var restore_stamina: float
@export var buff_duration: float
@export var buff_type: BuffType

enum BuffType {
    NONE,
    SPEED,
    DAMAGE,
    DEFENSE
}
```

#### 11.1.4 SpellData
```gdscript
class_name SpellData
extends Resource

@export var spell_id: String
@export var spell_name: String
@export var description: String
@export var icon: Texture2D
@export var spell_type: SpellType
@export var mana_cost: float
@export var cooldown: float
@export var damage: float
@export var spell_range: float
@export var projectile_speed: float
@export var pierce: bool
@export var max_targets: int
@export var knockback_force: float
@export var speed_modifier: float  # Para buffs/debuffs
@export var spell_color: Color
@export var sprite_frames: SpriteFrames

enum SpellType {
    PROJECTILE,
    SELF_BUFF,
    AREA_EFFECT,
    SUMMON
}
```

#### 11.1.5 EnemyData
```gdscript
class_name EnemyData
extends Resource

@export var enemy_id: String
@export var enemy_name: String
@export var max_health: float
@export var damage: float
@export var defense: float
@export var move_speed: float
@export var chase_range: float
@export var attack_range: float
@export var attack_cooldown: float
@export var hit_flash_duration: float
@export var behavior: String  # "Aggressive", "Passive", "Neutral"
@export var experience_drop: int
@export var coin_drop: int
@export var sprite_frames: SpriteFrames
@export var sprite_scale: Vector2
@export var attack_hitbox_shape: Shape2D
@export var attack_hitbox_offset: Vector2
@export var attack_warning_duration: float
@export var attack_duration: float
@export var hitbox_color: Color
```

### 11.2 Singletons (Autoload)

#### 11.2.1 GameStats
- **Path**: `res://scripts/singletons/game_stats.gd`
- **Autoload**: Sim
- **Função**: Rastrear estatísticas globais

### 11.3 Estrutura de Pastas
```
test_v02/
├── scenes/
│   ├── game/
│   │   └── the_game.tscn        # Cena principal do jogo
│   ├── player/
│   │   └── player.tscn          # Cena do player
│   ├── enemies/
│   │   └── enemy.tscn           # Template de inimigo
│   ├── spells/
│   │   ├── projectile.tscn      # Projétil genérico
│   │   └── ice_beam.tscn        # Raio de gelo
│   ├── ui/
│   │   ├── player_hud.tscn
│   │   ├── inventory_ui.tscn
│   │   ├── spell_selector_ui.tscn
│   │   ├── hotbar.tscn
│   │   └── pause_menu.tscn
│   └── menu/
│       └── main_menu.tscn
│
├── scripts/
│   ├── player/
│   │   └── player.gd
│   ├── enemy/
│   │   └── enemy.gd
│   ├── spells/
│   │   ├── projectile.gd
│   │   └── ice_beam.gd
│   ├── ui/
│   │   ├── player_hud.gd
│   │   ├── inventory_ui.gd
│   │   ├── spell_selector_ui.gd
│   │   ├── hotbar.gd
│   │   ├── slot_ui.gd
│   │   └── pause_menu.gd
│   ├── inventory/
│   │   └── inventory.gd
│   ├── spawner/
│   │   └── enemy_spawner.gd
│   └── singletons/
│       └── game_stats.gd
│
├── resources/
│   ├── classes/
│   │   ├── ItemData.gd
│   │   ├── WeaponData.gd
│   │   ├── ConsumableData.gd
│   │   ├── SpellData.gd
│   │   └── EnemyData.gd
│   ├── weapons/
│   │   ├── bow.tres
│   │   └── sword.tres
│   ├── spells/
│   │   ├── fireball.tres
│   │   ├── ice_bolt.tres
│   │   ├── heal.tres
│   │   └── speed_boost.tres
│   ├── enemies/
│   │   ├── lobo_veloz.tres
│   │   ├── lobo_cinza.tres
│   │   └── lobo_alfa.tres
│   └── consumables/
│       └── (poções diversas)
│
└── art/
    ├── player/
    ├── enemies/
    ├── weapons/
    ├── spells/
    └── ui/
```

---

## 12. SISTEMAS PLANEJADOS (NÃO IMPLEMENTADOS)

### 12.1 Sistema de Experiência e Level Up
- Ganho de XP ao matar inimigos
- Level up com aumento de stats
- Skill tree
- Pontos de atributo

### 12.2 Sistema de Quests
- NPCs com quests
- Sistema de diálogo
- Objetivos rastreáveis
- Recompensas

### 12.3 Sistema de Crafting
- Combinação de materiais
- Receitas
- Upgrade de equipamentos

### 12.4 Sistema de Save/Load
- Salvar progresso
- Múltiplos slots de save
- Auto-save

### 12.5 Sistema de Audio
- Música de fundo
- Sound effects
- Controle de volume

### 12.6 Sistema de Partículas
- Efeitos visuais de magias
- Impactos
- Trail effects

### 12.7 Sistema de Iluminação
- Dia/Noite
- Luzes dinâmicas
- Sombras

### 12.8 Multiplayer
- Co-op local
- Online (distante)

---

## 13. BUGS CONHECIDOS E CORREÇÕES APLICADAS

### 13.1 ✅ CORRIGIDOS

#### 13.1.1 Função take_damage
- **Bug**: Chamada com 3 argumentos, esperava 1
- **Correção**: Simplificado para `take_damage(amount)`

#### 13.1.2 Propriedade enemy_data.speed
- **Bug**: Propriedade não existe
- **Correção**: Alterado para `enemy_data.move_speed`

#### 13.1.3 Inimigos congelando com Ice Bolt
- **Bug**: Timer one_shot não renovava slow
- **Correção**: `one_shot = true` + renovação via `start(duration)`

#### 13.1.4 Ice Bolt causando stun
- **Bug**: Inimigos travavam ao receber dano do Ice Bolt
- **Correção**: Adicionado parâmetro `apply_stun: bool = true` em `take_damage()`
  - Ice Bolt passa `false` para não causar estado HURT
  - Outros ataques passam `true` (padrão) para manter stun

#### 13.1.5 Raio não seguindo mouse
- **Bug**: Raio ia reto após ser filho do weapon_marker
- **Correção**: 
  - Beam criado no mundo (não como filho)
  - `global_position` atualizada para seguir player
  - `global_rotation` atualizada para seguir mouse
  - Atualização constante em `_process()`

### 13.2 ⚠️ CONHECIDOS (NÃO CRÍTICOS)

#### 13.2.1 Slot UI warnings
- **Aviso**: "icon_rect ou quantity_label NULL"
- **Impacto**: Visual, não afeta funcionalidade
- **Prioridade**: Baixa

#### 13.2.2 DetectionArea delay
- **Descrição**: Inimigos aguardam 1 frame para verificar overlaps
- **Impacto**: Atraso mínimo na detecção
- **Prioridade**: Baixa

---

## 14. PERFORMANCE E OTIMIZAÇÃO

### 14.1 Considerações Atuais
- **Inimigos**: Máximo de 20 simultâneos
- **Projéteis**: Auto-destruição ao sair do alcance
- **UI**: Atualização apenas quando necessário (via signals)
- **Colisões**: Layers bem definidas para evitar checks desnecessários

### 14.2 Otimizações Planejadas
- **Object Pooling**: Para projéteis e inimigos
- **Spatial Partitioning**: Para otimizar detecções
- **LOD**: Para sprites distantes
- **Culling**: Não processar entidades fora da tela

---

## 15. CONTROLES

### 15.1 Teclado e Mouse

#### Movimento
- **W/↑**: Mover para cima
- **A/←**: Mover para esquerda
- **S/↓**: Mover para baixo
- **D/→**: Mover para direita
- **SHIFT**: Dash

#### Combate
- **Mouse**: Rotação do personagem (sempre aponta para cursor)
- **Botão Esquerdo (Click)**: Ataque corpo a corpo
- **Botão Direito (Click)**: Lançar magia
- **Botão Direito (Hold)**: Manter Ice Bolt ativo

#### Magias
- **Q**: Magia anterior
- **E**: Próxima magia

#### Inventário e Hotbar
- **TAB**: Abrir/Fechar inventário
- **1-9**: Usar item da hotbar

#### Sistema
- **ESC**: Pausar jogo
- **ENTER**: Confirmar (em menus)
- **SETAS**: Navegar menus

---

## 16. CONFIGURAÇÕES DO PROJETO

### 16.1 Godot Settings
- **Engine**: Godot 4.5.dev4.official.209a446e3
- **Renderer**: Forward+ (Vulkan 1.3.212)
- **Resolução**: 1152x648 (16:9)
- **VSync**: Enabled
- **Physics FPS**: 60

### 16.2 Collision Layers
```
Layer 1 (1):   Mundo/Terreno
Layer 2 (2):   Player
Layer 3 (4):   Inimigos
Layer 4 (8):   Hitbox de ataque (inimigos)
Layer 5 (16):  Projéteis
Layer 6 (32):  Itens coletáveis
```

---

## 17. NOTAS FINAIS

### 17.1 Prioridades para Polimento
1. **Audio**: Adicionar música e efeitos sonoros
2. **Partículas**: Melhorar feedback visual
3. **UI**: Animações e transições suaves
4. **Balanceamento**: Ajustar dano, HP, velocidades
5. **Performance**: Implementar object pooling
6. **Save System**: Persistência de progresso

### 17.2 Recursos Disponíveis Não Utilizados
- **Arte**:
  - Mesa (mesa.png)
  - Árvore (Arvore.png)
  - Moeda (moeda_game1.png)
  - Sprites diversos do Liron

### 17.3 Documentação Complementar
- Consultar `project.godot` para configurações completas
- Consultar arquivos `.tres` para valores exatos
- Consultar scripts individuais para lógica detalhada

---

**Documento criado em:** 27/10/2025  
**Versão:** 1.0  
**Autor:** Sistema de Documentação Automática  
**Status:** ✅ Completo e Atualizado
