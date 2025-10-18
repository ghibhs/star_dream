# Sistema de Debug - Monitoramento Completo 🔍

## 📊 Mensagens de Debug Implementadas

### Sistema Completo de Logs

Todos os scripts agora possuem mensagens detalhadas de debug com prefixos identificáveis:
- **[PLAYER]** - Ações do jogador
- **[ENEMY]** - Ações dos inimigos
- **[PROJECTILE]** - Ações dos projéteis

### 🎮 PLAYER (entidades.gd)

#### Inicialização:
```
[PLAYER] Inicializado e adicionado ao grupo 'player'
[PLAYER] Saúde inicializada: 100.0/100.0
[PLAYER] Timer de ataque configurado: 0.50s cooldown
```

#### Recebimento de Arma:
```
[PLAYER] 🗡️ Arma recebida: Espada de Ferro
[PLAYER]    Tipo: melee
[PLAYER]    Dano: 25.0
[PLAYER] Configurando arma: Espada de Ferro
[PLAYER]    Hitbox shape: CapsuleShape2D
[PLAYER]    Layer: 16, Mask: 4
[PLAYER] ✅ Arma configurada com sucesso
```

#### Sistema de Ataque:
```
[PLAYER] Tecla de ataque pressionada
[PLAYER] Iniciando ataque...
[PLAYER] ⚔️ ATACANDO com Espada de Ferro
[PLAYER]    Tipo: melee
[PLAYER]    → Executando ataque melee
[PLAYER] 🗡️ Executando ataque melee...
[PLAYER]    Direção: DIREITA (mouse_x: 45.3)
[PLAYER]    ✅ Animação: attack_right
[PLAYER]    Hitbox ATIVADA (monitoring = true)
[PLAYER]    Cooldown iniciado: 0.50s
```

#### Colisão de Ataque (Melee):
```
[PLAYER] 💥 Hitbox colidiu com: Goblin
[PLAYER]    Grupos: ["enemies"]
[PLAYER]    ✅ É um inimigo! Aplicando dano...
[PLAYER] 💥 Causando 25.0 de dano em Goblin
[PLAYER]    ✅ Dano aplicado com sucesso
[PLAYER]    Hitbox DESATIVADA (monitoring = false)
[PLAYER]    Voltando para animação: idle
```

#### Ataque Ranged:
```
[PLAYER]    → Disparando projétil
[PLAYER] 🏹 Disparando projétil...
[PLAYER]    Spawn position: (150.0, 200.0)
[PLAYER]    Projétil adicionado à cena
[PLAYER]    Direção: (0.707, -0.707)
[PLAYER]    ✅ Projétil configurado e disparado
```

#### Recebimento de Dano:
```
[PLAYER] 💔 DANO RECEBIDO: 10.0
[PLAYER]    HP atual: 90.0/100.0 (90.0%)
[PLAYER]    🔴 Aplicando flash vermelho
[PLAYER]    ✅ Flash terminado
```

#### Cooldown:
```
[PLAYER] ⏱️ Cooldown terminado, can_attack = true
```

#### Morte:
```
[PLAYER] ☠️ HP chegou a 0, iniciando morte...
[PLAYER] ☠️☠️☠️ PLAYER MORREU! ☠️☠️☠️
[PLAYER]    Physics desativado
```

---

### 👾 ENEMY (enemy.gd)

#### Inicialização:
```
[ENEMY] Inicializado e adicionado ao grupo 'enemies'
[ENEMY] Carregando dados: Goblin Básico
[ENEMY] ⚙️ Configurando inimigo...
[ENEMY]    HP: 50.0/50.0
[ENEMY]    Dano: 10.0 | Defesa: 2.0
[ENEMY]    Velocidade: 80.0
[ENEMY]    Chase Range: 200.0 | Attack Range: 30.0
[ENEMY]    Sprite configurado (scale: (2.0, 2.0))
[ENEMY]    CollisionShape configurado
[ENEMY]    Hitbox configurada (Layer: 8, Mask: 2)
[ENEMY]    DetectionArea configurada (radius: 200.0)
[ENEMY]    AttackTimer configurado (cooldown: 1.50s)
[ENEMY]    HitFlashTimer configurado (duração: 0.15s)
[ENEMY] ✅ Configuração completa! Estado inicial: IDLE
```

