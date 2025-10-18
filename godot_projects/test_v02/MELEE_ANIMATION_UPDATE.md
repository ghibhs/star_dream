# ⚔️ Atualização: Animação de Ataque Melee

**Data**: 18 de outubro de 2025  
**Funcionalidades**: Animação de ataque + Rotação na base da espada

---

## 🎯 O Que Foi Implementado

### 1. ✅ Animação de Ataque da Espada

A espada agora toca a animação **"attack"** quando você ataca e volta para **"default"** quando termina.

**Código adicionado em `melee_attack()`**:
```gdscript
func melee_attack() -> void:
    if not attack_area:
        print("no attack area")
        return
    
    # Toca animação de ataque
    if current_weapon_sprite and current_weapon_data:
        if current_weapon_data.sprite_frames.has_animation("attack"):
            current_weapon_sprite.play("attack")
    
    # Ativa hitbox
    attack_area.monitoring = true
    await get_tree().create_timer(0.2).timeout
    
    # Desativa hitbox
    attack_area.monitoring = false
    
    # Volta para animação idle/default
    if current_weapon_sprite and current_weapon_data:
        if current_weapon_data.animation_name != "":
            current_weapon_sprite.play(current_weapon_data.animation_name)
        else:
            current_weapon_sprite.stop()
```

**Fluxo**:
1. Click de ataque → Toca "attack"
2. Hitbox ativa por 0.2s
3. Hitbox desativa
4. Volta para "default"

---

### 2. ✅ Rotação na Base da Espada

Agora a espada rotaciona no **pivot da base** (cabo), não no centro da lâmina.

**Como Funciona**:
- O `AnimatedSprite2D` tem uma propriedade `offset` que move o ponto de rotação
- Offset positivo em Y = move o pivot para BAIXO (base da espada)
- Offset negativo em Y = move o pivot para CIMA (ponta da espada)

**Novo Campo em `WeaponData.gd`**:
```gdscript
@export var sprite_offset: Vector2 = Vector2.ZERO  # Offset do pivot para rotação
```

**Configurado em `sword.tres`**:
```gdscript
sprite_offset = Vector2(0, 20)  # Pivot na base (ajuste conforme necessário)
```

**Código em `create_or_update_weapon_sprite()`**:
```gdscript
# Configura offset para rotacionar na base da espada (não no centro)
if "sprite_offset" in current_weapon_data:
    current_weapon_sprite.offset = current_weapon_data.sprite_offset
elif current_weapon_data.weapon_type == "melee":
    # Fallback: Para espada vertical, offset positivo move pivot para baixo
    current_weapon_sprite.offset = Vector2(0, 16)
else:
    current_weapon_sprite.offset = Vector2.ZERO
```

---

## 🎨 Como Ajustar o Pivot da Espada

O valor `sprite_offset = Vector2(0, 20)` pode precisar ser ajustado dependendo do tamanho da sua sprite.

### Como Encontrar o Valor Ideal

1. **Abra o Godot**
2. **Rode a cena** e equipe a espada
3. **No Remote Scene Tree** (enquanto joga):
   - Encontre o nó `WeaponAnimatedSprite2D`
   - Ajuste a propriedade `Offset` em tempo real
   - Veja a espada rotacionando

4. **Anote o valor** que funcionou
5. **Atualize `sword.tres`**:
   ```gdscript
   sprite_offset = Vector2(0, SEU_VALOR_AQUI)
   ```

### Valores de Referência

| Tamanho da Sprite | Offset Sugerido | Resultado |
|-------------------|-----------------|-----------|
| 16x16 pixels | `Vector2(0, 8)` | Pivot no centro-base |
| 32x32 pixels | `Vector2(0, 16)` | Pivot no centro-base |
| 64x64 pixels | `Vector2(0, 32)` | Pivot no centro-base |
| Sua sprite (scale 0.2) | `Vector2(0, 20)` | **Configurado** |

**Dica**: Se a espada ainda rotacionar no meio, **aumente** o valor Y (ex: 30, 40).

---

## 🧪 Como Testar

### Teste Rápido (1 minuto)

1. **Abra Godot** e carregue o projeto
2. **Rode a cena** (F5)
3. **Equipe a espada** (via código em `the_game.gd`):
   ```gdscript
   func _ready():
       var sword_data = preload("res://ItemData/sword.tres")
       $entidades.receive_weapon_data(sword_data)
   ```
4. **Clique para atacar**

### Checklist de Validação

- [ ] **Animação "attack" toca** quando clica
- [ ] **Animação volta para "default"** após 0.2s
- [ ] **Espada rotaciona na base**, não no meio
- [ ] **Hitbox ativa** durante a animação
- [ ] **Hitbox desativa** após 0.2s
- [ ] **Cooldown funciona** (~0.33s entre ataques)

