# 🎯 Sistema de Posicionamento da Hitbox Melee

## 📋 Configuração no .tres

### Campo Disponível no WeaponData.gd:
```gdscript
@export var attack_collision_position: Vector2 = Vector2.ZERO
```

Este campo define **onde a hitbox de ataque melee será posicionada** em relação ao `weapon_marker`.

---

## 🔧 Como Funciona

### Hierarquia de Nodes:
```
Player (CharacterBody2D)
└─ WeaponMarker2D (position definida por weapon_marker_position)
   └─ attack_area (Area2D - position definida por attack_collision_position)
      └─ CollisionShape2D (shape definido por attack_collision)
```

### Fluxo de Posicionamento:

1. **weapon_marker_position** → Posiciona o marker (pivot de rotação)
2. **attack_collision_position** → Posiciona a hitbox em relação ao marker
3. **attack_collision** → Define a forma/tamanho da hitbox

---

## 🎮 Exemplos de Configuração

### Espada (sword.tres):
```gdresource
weapon_marker_position = Vector2(0, 8)      # Marker no bottom do sprite
attack_collision_position = Vector2(20, 0)  # Hitbox 20px à direita
attack_collision = RectangleShape2D         # Formato retangular
sprite_position = Vector2(20, 0)            # Sprite alinhado com hitbox
```

**Resultado Visual:**
```
     [Marker]
        |
        | (0, 8)
        ▼
     [Player]
        |
        +----[Sprite]----[Hitbox]
                (20, 0)    (collision)
                
→ Hitbox fica na ponta da espada
```

---

### Arco (bow.tres):
```gdresource
weapon_marker_position = Vector2(0, 0)      # Marker no centro
attack_collision_position = Vector2(0, 0)   # Hitbox no centro (não usado)
attack_collision = CircleShape2D            # Formato circular (backup)
weapon_type = "projectile"                  # Usa projéteis, não melee
```

---

## ⚙️ Implementação no Código

### No setup_attack_area() (entidades.gd):
```gdscript
func setup_attack_area() -> void:
    if current_weapon_data.attack_collision:
        attack_area = Area2D.new()
        
        # ✅ APLICA POSIÇÃO DO .TRES
        if "attack_collision_position" in current_weapon_data:
            attack_area.position = current_weapon_data.attack_collision_position
            print("[PLAYER]    Hitbox position: ", current_weapon_data.attack_collision_position)
        else:
            attack_area.position = Vector2.ZERO
            print("[PLAYER]    ⚠️ attack_collision_position não definido")
        
        # Cria collision shape
        var collision_shape := CollisionShape2D.new()
        collision_shape.shape = current_weapon_data.attack_collision
        attack_area.add_child(collision_shape)
        
        # Adiciona como filho do marker
        weapon_marker.add_child(attack_area)
```

---

## 📐 Coordenadas e Referências

### Sistema de Coordenadas:
```
        Y- (Cima)
         |
         |
X- ------+------ X+ (Direita)
         |
         |
        Y+ (Baixo)
```

### Exemplos de Posicionamento:

| Posição | Vector2 | Onde fica |
|---------|---------|-----------|
| Centro | `(0, 0)` | No marker |
| Direita | `(20, 0)` | 20px à direita |
| Esquerda | `(-20, 0)` | 20px à esquerda |
| Baixo | `(0, 20)` | 20px abaixo |
| Cima | `(0, -20)` | 20px acima |
| Diagonal | `(15, 15)` | Baixo-direita |

---

## 🎨 Configurando no Editor Godot

### Passo a Passo:

1. **Abra o arquivo .tres da arma** (ex: sword.tres)
2. **Localize o campo `attack_collision_position`**
3. **Configure os valores X e Y:**
   - **X positivo** → Hitbox vai para direita
   - **X negativo** → Hitbox vai para esquerda
   - **Y positivo** → Hitbox vai para baixo
   - **Y negativo** → Hitbox vai para cima

4. **Teste no jogo:**
   - Execute o jogo
   - Equipe a arma
   - Observe no console: `[PLAYER]    Hitbox position: (X, Y)`
   - Ative **Debug → Visible Collision Shapes** para ver visualmente

---

## 🔍 Debug Visual

### Ver Hitbox no Editor:
```
1. Menu: Debug → Visible Collision Shapes (ou F7)
2. Execute o jogo
3. A hitbox aparece em azul quando ativa
4. Verifique se está posicionada corretamente
```

### Mensagens de Debug:
```
[PLAYER] Criando hitbox de melee...
[PLAYER]    Hitbox position: (20.0, 0.0)  ← Confirma posição do .tres
[PLAYER]    Hitbox shape: <RectangleShape2D>
[PLAYER]    Layer: 16, Mask: 4
```

---

## 📊 Diferença Entre Campos

| Campo | Afeta | Exemplo |
|-------|-------|---------|
| `weapon_marker_position` | Posição do pivot (rotação) | `(0, 8)` = pivot no bottom |
| `attack_collision_position` | Posição da hitbox | `(20, 0)` = hitbox 20px direita |
| `sprite_position` | Posição do sprite visual | `(20, 0)` = sprite alinha com hitbox |
| `attack_collision` | Forma/tamanho da hitbox | `RectangleShape2D` |

---

## 🎯 Casos de Uso Comuns

### 1. Espada Longa (alcance na ponta):
```gdresource
weapon_marker_position = Vector2(0, 5)
attack_collision_position = Vector2(30, 0)  # Longe do player
sprite_position = Vector2(30, 0)
```

### 2. Adaga (alcance curto, próximo):
```gdresource
weapon_marker_position = Vector2(0, 3)
attack_collision_position = Vector2(10, 0)  # Perto do player
sprite_position = Vector2(10, 0)
```

### 3. Martelo (grande área, centralizado):
```gdresource
weapon_marker_position = Vector2(0, 10)
attack_collision_position = Vector2(0, 0)  # Centralizado
sprite_position = Vector2(0, 0)
attack_collision = CircleShape2D  # Área circular
```

### 4. Lança (muito alcance):
```gdresource
weapon_marker_position = Vector2(0, 8)
attack_collision_position = Vector2(50, 0)  # Muito longe
sprite_position = Vector2(50, 0)
attack_collision = CapsuleShape2D  # Alongada
```

---

## ⚠️ Notas Importantes

1. **Position é relativa ao marker:**
   - Se marker está em `(0, 8)`
   - E hitbox em `(20, 0)`
   - Hitbox final estará em `(20, 8)` do player

2. **Rotação afeta posição:**
   - O marker rotaciona para o mouse
   - A hitbox rotaciona junto
   - Position rotaciona ao redor do marker

3. **Collision Shape também tem transform:**
   - O `CollisionShape2D` filho pode ter posição própria
   - Mas geralmente deixa-se `(0, 0)` e usa a position do `Area2D`

---

## ✅ Checklist de Configuração

- [ ] `weapon_marker_position` definido no .tres
- [ ] `attack_collision_position` definido no .tres
- [ ] `attack_collision` (shape) definido no .tres
- [ ] `sprite_position` alinhado com `attack_collision_position`
- [ ] Testado no jogo com collision shapes visíveis
- [ ] Hitbox acerta inimigos na posição esperada

---

## 🚀 Status

✅ **Sistema implementado e funcional!**

- Campo `attack_collision_position` existente no WeaponData.gd
- Aplicado automaticamente no `setup_attack_area()`
- Mensagens de debug confirmam posição
- Pronto para configuração nos .tres files

**Agora você tem controle total sobre onde a hitbox aparece!** 🎯