#### Sistema de Detecção:
```
[ENEMY] 👁️ DetectionArea detectou: Player
[ENEMY]    Grupos: ["player"]
[ENEMY]    Behavior: Aggressive
[ENEMY]    ✅ É o player e sou agressivo! Definindo como alvo...
[ENEMY]    Estado: IDLE → CHASE
```

#### Mudanças de Estado:
```
[ENEMY] Estado: CHASE → ATTACK (distância: 25.5)
[ENEMY] ⚔️ ATACANDO! (can_attack = false)
[ENEMY]    Animação 'attack' tocando
[ENEMY]    Cooldown iniciado (1.50s)
```

#### Aplicação de Dano ao Player:
```
[ENEMY] 💥 Hitbox colidiu com: Player
[ENEMY]    Grupos: ["player"]
[ENEMY]    can_attack: true
[ENEMY]    ✅ É o player e pode atacar!
[ENEMY]    💥 Causando 10.0 de dano no player!
[ENEMY]    ✅ Dano aplicado com sucesso
```

#### Recebimento de Dano:
```
[ENEMY] 💔 Goblin Básico RECEBEU DANO!
[ENEMY]    Dano bruto: 25.0 | Defesa: 2.0 | Dano real: 23.0
[ENEMY]    HP atual: 27.0/50.0 (54.0%)
[ENEMY]    🔴 Aplicando flash vermelho
[ENEMY] Estado: CHASE → HURT
[ENEMY]    ✅ Flash terminado
[ENEMY] Estado: HURT → CHASE (flash terminado)
```

#### Morte:
```
[ENEMY] ☠️ HP chegou a 0, iniciando morte...
[ENEMY] ☠️☠️☠️ Goblin Básico MORREU! ☠️☠️☠️
[ENEMY]    Exp drop: 15 | Coins drop: 5
[ENEMY]    Animação de morte tocando...
[ENEMY]    Animação de morte terminada
[ENEMY] 💰 Dropando recompensas: 15 exp e 5 moedas
[ENEMY]    Removendo da cena (queue_free)
```

#### Perda de Alvo:
```
[ENEMY] 👁️ DetectionArea saiu: Player
[ENEMY]    Era meu alvo! Perdendo alvo e voltando para IDLE
[ENEMY] Estado: CHASE → IDLE (alvo perdido)
```

---

### 🏹 PROJECTILE (projectile.gd)

#### Criação:
```
[PROJECTILE] Inicializado
[PROJECTILE] Configurando projétil...
[PROJECTILE]    Arma: Arco Longo
[PROJECTILE]    Direção: (0.707, -0.707)
[PROJECTILE]    Sprite configurado (animação: arrow)
[PROJECTILE]    CollisionShape configurado
[PROJECTILE]    Velocidade: 300.0 | Dano: 15.0 | Pierce: false
[PROJECTILE]    ✅ Configuração completa!
```

#### Colisão com Inimigo:
```
[PROJECTILE] 💥 Colidiu com: Goblin
[PROJECTILE]    Grupos: ["enemies"]
[PROJECTILE]    ✅ É um inimigo!
[PROJECTILE]    💥 Causando 15.0 de dano
[PROJECTILE]    ✅ Dano aplicado
[PROJECTILE]    🗑️ Projétil sem pierce, destruindo...
```

#### Colisão com Parede:
```
[PROJECTILE] 💥 Colidiu com: Wall
[PROJECTILE]    Grupos: ["walls"]
[PROJECTILE]    🧱 Colidiu com parede
[PROJECTILE]    🗑️ Destruindo projétil...
```

---

## 🔍 Como Usar o Sistema de Debug

### 1. Executar o Jogo
No Godot, pressione **F5** ou clique em **Play** e abra a janela de **Output** (Console).

### 2. Filtrar Mensagens
Use Ctrl+F no console para buscar por:
- `[PLAYER]` - Ver apenas ações do player
- `[ENEMY]` - Ver apenas ações dos inimigos
- `[PROJECTILE]` - Ver apenas ações dos projéteis
- `💥` - Ver apenas colisões
- `☠️` - Ver apenas mortes
- `⚠️` - Ver apenas warnings/erros

### 3. Monitorar Fluxo de Combate

