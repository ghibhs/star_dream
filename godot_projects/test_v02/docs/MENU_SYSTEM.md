# 🎮 Sistema de Menu e Reinício - Documentação

## 📁 Arquivos Criados

### 1. **main_menu.tscn** - Tela do Menu Principal
Interface visual com:
- Título "STAR DREAM"
- Botão "INICIAR JOGO" (inicia the_game.tscn)
- Botão "OPÇÕES" (placeholder)
- Botão "SAIR" (fecha o jogo)
- Versão do jogo

### 2. **main_menu.gd** - Lógica do Menu
Funcionalidades:
- `_on_start_button_pressed()` - Carrega o jogo
- `_on_options_button_pressed()` - Abre opções (a implementar)
- `_on_quit_button_pressed()` - Fecha o jogo
- `start_game()` - Transição para the_game.tscn

### 3. **game_over.gd** - Atualizado
Agora o botão "MENU PRINCIPAL" funciona:
- Despausa o jogo
- Carrega main_menu.tscn
- Retorna ao menu inicial

---

## ⚙️ Configuração Manual Necessária

### Passo 1: Definir Main Scene (Menu Inicial)

1. Abra o Godot Editor
2. Vá em **Project → Project Settings**
3. Na aba **General**, procure **Application → Run**
4. Em **Main Scene**, clique no ícone de pasta
5. Selecione `main_menu.tscn`
6. Clique **Close**

**Ou edite manualmente o `project.godot`:**
```ini
[application]
run/main_scene="res://main_menu.tscn"
```

### Passo 2: Configurar Autoload GameStats (se ainda não fez)

1. Vá em **Project → Project Settings**
2. Aba **Autoload**
3. **Path:** `res://game_stats.gd`
4. **Node Name:** `GameStats`
5. Clique **Add**

---

## 🎯 Fluxo de Navegação

```
┌─────────────────┐
│  Main Menu      │ ← Cena inicial
│  main_menu.tscn │
└────────┬────────┘
         │ [INICIAR JOGO]
         ↓
┌─────────────────┐
│  The Game       │
│  the_game.tscn  │
└────────┬────────┘
         │ [Player morre]
         ↓
┌─────────────────┐
│  Game Over      │
│  game_over.tscn │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
[REINICIAR] [MENU]
    │         │
    ↓         ↓
the_game  main_menu
```

---

## 🎮 Funcionalidades Implementadas

### Menu Principal (main_menu.tscn)

**Botão INICIAR JOGO:**
```gdscript
func _on_start_button_pressed() -> void:
    get_tree().change_scene_to_file("res://the_game.tscn")
```
✅ Carrega a cena do jogo
✅ Começa uma nova partida

**Botão OPÇÕES:**
```gdscript
func _on_options_button_pressed() -> void:
    # TODO: Implementar tela de opções
    print("[MAIN_MENU] Opções ainda não implementadas")
```
⏳ Placeholder para futuras configurações

**Botão SAIR:**
```gdscript
func _on_quit_button_pressed() -> void:
    get_tree().quit()
```
✅ Fecha o jogo

### Game Over (game_over.tscn)

**Botão REINICIAR:**
```gdscript
func _on_restart_button_pressed() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()
```
✅ Despausa o jogo
✅ Recarrega the_game.tscn
✅ Reinicia com tudo zerado

**Botão MENU PRINCIPAL:**
```gdscript
func _on_menu_button_pressed() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://main_menu.tscn")
```
✅ Despausa o jogo
✅ Volta para o menu inicial
✅ Permite começar nova partida

**Botão SAIR:**
```gdscript
func _on_quit_button_pressed() -> void:
    get_tree().quit()
```
✅ Fecha o jogo

---

## 📊 Sistema de Estatísticas

### GameStats (Autoload Global)

**Variáveis rastreadas:**
- `enemies_defeated` - Total de inimigos derrotados
- `survival_time` - Tempo de sobrevivência em segundos

**Métodos principais:**
```gdscript
start_game()         # Inicia contagem (chamado no player._ready())
stop_game()          # Para contagem (chamado no player.die())
enemy_defeated()     # Incrementa contador (chamado no enemy.die())
reset_stats()        # Zera estatísticas
```

**Ciclo de vida:**
```
Menu → [INICIAR] → GameStats.start_game()
                 → Player spawna
                 → Jogo roda...
                 → Player morre
                 → GameStats.stop_game()
                 → Game Over mostra stats
                 
Game Over → [REINICIAR] → reload_current_scene()
                         → GameStats.start_game() (automático no player._ready())
         
         → [MENU] → main_menu.tscn
                  → Estatísticas mantidas (não resetadas)
```

