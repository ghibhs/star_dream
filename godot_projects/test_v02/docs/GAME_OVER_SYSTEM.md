# 🎮 Sistema de Game Over - Documentação Completa

## 📋 Visão Geral

Sistema completo de tela de morte com:
- ✅ Tela de Game Over com UI completa
- ✅ Estatísticas (inimigos derrotados, tempo de sobrevivência)
- ✅ Botões para reiniciar, menu e sair
- ✅ Pausa automática do jogo
- ✅ Sistema de tracking global de estatísticas

---

## 🗂️ Arquivos Criados

### 1. **game_over.tscn** - Cena da Tela de Game Over
```
CanvasLayer
├─ ColorRect (fundo escuro semi-transparente)
└─ CenterContainer
   └─ VBoxContainer
      ├─ TitleLabel ("VOCÊ MORREU")
      ├─ StatsLabel (estatísticas)
      ├─ RestartButton
      ├─ MenuButton
      └─ QuitButton
```

### 2. **game_over.gd** - Script da Tela
Funcionalidades:
- Pausa o jogo automaticamente
- Exibe estatísticas
- Gerencia botões
- Recarrega cena ou sai do jogo

### 3. **game_stats.gd** - Autoload de Estatísticas Globais
Rastreia:
- `enemies_defeated` - Total de inimigos derrotados
- `survival_time` - Tempo de sobrevivência
- `game_started` - Flag de jogo ativo

---

## ⚙️ Configuração Necessária

### Passo 1: Adicionar Autoload

1. **Menu:** Project → Project Settings → Autoload
2. **Adicionar:**
   - **Path:** `res://game_stats.gd`
   - **Node Name:** `GameStats`
   - **Enable:** ✅ Checked
3. **Salvar**

### Passo 2: Configurar Process Mode

Para que a tela de Game Over funcione enquanto o jogo está pausado:

1. Abra `game_over.tscn` no editor
2. Selecione o node **GameOver** (CanvasLayer raiz)
3. No Inspector, vá em **Node → Process**
4. Defina **Process Mode** como: **Always** ou **When Paused**

---

## 🎯 Como Funciona

### Fluxo de Morte do Player:

```
1. Player HP <= 0
   ↓
2. entidades.gd: die() chamado
   ↓
3. set_physics_process(false) - Para movimento
   ↓
4. GameStats.stop_game() - Para contagem de tempo
   ↓
5. await 1.5 segundos (animação de morte)
   ↓
6. show_game_over() - Carrega game_over.tscn
   ↓
7. get_tree().paused = true - Pausa o jogo
   ↓
8. Tela de Game Over exibida
```

### Fluxo de Estatísticas:

**No início do jogo:**
```gdscript
// entidades._ready()
GameStats.start_game()  // Reseta stats e inicia timer
```

**Quando inimigo morre:**
```gdscript
// enemy.die()
GameStats.enemy_defeated()  // Incrementa contador
```

**Quando player morre:**
```gdscript
// entidades.die()
GameStats.stop_game()  // Para timer de sobrevivência
```

**Na tela de Game Over:**
```gdscript
// game_over._ready()
var stats = GameStats
enemies_defeated = stats.enemies_defeated
survival_time = stats.survival_time
```

---

## 🎨 Aparência da Tela

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│         VOCÊ MORREU                 │
│       (vermelho, 64px)              │
│                                     │
│                                     │
│         Estatísticas:               │
│     Inimigos Derrotados: 12         │
│     Tempo Sobrevivido: 03:45        │
│                                     │
│                                     │
│      ┌─────────────────┐            │
│      │    REINICIAR    │            │
│      └─────────────────┘            │
│      ┌─────────────────┐            │
│      │ MENU PRINCIPAL  │            │
│      └─────────────────┘            │
│      ┌─────────────────┐            │
│      │  SAIR DO JOGO   │            │
│      └─────────────────┘            │
│                                     │
└─────────────────────────────────────┘
```

---

## 🎮 Funcionalidades dos Botões

### 1️⃣ Botão REINICIAR
```gdscript
func _on_restart_button_pressed():
    get_tree().paused = false
    get_tree().reload_current_scene()
```
- Despausa o jogo
- Recarrega a cena atual
- Reinicia tudo do zero

### 2️⃣ Botão MENU PRINCIPAL
```gdscript
func _on_menu_button_pressed():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://menu.tscn")
```
- Despausa o jogo
- Vai para o menu principal
- **⚠️ Implementar menu.tscn se necessário**

### 3️⃣ Botão SAIR DO JOGO
```gdscript
func _on_quit_button_pressed():
    get_tree().quit()
```
- Fecha o jogo completamente

---

## 📊 Estatísticas Rastreadas

### Inimigos Derrotados
```gdscript
// Cada vez que um inimigo morre:
GameStats.enemy_defeated()
```
**Incrementa:** `GameStats.enemies_defeated += 1`

### Tempo de Sobrevivência
```gdscript
// Conta automaticamente em _process:
func _process(delta):
    if game_started:
        survival_time += delta
