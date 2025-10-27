# 🔮 Sistema de Seleção de Magias - Guia de Configuração

## 📋 Visão Geral

Sistema completo de seleção e lançamento de magias com:
- ✅ Barra visual de seleção abaixo da barra de mana
- ✅ Navegação com Q (anterior) e E (próximo)
- ✅ Lançamento com botão direito do mouse
- ✅ Sistema de mana integrado
- ✅ 3 magias de exemplo (Fireball, Ice Bolt, Heal)

---

## 🎯 Arquivos Criados/Modificados

### **Criados:**
1. `scripts/ui/spell_selector_ui.gd` - UI de seleção de magias
2. `docs/SPELL_SELECTOR_SETUP.md` - Este guia

### **Modificados:**
1. `scripts/player/player.gd` - Integração com sistema de magias
   - Adicionadas variáveis do sistema de magias
   - Funções de seleção e lançamento
   - Inputs Q, E e botão direito

---

## ⚙️ Configuração no Godot

### **Passo 1: Configurar Inputs no Project Settings**

Abra: **Project → Project Settings → Input Map**

Adicione os seguintes inputs:

#### 1️⃣ **spell_previous** (Magia Anterior - Tecla Q)
- Clique em **Add New Action**
- Nome: `spell_previous`
- Clique no **+** → **Key** → Pressione **Q**
- ✅ Confirme

#### 2️⃣ **spell_next** (Próxima Magia - Tecla E)
- Clique em **Add New Action**
- Nome: `spell_next`
- Clique no **+** → **Key** → Pressione **E**
- ✅ Confirme

#### 3️⃣ **cast_spell** (Lançar Magia - Botão Direito)
- Clique em **Add New Action**
- Nome: `cast_spell`
- Clique no **+** → **Mouse Button** → Selecione **Right Button (Mouse 2)**
- ✅ Confirme

---

### **Passo 2: Adicionar SpellSelectorUI à Cena do Player**

1. **Abra a cena:** `scenes/player/player.tscn`

2. **Adicione o nó SpellSelectorUI:**
   - Clique com botão direito no nó `Player`
   - **Add Child Node** → Busque por `CanvasLayer`
   - Renomeie para `SpellSelectorCanvasLayer`

3. **Dentro do CanvasLayer:**
   - **Add Child Node** → Busque por `HBoxContainer`
   - Renomeie para `SpellSelectorUI`

4. **Configure o SpellSelectorUI:**
   - Selecione o nó `SpellSelectorUI`
   - No **Inspector**, clique em **Attach Script**
   - Navegue para: `res://scripts/ui/spell_selector_ui.gd`
   - **Load** o script

5. **Posicione o UI:**
   - Selecione `SpellSelectorUI`
   - No **Inspector → Layout**:
     - **Anchors Preset**: Bottom Left
     - **Position**: X = 10, Y = -70 (abaixo da barra de mana)
   - **Size**: O script ajusta automaticamente

6. **Configure propriedades (opcional):**
   ```
   Slot Size: 48x48
   Slot Spacing: 8
   Max Visible Slots: 5
   ```

---

### **Passo 3: Verificar Estrutura da Cena**

A hierarquia deve ficar assim:

```
Player (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D
├── ...
├── SpellSelectorCanvasLayer (CanvasLayer)
│   └── SpellSelectorUI (HBoxContainer) [spell_selector_ui.gd]
└── ...
```

---

## 🎮 Como Usar

### **Controles:**

| Tecla/Botão | Ação |
|-------------|------|
| **Q** | Seleciona magia anterior |
| **E** | Seleciona próxima magia |
| **Botão Direito** | Lança magia selecionada |

### **Indicadores Visuais:**

- 🟡 **Borda Amarela Grossa** = Magia selecionada
- 🔵 **Cor do Ícone** = Tipo de magia:
  - 🟠 Laranja = Projétil (Fireball, Ice Bolt)
  - 🟢 Verde = Cura (Heal)
  - 🔵 Azul = Área
  - 🟣 Roxo = Buff

---

## 🔧 Magias Disponíveis

### 1️⃣ **Fireball** 🔥
- **Tipo**: Projétil
- **Custo**: 20 mana
- **Dano**: 30
- **Velocidade**: 400
- **Arquivo**: `resources/spells/fireball.tres`

### 2️⃣ **Ice Bolt** ❄️
- **Tipo**: Projétil
- **Custo**: 15 mana
- **Dano**: 20
- **Velocidade**: 500
- **Arquivo**: `resources/spells/ice_bolt.tres`

### 3️⃣ **Heal** 💚
- **Tipo**: Cura
- **Custo**: 25 mana
- **Cura**: 50 HP
- **Arquivo**: `resources/spells/heal.tres`

---

## 📊 Sistema de Mana

- **Mana Máxima**: 100
- **Regeneração**: 5 mana/segundo
- **Automática**: Sim

**Barra de Mana** já existente no canto superior direito mostra:
- Mana atual / Mana máxima
- Cor azul

