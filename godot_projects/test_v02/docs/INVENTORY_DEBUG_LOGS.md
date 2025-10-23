# 🔍 Sistema de Inventário - Logs de Debug

Este documento lista todos os logs de debug implementados no sistema de inventário para facilitar a detecção de problemas.

---

## 📦 INVENTORY (inventory.gd)

### **Inicialização**
```
[INVENTORY] Inventário inicializado com X slots
```

### **Adicionar Item**
```
[INVENTORY] 📥 Tentando adicionar: ITEM_NAME xQUANTIDADE (tipo: TIPO)
[INVENTORY] ❌ Tentou adicionar item NULL
[INVENTORY] ❌ Quantidade inválida: X
[INVENTORY] ✅ Item adicionado com sucesso!
[INVENTORY] ⚠️ Inventário cheio! Não coube: X itens
```

### **Usar Item**
```
[INVENTORY] 🔍 Tentando usar item do slot X
[INVENTORY]    Item: NOME (tipo: TIPO)
[INVENTORY]    Restore Health: X
[INVENTORY]    Restore Mana: X
[INVENTORY]    Buff Duration: Xs
[INVENTORY] 🍷 Emitindo sinal item_used...
[INVENTORY]    Removendo 1 unidade (tinha: X)
[INVENTORY]    Agora tem: X
[INVENTORY] ✅ Item é consumível!
[INVENTORY] ⚠️ Item não é consumível: NOME
[INVENTORY] ❌ Índice inválido: X (total: Y)
[INVENTORY] ❌ Slot está vazio
```

### **Equipar Item**
```
[INVENTORY] 🎽 Tentando equipar item do slot X
[INVENTORY]    Item: NOME
[INVENTORY]    Slot de destino: TIPO_SLOT
[INVENTORY]    Já existe item equipado, desequipando...
[INVENTORY] ✅ Equipado: NOME no slot TIPO
[INVENTORY] ❌ Índice inválido: X
[INVENTORY] ❌ Slot está vazio
[INVENTORY] ❌ Item não é equipável: NOME
```

### **Remover Item**
```
[INVENTORY] Removido: NOME xQUANTIDADE
```

---

## 🎨 INVENTORY UI (inventory_ui.gd)

### **Configuração**
```
[INVENTORY UI] 🔧 Configurando inventário...
[INVENTORY UI]    Slots: X
[INVENTORY UI] ❌ Inventário é NULL!
```

### **Abrir/Fechar**
```
[INVENTORY UI] 📂 Abrindo inventário...
[INVENTORY UI] ✅ Inventário aberto
[INVENTORY UI] 📁 Fechando inventário...
[INVENTORY UI] ✅ Inventário fechado
```

### **Botão Usar**
```
[INVENTORY UI] 🔘 Botão 'Usar' pressionado
[INVENTORY UI]    Slot selecionado: X
[INVENTORY UI] ✅ Item usado com sucesso
[INVENTORY UI] ❌ Falha ao usar item
[INVENTORY UI] ❌ Nenhum slot selecionado
[INVENTORY UI] ❌ Inventário é NULL!
```

### **Filtros**
```
[INVENTORY UI] 🔍 Mudando filtro para: X
[INVENTORY UI] ✅ Filtro aplicado: NOME_FILTRO
[INVENTORY UI]    Itens visíveis após filtro: X
[INVENTORY UI] ⚠️ Filtro: Inventário é NULL
```

---

## 🎮 HOTBAR (hotbar_ui.gd)

### **Inicialização**
```
[HOTBAR] 🎮 Inicializando hotbar...
[HOTBAR]    Tamanho: X slots
[HOTBAR] ⚠️ Inventário não configurado no _ready
```

### **Configuração**
```
[HOTBAR] 🔗 Conectando ao inventário...
[HOTBAR] ✅ Sinal inventory_changed conectado
[HOTBAR] ✅ Hotbar configurada
[HOTBAR] ❌ Inventário é NULL!
```

### **Usar Slot**
```
[HOTBAR] 🎯 Tentando usar slot X da hotbar
[HOTBAR]    Índice do inventário: X
[HOTBAR]    Item: NOME
[HOTBAR] ✅ Item usado do slot X
[HOTBAR] ❌ Índice inválido: X (máx: Y)
[HOTBAR] ⚠️ Slot da hotbar está vazio
[HOTBAR] ❌ Inventário é NULL!
[HOTBAR] ❌ Índice inválido no inventário: X >= Y
[HOTBAR] ⚠️ Item do inventário foi removido
[HOTBAR] ❌ Falha ao usar item
```

### **Input**
```
[HOTBAR] ⌨️ Tecla X pressionada
```

### **Adicionar/Remover**
```
[HOTBAR] Item adicionado ao slot X: índice Y
```

---

## 🧑 PLAYER (player.gd)

