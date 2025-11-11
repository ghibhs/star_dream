# 🖱️ Sistema de Drag and Drop para Hotbar

## ✅ Funcionalidades Implementadas

### 1. **Arrastar do Inventário para Hotbar**
- Abra o inventário com `TAB`
- Clique e segure em qualquer item
- Arraste até um dos 5 slots da hotbar (numerados 1-5)
- Solte para adicionar o item à hotbar

### 2. **Usar Items da Hotbar**
- **Teclas 1-5**: Usa o item no slot correspondente
- **Click Esquerdo**: Usa o item
- **Click Direito**: Remove da hotbar

### 3. **Visual Feedback**
- **Durante Drag**: Item aparece semi-transparente
- **Preview**: Mostra o ícone do item enquanto arrasta
- **Label de Número**: Cada slot mostra seu número (1-5)

---

## 🔧 Estrutura Técnica

### Arquivos Modificados

#### **inventory_ui.gd**
```gdscript
# Variáveis adicionadas:
var hotbar_ui: HotbarUI = null
var dragging_from_slot: int = -1
var dragging_to_hotbar: bool = false

# Conexões de sinais:
slot_ui.drag_started.connect(_on_slot_drag_started)
slot_ui.drag_ended.connect(_on_slot_drag_ended)

# Funções:
- _on_slot_drag_started(slot_index)
- _on_slot_drag_ended(target_slot_index)
- add_inventory_item_to_hotbar(inventory_slot, hotbar_slot)
```

#### **hotbar_ui.gd**
```gdscript
# Grupo adicionado:
add_to_group("hotbar_ui")

# Conexões de sinais:
slot_ui.drag_ended.connect(_on_hotbar_slot_drag_ended.bind(i))

# Funções:
- _on_hotbar_slot_drag_ended(from_inventory_slot, to_hotbar_slot)
```

#### **inventory_slot_ui.gd**
Sistema já existente:
- `_get_drag_data()` - Cria preview e retorna dados
- `_can_drop_data()` - Valida se pode receber drop
- `_drop_data()` - Processa o drop
- Sinais: `drag_started`, `drag_ended`

---

## 🎮 Como Funciona

### Fluxo de Drag and Drop

```
1. Usuário clica e arrasta item do inventário
   ↓
2. InventorySlotUI._get_drag_data() é chamado
   - Cria preview visual (80% do tamanho)
   - Emite signal drag_started(slot_index)
   - Retorna dados: {slot_index, item, quantity}
   ↓
3. Usuário move mouse sobre slot da hotbar
   ↓
4. HotbarSlotUI._can_drop_data() valida
   - Verifica se data é Dictionary
   - Verifica se tem slot_index
   ↓
5. Usuário solta mouse
   ↓
6. HotbarSlotUI._drop_data() é chamado
   - Emite signal drag_ended(from_slot)
   ↓
7. HotbarUI._on_hotbar_slot_drag_ended() processa
   - Chama add_to_hotbar(inventory_index, hotbar_index)
   - Atualiza visual do slot
   - Mantém referência ao inventário
```

---

## 📊 Estado dos Slots da Hotbar

### Estrutura de Dados
```gdscript
# hotbar_item_indices: Array[int]
# Cada posição corresponde a um slot da hotbar (0-4)
# Valor: índice do item no inventário principal
# -1 = slot vazio

Exemplo:
hotbar_item_indices = [5, -1, 12, -1, 0]
					   ↑   ↑   ↑    ↑   ↑
					   1   2   3    4   5
					   
Significa:
- Slot 1: Item do inventário[5]
- Slot 2: Vazio
- Slot 3: Item do inventário[12]
- Slot 4: Vazio
- Slot 5: Item do inventário[0]
```

### Sincronização com Inventário
- Hotbar **não duplica** items
- Hotbar **referencia** items do inventário
- Quando inventário muda, hotbar atualiza automaticamente
- Signal `inventory_changed` mantém tudo sincronizado

---

## 🐛 Debug e Logs

### Logs Importantes

#### Inicialização
```
[INVENTORY UI] 🔗 Hotbar encontrado para drag and drop
[HOTBAR] 🎮 Inicializando hotbar...
[HOTBAR]    Tamanho: 5 slots
```

#### Durante Drag
```
[INVENTORY UI] 🖱️ Drag iniciado no slot 3
[HOTBAR] 🎯 Drag para hotbar - inventário[3] -> hotbar[0]
[HOTBAR] Item adicionado ao slot 0: índice 3
[HOTBAR] ✅ Item adicionado à hotbar!
```

#### Uso de Item
```
[HOTBAR] ⌨️ Tecla 1 pressionada
[HOTBAR] 🎯 Tentando usar slot 0 da hotbar
[HOTBAR]    Índice no inventário: 3
[HOTBAR] ✅ Item usado do slot 0
```

---

## ✅ Checklist de Testes

### Teste 1: Drag Básico
- [ ] Abrir inventário (TAB)
- [ ] Clicar e segurar item
- [ ] Ver preview semi-transparente
- [ ] Arrastar até slot 1 da hotbar
- [ ] Soltar e ver item aparecer
- [ ] Log: `[HOTBAR] ✅ Item adicionado à hotbar!`

