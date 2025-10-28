# 🎯 Sistema de Posicionamento da Hitbox - Quick Reference

## ✅ Implementado!

### O que foi feito:
```gdscript
// No setup_attack_area() de entidades.gd:
attack_area.position = current_weapon_data.attack_collision_position
```

### Output no console:
```
[PLAYER] Criando hitbox de melee...
[PLAYER]    Hitbox position: (20.0, 0.0)  ← Do .tres!
[PLAYER]    Hitbox shape: <RectangleShape2D>
```

---

## 📝 Como Configurar no .tres

### Campos Importantes:
```gdresource
weapon_marker_position = Vector2(0, 8)      # Pivot de rotação
attack_collision_position = Vector2(20, 0)  # ← POSIÇÃO DA HITBOX
attack_collision = RectangleShape2D         # Forma da hitbox
sprite_position = Vector2(20, 0)            # Visual alinhado
```

---

## 🎨 Exemplos Práticos

### Espada (alcance na ponta):
```
attack_collision_position = Vector2(30, 0)
```
```
[Player]----[Sprite]----[Hitbox]
                 30px →
```

### Adaga (alcance curto):
```
attack_collision_position = Vector2(10, 0)
```
```
[Player]-[Sprite]-[Hitbox]
         10px →
```

### Martelo (área ao redor):
```
attack_collision_position = Vector2(0, 0)
attack_collision = CircleShape2D  # Grande raio
```
```
     [Hitbox área]
        [Player]
```

---

## 🔍 Como Visualizar

### No Editor:
1. Debug → Visible Collision Shapes (F7)
2. Execute o jogo
3. Ataque com a arma
4. Hitbox aparece em **azul** quando ativa

### Sistema de Coordenadas:
```
     Y- (↑ Cima)
      |
X- ←--+--→ X+ (Direita)
      |
     Y+ (↓ Baixo)
```

---

## 📊 Configurações Recomendadas

| Arma | X | Y | Explicação |
|------|---|---|------------|
| Espada Curta | 15 | 0 | Perto do player |
| Espada Longa | 30 | 0 | Longe do player |
| Lança | 50 | 0 | Muito longe |
| Adaga | 10 | 0 | Bem perto |
| Machado | 20 | -5 | Levemente acima |
| Martelo | 0 | 0 | Centralizado (CircleShape2D) |

---

## ⚡ Funcionalidades

✅ Posição automática do .tres  
✅ Debug com valores exatos  
✅ Rotação junto com o marker  
✅ Fallback para Vector2.ZERO  
✅ Mensagem de aviso se não definido  

---

## 🎯 Teste Rápido

1. Abra `ItemData/sword.tres`
2. Modifique `attack_collision_position`
3. Execute o jogo
4. Equipe a espada
5. Veja no console a posição aplicada
6. Ataque e observe a hitbox (F7)

**Documentação completa:** `HITBOX_POSITIONING.md`
