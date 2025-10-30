# ⚡ GUIA COMPLETO - Sistema de Raio Contínuo (Continuous Beam)

## 📋 Índice
1. [Visão Geral](#visão-geral)
2. [Estrutura da Cena](#estrutura-da-cena)
3. [Como Funciona](#como-funciona)
4. [Integração com o Player](#integração-com-o-player)
5. [Criando Sprites](#criando-sprites)
6. [Configuração Avançada](#configuração-avançada)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Sistema de **raio contínuo** (beam) que:
- ✅ Segue o mouse em tempo real
- ✅ Ajusta comprimento dinamicamente até o ponto de colisão
- ✅ Usa sprite modular que se repete
- ✅ Mostra sprite de impacto na ponta
- ✅ Aplica dano contínuo aos inimigos
- ✅ Consome mana enquanto ativo
- ✅ Efeitos visuais de pulsação e oscilação
- ✅ Partículas de impacto

---

## 🏗️ Estrutura da Cena

### Hierarquia de Nós:
```
ContinuousBeam (Node2D) [Script: continuous_beam.gd]
├── RayCast2D
│   └── (Detecta colisões e calcula comprimento do raio)
│
├── BeamContainer (Node2D)
│   └── BeamSegment (Sprite2D)
│       └── (Sprite modular do raio que se repete)
│
├── ImpactSprite (Sprite2D)
│   └── (Sprite de impacto na ponta do raio)
│
├── ImpactParticles (GPUParticles2D)
│   └── (Partículas de impacto)
│
├── DamageTimer (Timer)
│   └── (Controla ticks de dano)
│
└── AudioStreamPlayer2D
    └── (Som do raio - opcional)
```

### Papel de Cada Nó:

#### 1. **ContinuousBeam (Node2D)**
   - **Função**: Nó raiz que controla todo o sistema
   - **Script**: `continuous_beam.gd`
   - **Responsabilidade**: Gerencia estado, direção, efeitos e dano

#### 2. **RayCast2D**
   - **Função**: Detecta colisões no caminho do raio
   - **Configuração**:
     - `target_position`: Vector2(800, 0) - Alcance máximo
     - `collision_mask`: 5 - Layer dos inimigos
     - `hit_from_inside`: true
   - **Responsabilidade**: Calcula onde o raio termina

#### 3. **BeamContainer (Node2D)**
   - **Função**: Container para organizar o sprite do raio
   - **Responsabilidade**: Facilita transformações e animações

#### 4. **BeamSegment (Sprite2D)**
   - **Função**: Sprite visual do raio
   - **Características**:
     - Escala X ajustada dinamicamente (comprimento)
     - Escala Y fixa (largura do raio)
     - Region enabled para repetir textura
   - **Responsabilidade**: Visual principal do raio

#### 5. **ImpactSprite (Sprite2D)**
   - **Função**: Sprite de impacto na ponta
   - **Características**:
     - Visível apenas quando há colisão
     - Posicionado dinamicamente
     - Rotacionado com o raio
   - **Responsabilidade**: Feedback visual de impacto

#### 6. **ImpactParticles (GPUParticles2D)**
   - **Função**: Efeito de partículas no impacto
   - **Características**:
     - Emite apenas quando acerta inimigo
     - Direção oposta ao raio
     - Cor azul/branca
   - **Responsabilidade**: Polimento visual

#### 7. **DamageTimer (Timer)**
   - **Função**: Controla frequência de dano
   - **Configuração**: wait_time = 0.2s (5 ticks/segundo)
   - **Responsabilidade**: Aplica dano em intervalos regulares

---

## ⚙️ Como Funciona

### Fluxo de Execução:

```
1. ATIVAÇÃO
   ├── Player pressiona botão (ex: clique esquerdo)
   ├── activate() é chamado
   ├── BeamSegment torna-se visível
   └── DamageTimer inicia

2. A CADA FRAME (_process)
   ├── update_direction() → Rotaciona para o mouse
   ├── update_raycast() → Detecta colisão e calcula comprimento
   ├── update_beam_visual() → Ajusta escala, pulsação, oscilação
   ├── update_impact_visual() → Posiciona sprite/partículas de impacto
   └── consume_mana() → Consome mana do player

3. A CADA TICK (0.2s)
   ├── _on_damage_tick() é chamado pelo DamageTimer
   ├── Verifica se há current_target (inimigo)
   └── Aplica dano via take_damage()

4. DESATIVAÇÃO
   ├── Player solta botão OU mana acaba
   ├── deactivate() é chamado
   ├── Sprites e partículas são escondidos
   └── DamageTimer para
```

### Cálculo do Comprimento:

```gdscript
# A cada frame:
raycast.force_raycast_update()

if raycast.is_colliding():
    # Calcula distância até colisão
    var collision_point = raycast.get_collision_point()
    beam_length = global_position.distance_to(collision_point)
else:
    # Usa alcance máximo
    beam_length = max_range
```

### Ajuste do Sprite Modular:

```gdscript
# Sprite original tem 64px de largura
var sprite_original_width = 64.0

# Calcula quantas vezes deve repetir
var scale_x = beam_length / sprite_original_width

# Aplica escala (com pulsação)
beam_segment.scale.x = scale_x * pulse

# Posiciona no meio do raio
beam_segment.position.x = beam_length / 2.0
```

### Efeitos Visuais:

**Pulsação** (afeta brilho e escala):
```gdscript
pulse_time += delta * pulse_speed
var pulse = 1.0 + sin(pulse_time) * pulse_intensity
```

**Oscilação** (movimento lateral):
```gdscript
oscillation_time += delta * oscillation_speed
var oscillation = sin(oscillation_time) * oscillation_amplitude
beam_segment.position.y = oscillation
```

---

## 🎮 Integração com o Player

### 1. Adicionar ao Script do Player:

```gdscript
# No topo do player.gd
const ContinuousBeamScene = preload("res://scenes/spells/continuous_beam.tscn")

# Variáveis
var current_beam: ContinuousBeam = null
var is_casting_beam: bool = false

# No _ready()
func _ready():
    # ... código existente ...
    setup_beam_spell()

# Nova função
func setup_beam_spell() -> void:
    # Instanciar o raio mas manter inativo
    current_beam = ContinuousBeamScene.instantiate()
    add_child(current_beam)
    current_beam.setup(self, null)  # Passar referência do player
    print("[PLAYER] ⚡ Beam spell configurado")

# No _process(delta) ou _unhandled_input(event)
func _process(delta):
    # ... código existente ...
    
    # Verificar input do raio
    if Input.is_action_pressed("cast_beam"):  # Ex: botão direito do mouse
        if not is_casting_beam and current_mana > 0:
            start_beam_casting()
    else:
        if is_casting_beam:
            stop_beam_casting()

func start_beam_casting() -> void:
    if current_beam:
        current_beam.activate()
        is_casting_beam = true
        print("[PLAYER] 🎯 Iniciando conjuração do raio")

func stop_beam_casting() -> void:
    if current_beam:
        current_beam.deactivate()
        is_casting_beam = false
        print("[PLAYER] ⏹️ Parando conjuração do raio")
```

### 2. Configurar Input no Project Settings:

```
Project > Project Settings > Input Map

Adicionar nova ação: "cast_beam"
├── Mouse Button Right (Botão direito)
└── Ou tecla de sua escolha (ex: Shift + Left Click)
```

### 3. Integração com SpellData:

```gdscript
# Criar SpellData para o raio
# Em resources/spells/lightning_beam.tres

spell_type = SpellData.SpellType.BEAM
spell_name = "Lightning Beam"
damage = 30.0  # Dano por segundo
mana_cost = 15.0  # Mana por segundo
max_range = 800.0
element = SpellData.Element.LIGHTNING

# No player.gd:
func setup_beam_spell() -> void:
    var beam_spell_data = load("res://resources/spells/lightning_beam.tres")
    current_beam = ContinuousBeamScene.instantiate()
    add_child(current_beam)
    current_beam.setup(self, beam_spell_data)
```

---

## 🎨 Criando Sprites

### Sprite do Raio (BeamSegment):

**Requisitos:**
- Tamanho recomendado: **64x32 pixels**
- Formato: PNG com transparência
- Design: Horizontal, repetível (tileable)
- Estilo: Energia, relâmpago, laser, etc.

**Exemplo de Design:**
```
┌──────────────────────────────────────────────────┐
│  ████░░░░████████░░░░████░░░░████████░░░░████    │ ← Borda superior
│  ██████████████████████████████████████████████  │ ← Centro brilhante
│  ████░░░░████████░░░░████░░░░████████░░░░████    │ ← Borda inferior
└──────────────────────────────────────────────────┘
     64 pixels de largura (se repete)
```

**Dicas:**
- Centro mais brilhante
- Bordas com transparência suave
- Padrão que se repete sem emendas visíveis

### Sprite de Impacto (ImpactSprite):

**Requisitos:**
- Tamanho recomendado: **32x32 ou 64x64 pixels**
- Formato: PNG com transparência
- Design: Explosão, faísca, bola de energia

**Exemplo de Design:**
```
    ┌──────┐
    │ ╱╲╱╲ │  ← Raios irradiando
    │╱★★★★╲│  ← Centro brilhante
    │╲★★★★╱│
    │ ╲╱╲╱ │
    └──────┘
```

### Sprite Placeholder:

Se não tiver sprites prontos, use ColorRect temporariamente:

```gdscript
# Substituir Sprite2D por ColorRect no código:
@onready var beam_segment: ColorRect = $BeamContainer/BeamSegment
@onready var impact_sprite: ColorRect = $ImpactSprite

# Configurar cores:
beam_segment.color = Color(0.3, 0.8, 1.0, 0.8)  # Azul
impact_sprite.color = Color(1.0, 1.0, 0.5, 1.0)  # Amarelo
```

---

## 🔧 Configuração Avançada

### Ajustar Dano:

```gdscript
# No Inspector ou código:
damage_per_second = 50.0  # Dano alto
damage_timer.wait_time = 0.1  # Ticks mais rápidos = dano mais suave
```

### Ajustar Alcance:

```gdscript
max_range = 1200.0  # Raio mais longo
raycast.target_position = Vector2(max_range, 0)
```

### Ajustar Efeitos Visuais:

```gdscript
# Pulsação mais intensa:
pulse_speed = 5.0
pulse_intensity = 0.4

# Oscilação mais suave:
oscillation_speed = 2.0
oscillation_amplitude = 5.0

# Cor diferente:
beam_color = Color(1.0, 0.3, 0.3, 0.9)  # Vermelho (laser)
```

### Adicionar Som:

```gdscript
@onready var beam_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func activate() -> void:
    # ... código existente ...
    if beam_sound and beam_sound.stream:
        beam_sound.play()

func deactivate() -> void:
    # ... código existente ...
    if beam_sound:
        beam_sound.stop()
```

---

## 🐛 Troubleshooting

### ❌ "Raio não aparece"
**Solução:**
- Verificar se `activate()` foi chamado
- Verificar se `beam_segment.visible = true`
- Verificar se a textura está carregada
- Checar layer de renderização (ZIndex)

### ❌ "Raio não detecta inimigos"
**Solução:**
- Verificar `collision_mask` do RayCast2D (deve ser layer dos inimigos)
- Verificar se inimigos têm CollisionShape2D
- Verificar se inimigos estão no grupo "enemies"
- Usar `get_tree().get_nodes_in_group("enemies")` para debug

### ❌ "Comprimento errado"
**Solução:**
- Verificar `sprite_original_width` (deve ser largura real do sprite)
- Ajustar `region_rect` do Sprite2D
- Verificar se `scale.x` está sendo aplicado corretamente

### ❌ "Dano não é aplicado"
**Solução:**
- Verificar se DamageTimer está ativo (`damage_timer.start()`)
- Verificar se inimigo tem método `take_damage()`
- Adicionar prints em `_on_damage_tick()` para debug
- Verificar se `current_target` não é null

### ❌ "Mana não diminui"
**Solução:**
- Verificar se player tem propriedade `current_mana`
- Verificar se signal `mana_changed` existe
- Verificar se `consume_mana()` está sendo chamado em `_process()`

---

## 📊 Performance

### Otimizações:

```gdscript
# Reduzir frequência de update se necessário
var update_interval: float = 0.0
const UPDATE_RATE: float = 1.0 / 60.0  # 60 FPS

func _process(delta: float) -> void:
    update_interval += delta
    if update_interval < UPDATE_RATE:
        return
    update_interval = 0.0
    
    # ... resto do código ...
```

---

## ✅ Checklist de Implementação

- [ ] Script `continuous_beam.gd` criado
- [ ] Cena `continuous_beam.tscn` configurada
- [ ] Sprites criados (beam + impact)
- [ ] RayCast2D com collision_mask correto
- [ ] Integração no player.gd
- [ ] Input "cast_beam" configurado
- [ ] SpellData criado (opcional)
- [ ] Inimigos no grupo "enemies"
- [ ] Método `take_damage()` nos inimigos
- [ ] Testado em jogo

---

## 🎯 Resultado Final

Quando tudo estiver configurado:

1. **Player pressiona botão** → Raio aparece instantaneamente
2. **Move o mouse** → Raio segue suavemente
3. **Acerta inimigo** → Sprite de impacto aparece, partículas ativam
4. **Inimigo recebe dano** → 5x por segundo (ou conforme configurado)
5. **Mana diminui** → Continuamente enquanto ativo
6. **Solta botão** → Raio desaparece

---

## 📚 Recursos Adicionais

### Variações Possíveis:

**1. Ice Beam (Raio de Gelo):**
```gdscript
beam_color = Color(0.3, 0.8, 1.0)  # Azul
# Adicionar slow effect no inimigo
```

**2. Fire Beam (Raio de Fogo):**
```gdscript
beam_color = Color(1.0, 0.3, 0.0)  # Laranja
# Adicionar burn DoT
```

**3. Healing Beam (Raio de Cura):**
```gdscript
collision_mask = 6  # Layer de aliados
# Aplicar cura ao invés de dano
```

---

**Autor**: Sistema Star Dream  
**Data**: 30/10/2025  
**Versão**: 1.0  
