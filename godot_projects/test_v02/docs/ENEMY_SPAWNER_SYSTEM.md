# Sistema de Geração de Inimigos (Enemy Spawner)

## 📋 Descrição
Sistema completo de spawn automático de inimigos com dificuldade progressiva e variedade de tipos.

## ✨ Recursos

### 🎯 Spawn Inteligente
- **Posições Aleatórias**: Inimigos aparecem ao redor do player em círculo
- **Distância Configurável**: Entre 300-600 unidades (evita spawn muito perto ou muito longe)
- **Limite de Inimigos**: Máximo de inimigos simultâneos na tela
- **Intervalo Dinâmico**: Tempo entre spawns diminui com a dificuldade

### 📈 Dificuldade Progressiva
- **Aumento Automático**: A cada 30 segundos (configurável)
- **Spawn Mais Rápido**: Intervalo diminui gradualmente (mínimo 0.5s)
- **Mais Inimigos**: Limite aumenta em 2 a cada nível
- **Escalada Infinita**: Dificuldade continua aumentando

### 🐺 Variedade de Inimigos
Três tipos de lobos com características únicas:

#### 1. **Lobo Veloz** (wolf_fast.tres)
- HP: 50
- Dano: 6
- Velocidade: 120
- Alcance: 180
- **Estilo**: Rápido e agressivo

#### 2. **Lobo Cinza** (wolf_normal.tres)
- HP: 60
- Dano: 8
- Velocidade: 90
- Alcance: 250
- **Estilo**: Balanceado

#### 3. **Lobo Alfa** (wolf_tank.tres)
- HP: 120
- Dano: 15
- Velocidade: 60
- Alcance: 300
- **Estilo**: Tanque resistente

## 🎮 Configuração

### Parâmetros do Inspector

#### Spawn Básico
```gdscript
@export var spawn_enabled: bool = true  # Ativar/Desativar spawn
@export var spawn_interval: float = 3.0  # Segundos entre spawns
@export var min_spawn_distance: float = 300.0  # Distância mínima
@export var max_spawn_distance: float = 600.0  # Distância máxima
@export var max_enemies_on_screen: int = 20  # Máximo simultâneo
```

#### Dificuldade
```gdscript
@export var difficulty_increase_interval: float = 30.0  # A cada X segundos
@export var spawn_interval_decrease: float = 0.1  # Quanto diminui
@export var min_spawn_interval: float = 0.5  # Intervalo mínimo
```

#### Cenas e Dados
```gdscript
@export var enemy_scene: PackedScene  # Cena do inimigo
@export var enemy_data_list: Array[Resource] = []  # Lista de EnemyData
```

## 🔧 Uso

### 1. Adicionar à Cena
```gdscript
# Instanciar o spawner na cena principal
[node name="EnemySpawner" parent="." instance=ExtResource("spawner")]
enemy_scene = ExtResource("enemy_scene")
enemy_data_list = Array[Resource]([ExtResource("wolf1"), ExtResource("wolf2")])
```

### 2. Controlar por Script
```gdscript
# Pausar spawning
$EnemySpawner.stop_spawning()

# Resumir spawning
$EnemySpawner.resume_spawning()

# Resetar para dificuldade inicial
$EnemySpawner.reset_spawner()
```

### 3. Criar Novos Tipos de Inimigos

#### Passo 1: Criar EnemyData
```gdscript
# No editor: Create New Resource → Enemy_Data
# Configurar propriedades:
- enemy_name: "Meu Inimigo"
- max_health: 100
- damage: 15
- move_speed: 80
- sprite_frames: [seu SpriteFrames]
# etc...
```

#### Passo 2: Adicionar à Lista
No Inspector do EnemySpawner:
- Abrir `enemy_data_list`
- Add Element
- Arrastar o novo .tres

## 📊 Sistema de Ondas

### Progressão de Dificuldade
```
Nível 1 (0-30s):   Spawn: 3.0s | Max: 20 inimigos
Nível 2 (30-60s):  Spawn: 2.9s | Max: 22 inimigos
Nível 3 (60-90s):  Spawn: 2.8s | Max: 24 inimigos
...
Nível 26+:         Spawn: 0.5s | Max: 70+ inimigos (cap no intervalo)
```

## 🐛 Debug

### Mensagens de Console
```
[SPAWNER] Sistema de spawn inicializado
[SPAWNER]    Intervalo inicial: 3.0s
[SPAWNER]    Tipos de inimigos: 3

[SPAWNER] 👹 Inimigo spawnado #1: Lobo Veloz em (256.5, -189.2)
[SPAWNER]    Inimigos ativos: 1/20

[SPAWNER] 📈 DIFICULDADE AUMENTADA!
[SPAWNER]    Nível: 2
[SPAWNER]    Intervalo: 2.90s
[SPAWNER]    Máx. Inimigos: 22
```

