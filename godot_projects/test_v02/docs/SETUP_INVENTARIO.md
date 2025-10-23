# 🎒 Como Configurar o Sistema de Inventário

## ⚠️ PROBLEMA ATUAL
O inventário abre mas não mostra slots porque **não está conectado ao nó Inventory**.

---

## ✅ SOLUÇÃO - Passo a Passo

### **1. Abrir a Cena do Player**
- No Godot, abra: `res://entidades.tscn` (ou a cena do player)

---

### **2. Adicionar o Nó Inventory**

1. Selecione o nó **Player** (raiz da cena)
2. Clique no botão **+** (Add Child Node) ou pressione `Ctrl+A`
3. Procure por **Node** e adicione
4. Renomeie para **Inventory**
5. Com o nó **Inventory** selecionado:
   - No Inspector (lado direito), procure **Script**
   - Clique no ícone de script e selecione: `res://scripts/inventory/inventory.gd`

---

### **3. Adicionar o Nó InventoryUI**

1. Selecione o nó **Player** novamente
2. Adicione um **CanvasLayer**
3. Renomeie para **InventoryUI**
4. Com **InventoryUI** selecionado:
   - Adicione o script: `res://scripts/ui/inventory_ui.gd`
   
5. **IMPORTANTE**: Conecte o inventário à UI
   - Com **InventoryUI** selecionado
   - No Inspector, procure a propriedade **Inventory**
   - Arraste o nó **Inventory** (criado no passo 2) para essa propriedade
   - Ou clique no ícone ao lado e selecione o nó

---

### **4. Adicionar HotbarUI (Opcional)**

#### **Opção A - Script direto no CanvasLayer (RECOMENDADO):**
1. Selecione o nó **Player**
2. Adicione um **CanvasLayer**
3. Renomeie para **HotbarUI**
4. Com **HotbarUI** selecionado:
   - Adicione o script: `res://scripts/ui/hotbar_ui.gd`
   - No Inspector, procure **Inventory**
   - Arraste o nó **Inventory** para essa propriedade

#### **Opção B - Script no HBoxContainer filho:**
1. Selecione o nó **Player**
2. Adicione um **CanvasLayer**
3. Renomeie para **HotbarUI**
4. Com **HotbarUI** selecionado, adicione um **HBoxContainer** como filho
5. Com **HBoxContainer** selecionado:
   - Adicione o script: `res://scripts/ui/hotbar_ui.gd`
   - No Inspector, procure **Inventory**
   - Arraste o nó **Inventory** para essa propriedade

---

## 📋 Estrutura Final

Sua cena do Player deve ficar assim:

```
Player (CharacterBody2D)
├── Inventory (Node) [script: inventory.gd]
├── InventoryUI (CanvasLayer) [script: inventory_ui.gd]
│   └── (property: inventory = Inventory)
├── HotbarUI (CanvasLayer) [script: hotbar_ui.gd] [opcional]
│   └── (property: inventory = Inventory)
└── ... (outros nós)
```

**OU** (se usou Opção B com HBoxContainer):

```
Player (CharacterBody2D)
├── Inventory (Node) [script: inventory.gd]
├── InventoryUI (CanvasLayer) [script: inventory_ui.gd]
│   └── (property: inventory = Inventory)
├── HotbarUI (CanvasLayer) [opcional]
│   └── HBoxContainer [script: hotbar_ui.gd]
│       └── (property: inventory = Inventory)
└── ... (outros nós)
```

---

## 🧪 Testar

Depois de configurar:

1. Salve a cena (Ctrl+S)
2. Execute o jogo (F5)
3. Observe o console - deve aparecer:

```
[INVENTORY] Inventário inicializado com 30 slots
[INVENTORY UI] 🔧 Configurando inventário...
[INVENTORY UI]    Slots: 30
[INVENTORY UI]    Slot 0 criado e conectado
[INVENTORY UI]    Slot 1 criado e conectado
[INVENTORY UI]    Slot 2 criado e conectado
...
[PLAYER] 🎒 Procurando sistema de inventário...
[PLAYER]    ✅ Inventory encontrado
[PLAYER]    ✅ InventoryUI encontrado
[PLAYER]    ✅ Sinal 'item_used' conectado
[PLAYER] ✅ Sistema de inventário inicializado
```

4. Pressione **TAB** no jogo
5. Você verá a UI do inventário com slots clicáveis
6. Tente clicar em um slot - deve aparecer:

```
[SLOT UI] 🖱️ Mouse event no slot X
[SLOT UI] ✅ CLIQUE ESQUERDO no slot X
[INVENTORY UI] 🖱️ CALLBACK _on_slot_clicked chamado!
[INVENTORY UI]    Slot: X
```

---

## 🔧 Adicionar Items de Teste (Opcional)

Para testar o sistema, adicione itens via código:

1. Abra `player.gd`
2. Adicione no `_ready()`:

```gdscript
# No final do _ready()
if inventory:
    # Cria alguns items de teste
    var health_potion = load("res://resources/items/health_potion.tres")
    if health_potion:
        inventory.add_item(health_potion, 3)
    
    var bow = load("res://resources/weapons/bow.tres")
    if bow:
        inventory.add_item(bow, 1)
```

---

## ❌ Se der erro

### "Inventory não encontrado"
- Verifique se o nó está nomeado exatamente como **Inventory** (com I maiúsculo)
- Verifique se tem o script `inventory.gd` attachado

### "Slots não aparecem"
- Verifique se a propriedade **inventory** da **InventoryUI** está conectada ao nó **Inventory**
- No Inspector do InventoryUI, deve mostrar: `Inventory: Inventory`

### "Não consigo clicar"
- Abra o console e veja se aparecem logs ao clicar
- Se não aparecer nada, pode ser problema de Z-index ou visibility

---

## 📖 Referências

- Estrutura completa: `docs/INVENTORY_SYSTEM.md`
- Logs de debug: `docs/INVENTORY_DEBUG_LOGS.md`
- Classes de dados: `resources/classes/ItemData.gd`

---

**Última atualização**: 22/10/2025