---

## 🎬 Animações Configuradas

### sword.tres - SpriteFrames

```gdscript
animations = [
    {
        "name": "attack",
        "frames": [Sprite-0004.png, Sprite-0004 - Copia.png],
        "loop": true,
        "speed": 5.0
    },
    {
        "name": "default",
        "frames": [Sprite-0004.png],
        "loop": true,
        "speed": 5.0
    }
]
```

**Você pode**:
- Adicionar mais frames em "attack" para swing mais suave
- Mudar `loop: true` para `loop: false` em "attack" (para não repetir)
- Ajustar `speed` para controlar velocidade da animação

---

## ⚙️ Configurações Recomendadas

### Para Animação de Ataque Mais Natural

1. **Desabilite loop da animação "attack"**:
   - Abra `sword.tres` no Godot
   - Vá em SpriteFrames → "attack"
   - Desmarque "Loop"
   - **Resultado**: Animação toca uma vez e para no último frame

2. **Ajuste duração do ataque**:
   ```gdscript
   # Em melee_attack(), mude de 0.2 para duração da animação
   var attack_duration = 0.3  # ou calcule: frames / fps
   await get_tree().create_timer(attack_duration).timeout
   ```

3. **Sincronize hitbox com frames específicos**:
   - Conecte o signal `animation_finished` do AnimatedSprite2D
   - Ative hitbox apenas em frames específicos (swing real)

---

## 🔧 Arquivos Modificados

```
✅ entidades.gd
   - melee_attack(): Adiciona animação attack/default
   - create_or_update_weapon_sprite(): Configura sprite_offset

✅ WeaponData.gd
   - Novo campo: sprite_offset (Vector2)

✅ ItemData/sword.tres
   - Adicionado: sprite_offset = Vector2(0, 20)
```

---

## 🎯 Próximos Passos (Opcional)

### Melhorias de Animação

1. **Rotação da Espada Durante Swing**:
   ```gdscript
   # Em melee_attack(), adicione tween de rotação
   var tween = create_tween()
   tween.tween_property(current_weapon_sprite, "rotation_degrees", 90, 0.2)
   await tween.finished
   current_weapon_sprite.rotation_degrees = 0
   ```

2. **Hitbox Move com o Swing**:
   ```gdscript
   # Mova a attack_area junto com a animação
   var tween = create_tween()
   tween.tween_property(attack_area, "position", Vector2(20, 0), 0.2)
   ```

3. **Som de Swing**:
   ```gdscript
   # Em melee_attack()
   $AudioStreamPlayer2D.play()  # Som de "swoosh"
   ```

4. **Partículas de Impacto**:
   ```gdscript
   # Em _on_attack_hit()
   var particles = preload("res://impact_particles.tscn").instantiate()
   particles.global_position = body.global_position
   get_tree().current_scene.add_child(particles)
   ```

---

## 📊 Comparação Antes vs Depois

| Aspecto | Antes | Depois |
|---------|-------|--------|
| **Animação** | Nenhuma | ✅ "attack" + "default" |
| **Rotação** | Centro da sprite | ✅ Base da espada |
| **Feedback Visual** | Hitbox invisível | ✅ Animação visível |
| **Configurabilidade** | Hardcoded | ✅ `sprite_offset` no .tres |
| **Reutilizável** | Não | ✅ Qualquer arma melee |

---

## ❓ Troubleshooting

### Problema: Espada não toca animação "attack"

**Causa**: Nome da animação errado ou não existe.

**Solução**:
1. Abra `sword.tres` no Godot
2. Clique em `sprite_frames`
3. Verifique se existe animação chamada **exatamente** "attack"
4. Se não, renomeie ou mude o código para usar o nome correto

---

### Problema: Espada ainda rotaciona no meio

**Causa**: `sprite_offset` muito pequeno.

**Solução**:
1. Aumente o valor Y em `sword.tres`:
   ```gdscript
   sprite_offset = Vector2(0, 30)  # ou 40, 50...
   ```
2. Teste no Godot até ficar bom
3. Use Remote Scene Tree para ajuste em tempo real

---

### Problema: Animação não volta para "default"

**Causa**: `animation_name` vazio no recurso.

**Solução**:
```gdscript
# Em sword.tres, verifique:
animation_name = "default"  # ← Deve estar preenchido
```

---

## ✅ Resumo

**Implementado com sucesso**:
- ✅ Animação "attack" toca ao atacar
- ✅ Animação volta para "default" após hitbox desativar
- ✅ Espada rotaciona na base (pivot configurável)
- ✅ Sistema funciona para qualquer arma melee
- ✅ Facilmente ajustável via `.tres`

**Pronto para uso!** 🎉

Para ajustar o pivot exato, rode o jogo e modifique `sprite_offset` em `sword.tres` até ficar perfeito.