---

## 🎨 Personalização

### **Modificar Cores dos Slots:**

Em `spell_selector_ui.gd`:

```gdscript
var selected_color: Color = Color(1.0, 1.0, 0.0, 1.0)  # Amarelo
var normal_color: Color = Color(0.8, 0.8, 0.8, 1.0)    # Cinza claro
var locked_color: Color = Color(0.3, 0.3, 0.3, 1.0)     # Cinza escuro
```

### **Modificar Tamanho dos Slots:**

```gdscript
@export var slot_size: Vector2 = Vector2(48, 48)  # Largura x Altura
@export var slot_spacing: int = 8                  # Espaço entre slots
@export var max_visible_slots: int = 5            # Quantos aparecem
```

### **Adicionar Novas Magias:**

1. **Crie um novo arquivo `.tres`** em `resources/spells/`
2. **Configure as propriedades** (veja `SpellData.gd`)
3. **Adicione ao player** em `load_available_spells()`:

```gdscript
var nova_magia = load("res://resources/spells/nova_magia.tres")
if nova_magia:
    available_spells.append(nova_magia)
```

---

## 🐛 Troubleshooting

### **Problema: UI não aparece**
✅ **Solução:**
- Verifique se `SpellSelectorUI` é filho de um `CanvasLayer`
- Confirme que o script está anexado ao nó correto
- Veja se as magias foram carregadas (console mostra "📚 Total de magias carregadas: 3")

### **Problema: Teclas Q/E não funcionam**
✅ **Solução:**
- Verifique **Project Settings → Input Map**
- Certifique-se que `spell_previous` e `spell_next` estão configurados
- Teste no jogo pressionando as teclas

### **Problema: Botão direito não lança magia**
✅ **Solução:**
- Verifique input `cast_spell` no Input Map
- Confirme que está configurado como **Mouse Button → Right Button**

### **Problema: "Mana insuficiente"**
✅ **Solução:**
- Aguarde a regeneração de mana (5/segundo)
- Verifique se a magia tem custo muito alto
- Aumente `max_mana` no player (Inspector)

---

## 📝 Logs de Debug

O sistema imprime logs detalhados no console:

```
[PLAYER] 🔮 ═══ INICIANDO SISTEMA DE MAGIAS ═══
[PLAYER]    🔥 Fireball carregada
[PLAYER]    ❄️ Ice Bolt carregada
[PLAYER]    💚 Heal carregada
[PLAYER] 📚 Total de magias carregadas: 3
[PLAYER] ✅ Spell Selector UI configurado

[SPELL_SELECTOR] ➡️ Próxima: [1] Ice Bolt
[PLAYER] 🎯 Magia selecionada: Ice Bolt

[PLAYER] 🔮 ═══ LANÇANDO MAGIA ═══
[PLAYER]    Nome: Ice Bolt
[PLAYER]    Custo: 15.0 mana
[PLAYER]    Tipo: PROJECTILE
```

---

## ✅ Checklist de Implementação

- [x] Script `spell_selector_ui.gd` criado
- [x] Sistema de magias integrado ao `player.gd`
- [x] Funções de seleção (Q/E) implementadas
- [x] Lançamento com botão direito implementado
- [x] Sistema de mana integrado
- [ ] **Inputs configurados no Godot** ← **VOCÊ PRECISA FAZER ISSO!**
- [ ] **UI adicionado à cena do player** ← **VOCÊ PRECISA FAZER ISSO!**
- [ ] Testar no jogo

---

## 🚀 Próximos Passos

### **Melhorias Futuras:**

1. **Projéteis Mágicos:**
   - Criar cena de projétil mágico
   - Implementar `cast_projectile_spell()` completo
   - Adicionar efeitos visuais (partículas, trails)

2. **Magias de Área:**
   - Implementar `cast_area_spell()`
   - Criar área de dano com `Area2D`
   - Adicionar explosões visuais

3. **Sistema de Buffs:**
   - Implementar `cast_buff_spell()`
   - Adicionar timers de duração
   - Criar indicadores visuais de buff ativo

4. **Cooldowns:**
   - Adicionar tempo de recarga para cada magia
   - Mostrar cooldown no UI
   - Bloquear lançamento durante cooldown

5. **Efeitos Visuais:**
   - Adicionar partículas ao lançar
   - Criar animações de cast
   - Adicionar sounds effects

6. **Ícones de Magias:**
   - Substituir `ColorRect` por sprites
   - Criar ícones personalizados para cada magia
   - Adicionar animações de hover

---

## 💡 Dicas de Uso

- **Troque de magia antes de combate** para ter a certa pronta
- **Heal consome bastante mana** (25), use com cautela
- **Fireball causa mais dano** mas custa mais mana
- **Ice Bolt é mais rápido** e econômico

---

**Sistema criado e pronto para uso!** 🎉

Agora basta:
1. Configurar os inputs no Godot
2. Adicionar o UI à cena do player
3. Testar e se divertir! 🔮⚡
