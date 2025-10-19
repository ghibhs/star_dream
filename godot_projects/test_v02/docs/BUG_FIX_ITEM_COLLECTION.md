# 🐛 BUG FIX: Coleta de Itens Quebrada

**Data:** 19/10/2025  
**Problema:** Após reorganização do projeto, itens não são mais coletados pelo player

---

## 🔍 Diagnóstico

### Sintoma
```
[PLAYER] Inicializado e adicionado ao grupo 'player'
[PLAYER]    Collision Layer: 2 (binário: 10)
[PLAYER]    Collision Mask: 13 (binário: 1101)
[PAUSE_MENU] Menu de pausa inicializado

# ⚠️ Player passa por cima do item mas nada acontece
# ⚠️ Nenhum log de colisão é gerado
```

### Causa Raiz
Os arquivos `.tscn` dos itens (`bow.tscn`, etc.) **não tinham `collision_layer` e `collision_mask` configurados**!

#### Antes (QUEBRADO):
```gdscene
[node name="Area2D" type="Area2D"]
script = ExtResource("1_2l2of")
# ❌ Sem collision_layer → Valor padrão = 1 (World)
# ❌ Sem collision_mask → Valor padrão = 1 (World)
```

**Resultado:** Item estava na Layer 1 (World) detectando Layer 1 (World), ignorando completamente o Player (Layer 2)!

---

## ✅ Solução Aplicada

### 1. Adicionado Debug ao Script

**Arquivo:** `scripts/items/area_2d.gd`

```gdscript
func _ready():
	print("[ITEM] Item inicializado: ", name)
	print("[ITEM]    Collision Layer: ", collision_layer)
	print("[ITEM]    Collision Mask: ", collision_mask)
	
	if item_data:
		setup_item()
		print("[ITEM]    Item Data: ", item_data.resource_path)
	
	body_entered.connect(_on_body_entered)
	print("[ITEM]    Signal body_entered conectado")

func _on_body_entered(body):
	print("[ITEM] 🎯 Colisão detectada!")
	print("[ITEM]    Body: ", body.name)
	print("[ITEM]    Está no grupo 'player'? ", body.is_in_group("player"))
	
	if body.is_in_group("player"):
		print("[ITEM] ✅ Player detectado! Enviando item_data...")
		body.call_deferred("receive_weapon_data", item_data)
		print("[ITEM]    Item sendo removido...")
		queue_free()
```

### 2. Corrigido Collision Layers nos .tscn

**Arquivos:** 
- `scenes/items/bow.tscn`
- `bow.tscn` (raiz)

#### Depois (CORRETO):
```gdscene
[node name="Area2D" type="Area2D"]
collision_layer = 0    # ✅ Item não está em nenhuma layer física
collision_mask = 2     # ✅ Detecta Player (Layer 2)
script = ExtResource("1_2l2of")
```

---

## 🎯 Convenção de Camadas para Itens

| Propriedade | Valor | Explicação |
|-------------|-------|------------|
| **collision_layer** | 0 | Itens não precisam colidir fisicamente, são apenas áreas de detecção |
| **collision_mask** | 2 | Detecta Player (Layer 2) para disparar `body_entered` |

### Por que Layer 0?
- Itens são **triggers**, não objetos físicos
- Não precisam estar em nenhuma camada de colisão
- Apenas **detectam** o player quando ele entra na área

### Por que Mask 2?
- Layer 2 = Player (conforme `COLLISION_SETUP.md`)
- Itens precisam detectar quando o player entra na área deles

---

## 📊 Debug Esperado (Após Fix)

### Ao iniciar o jogo:
```
[ITEM] Item inicializado: Area2D
[ITEM]    Collision Layer: 0 (binário: 0)
[ITEM]    Collision Mask: 2 (binário: 10)
[ITEM]    Item Data: res://ItemData/bow.tres
[ITEM]    Signal body_entered conectado
```

### Ao coletar o item:
```
[ITEM] 🎯 Colisão detectada!
[ITEM]    Body: Entidades
[ITEM]    Body tipo: CharacterBody2D
[ITEM]    Está no grupo 'player'? true
[ITEM] ✅ Player detectado! Enviando item_data...
[ITEM]    Item sendo removido...
[PLAYER] 🎁 Arma recebida: [WeaponData...]
```

---

## 🔧 Checklist de Validação

- [x] Collision layers configuradas nos .tscn
- [x] Debug adicionado ao script
- [x] Código testável para identificar problemas futuros
- [ ] **Testar no jogo:** Coletar item e verificar logs

---

## 📝 Lições Aprendidas

1. **Sempre configure collision layers explicitamente** nos arquivos .tscn
2. **Valores padrão podem não ser os esperados** (padrão = 1, não 0)
3. **Debug de collision layers é essencial** para depuração
4. **Area2D sem layers corretas = invisível** para outras entidades

---

## 🎓 Referências

- `docs/COLLISION_SETUP.md` - Sistema completo de camadas
- `docs/CONVENTIONS.md` - Convenções de collision layers
- `docs/PROJECT_MAP.md` - Mapa de camadas do projeto

---

## ✅ Status

**CORRIGIDO** - Itens agora têm collision layers adequadas e debug extensivo para validação.

**Próximo Teste:** Rodar o jogo e verificar se os logs aparecem e se a coleta funciona.