**⚠️ Nota:** As estatísticas persistem entre cenas até o jogo fechar!

---

## 🎨 Personalização do Menu

### Cores e Estilo

**Fundo:**
```gdscript
ColorRect.color = Color(0.1, 0.1, 0.15, 1)  # Azul escuro
```

**Título:**
```gdscript
TitleLabel.theme_override_font_sizes/font_size = 72
TitleLabel.text = "STAR DREAM"
```

**Botões:**
```gdscript
theme_override_colors/font_hover_color = Color(1, 0.8, 0.2, 1)  # Amarelo ao passar mouse
```

### Adicionar Animações (Opcional)

No `main_menu.gd._ready()`:
```gdscript
func _ready() -> void:
    # Fade in do menu
    modulate.a = 0
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 1.0, 0.5)
```

---

## 🧪 Teste do Sistema

### Teste 1: Menu → Jogo
1. Execute o projeto
2. Menu principal deve aparecer
3. Clique em "INICIAR JOGO"
4. **Resultado esperado:** Jogo carrega normalmente

**Log esperado:**
```
[MAIN_MENU] Menu principal inicializado
[MAIN_MENU] 🎮 Botão INICIAR JOGO pressionado
[MAIN_MENU]    ✅ Transição para jogo iniciada
[PLAYER] Inicializado e adicionado ao grupo 'player'
```

### Teste 2: Game Over → Reiniciar
1. Deixe o player morrer
2. Tela de Game Over aparece
3. Clique em "REINICIAR"
4. **Resultado esperado:** Jogo recarrega, player volta ao início

**Log esperado:**
```
[GAME_OVER] 🔄 Botão REINICIAR pressionado
[GAME_OVER] Cena recarregada
[PLAYER] Inicializado e adicionado ao grupo 'player'
[PLAYER] Saúde inicializada: 100.0/100.0
```

### Teste 3: Game Over → Menu
1. Deixe o player morrer
2. Tela de Game Over aparece
3. Clique em "MENU PRINCIPAL"
4. **Resultado esperado:** Volta para menu inicial

**Log esperado:**
```
[GAME_OVER] 🏠 Botão MENU PRINCIPAL pressionado
[GAME_OVER]    ✅ Voltando para menu principal
[MAIN_MENU] Menu principal inicializado
```

### Teste 4: Sair do Jogo
1. No menu principal, clique em "SAIR"
2. **Resultado esperado:** Jogo fecha completamente

---

## 🚀 Próximas Melhorias

### Opções Sugeridas:
- [ ] Tela de opções (volume, fullscreen, controles)
- [ ] Animações de transição entre cenas
- [ ] Música de fundo no menu
- [ ] Efeitos sonoros nos botões
- [ ] Pause menu durante o jogo (tecla ESC)
- [ ] Save/Load de highscores
- [ ] Seleção de dificuldade
- [ ] Tutorial inicial

### Pause Menu (Sugestão):

Criar `pause_menu.tscn` com botões:
- Continuar (despausa)
- Reiniciar (reload)
- Opções
- Menu Principal
- Sair

Adicionar no `entidades.gd` ou `the_game.gd`:
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):  # ESC
        toggle_pause()
```

---

## ✅ Checklist de Implementação

- [x] main_menu.tscn criado
- [x] main_menu.gd criado
- [x] Botão INICIAR JOGO funcional
- [x] Botão SAIR funcional
- [x] game_over.gd atualizado
- [x] Botão REINICIAR funcional
- [x] Botão MENU PRINCIPAL funcional
- [ ] **Main Scene configurada no project.godot** ⚠️ FAZER MANUALMENTE
- [ ] **GameStats autoload configurado** ⚠️ FAZER MANUALMENTE (se ainda não fez)
- [ ] Testado: Menu → Jogo
- [ ] Testado: Game Over → Reiniciar
- [ ] Testado: Game Over → Menu
- [ ] Testado: Sair do jogo

---

## 📝 Comandos de Debug

### Recarregar Cena Atual (Console):
```gdscript
get_tree().reload_current_scene()
```

### Ir para Menu (Console):
```gdscript
get_tree().change_scene_to_file("res://main_menu.tscn")
```

### Ir para Jogo (Console):
```gdscript
get_tree().change_scene_to_file("res://the_game.tscn")
```

### Pausar/Despausar (Console):
```gdscript
get_tree().paused = true   # Pausa
get_tree().paused = false  # Despausa
```

---

**Sistema de Menu e Reinício completo!** 🎉

Lembre-se de configurar a Main Scene no Project Settings!
