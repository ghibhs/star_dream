# Sistema de Área de Impacto para Projéteis

## 📋 Visão Geral

O sistema de área de impacto permite que projéteis criem uma zona de dano quando acertam um inimigo. Isso é perfeito para:
- **Explosões** de bola de fogo
- **Ondas de choque** de raios
- **Estilhaços** de gelo
- Qualquer efeito de área (AoE) no impacto

## 🎯 Como Funciona

Quando um projétil com `create_impact_area = true` acerta um inimigo:

1. **Dano direto**: O inimigo atingido recebe o dano do projétil
2. **Área criada**: Uma área de efeito é criada no ponto de impacto
3. **Dano em área**: Todos os inimigos dentro do raio recebem dano adicional
4. **Sprite visual**: Um sprite animado mostra a área de efeito
5. **Auto-destruição**: A área desaparece após a duração configurada

## ⚙️ Configuração no SpellData

### Propriedades Novas (Impact Area Effect)

```gdscript
# Ativar sistema
create_impact_area: bool = false  # true para ativar

# Visual
impact_area_sprite_frames: SpriteFrames  # Sprite da explosão/área
impact_area_animation: String = "default"  # Nome da animação

# Mecânicas
impact_area_radius: float = 50.0      # Raio em pixels
impact_area_damage: float = 10.0      # Dano da área
impact_area_duration: float = 0.5     # Duração em segundos
```

### Exemplo: Bola de Fogo Explosiva

No arquivo `fireball.tres` (ou via editor):

```
[Impact Area Effect]
create_impact_area = true
impact_area_sprite_frames = <sprite da explosão>
impact_area_animation = "explode"
impact_area_radius = 80.0
impact_area_damage = 15.0
impact_area_duration = 0.6
```

**Resultado:**
- Bola de fogo causa **20 de dano** (dano base do projétil)
- Cria explosão de **80px de raio**
- Inimigos próximos recebem **15 de dano** adicional
- Explosão dura **0.6 segundos** antes de sumir

## 🎨 Criando Sprites de Área

### Passo 1: Preparar Arte

Crie uma spritesheet de explosão/impacto. Exemplo:

```
explosion_sheet.png
- 64x64 pixels por frame
- 8 frames de animação
- Layout horizontal (512x64 total)
```

### Passo 2: Criar SpriteFrames

No Godot:
1. Crie um novo recurso `SpriteFrames` (ex: `explosion_spriteframes.tres`)
2. Adicione sua spritesheet
3. Configure os frames (ex: 8 frames a 12 FPS)
4. Nomeie a animação (ex: "explode")

### Passo 3: Linkar ao Spell

No seu SpellData:
1. Em **Impact Area Effect**, ative `create_impact_area`
2. Arraste o `explosion_spriteframes.tres` para `impact_area_sprite_frames`
3. Digite "explode" em `impact_area_animation`
4. Configure raio, dano e duração

## 📊 Exemplo Completo: Três Magias

### 1. Bola de Fogo (Explosão Grande)

```
Spell Properties:
- damage = 25.0 (dano direto)
- projectile_speed = 400.0

Impact Area:
- create_impact_area = true
- impact_area_radius = 100.0 (explosão grande)
- impact_area_damage = 20.0 (dano significativo)
- impact_area_duration = 0.8
- sprite: explosão de fogo (vermelho/laranja)
```

**Uso:** Alta área de efeito, ideal para grupos de inimigos

---

### 2. Shard de Gelo (Estilhaços)

```
Spell Properties:
- damage = 15.0 (dano direto)
- projectile_speed = 500.0

Impact Area:
- create_impact_area = true
- impact_area_radius = 50.0 (área pequena)
- impact_area_damage = 8.0 (dano menor)
- impact_area_duration = 0.4
- sprite: estilhaços de gelo (azul claro)
```

**Uso:** Área menor, ideal para controle de pequenos grupos

---

### 3. Raio Arcano (Sem Área)

```
Spell Properties:
- damage = 30.0 (dano direto alto)
- projectile_speed = 600.0

Impact Area:
- create_impact_area = false (SEM área de efeito)
```

**Uso:** Foco em dano único, sem área

## 🔧 Detalhes Técnicos

### Estrutura de Classes