**Exemplo de combate completo no console:**
```
[PLAYER] Tecla de ataque pressionada
[PLAYER] ⚔️ ATACANDO com Espada de Ferro
[PLAYER]    Hitbox ATIVADA
[PLAYER] 💥 Hitbox colidiu com: Goblin
[PLAYER]    ✅ É um inimigo! Aplicando dano...
[PLAYER] 💥 Causando 25.0 de dano em Goblin
[ENEMY] 💔 Goblin Básico RECEBEU DANO!
[ENEMY]    Dano real: 23.0
[ENEMY]    HP atual: 27.0/50.0
[ENEMY] Estado: CHASE → HURT
[ENEMY] 💥 Hitbox colidiu com: Player
[ENEMY]    💥 Causando 10.0 de dano no player!
[PLAYER] 💔 DANO RECEBIDO: 10.0
[PLAYER]    HP atual: 90.0/100.0
```

---

## 🐛 Debug de Problemas Comuns

### ❌ Player não causa dano em inimigos

**O que procurar no console:**
```
[PLAYER] 💥 Hitbox colidiu com: Goblin
[PLAYER]    ⚠️ Não é um inimigo, ignorando
```
**Causa:** Inimigo não está no grupo "enemies"  
**Solução:** Verificar `enemy._ready()` e confirmar `add_to_group("enemies")`

---

### ❌ Inimigo não causa dano no player

**O que procurar no console:**
```
[ENEMY] 💥 Hitbox colidiu com: Player
[ENEMY]    ⚠️ Não é o player
```
**Causa:** Player não está no grupo "player"  
**Solução:** Verificar `entidades._ready()` e confirmar `add_to_group("player")`

**OU:**
```
[ENEMY] 💥 Hitbox colidiu com: Player
[ENEMY]    ⚠️ Ainda em cooldown
```
**Causa:** Tentando atacar durante cooldown  
**Solução:** Normal, aguardar timer

---

### ❌ Projétil não acerta inimigos

**O que procurar no console:**
```
[PROJECTILE] 💥 Colidiu com: Goblin
[PROJECTILE]    ⚠️ Inimigo não tem método take_damage()
```
**Causa:** Script do inimigo não tem método `take_damage()`  
**Solução:** Usar script enemy.gd fornecido

---

### ❌ Ataque não acontece

**O que procurar no console:**
```
[PLAYER] ⚠️ Ataque bloqueado: can_attack = false
```
**Causa:** Ainda em cooldown  
**Solução:** Aguardar timer

**OU:**
```
[PLAYER] ⚠️ Tentou atacar sem arma equipada
```
**Causa:** Nenhuma arma equipada  
**Solução:** Chamar `receive_weapon_data()` com um .tres

---

## 📈 Estatísticas Visíveis

O sistema de debug mostra:
- ✅ HP atual e percentual
- ✅ Dano bruto vs dano real (com defesa)
- ✅ Estados da IA (IDLE, CHASE, ATTACK, HURT, DEAD)
- ✅ Distâncias de detecção e ataque
- ✅ Cooldowns de ataque
- ✅ Direção e velocidade de projéteis
- ✅ Grupos de cada entidade
- ✅ Drops de recompensas

---

## 🎯 Emojis Usados para Identificação Rápida

| Emoji | Significado |
|-------|-------------|
| 🗡️ | Arma recebida/equipada |
| ⚔️ | Ataque iniciado |
| 💥 | Colisão detectada |
| 💔 | Dano recebido |
| 🔴 | Flash de dano visual |
| ☠️ | Morte |
| 👁️ | Detecção (área de chase) |
| 🏹 | Projétil disparado |
| 💰 | Recompensas dropadas |
| ⏱️ | Cooldown terminado |
| ✅ | Operação bem-sucedida |
| ⚠️ | Aviso/bloqueio |
| 🗑️ | Objeto destruído |
| ⚙️ | Configuração |

---

## 💡 Dicas de Uso

1. **Deixe o console aberto** durante testes para ver tudo em tempo real

2. **Use filtros** para focar em sistemas específicos

3. **Grave o log** para análise posterior (Edit → Copy Output)

4. **Compare valores** - HP, dano, cooldowns aparecem em números exatos

5. **Trace fluxos** - Siga uma ação do início ao fim:
   ```
   Pressionar ataque → Hitbox ativa → Colisão → Dano aplicado → 
   Inimigo hurt → Flash → Volta a chase
   ```

6. **Identifique delays** - Se algo não acontece, veja se há mensagem de bloqueio

---

**Sistema de debug 100% implementado!** 🎉

Todos os eventos importantes agora são logados com informações detalhadas.
