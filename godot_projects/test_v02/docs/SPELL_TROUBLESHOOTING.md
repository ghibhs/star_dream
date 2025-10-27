# 🔧 Troubleshooting - Sistema de Magias

## ❌ Problema: "Já criei as coisas e não aparece nem funciona"

### 📋 **Checklist de Verificação**

---

## 1️⃣ **VERIFICAR CONSOLE DO GODOT**

Rode o jogo e verifique se aparecem estas mensagens:

### ✅ **Mensagens que DEVEM aparecer:**

```
[SPELL_SELECTOR] ═══════════════════════════════
[SPELL_SELECTOR] 🎯 INICIALIZANDO...
[SPELL_SELECTOR]    Tamanho dos slots: (48, 48)
[SPELL_SELECTOR]    Máximo visível: 5
[SPELL_SELECTOR]    Node name: SpellSelectorUI
[SPELL_SELECTOR]    Parent: SpellSelectorCanvasLayer
[SPELL_SELECTOR]    Position: (10, -70)
[SPELL_SELECTOR]    Visible: True
[SPELL_SELECTOR] ═══════════════════════════════

[PLAYER] 🔮 ═══ INICIANDO SISTEMA DE MAGIAS ═══
[PLAYER]    🔥 Fireball carregada
[PLAYER]    ❄️ Ice Bolt carregada
[PLAYER]    💚 Heal carregada
[PLAYER] 📚 Total de magias carregadas: 3
[PLAYER] ✅ Spell Selector UI configurado
```

### ❌ **Se aparecer:**

**"⚠️ SpellSelectorUI não encontrado na cena"**
- **Problema:** O UI não está na cena do player
- **Solução:** Vá para o passo 2

**"⚠️ Nenhuma magia disponível"**
- **Problema:** Arquivos de magias não carregaram
- **Solução:** Vá para o passo 5

---

## 2️⃣ **VERIFICAR HIERARQUIA DA CENA**

Abra `scenes/player/player.tscn` e verifique:

### ✅ **Estrutura CORRETA:**

```
Player (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D
├── Camera2D
├── ...
├── SpellSelectorCanvasLayer (CanvasLayer) ← IMPORTANTE!
│   └── SpellSelectorUI (HBoxContainer)    ← COM SCRIPT!
│       └── (slots serão criados dinamicamente)
└── ...
```

### ❌ **Erros Comuns:**

1. **SpellSelectorUI não é filho de CanvasLayer**
   - **Solução:** Crie um `CanvasLayer` e coloque o `HBoxContainer` dentro dele

2. **Nome errado do nó**
   - **DEVE SER:** `SpellSelectorUI` (exato!)
   - **Não pode ser:** `SpellSelector`, `spellselector`, etc.

3. **Script não anexado**
   - Selecione `SpellSelectorUI`
   - Verifique se tem ícone de script 📜 ao lado
   - Se não: **Attach Script** → `res://scripts/ui/spell_selector_ui.gd`

---

## 3️⃣ **VERIFICAR POSICIONAMENTO DO UI**

Selecione `SpellSelectorUI` no editor:

### ✅ **Configurações Corretas:**

No **Inspector → Layout:**

```
Anchors Preset: Bottom Left
Position:
  - X: 10
  - Y: -70  ← NEGATIVO! (acima da borda)
  
OU (mais fácil):

Anchors Preset: Bottom Left
Offset Left: 10
Offset Top: -70
Offset Right: 260  (calculado automaticamente)
Offset Bottom: -22  (calculado automaticamente)
```

### 🎯 **Como Posicionar Visualmente:**

1. Selecione `SpellSelectorUI`
2. No **Inspector**, procure **Layout**
3. Clique no ícone de **Anchor Preset** (🎯)
4. Escolha **Bottom Left** (canto inferior esquerdo)
5. Ajuste **Offset Top** para `-70` (70 pixels acima da borda)
6. Ajuste **Offset Left** para `10` (10 pixels da esquerda)