### **Inicialização do Inventário**
```
[PLAYER] 🎒 Procurando sistema de inventário...
[PLAYER]    ✅ Inventory encontrado
[PLAYER]    ❌ Inventory NÃO encontrado
[PLAYER]    ✅ InventoryUI encontrado
[PLAYER]    ❌ InventoryUI NÃO encontrado
[PLAYER]    ✅ Sinal 'item_used' conectado
[PLAYER]    ⚠️ Sinal 'item_used' já estava conectado
[PLAYER]    ❌ Sinal 'item_used' NÃO existe no inventário!
[PLAYER] ✅ Sistema de inventário inicializado
[PLAYER] ⚠️ Nó 'Inventory' não encontrado - adicione à cena do player
[PLAYER] ⚠️ Nó 'InventoryUI' não encontrado - adicione à cena do player
```

### **Uso de Consumível**
```
[PLAYER] ═══════════════════════════════════
[PLAYER] 🍷 USANDO CONSUMÍVEL
[PLAYER] ═══════════════════════════════════
[PLAYER]    Item: NOME
[PLAYER]    Tipo: TIPO
[PLAYER]    HP atual: X / Y
[PLAYER]    💚 Restaurando vida:
[PLAYER]       Antes: X
[PLAYER]       Curado: +X
[PLAYER]       Depois: X / Y
[PLAYER]       HUD atualizado
[PLAYER]       ⚠️ PlayerHUD não encontrado
[PLAYER]    ⚪ Sem restauração de HP
[PLAYER]    💙 +X Mana (sistema não implementado)
[PLAYER]    💛 +X Stamina (sistema não implementado)
[PLAYER]    ✨ Aplicando buff temporário...
[PLAYER]    ⚪ Sem buffs
[PLAYER] ═══════════════════════════════════
[PLAYER] ✅ Consumível aplicado com sucesso!
[PLAYER] ═══════════════════════════════════
[PLAYER] ❌ Item é NULL!
```

### **Buff Temporário**
```
[PLAYER] ✨ ═══ INICIANDO BUFF ═══
[PLAYER]    Duração: Xs
[PLAYER]    Stats ANTES do buff:
[PLAYER]       Velocidade: X
[PLAYER]       Dano: X
[PLAYER]    🚀 BUFF DE VELOCIDADE:
[PLAYER]       Multiplicador: xX
[PLAYER]       Nova velocidade: X
[PLAYER]    ⚔️ BUFF DE DANO:
[PLAYER]       Multiplicador: xX
[PLAYER]       Novo dano: X
[PLAYER]    ⚠️ Buff de dano ignorado: sem arma equipada
[PLAYER]    ⚠️ Nenhum buff foi aplicado (multiplicadores = 1.0)
[PLAYER] ═══ BUFF ATIVO ═══
[PLAYER] ⏱️ ═══ BUFF EXPIROU ═══
[PLAYER]    Restaurando valores originais...
[PLAYER]    Stats APÓS restauração:
[PLAYER]       Velocidade: X
[PLAYER]       Dano: X
[PLAYER] ═══ BUFF REMOVIDO ═══
```

---

## 🔧 Como Ler os Logs

### **Símbolos**
- ✅ = Sucesso
- ❌ = Erro crítico
- ⚠️ = Aviso (pode não ser crítico)
- ⚪ = Informação neutra
- 🔍 = Inspeção/Debug
- 💚💙💛 = Restauração de stats
- ✨ = Buff/Efeito especial
- 🎯 = Ação direcionada
- 📦📥 = Operações de item
- 🎮⌨️ = Input do usuário

### **Ordem Esperada (Usar Item)**
1. Input (tecla ou botão)
2. Hotbar detecta input
3. Hotbar chama inventory.use_item()
4. Inventory valida e emite sinal
5. Player recebe sinal
6. Player aplica efeitos
7. Stats atualizados

### **Problemas Comuns**

**"Inventário é NULL"**
- Verifique se o nó `Inventory` existe na cena
- Verifique se o nome está correto

**"Sinal item_used NÃO existe"**
- Código do inventory.gd está desatualizado
- Falta a linha: `signal item_used(item: ItemData)`

**"Item não é consumível"**
- ItemData.item_type deve ser CONSUMABLE
- Verifique o .tres do item

**"Buff não foi aplicado"**
- Multiplicadores estão em 1.0
- Configure buff_speed_multiplier ou buff_damage_multiplier

**"Slot está vazio após usar"**
- Normal se era o último item
- Hotbar deve remover referência automaticamente

---

## 📊 Debug Console

Para ver todos os logs, ative o console do Godot:
- Editor: Aba "Depurador" (Debugger)
- Jogo rodando: Pressione F4

Filtros úteis:
- `[INVENTORY]` - Todas operações de inventário
- `[HOTBAR]` - Ações da hotbar
- `[PLAYER]` - Efeitos no player
- `❌` - Apenas erros
- `✅` - Apenas sucessos

---

**Última atualização**: 22/10/2025
