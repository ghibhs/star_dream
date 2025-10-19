# 📚 Índice de Documentação - Star Dream

## 🗂️ Documentação Organizada por Categoria

### 🐛 Correções de Bugs

| Documento | Descrição |
|-----------|-----------|
| [BUG_FIX_CHASE.md](BUG_FIX_CHASE.md) | Correção do sistema de perseguição de inimigos |
| [BUG_FIX_COLLISION_LAYERS.md](BUG_FIX_COLLISION_LAYERS.md) | Correção crítica das camadas de colisão do player |

### 🔍 Debug e Verificação

| Documento | Descrição |
|-----------|-----------|
| [DEBUG_DETECTION.md](DEBUG_DETECTION.md) | Sistema de debug para detecção de inimigos |
| [DEBUG_SUMMARY.md](DEBUG_SUMMARY.md) | Resumo geral do sistema de debug |
| [DEBUG_SYSTEM.md](DEBUG_SYSTEM.md) | Documentação completa do sistema de debug |
| [CHECKUP_REPORT.md](CHECKUP_REPORT.md) | Relatório de verificação do projeto |
| [CHECKUP_SUMMARY.md](CHECKUP_SUMMARY.md) | Resumo da verificação |

### ⚙️ Sistemas Principais

| Documento | Descrição |
|-----------|-----------|
| [COLLISION_SETUP.md](COLLISION_SETUP.md) | Configuração completa do sistema de colisão (6 camadas) |
| [ENEMY_SYSTEM_README.md](ENEMY_SYSTEM_README.md) | Sistema completo de IA e comportamento de inimigos |
| [SISTEMA_EMPURRAO.md](SISTEMA_EMPURRAO.md) | Sistema de empurrão dinâmico entre player e inimigos |
| [MENU_SYSTEM.md](MENU_SYSTEM.md) | Sistema completo de menus (main, pause, game over) |
| [GAME_OVER_SYSTEM.md](GAME_OVER_SYSTEM.md) | Sistema de morte e reinício |

### 🎯 Combate e Hitbox

| Documento | Descrição |
|-----------|-----------|
| [HITBOX_POSITIONING.md](HITBOX_POSITIONING.md) | Posicionamento correto de hitboxes |
| [HITBOX_QUICK_REFERENCE.md](HITBOX_QUICK_REFERENCE.md) | Referência rápida para hitboxes |
| [MELEE_ANIMATION_UPDATE.md](MELEE_ANIMATION_UPDATE.md) | Atualização do sistema de animação de ataque corpo a corpo |

### 🚀 Guias Rápidos

| Documento | Descrição |
|-----------|-----------|
| [QUICK_START_ENEMIES.md](QUICK_START_ENEMIES.md) | Guia rápido para criar e configurar novos inimigos |

---

## 📖 Por Onde Começar?

### Novo no Projeto?
1. Leia o [README.md](../README.md) na raiz do projeto
2. Consulte [COLLISION_SETUP.md](COLLISION_SETUP.md) para entender as colisões
3. Veja [ENEMY_SYSTEM_README.md](ENEMY_SYSTEM_README.md) para criar inimigos

### Problemas com Colisão?
→ [BUG_FIX_COLLISION_LAYERS.md](BUG_FIX_COLLISION_LAYERS.md)
→ [COLLISION_SETUP.md](COLLISION_SETUP.md)

### Criando um Novo Inimigo?
→ [QUICK_START_ENEMIES.md](QUICK_START_ENEMIES.md)
→ [ENEMY_SYSTEM_README.md](ENEMY_SYSTEM_README.md)

### Configurando Hitboxes?
→ [HITBOX_QUICK_REFERENCE.md](HITBOX_QUICK_REFERENCE.md)
→ [HITBOX_POSITIONING.md](HITBOX_POSITIONING.md)

### Problemas com Menus?
→ [MENU_SYSTEM.md](MENU_SYSTEM.md)
→ [GAME_OVER_SYSTEM.md](GAME_OVER_SYSTEM.md)

### Debug de Inimigos?
→ [DEBUG_DETECTION.md](DEBUG_DETECTION.md)
→ [DEBUG_SYSTEM.md](DEBUG_SYSTEM.md)

---

## 🎓 Tutoriais Passo a Passo

### Como Criar um Novo Inimigo

1. **Criar o Resource**
   ```gdscript
   # EnemyData/novo_inimigo.tres
   enemy_name = "Novo Inimigo"
   max_health = 50.0
   damage = 10.0
   move_speed = 80.0
   push_force = 50.0  # Ver SISTEMA_EMPURRAO.md
   ```
   📖 [QUICK_START_ENEMIES.md](QUICK_START_ENEMIES.md)

2. **Configurar Colisões**
   - Layer: 4 (Enemy)
   - Mask: 1+2+16 (World, Player, Player Hitbox)
   
   📖 [COLLISION_SETUP.md](COLLISION_SETUP.md)

3. **Adicionar à Cena**
   - Instanciar `scenes/enemy/enemy.tscn`
   - Atribuir o resource criado
   
   📖 [ENEMY_SYSTEM_README.md](ENEMY_SYSTEM_README.md)

### Como Ajustar Sistema de Empurrão

1. **Configurar força do jogador**
   ```gdscript
   # scripts/player/entidades.gd
   @export var player_push_strength: float = 100.0
   ```

2. **Configurar resistência do inimigo**
   ```gdscript
   # EnemyData/inimigo.tres
   push_force = 60.0  # Menor que 100 = empurrável
   ```

3. **Testar resultado**
   - 100 > 60 ✅ Empurra
   - 100 < 150 ❌ Não empurra
   
   📖 [SISTEMA_EMPURRAO.md](SISTEMA_EMPURRAO.md)

---

## 🔧 Troubleshooting

| Problema | Solução |
|----------|---------|
| Inimigo não detecta player | [BUG_FIX_COLLISION_LAYERS.md](BUG_FIX_COLLISION_LAYERS.md) |
| Player não leva dano | [HITBOX_POSITIONING.md](HITBOX_POSITIONING.md) |
| Inimigo não persegue | [BUG_FIX_CHASE.md](BUG_FIX_CHASE.md) |
| Player fica travado | [SISTEMA_EMPURRAO.md](SISTEMA_EMPURRAO.md) |
| Menu não funciona | [MENU_SYSTEM.md](MENU_SYSTEM.md) |
| Animação de ataque errada | [MELEE_ANIMATION_UPDATE.md](MELEE_ANIMATION_UPDATE.md) |

---

## 📊 Arquitetura do Projeto

```
Sistemas Principais:
├── Colisão (6 camadas)
├── Inimigos (AI baseada em estados)
├── Empurrão (Baseado em força)
├── Menus (Main, Pause, Game Over)
├── Combate (Hitbox + Damage)
└── Stats (GameStats Autoload)
```

📖 Veja [README.md](../README.md) para estrutura completa de pastas

---

**Total de Documentos**: 16
**Última Atualização**: Organização completa do projeto
**Versão**: test_v02 (thirdversion)