---

## 4️⃣ **VERIFICAR VISIBILIDADE DO UI**

### Teste no Editor:

1. Selecione `SpellSelectorUI`
2. No **Inspector**, verifique:
   - ✅ **Visible**: ON
   - ✅ **Modulate → Alpha**: 255
   - ✅ **Self Modulate → Alpha**: 255

3. Verifique o `CanvasLayer`:
   - Selecione `SpellSelectorCanvasLayer`
   - ✅ **Visible**: ON
   - ✅ **Layer**: 1 ou maior

---

## 5️⃣ **VERIFICAR ARQUIVOS DE MAGIAS**

Confirme que existem:

```
resources/spells/
├── fireball.tres
├── ice_bolt.tres
└── heal.tres
```

### 🔍 **Como Verificar:**

1. No **FileSystem** do Godot
2. Navegue para `res://resources/spells/`
3. Devem aparecer 3 arquivos `.tres`
4. Clique duplo em cada um para abrir
5. Verifique se tem as propriedades:
   - `spell_name`
   - `mana_cost`
   - `damage`
   - `spell_type`

### ⚠️ **Se os arquivos não existem:**

Crie manualmente:

1. **Clique direito** em `resources/spells/`
2. **New Resource**
3. Busque por `SpellData`
4. Configure as propriedades
5. Salve como `.tres`

---

## 6️⃣ **VERIFICAR INPUTS**

Abra: **Project → Project Settings → Input Map**

### ✅ **Devem existir:**

| Input | Tecla/Botão |
|-------|-------------|
| `spell_previous` | Q (keycode 81) |
| `spell_next` | E (keycode 69) |
| `cast_spell` | Mouse Button Right (button_index 2) |

### 🔧 **Como Adicionar (se não existem):**

1. Digite `spell_previous` no campo **Add New Action**
2. Clique **Add**
3. Clique no **+** ao lado
4. Escolha **Key**
5. Pressione **Q**
6. Repita para `spell_next` (E) e `cast_spell` (Right Mouse)

---

## 7️⃣ **TESTAR FUNÇÕES INDIVIDUALMENTE**

### Teste 1: UI Aparece?

Rode o jogo e procure no **canto inferior esquerdo** da tela:
- Devem aparecer **3 quadrados coloridos**
- Um com **borda amarela grossa** (selecionado)

**❌ Não aparece?**
- Volte ao passo 3 (posicionamento)
- Verifique se o `CanvasLayer` está em cima de todos os elementos

### Teste 2: Teclas Q e E funcionam?

Pressione **Q** e **E** enquanto joga:
- Console deve mostrar:
  ```
  [SPELL_SELECTOR] ⬅️ Anterior: [0] Fireball
  [SPELL_SELECTOR] ➡️ Próxima: [1] Ice Bolt
  ```

**❌ Não funciona?**
- Volte ao passo 6 (inputs)
- Verifique se digitou os nomes EXATAMENTE como mostrado

### Teste 3: Botão Direito lança magia?

Clique com **botão direito**:
- Console deve mostrar:
  ```
  [PLAYER] 🔮 ═══ LANÇANDO MAGIA ═══
  [PLAYER]    Nome: Fireball
  [PLAYER]    Custo: 20.0 mana
  [PLAYER]    Tipo: PROJECTILE
  ```

**❌ Não funciona?**
- Verifique input `cast_spell`
- Confirme que é **Mouse Button Right** (button_index: 2)

---

## 8️⃣ **VERIFICAR MANA**

Se as magias não lançam:

### Console mostra: "❌ Mana insuficiente"

**Solução:**
1. Selecione o nó `Player` na cena
2. No **Inspector**, procure:
   - `Max Mana`: Aumente para 200+
   - `Mana Regen Rate`: Aumente para 10+
3. Aguarde alguns segundos para mana regenerar
4. Tente lançar novamente

