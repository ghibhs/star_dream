# Sistema de Inventário Completo

## 📦 Visão Geral

Sistema de inventário robusto para Godot 4.5+ com suporte a:
- ✅ **Stack de itens** (empilhamento automático)
- ✅ **Split de itens** (dividir pilhas)
- ✅ **Drag and Drop** (arrastar e soltar)
- ✅ **Equipamentos** (armas, armaduras, acessórios)
- ✅ **Transferência entre inventários** (player ↔ baús, etc)
- ✅ **UI responsiva** com grid dinâmico

## 🗂️ Estrutura de Arquivos

```
resources/classes/
├── ItemData.gd              # Definição de itens (stackable, equipável, etc)
└── InventorySlot.gd         # Slot individual (item + quantidade)

scripts/inventory/
└── inventory.gd             # Gerenciador de inventário (add, remove, equip)

scripts/ui/
├── inventory_ui.gd          # UI principal do inventário
└── inventory_slot_ui.gd     # UI de cada slot (drag and drop)

resources/items/             # Itens de exemplo (.tres)
├── health_potion.tres       # Poção empilhável
├── iron_helmet.tres         # Equipamento
└── wood_arrow.tres          # Material empilhável
```

## 🎮 Como Usar

### 1. Adicionar Inventário ao Player

Na cena do player, adicione como filhos:

```
Player (CharacterBody2D)
├── Inventory (Node)          # Script: inventory.gd
└── InventoryUI (CanvasLayer) # Script: inventory_ui.gd
```

No `player.gd`:
```gdscript
@onready var inventory: Inventory = $Inventory
@onready var inventory_ui: InventoryUI = $InventoryUI

func _ready() -> void:
    inventory_ui.setup_inventory(inventory)
```

### 2. Abrir/Fechar Inventário

**Input configurado:**
- `I` ou `Tab` → Abre/fecha o inventário

O input é capturado automaticamente pela `InventoryUI`.

### 3. Adicionar Itens ao Inventário

```gdscript
# Carregar item
var potion = preload("res://resources/items/health_potion.tres")

# Adicionar ao inventário
if inventory.add_item(potion, 5):  # Adiciona 5 poções
    print("Itens adicionados!")
else:
    print("Inventário cheio!")
```

### 4. Criar Novos Itens (.tres)

1. Crie um novo arquivo `.tres`
2. Defina `script` como `ItemData`
3. Configure as propriedades:

```gdscript
# Exemplo: Espada de Ferro
item_id = "iron_sword"
item_name = "Espada de Ferro"
description = "Uma espada resistente"
item_type = ItemType.WEAPON          # Tipo
is_stackable = false                 # Não empilha
is_equippable = true                 # Pode equipar
equipment_slot = WEAPON_PRIMARY      # Slot de arma primária
bonus_damage = 15.0                  # +15 de dano
value = 200                          # 200 moedas
```

## 🔧 Componentes do Sistema

### ItemData (Resource)

Define as propriedades de um item:

| Propriedade | Tipo | Descrição |
|------------|------|-----------|
| `item_id` | String | ID único do item |
| `item_name` | String | Nome exibido |
| `description` | String | Descrição/tooltip |
| `icon` | Texture2D | Ícone na UI |
| `item_type` | Enum | CONSUMABLE, EQUIPMENT, WEAPON, etc |
| `is_stackable` | bool | Se empilha ou não |
| `max_stack_size` | int | Máximo por pilha (padrão: 99) |
| `is_equippable` | bool | Se pode equipar |
| `equipment_slot` | Enum | Slot de equipamento |
| `weapon_data` | WeaponData | Dados da arma (se for arma) |
| `bonus_health` | float | +HP quando equipado |
| `bonus_defense` | float | +Defesa quando equipado |
| `bonus_speed` | float | +Velocidade quando equipado |
| `bonus_damage` | float | +Dano quando equipado |
| `value` | int | Preço em moedas |

### InventorySlot (Resource)

Representa um slot no inventário:

```gdscript
var item_data: ItemData   # Item neste slot
var quantity: int         # Quantidade

# Métodos principais:
func add(amount: int) -> int          # Adiciona, retorna sobra
func remove(amount: int) -> int       # Remove, retorna quanto removeu
func split() -> Dictionary            # Divide ao meio
func can_stack_with(item) -> bool     # Verifica se pode empilhar
```

### Inventory (Node)

Gerenciador principal do inventário:

```gdscript
# Propriedades
@export var inventory_size: int = 30  # Número de slots

var slots: Array[InventorySlot]       # Slots principais
var equipment_slots: Dictionary       # Equipamentos

# Métodos principais:
func add_item(item: ItemData, quantity: int) -> bool
func remove_item(item: ItemData, quantity: int) -> int
func count_item(item: ItemData) -> int
func equip_item(inventory_index: int) -> bool
func unequip_item(slot_type) -> bool
func swap_slots(index_a: int, index_b: int)
func move_item(from: int, to: int)
func split_slot(index: int) -> int
func transfer_to(target_inv: Inventory, from: int, quantity: int) -> bool
```

### InventoryUI (CanvasLayer)

Interface visual do inventário:

- **Grid de slots** organizados em colunas
- **Panel de equipamentos** à direita
- **Drag and Drop** funcional
- **Botões de ação** (split, drop, etc)

### InventorySlotUI (Panel)

UI de cada slot individual:

- Exibe **ícone** do item
- Mostra **quantidade** (se stackable)
- **Tooltip** com informações detalhadas
- Suporte a **drag and drop**

## 🎯 Funcionalidades

### Stack Automático

Quando você adiciona um item empilhável, ele:
1. Procura slots com o mesmo item
2. Empilha até o `max_stack_size`
3. Cria novos slots se necessário

```gdscript
inventory.add_item(arrow_item, 150)  # 150 flechas
# Resultado: 2 slots (99 + 51)
```

### Split de Itens

**Shift + Click** em um slot divide a pilha ao meio:

```gdscript
# Slot com 10 itens
# Shift+Click → Slot 1: 5 itens | Slot 2: 5 itens
inventory.split_slot(slot_index)
```

### Drag and Drop

1. **Click e arraste** um slot
2. **Solte** em outro slot:
   - Se **vazio** → move tudo
   - Se **mesmo item** → empilha
   - Se **item diferente** → troca

### Equipar Itens

**Click** em item equipável → Equipa automaticamente

```gdscript
# No código:
inventory.equip_item(slot_index)

# Ou desequipar:
inventory.unequip_item(ItemData.EquipmentSlot.WEAPON_PRIMARY)
```

### Transferir entre Inventários

```gdscript
# Player → Baú
player_inventory.transfer_to(chest_inventory, slot_index, quantity)

# Baú → Player
chest_inventory.transfer_to(player_inventory, slot_index, quantity)
```

## 🎨 Customização da UI

### Tamanho dos Slots

```gdscript
# No InventoryUI
@export var slot_size: Vector2 = Vector2(64, 64)
@export var grid_columns: int = 6
@export var slot_spacing: int = 4
```

### Cores e Temas

Os componentes usam `Panel`, `Button`, `Label` padrão do Godot.
Você pode aplicar temas personalizados via **Theme Override**.

### Adicionar Novos Slots de Equipamento

Em `inventory_ui.gd`, edite:

```gdscript
func create_equipment_slots(parent: VBoxContainer) -> void:
    var equipment_types = [
        ItemData.EquipmentSlot.HEAD,
        ItemData.EquipmentSlot.CHEST,
        # Adicione mais aqui:
        ItemData.EquipmentSlot.RING,
        ItemData.EquipmentSlot.AMULET,
    ]
```

## 🔔 Signals (Eventos)

### Inventory

```gdscript
signal inventory_changed()                           # Qualquer mudança
signal item_added(item: ItemData, quantity: int)    # Item adicionado
signal item_removed(item: ItemData, quantity: int)  # Item removido
signal equipment_changed(slot_type)                 # Equipamento mudou
```

### InventorySlot

```gdscript
signal slot_changed()  # Quantidade ou item mudou
```

### Uso dos Signals

```gdscript
# Conectar no player:
func _ready():
    inventory.item_added.connect(_on_item_added)
    inventory.equipment_changed.connect(_on_equipment_changed)

func _on_item_added(item: ItemData, quantity: int):
    print("Recebeu: %s x%d" % [item.item_name, quantity])

func _on_equipment_changed(slot_type):
    var equipped = inventory.get_equipped_item(slot_type)
    if equipped:
        apply_equipment_bonuses(equipped)
```

## 📋 Checklist de Implementação

### Feito ✅
- [x] Sistema de ItemData com stack e equipamentos
- [x] InventorySlot com add/remove/split
- [x] Inventory Manager com todas mecânicas
- [x] UI com drag and drop
- [x] Slots de equipamento
- [x] Input "inventory" (I ou Tab)
- [x] Transferência entre inventários
- [x] Itens de exemplo (.tres)

### Próximos Passos (Opcional)
- [ ] Sistema de craft (combinar itens)
- [ ] Drop de itens no mundo
- [ ] Hotbar com atalhos (1-9)
- [ ] Peso máximo do inventário
- [ ] Filtros e busca na UI
- [ ] Som ao pegar/dropar itens
- [ ] Animações de hover/click
- [ ] Baús/containers no mundo

## 🐛 Troubleshooting

### "Could not find type InventorySlot"
- Abra o projeto no Godot e espere recarregar
- Os `class_name` serão reconhecidos automaticamente

### Inventário não abre
- Verifique se o input "inventory" está em `project.godot`
- Confirme que `InventoryUI` é filho do Player ou está na cena

### Drag and Drop não funciona
- Certifique-se que `mouse_filter` está como `STOP` no InventorySlotUI
- Verifique se `_get_drag_data()` está retornando um Dictionary

### Items não empilham
- Confirme `is_stackable = true` no ItemData
- Verifique se `item_data` é o **mesmo recurso** (.tres)

## 💡 Dicas de Performance

1. **Reutilize ItemData**: Sempre use `preload()` ou referências aos mesmos `.tres`
2. **Limite de slots**: 30-50 slots é ideal para performance
3. **Lazy loading**: Só crie a UI quando abrir o inventário
4. **Pooling**: Reutilize InventorySlotUI em vez de criar/destruir

## 📚 Referências

- [Documentação Godot - Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Documentação Godot - Drag and Drop](https://docs.godotengine.org/en/stable/tutorials/inputs/drag_and_drop.html)
- [Documentação Godot - Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)

---

**Sistema criado por:** GitHub Copilot  
**Data:** 21 de outubro de 2025  
**Versão Godot:** 4.5+