```
**Formato exibido:** `MM:SS` (ex: 03:45)

---

## 🔧 Modificações nos Scripts Existentes

### entidades.gd (Player):

**No _ready():**
```gdscript
if has_node("/root/GameStats"):
    get_node("/root/GameStats").start_game()
```

**No die():**
```gdscript
func die():
    is_dead = true
    set_physics_process(false)
    velocity = Vector2.ZERO
    
    if has_node("/root/GameStats"):
        get_node("/root/GameStats").stop_game()
    
    await get_tree().create_timer(1.5).timeout
    show_game_over()

func show_game_over():
    var game_over_scene = load("res://game_over.tscn")
    var game_over_instance = game_over_scene.instantiate()
    get_tree().current_scene.add_child(game_over_instance)
```

### enemy.gd (Inimigo):

**No die():**
```gdscript
func die():
    # ... código existente ...
    
    # Contabiliza inimigo derrotado
    if has_node("/root/GameStats"):
        get_node("/root/GameStats").enemy_defeated()
    
    # ... resto do código ...
```

---

## 🐛 Debug do Sistema

### Mensagens de Log:

**Ao iniciar o jogo:**
```
[PLAYER] Saúde inicializada: 100.0/100.0
[PLAYER] Sistema de estatísticas iniciado
[GAME_STATS] 🎮 Jogo iniciado, resetando estatísticas
```

**Ao derrotar inimigo:**
```
[ENEMY] ☠️☠️☠️ Lobo Veloz MORREU! ☠️☠️☠️
[GAME_STATS] 💀 Inimigo derrotado! Total: 1
```

**Ao morrer:**
```
[PLAYER] ☠️☠️☠️ PLAYER MORREU! ☠️☠️☠️
[PLAYER]    Physics desativado
[GAME_STATS] ⏹️ Jogo pausado
[PLAYER] 📺 Mostrando tela de Game Over
[GAME_OVER] Tela de Game Over inicializada
[GAME_OVER] Jogo pausado
[GAME_OVER] Estatísticas:
[GAME_OVER]    Inimigos: 5
[GAME_OVER]    Tempo: 03:24
```

**Ao reiniciar:**
```
[GAME_OVER] 🔄 Botão REINICIAR pressionado
[GAME_OVER] Cena recarregada
```

---

## 🎨 Personalização

### Mudar Cores:

**No game_over.tscn:**
```gdscript
# Fundo
ColorRect.color = Color(0, 0, 0, 0.8)  # Preto 80% opaco

# Título
TitleLabel.theme_override_colors/font_color = Color(1, 0.2, 0.2, 1)  # Vermelho
```

### Mudar Textos:

```gdscript
TitleLabel.text = "GAME OVER"
RestartButton.text = "Try Again"
MenuButton.text = "Main Menu"
QuitButton.text = "Exit"
```

### Adicionar Animação:

```gdscript
func _ready():
    # Fade in da tela
    modulate.a = 0
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 1.0, 0.5)
```

---

## ✅ Checklist de Implementação

- [x] game_over.tscn criado
- [x] game_over.gd criado
- [x] game_stats.gd criado (autoload)
- [ ] **Autoload configurado no Project Settings** ⚠️ FAZER MANUALMENTE
- [ ] **Process Mode configurado em game_over.tscn** ⚠️ FAZER MANUALMENTE
- [x] entidades.gd modificado (die + start_game)
- [x] enemy.gd modificado (enemy_defeated)
- [x] Debug messages adicionados

---

## 🚀 Teste Rápido

1. **Configure o Autoload** (Project Settings)
2. **Execute o jogo**
3. **Deixe o player morrer** (inimigos causam dano)
4. **Aguarde 1.5 segundos**
5. **Tela de Game Over deve aparecer**
6. **Verifique estatísticas**
7. **Teste botão REINICIAR**

---

## ⚠️ Troubleshooting

### Problema: "Jogo não pausa"
**Solução:** Configure Process Mode do GameOver para "Always" ou "When Paused"

### Problema: "Estatísticas zeradas"
**Solução:** Verifique se GameStats está no Autoload

### Problema: "Tela não aparece"
**Causa:** game_over.tscn não encontrado  
**Solução:** Verifique path em `load("res://game_over.tscn")`

### Problema: "Botões não funcionam"
**Causa:** Signals não conectados  
**Solução:** Verifique connections no game_over.tscn

---

## 📚 Próximas Melhorias

- [ ] Animação de fade in/out
- [ ] Sons de game over
- [ ] Highscore system
- [ ] Menu principal completo
- [ ] Salvar estatísticas
- [ ] Achievements
- [ ] Replay da partida

---

**Sistema completo e funcional!** 🎉
