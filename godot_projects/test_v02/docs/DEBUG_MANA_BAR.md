# 🔍 DEBUG - Barra de Mana Não Diminui

## ✅ O que foi feito:

### 1. **Adicionado Debug Extensivo**
   
#### No `mana_bar.gd`:
- ✅ Print quando player é encontrado
- ✅ Print quando sinais são conectados
- ✅ Print dos valores iniciais (max_mana, current_mana)
- ✅ Print toda vez que `_on_mana_changed()` é chamado
- ✅ Aguarda frame antes de buscar player (`await get_tree().process_frame`)

#### No `player.gd`:
- ✅ Print detalhado na inicialização da mana
- ✅ Print ANTES de consumir mana
- ✅ Print DEPOIS de consumir mana
- ✅ Print quando emite sinal `mana_changed`
- ✅ Print confirmando que sinal foi emitido

---

## 🎮 Como Testar:

### 1. **Abra o Console do Godot**
   - Rode o jogo (F5)
   - Olhe o console na parte de baixo

### 2. **Verifique os Logs de Inicialização**

Você deve ver algo assim:

```
[PLAYER] 🔮 ═══ INICIALIZANDO MANA ═══
[PLAYER]    Max Mana: 100.0
[PLAYER]    Current Mana: 100.0
[PLAYER]    Emitindo sinal mana_changed...
[PLAYER]    Emitindo sinal max_mana_changed...
[PLAYER] ═══════════════════════════════

[MANA_BAR] ✅ Player encontrado: Player
[MANA_BAR] ✅ Conectado ao sinal mana_changed
[MANA_BAR] ✅ Conectado ao sinal max_mana_changed
[MANA_BAR] Max mana: 100.0
[MANA_BAR] Current mana: 100.0
[MANA_BAR] 🔮 Mana atualizada: 100.0/100.0
```

### 3. **Teste Lançar uma Magia**
   - Pressione **E** para selecionar próxima magia
   - Pressione **Botão Direito do Mouse** para lançar

Você deve ver:

```
[PLAYER] 🔮 ANTES de consumir - Mana: 100.0
[PLAYER] 🔮 DEPOIS de consumir - Mana: 85.0
[PLAYER] 🔮 Emitindo sinal mana_changed com valor: 85.0
[PLAYER] 🔮 Sinal emitido!

[MANA_BAR] 🔮 Mana atualizada: 85.0/100.0
```

---

## ❌ Possíveis Problemas:

### Problema 1: Player não encontrado
```
[MANA_BAR] ❌ Player não encontrado!
```

**Solução:**
- Verifique se o player tem o grupo "player"
- No Godot, selecione o nó Player
- Vá em "Node" → "Groups"
- Adicione o grupo "player"

### Problema 2: Sinal não existe
```
[MANA_BAR] ❌ Sinal mana_changed não existe no player!
```

**Solução:**
- Verificar se no início do `player.gd` tem:
```gdscript
signal mana_changed(new_mana: float)
signal max_mana_changed(new_max_mana: float)
```

### Problema 3: Sinal emitido mas barra não atualiza
```
[PLAYER] 🔮 Sinal emitido!
```
Mas não aparece:
```
[MANA_BAR] 🔮 Mana atualizada: ...
```

**Solução:**
- O sinal não está conectado corretamente
- Recarregue o projeto (Project → Reload Current Project)
- Ou recrie a conexão manualmente

### Problema 4: Barra existe mas não está visível
- Verifique se `ManaBarUI` está com `visible = true`
- Verifique se está na camada 100 (deveria estar acima de tudo)
- Verifique a posição: canto superior direito

---

## 🔧 Verificações Rápidas:

1. **O player tem o grupo "player"?**
   - Selecione o nó Player
   - Tab "Node" → "Groups"
   - Deve ter "player" na lista

2. **A barra está visível no editor?**
   - Abra `player.tscn`
   - Selecione `ManaBarUI/ManaBar`
   - Deve estar visível (olho aberto)

3. **O script está anexado?**
   - Selecione `ManaBarUI/ManaBar`
   - No Inspector, deve ter `Script: mana_bar.gd`

---

## 🎯 Teste Definitivo:

Execute este teste simples:

1. Rode o jogo (F5)
2. Olhe o console - deve ver inicialização
3. Pressione **E** para mudar magia
4. Pressione **Botão Direito** para lançar
5. Olhe o console novamente

**Se aparecer:**
```
[PLAYER] 🔮 DEPOIS de consumir - Mana: 85.0
[MANA_BAR] 🔮 Mana atualizada: 85.0/100.0
```

**A barra DEVE diminuir!**

---

## 📊 O que Esperar:

### Visual da Barra:
- **Antes:** Barra azul 100% cheia
- **Depois de lançar Fireball (15 mana):** Barra 85% cheia
- **Depois de lançar Ice Bolt (12 mana):** Barra 73% cheia
- **Depois de lançar Heal (20 mana):** Barra 53% cheia

### Regeneração:
- A barra deve **encher gradualmente** (5 mana/segundo)
- Em ~10 segundos volta a 100%

---

## 🚨 Se AINDA não funcionar:

**Me envie o seguinte do console:**

1. Todos os logs com `[MANA_BAR]`
2. Todos os logs com `[PLAYER] 🔮`
3. Screenshot da hierarquia da cena (mostrando ManaBarUI/ManaBar)
4. Screenshot do Inspector do nó ManaBar (mostrando o script)

---

**Teste agora e me diga o que aparece no console! 🔍**