### Teste 2: Usar Item da Hotbar
- [ ] Pressionar tecla 1
- [ ] Ver item ser usado
- [ ] Quantidade diminuir
- [ ] Log: `[HOTBAR] ✅ Item usado do slot 0`

### Teste 3: Remover da Hotbar
- [ ] Click direito no slot da hotbar
- [ ] Ver item desaparecer
- [ ] Slot ficar vazio
- [ ] Item ainda no inventário

### Teste 4: Arrastar Para Múltiplos Slots
- [ ] Adicionar item no slot 1
- [ ] Adicionar item no slot 2
- [ ] Adicionar item no slot 5
- [ ] Todos funcionam independentemente

### Teste 5: Slot Já Ocupado
- [ ] Adicionar item no slot 1
- [ ] Arrastar outro item para slot 1
- [ ] Item anterior ser substituído
- [ ] Novo item aparecer

### Teste 6: Sincronização
- [ ] Adicionar item à hotbar
- [ ] Usar item pela hotbar (tecla 1)
- [ ] Abrir inventário
- [ ] Ver quantidade atualizada
- [ ] Se quantidade = 0, slot esvazia

---

## 🎨 Melhorias Visuais Possíveis

### Já Implementado
✅ Preview semi-transparente durante drag
✅ Labels de número em cada slot
✅ Ícones dos items aparecem

### Sugestões Futuras
- 🔲 Borda brilhante quando hovering sobre hotbar
- 🔲 Animação quando adiciona item
- 🔲 Partículas quando usa item
- 🔲 Cooldown visual após usar
- 🔲 Shake quando tenta usar slot vazio
- 🔲 Glow no slot ativo

---

## 🔑 Atalhos de Teclado

| Tecla | Ação |
|-------|------|
| `TAB` | Abre/fecha inventário |
| `1-5` | Usa item da hotbar (slots 1-5) |
| `Click Esq` no slot | Usa item |
| `Click Dir` no slot | Remove da hotbar |
| `Arrasta` do inventário | Adiciona à hotbar |

---

## 🚨 Possíveis Problemas e Soluções

### Problema: "Item não aparece na hotbar"
**Causas:**
- Hotbar não encontrado no grupo
- Índice inválido
- Slot do inventário vazio

**Solução:**
```gdscript
# Verificar logs:
[INVENTORY UI] ⚠️ Hotbar não encontrado!
[HOTBAR] ❌ Índices inválidos
[INVENTORY UI] ❌ Slot vazio - não pode adicionar à hotbar
```

### Problema: "Teclas 1-5 não funcionam"
**Causas:**
- Inventário aberto (bloqueado intencionalmente)
- Hotbar invisível
- Input não configurado

**Solução:**
```gdscript
# Fechar inventário primeiro
# Verificar log:
[HOTBAR] ⌨️ Tecla X pressionada
```

### Problema: "Drag não funciona"
**Causas:**
- Sinais não conectados
- Slot vazio
- MouseFilter bloqueando

**Solução:**
```gdscript
# Verificar conexões em create_hotbar() e create_inventory_slots()
slot_ui.drag_started.connect(_on_slot_drag_started)
slot_ui.drag_ended.connect(_on_slot_drag_ended)
```

---

## 📝 Exemplo de Uso Completo

```gdscript
# 1. Jogador pressiona TAB
# Inventário abre com 17 items

# 2. Jogador arrasta "Poção de Vida" (slot 0) para hotbar slot 1
[INVENTORY UI] 🖱️ Drag iniciado no slot 0
[HOTBAR] 🎯 Drag para hotbar - inventário[0] -> hotbar[0]
[HOTBAR] ✅ Item adicionado à hotbar!

# 3. Jogador fecha inventário (TAB)

# 4. Jogador pressiona tecla 1
[HOTBAR] ⌨️ Tecla 1 pressionada
[HOTBAR] 🎯 Tentando usar slot 0 da hotbar
[INVENTORY] 💊 Usando item: Poção de Vida Pequena
[INVENTORY] ❤️ Curou 50 de vida
[HOTBAR] ✅ Item usado do slot 0

# 5. Quantidade diminui de 5 para 4
# Visual da hotbar atualiza automaticamente
```

---

## 🎯 Status Final

### ✅ Completamente Funcional
- [x] Drag and drop do inventário para hotbar
- [x] Preview visual durante drag
- [x] Uso de items pelas teclas 1-5
- [x] Remoção por click direito
- [x] Sincronização automática
- [x] Labels de número
- [x] Bloqueio quando inventário aberto
- [x] Logs detalhados
- [x] Sistema de grupos para comunicação

### 🎨 Visual Básico Completo
- Icons aparecem corretamente
- Preview semi-transparente
- Labels visíveis
- Sistema funcional

### 🚀 Pronto para Expandir
Próximos passos sugeridos:
1. Adicionar sprites de armas específicas
2. Criar slot de arma primária dedicado
3. Adicionar animações de uso
4. Implementar cooldowns visuais
5. Efeitos de partículas

---

**Sistema totalmente implementado e testável! 🎉**
