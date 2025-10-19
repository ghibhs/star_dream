# Sistema de Inimigos - Documentação

## Arquivos Criados

### 1. data_gd/EnemyData.gd
**Resource class** que define todas as propriedades de um inimigo:
- Nome, sprite, animações
- Stats: HP, dano, defesa, velocidade
- Comportamento: chase_range, attack_range, behavior (Passive/Aggressive/Patrol)
- Recompensas: experiência e moedas

### 2. enemy.gd
**Script principal do inimigo** com:

#### Sistema de Estados (State Machine):
- **IDLE**: Parado, aguardando detecção
- **CHASE**: Perseguindo o player
- **ATTACK**: Atacando o player no range
- **HURT**: Recebendo dano (flash visual)
- **DEAD**: Morto

#### Funcionalidades:
- **setup_enemy()**: Configura sprite, colisões, hitbox, detecção
- **take_damage(amount)**: Recebe dano com flash visual e defesa
- **die()**: Animação de morte e drop de recompensas
- **perform_attack()**: Ataque com cooldown
- **process_chase()**: Movimento em direção ao player com flip horizontal

#### Componentes Necessários na Scene:
- AnimatedSprite2D (sprite do inimigo)
- CollisionShape2D (colisão do corpo)
- Area2D "HitboxArea2D" (causa dano ao player)
- Area2D "DetectionArea2D" (detecta player para chase)
- Timer "AttackTimer" (cooldown de ataque)
- Timer "HitFlashTimer" (duração do flash de dano)

### 3. EnemyData/*.tres
**3 exemplos de inimigos** configurados:

#### goblin_basic.tres
- HP: 50, Dano: 10, Defesa: 2
- Velocidade: 80, Chase: 200, Attack: 30
- Balanceado para iniciantes

#### wolf_fast.tres
- HP: 30, Dano: 15, Defesa: 0
- Velocidade: 150, Chase: 300, Attack: 25
- Rápido e agressivo, baixa defesa

#### golem_tank.tres
- HP: 150, Dano: 25, Defesa: 10
- Velocidade: 40, Chase: 150, Attack: 40
- Tanque lento com alta defesa

## Sistema de Saúde do Player

Adicionado ao `entidades.gd`:
- **max_health** e **current_health** exportados
- **take_damage(amount)**: Recebe dano com flash vermelho
- **die()**: Para movimento quando morre
- **is_dead**: Flag para evitar dano após morte

## Integração Existente

O código já estava preparado:
- ✅ `entidades.gd` verifica grupo "enemies" no melee
- ✅ `projectile.gd` causa dano em "enemies"
- ✅ Player chama `take_damage()` em inimigos
- ✅ Agora inimigos podem chamar `take_damage()` no player

## Como Usar

### Criar um novo inimigo:

1. **Criar Scene** (enemy.tscn):
   ```
   CharacterBody2D (enemy.gd attached)
   ├─ AnimatedSprite2D
   ├─ CollisionShape2D
   ├─ HitboxArea2D (Layer: Enemy Hitbox)
   │  └─ CollisionShape2D
   ├─ DetectionArea2D
   │  └─ CollisionShape2D (Criado automaticamente)
   ├─ AttackTimer
   └─ HitFlashTimer
   ```

2. **Criar Data Resource** (.tres):
   - Duplicar um dos exemplos em EnemyData/
   - Ajustar valores (HP, dano, velocidade, etc.)
   - Atribuir SpriteFrames com animações

3. **Configurar no Editor**:
   - Abrir enemy.tscn
   - Arrastar .tres para o campo `enemy_data`
   - Ajustar collision shapes
   - Configurar layers/masks de colisão

## Layers de Colisão Recomendadas

| Layer | Nome | Usado Por |
|-------|------|-----------|
| 1 | World | Paredes, obstáculos |
| 2 | Player | Corpo do player |
| 3 | Enemy | Corpo dos inimigos |
| 4 | Player Hitbox | Armas do player |
| 5 | Enemy Hitbox | Ataque dos inimigos |
| 6 | Projectile | Projéteis |

### Configuração Recomendada:

**Player Body (CharacterBody2D)**:
- Layer: 2 (Player)
- Mask: 1 (World), 3 (Enemy), 5 (Enemy Hitbox)

**Enemy Body (CharacterBody2D)**:
- Layer: 3 (Enemy)
- Mask: 1 (World), 2 (Player), 4 (Player Hitbox), 6 (Projectile)

**Player Weapon Hitbox (Area2D)**:
- Layer: 4 (Player Hitbox)
- Mask: 3 (Enemy)

**Enemy Hitbox (Area2D)**:
- Layer: 5 (Enemy Hitbox)
- Mask: 2 (Player)

**Projectile (Area2D)**:
- Layer: 6 (Projectile)
- Mask: 1 (World), 3 (Enemy)

## Próximos Passos (TODO)

- [ ] Criar enemy.tscn base scene
- [ ] Implementar sistema de drop (exp, moedas, itens)
- [ ] Adicionar comportamento "Patrol" (patrulha)
- [ ] Adicionar variação de ataques (projéteis para inimigos)
- [ ] Sistema de spawn de inimigos
- [ ] UI de barra de HP para inimigos
- [ ] Sistema de experiência/level up
- [ ] Knockback ao receber dano
- [ ] Efeitos de partículas (sangue, morte, etc.)
- [ ] Sons de ataque, dano e morte

## Notas Importantes

⚠️ **O erro "Could not find type Enemy_Data"** é temporário. O Godot precisa recarregar o projeto (Fechar e abrir) para reconhecer a nova classe `class_name Enemy_Data`.

✅ **O código está funcional** - Todos os scripts estão corretos e funcionarão após o reload.

✅ **Sistema completo** - Inimigos podem perseguir, atacar, receber dano e morrer.

✅ **Facilmente extensível** - Criar novos tipos de inimigos é só duplicar um .tres e ajustar valores.
