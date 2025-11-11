# Configuração de Áreas de Impacto

## ✨ Sistema Implementado

### 🔥 Bola de Fogo (Projectile)
**Comportamento**: Área de impacto única quando acerta um inimigo

**Configuração** (`fireball.tres`):
```
create_impact_area = true
impact_area_radius = 80.0      # Explosão grande (80px)
impact_area_damage = 20.0      # Dano adicional à explosão
impact_area_duration = 0.6     # Explosão visível por 0.6s
```

**Resultado no Jogo**:
1. Bola de fogo viaja até acertar inimigo
2. **30 de dano direto** no inimigo atingido
3. 💥 **Explosão de 80px** é criada no ponto de impacto
4. **20 de dano em área** para todos os inimigos próximos
5. ⏱️ Explosão dura 0.6s e desaparece

---

### ❄️ Raio Gélido (Beam)
**Comportamento**: Áreas de impacto contínuas ao longo do raio enquanto ativo

**Configuração** (`ice_beam.tres`):
```
create_impact_area = true
impact_area_radius = 40.0      # Áreas menores (40px)
impact_area_damage = 8.0       # Dano menor por área
impact_area_duration = 0.4     # Áreas temporárias (0.4s)
```

**Resultado no Jogo**:
1. Raio contínuo segue o mouse
2. **25 dps** contínuo para inimigos no raio principal
3. ❄️ **Áreas de 40px são criadas** ao longo do raio a cada 0.15s
4. **8 de dano** por área criada (inimigos próximos são atingidos)
5. **Slow 50%** aplicado continuamente
6. ⏱️ Cada área dura 0.4s antes de sumir

**Frequência**: Nova área a cada 0.15s enquanto o raio está ativo

---

## 🎯 Diferença Entre os Dois Sistemas

### Bola de Fogo (Impacto Único)
- ✅ Uma área criada por projétil
- ✅ No momento exato do impacto
- ✅ Ideal para burst damage em grupo
- ✅ Alta área (80px), alto dano (20)

### Raio Gélido (Impacto Contínuo)
- ✅ Múltiplas áreas ao longo do raio
- ✅ Criadas continuamente enquanto ativo (0.15s interval)
- ✅ Ideal para zona de controle
- ✅ Área menor (40px), dano menor (8), mas frequente

---

## 🔧 Como Funciona Tecnicamente

### Projétil (spell_projectile.gd)
```gdscript
func _on_body_entered(body: Node2D):
    # Aplica dano direto
    body.take_damage(damage, false)
    
    # Se configurado, cria área de impacto
    if spell_data.create_impact_area:
        create_impact_area_effect()  # UMA VEZ no impacto
```

### Beam (spell_beam.gd)
```gdscript
func _process(delta: float):
    # Atualiza raio, aplica dano contínuo...
    
    # Se configurado, cria áreas continuamente
    if spell_data.create_impact_area:
        impact_area_spawn_timer += delta
        if impact_area_spawn_timer >= 0.15:  # A cada 0.15s
            create_continuous_impact_areas(beam_length)
            impact_area_spawn_timer = 0.0
```

**Área ao longo do raio**: Calcula posições distribuídas e cria múltiplas áreas

---

## 🎨 Visual (Quando Configurado)

### Bola de Fogo
```
    🔥 → → → 💥
    (viaja)  (explosão única)
             ⭕ área 80px
```

### Raio Gélido
```
    ❄️━━━━━━━━━━━━━→
    ⭕  ⭕  ⭕  ⭕  ⭕  (áreas contínuas 40px)
    (criadas a cada 0.15s ao longo do raio)
```

---

## 🎮 Para Testar

### Teste 1: Bola de Fogo em Grupo
1. Agrupe 3-5 inimigos bem próximos
2. Lance bola de fogo no centro
3. Observe:
   - Inimigo atingido: 30 (direto) + 20 (área) = **50 de dano total**
   - Inimigos próximos: 20 (apenas área) = **20 de dano**
   - Explosão visível por 0.6s

### Teste 2: Raio Gélido em Corredor
1. Posicione vários inimigos em linha
2. Segure raio sobre eles por 2-3 segundos
3. Observe:
   - Dano do raio principal: 25 dps
   - Áreas criadas constantemente
   - Inimigos recebem dano adicional das áreas (8 dmg cada)
   - Slow aplicado continuamente

---

## ⚙️ Configurações Recomendadas

### Para Outros Projectiles

**Raio Arcano** (alto dano único):
```
create_impact_area = false  # Sem área
damage = 50.0              # Dano concentrado
```

**Shard de Gelo** (controle leve):
```
create_impact_area = true
impact_area_radius = 50.0   # Área média
impact_area_damage = 10.0   # Dano moderado
impact_area_duration = 0.5
```

### Para Outros Beams

**Raio Elétrico** (chain damage):
```
create_impact_area = true
impact_area_radius = 60.0   # Área maior para chain
impact_area_damage = 12.0
impact_area_duration = 0.3  # Curto para efeito rápido
```

---

## 📊 Dano Total Calculado

### Bola de Fogo
- **Dano direto**: 30
- **Dano de área**: 20
- **Dano total (alvo principal)**: 50
- **Dano total (alvos secundários)**: 20

### Raio Gélido (3 segundos ativo)
- **Dano do raio**: 25 dps × 3s = 75
- **Áreas criadas**: 3s ÷ 0.15s = ~20 áreas
- **Dano das áreas**: 8 × quantidade que acerta = variável
- **Dano total estimado**: 75-150 (depende do posicionamento)

---

✅ **Ambos os sistemas estão configurados e prontos para testar!**