```
spell_projectile.gd (Projétil)
    ├── Colisão com inimigo
    ├── Aplica dano direto
    └── create_impact_area_effect()
            ↓
spell_impact_area.gd (Área de Efeito)
    ├── Area2D com raio configurável
    ├── Sprite animado
    ├── Detecta inimigos dentro
    ├── Aplica dano em área (uma vez por inimigo)
    └── Auto-destrói após duração
```

### Prevenção de Dano Duplicado

O sistema garante que cada inimigo:
1. **Recebe dano direto** do projétil (uma vez)
2. **Recebe dano da área** (uma vez, se estiver no raio)
3. **Nunca recebe dano duplo** da mesma área

Implementado via:
```gdscript
var affected_enemies: Array = []  # Lista de inimigos já atingidos

if affected_enemies.has(body):
    return  # Ignora se já foi atingido
```

### Performance

- **Leve:** Apenas cria área quando projétil acerta
- **Otimizado:** Usa collision_mask para detectar apenas inimigos (layer 4)
- **Auto-limpeza:** Timer garante destruição após duração

## 🎮 Testando

### Teste Básico

1. Configure uma magia com `create_impact_area = true`
2. Lance contra um inimigo isolado
3. Verifique no console:
   ```
   [PROJECTILE] 💥 Atingiu: Enemy1
   [PROJECTILE]    💥 Área de impacto criada
   [IMPACT_AREA] 💥 Área de impacto criada - Raio: 80, Dano: 15
   [IMPACT_AREA]    💥 Atingiu inimigo: Enemy1
   [IMPACT_AREA]    ⚔️ Dano aplicado: 15
   ```

### Teste de Múltiplos Inimigos

1. Agrupe 3-5 inimigos próximos
2. Lance a magia no centro
3. Observe: 
   - Inimigo atingido recebe **dano direto + dano de área**
   - Inimigos próximos recebem **apenas dano de área**

### Verificação Visual

- ✅ Sprite de explosão aparece no local do impacto
- ✅ Sprite está centralizado no ponto de colisão
- ✅ Animação reproduz completamente
- ✅ Área desaparece após duração

## 🐛 Debug

### Ativar Logs Detalhados

Os logs estão sempre ativos. Procure por:
- `[PROJECTILE]` - Eventos do projétil
- `[IMPACT_AREA]` - Eventos da área

### Problemas Comuns

**❌ Área não aparece:**
- Verifique se `create_impact_area = true`
- Confirme que `impact_area_sprite_frames` está configurado

**❌ Sem dano em área:**
- Verifique `impact_area_damage` > 0
- Confirme que inimigos estão no layer 4 (collision_mask)

**❌ Área permanece para sempre:**
- Verifique `impact_area_duration` > 0
- Cheque se não há erros no console (timer pode ter falhado)

**❌ Sprite não anima:**
- Confirme que `impact_area_animation` corresponde ao nome no SpriteFrames
- Verifique se o SpriteFrames tem frames configurados

## 📈 Balanceamento

### Recomendações

**Dano de Área vs. Dano Direto:**
- Área: 50-75% do dano direto
- Exemplo: Projétil 20 dmg → Área 10-15 dmg

**Raio vs. Dano:**
- Raio maior = dano menor
- Raio menor = dano maior
- Exemplo: 
  - 100px raio = 10 dmg
  - 50px raio = 15 dmg

**Duração:**
- Visual puro: 0.3-0.5s (tempo da animação)
- Com gameplay: 0.5-1.0s (permite reação do jogador)

## 🚀 Próximos Passos

Para expandir o sistema, você pode adicionar:

1. **Status Effects na Área:**
   - Slow em área
   - Burn/DOT em área
   - Stun em área

2. **Efeitos Visuais:**
   - Partículas de impacto
   - Screen shake na explosão
   - Flash de luz

3. **Variações:**
   - Área que empurra inimigos (knockback)
   - Área que cura aliados
   - Área que aplica buffs/debuffs

## 📝 Resumo Rápido

```gdscript
# No SpellData (.tres):
create_impact_area = true
impact_area_sprite_frames = <seu_sprite>
impact_area_animation = "default"
impact_area_radius = 80.0
impact_area_damage = 15.0
impact_area_duration = 0.5

# Automaticamente ao acertar inimigo:
# 1. Dano direto aplicado
# 2. Área criada no ponto de impacto
# 3. Inimigos no raio recebem dano adicional
# 4. Área desaparece após duração
```

---

✨ **Sistema implementado e pronto para usar!**
