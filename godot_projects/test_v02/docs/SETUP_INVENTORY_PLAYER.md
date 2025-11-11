# 🎮 Como Adicionar o Inventário ao Player

## Passo a Passo (Editor do Godot)

### 1. Abra a cena do Player
Vá em `scenes/player/player.tscn` ou onde estiver sua cena do player.

### 2. Adicione o nó Inventory

1. Selecione o nó **Player** (root da cena)
2. Clique com botão direito → **Add Child Node** (ou Ctrl+A)
3. Busque por: `Node`
4. Adicione um **Node** normal
5. Renomeie para: `Inventory`
6. No Inspector, vá em **Script**
7. Clique em **Load** (ícone de pasta)
8. Navegue até: `res://scripts/inventory/inventory.gd`
9. Clique em **Open**

**Configurações do Inventory:**
- `Inventory Size`: 30 (quantidade de slots)
- `Enable Equipment Slots`: ✅ true

### 3. Adicione o nó InventoryUI

1. Selecione o nó **Player** novamente
2. Clique com botão direito → **Add Child Node**
3. Busque por: `CanvasLayer`
4. Adicione um **CanvasLayer**
5. Renomeie para: `InventoryUI`
6. No Inspector, vá em **Script**
7. Clique em **Load**
8. Navegue até: `res://scripts/ui/inventory_ui.gd`
9. Clique em **Open**

**Configurações do InventoryUI:**
- `Inventory`: Arraste o nó `Inventory` para este campo
- `Grid Columns`: 6
- `Slot Size`: X=64, Y=64
- `Slot Spacing`: 4

### 4. Estrutura Final

Sua cena deve ficar assim:

```
Player (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D
├── WeaponMarker2D
│   └── ...
├── Inventory (Node) 📦
│   └── Script: inventory.gd
└── InventoryUI (CanvasLayer) 🎨
    └── Script: inventory_ui.gd
```

### 5. Salve e Teste

1. Salve a cena (**Ctrl+S**)
2. Rode o jogo (**F5**)
3. Pressione **`I`** ou **`Tab`** para abrir o inventário

## ✅ Verificação

No console, você deve ver:
```
[PLAYER] ✅ Sistema de inventário inicializado
[INVENTORY] Inventário inicializado com 30 slots
[INVENTORY UI] Inventário aberto
```

## ⚠️ Se aparecer erros:

### "Node not found: Inventory"
→ Você não adicionou o nó `Inventory` como filho do Player

### "Node not found: InventoryUI"  
→ Você não adicionou o nó `InventoryUI` como filho do Player

### "Could not find type 'Inventory'"
→ Reabra o projeto no Godot para ele reconhecer os `class_name`

### "Inventory is null"
→ Certifique-se que:
  1. O nó se chama exatamente `Inventory` (case-sensitive)
  2. O script `inventory.gd` está anexado
  3. O nó é filho direto do Player

## 🎯 Testando o Sistema

### Adicionar itens via código (para teste)

No `player.gd`, adicione isso no `_ready()` ou em qualquer função:

```gdscript
# Teste: Adiciona itens ao inventário
func _ready():
    # ... código existente ...
    
    # Testa inventário (após esperar 1 frame)
    await get_tree().process_frame
    test_inventory()

func test_inventory():
    if not inventory:
        return
    
    # Carrega itens
    var potion = load("res://resources/items/health_potion.tres")
    var helmet = load("res://resources/items/iron_helmet.tres")
    var arrows = load("res://resources/items/wood_arrow.tres")
    
    # Adiciona ao inventário
    inventory.add_item(potion, 5)
    inventory.add_item(helmet, 1)
    inventory.add_item(arrows, 50)
    
    print("[TEST] Itens adicionados ao inventário!")
```

Agora pressione **`I`** e você verá os itens no inventário! 🎉

## 🔧 Alternativa: Criar via Script

Se preferir criar os nós via código (não recomendado, mas funciona):

```gdscript
func _ready():
    # ... código existente ...
    
    # Cria inventário se não existir
    if not has_node("Inventory"):
        var inv = Inventory.new()
        inv.name = "Inventory"
        inv.inventory_size = 30
        add_child(inv)
        inventory = inv
    
    # Cria UI se não existir
    if not has_node("InventoryUI"):
        var inv_ui = InventoryUI.new()
        inv_ui.name = "InventoryUI"
        inv_ui.inventory = inventory
        add_child(inv_ui)
        inventory_ui = inv_ui
        
        # Configura após criar
        await get_tree().process_frame
        inventory_ui.setup_inventory(inventory)
```

---

**Resumo:** Adicione 2 nós filhos do Player:
1. `Inventory` (Node) com script `inventory.gd`
2. `InventoryUI` (CanvasLayer) com script `inventory_ui.gd`

Pronto! 🚀