### Verificar Estado
```gdscript
print("Dificuldade atual: ", $EnemySpawner.current_difficulty)
print("Inimigos spawnados: ", $EnemySpawner.enemies_spawned)
print("Inimigos ativos: ", $EnemySpawner.active_enemies)
```

## 💡 Dicas de Gameplay

### Balanceamento
1. **Início Fácil**: Comece com spawn_interval alto (3-5s)
2. **Progressão Suave**: Use decrease pequeno (0.05-0.15)
3. **Limite Razoável**: max_enemies entre 15-30
4. **Distância Segura**: min_spawn_distance > 250

### Variedade
1. **Mix de Tipos**: Use pelo menos 3 tipos diferentes
2. **Raridade**: Inimigos fortes podem ser menos frequentes
3. **Pesos**: (Implementação futura) Adicionar probabilidades

### Performance
1. **Limite Superior**: Não exceda 50 inimigos simultâneos
2. **Intervalo Mínimo**: Não vá abaixo de 0.3s
3. **Pool de Objetos**: (Implementação futura) Reutilizar instâncias

## 🚀 Melhorias Futuras

### Planejadas
- [ ] Sistema de Pesos/Probabilidades para cada tipo
- [ ] Spawn em Ondas (waves) com pausas
- [ ] Pontos de Spawn fixos (spawn points)
- [ ] Boss a cada X níveis
- [ ] Eventos especiais (hordas, elite spawns)
- [ ] Sistema de Object Pooling
- [ ] Spawn baseado em áreas/zonas
- [ ] Variação por tempo de jogo

### Possíveis
- [ ] Partículas de spawn
- [ ] Som ao spawnar
- [ ] Indicador visual de onde vai spawnar
- [ ] Spawn condicionado (ex: só de dia/noite)

## 📁 Arquivos Relacionados

```
scripts/game/
  └── enemy_spawner.gd          # Script principal do spawner

scenes/game/
  └── enemy_spawner.tscn        # Cena do spawner

EnemyData/
  ├── wolf_fast.tres            # Lobo veloz
  ├── wolf_normal.tres          # Lobo cinza
  └── wolf_tank.tres            # Lobo alfa

data_gd/
  └── EnemyData.gd              # Resource base
```

## 🎓 Como Funciona

### Ciclo de Spawn
1. **Timer**: Contador aumenta a cada frame (_process)
2. **Verificação**: Quando timer >= spawn_interval
3. **Limite**: Checa se não excedeu max_enemies
4. **Posição**: Calcula posição aleatória ao redor do player
5. **Tipo**: Escolhe um EnemyData aleatório da lista
6. **Instância**: Cria e adiciona inimigo à cena
7. **Reset**: Zera o timer e recomeça

### Cálculo de Posição
```gdscript
# Ângulo aleatório (círculo completo)
angle = randf() * TAU  # TAU = 2π

# Distância aleatória entre min e max
distance = randf_range(min_spawn_distance, max_spawn_distance)

# Converte para coordenadas cartesianas
offset = Vector2(cos(angle), sin(angle)) * distance

# Posição final
spawn_pos = player.global_position + offset
```

### Progressão de Dificuldade
```gdscript
# A cada difficulty_increase_interval segundos:
current_difficulty += 1

# Diminui intervalo (mais inimigos por segundo)
spawn_interval -= spawn_interval_decrease
spawn_interval = max(spawn_interval, min_spawn_interval)  # Não vai abaixo do mínimo

# Aumenta limite (mais inimigos na tela)
max_enemies_on_screen += 2
```

## ⚠️ Requisitos

### Obrigatórios
- ✅ Player deve estar no grupo "player"
- ✅ Inimigos devem estar no grupo "enemies"
- ✅ enemy_scene deve ter script que aceita enemy_data
- ✅ enemy_data_list não pode estar vazia

### Recomendados
- 📋 Pelo menos 2-3 tipos de inimigos diferentes
- 🎯 EnemyData com valores balanceados
- 🏃 Player com velocidade > 100 (para escapar)
- ⚔️ Sistema de combate funcional

## 🐛 Troubleshooting

### "Player não encontrado!"
**Solução**: Certifique-se que o player tem `add_to_group("player")`

### "Cena ou dados de inimigo não configurados!"
**Solução**: Configure enemy_scene e enemy_data_list no Inspector

### Inimigos não aparecem
**Verifique**:
1. spawn_enabled = true?
2. spawn_interval não muito alto?
3. Player está na cena?
4. min/max_spawn_distance corretos?

### Performance ruim
**Otimize**:
1. Reduza max_enemies_on_screen
2. Aumente spawn_interval
3. Simplifique sprites dos inimigos
4. Use object pooling (futuro)

---

**Versão**: 1.0  
**Criado**: 2025-10-19  
**Compatível**: Godot 4.x