---

## 9️⃣ **FORÇAR ATUALIZAÇÃO DO UI**

Se ainda não aparece, force o UI manualmente:

### Adicione ao `_ready()` do player.gd:

```gdscript
func _ready() -> void:
	# ... código existente ...
	
	# FORÇA VISIBILIDADE DO UI (DEBUG)
	await get_tree().process_frame
	if spell_selector_ui:
		spell_selector_ui.visible = true
		spell_selector_ui.modulate = Color.WHITE
		print("[PLAYER] 🔧 UI forçado a ser visível")
```

---

## 🔟 **VERIFICAR SCRIPT DO PLAYER**

Abra `scripts/player/player.gd` e confirme:

### ✅ **Variáveis existem (linhas ~47-49):**

```gdscript
var available_spells: Array[Resource] = []
var current_spell_index: int = 0
var spell_selector_ui: Control = null
```

### ✅ **Função existe (linha ~322):**

```gdscript
setup_spell_system()
```

### ✅ **Inputs no _physics_process (linha ~74+):**

```gdscript
if Input.is_action_just_pressed("spell_previous"):
	select_previous_spell()

if Input.is_action_just_pressed("spell_next"):
	select_next_spell()

if Input.is_action_just_pressed("cast_spell"):
	cast_current_spell()
```

---

## 🎨 **TESTE DE VISIBILIDADE EXTREMO**

Se NADA funciona, teste com UI gigante:

1. Selecione `SpellSelectorUI`
2. No **Inspector**:
   - `Custom Minimum Size`: (500, 100)
   - `Position`: (100, 100)
3. Rode o jogo
4. Deve aparecer uma **barra GIGANTE** no meio da tela

**✅ Apareceu?**
- Problema era o posicionamento
- Volte às configurações corretas do passo 3

**❌ Ainda não aparece?**
- O script não está anexado corretamente
- Volte ao passo 2

---

## 📊 **CHECKLIST FINAL**

Marque cada item:

- [ ] Console mostra mensagens de inicialização
- [ ] Hierarquia da cena está correta
- [ ] SpellSelectorUI tem o script anexado
- [ ] UI está posicionado no canto inferior esquerdo
- [ ] CanvasLayer está visível
- [ ] Arquivos de magias existem (.tres)
- [ ] Inputs configurados no Project Settings
- [ ] Mana suficiente (100+)
- [ ] Funções existem no player.gd
- [ ] Teste de visibilidade passou

---

## 🆘 **ÚLTIMO RECURSO: RECOMEÇAR DO ZERO**

Se NADA funcionou:

### 1. Delete tudo relacionado:

```
- SpellSelectorCanvasLayer (da cena)
- SpellSelectorUI (da cena)
```

### 2. Reabra a cena do player

### 3. Siga exatamente:

1. **Add Child Node** → `CanvasLayer`
2. Renomeie para `SpellSelectorCanvasLayer`
3. Clique direito nele → **Add Child Node** → `HBoxContainer`
4. Renomeie para `SpellSelectorUI`
5. Selecione `SpellSelectorUI`
6. **Inspector → Script** → 📁 **Quick Load**
7. Digite: `spell_selector_ui.gd`
8. Deve aparecer `res://scripts/ui/spell_selector_ui.gd`
9. Clique **Load**
10. **Inspector → Layout → Anchor Preset** → **Bottom Left**
11. **Offset Top**: `-70`
12. **Offset Left**: `10`
13. Salve a cena (**Ctrl+S**)
14. Rode o jogo (**F5**)

---

## 💬 **AINDA NÃO FUNCIONA?**

**Copie e cole no console do Godot:**

Rode o jogo e envie a saída completa do console, especialmente:
- Linhas com `[SPELL_SELECTOR]`
- Linhas com `[PLAYER]` relacionadas a magias
- Qualquer erro em vermelho

---

**Com essas etapas, o sistema DEVE funcionar!** ✅
