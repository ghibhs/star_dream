# 🎮 Star Dream - Projeto de Jogo RPG 2D

<div align="center">

![Godot Engine](https://img.shields.io/badge/Godot-4.5-blue?logo=godot-engine)
![Status](https://img.shields.io/badge/status-Em%20Desenvolvimento-yellow)
![License](https://img.shields.io/badge/license-MIT-green)

**Sistema de combate RPG com inimigos, magias e inventário desenvolvido em Godot Engine**

[🎯 Características](#-características-principais) • 
[📥 Instalação](#-como-instalar-e-rodar) • 
[🎮 Jogar Agora](#-como-jogar) • 
[📚 Documentação](#-documentação) • 
[👥 Equipe](#-equipe)

</div>

---

## 📖 Sobre o Projeto

**Star Dream** é um jogo RPG 2D desenvolvido como projeto acadêmico, focado em mecânicas de combate, sistema de inimigos com IA, magias, inventário e interface completa. O projeto demonstra implementação de sistemas complexos de jogos utilizando a Godot Engine 4.5.

### 🎯 Características Principais

#### ⚔️ Sistema de Combate
- **Combate Corpo a Corpo**: Ataque com hitbox dinâmica e cooldown configurável
- **Sistema de Magias**: 4 magias implementadas (Fireball, Ice Beam, Heal, Speed Boost)
- **Projéteis**: Sistema completo com knockback e pierce
- **Dano Inteligente**: Cálculo com defesa e sistema de stun opcional

#### 🤖 Inteligência Artificial
- **State Machine**: 5 estados (IDLE, CHASE, ATTACK, HURT, DEAD)
- **3 Tipos de Inimigos**: Lobo Veloz, Lobo Cinza, Lobo Alfa
- **Detecção por Range**: Sistema de perseguição e ataque
- **Sistema de Slow**: Ice Beam aplica lentidão sem stun

#### 🎒 Sistema de Inventário
- **30 Slots**: Inventário completo com empilhamento
- **Hotbar**: 9 slots de acesso rápido (teclas 1-9)
- **Equipamentos**: Sistema de armas (Arco e Espada)
- **Items Consumíveis**: Poções de cura, mana, stamina e buffs

#### 🎨 Interface do Usuário
- **HUD Completo**: Barras de vida, mana, spell selector
- **Menu Principal**: Start, Options, Quit
- **Pause Menu**: Sistema de pausa (ESC)
- **Game Over**: Tela de derrota com opções

---

## 📥 Como Instalar e Rodar

### Pré-requisitos

- **Godot Engine 4.5+** (Dev4 ou superior) - [Download aqui](https://godotengine.org/download)
- **Git** - [Download aqui](https://git-scm.com/downloads)

### Passo a Passo

#### 1️⃣ Clone o Repositório

```bash
git clone https://github.com/ghibhs/star_dream.git
cd star_dream
```

#### 2️⃣ Checkout na Branch Correta

```bash
git checkout thirdversion
```

#### 3️⃣ Abra no Godot

1. Abra o Godot Engine
2. Clique em **"Import"**
3. Navegue até `star_dream/godot_projects/test_v02`
4. Selecione o arquivo `project.godot`
5. Clique em **"Import & Edit"**

#### 4️⃣ Execute o Jogo

Pressione **F5** ou clique no botão ▶️ no canto superior direito

---

## 🎮 Como Jogar

### Controles

#### Movimento
- **W/A/S/D** ou **Setas**: Movimentação em 8 direções
- **SHIFT**: Dash com cooldown
- **Mouse**: Rotação do personagem

#### Combate
- **Botão Esquerdo (Click)**: Ataque corpo a corpo
- **Botão Direito (Click)**: Lançar magia
- **Botão Direito (Hold)**: Manter Ice Bolt ativo
- **Q/E**: Trocar magia equipada

#### Interface
- **1-9**: Usar item da hotbar
- **TAB**: Abrir/Fechar inventário
- **ESC**: Pausar jogo

---

## 📚 Documentação

### 📂 Estrutura do Projeto

```
star_dream/
├── godot_projects/
│   └── test_v02/                    # 🎮 Projeto principal do jogo
│       ├── README.md                 # Documentação detalhada
│       ├── RELATORIO_FINAL.md        # Relatório acadêmico
│       ├── GAME_FEATURES.md          # Todas funcionalidades
│       │
│       ├── scripts/                  # 📜 Scripts organizados
│       │   ├── player/
│       │   ├── enemy/
│       │   ├── spells/
│       │   ├── ui/
│       │   └── components/
│       │
│       ├── scenes/                   # 🎬 Cenas do jogo
│       │   ├── player/
│       │   ├── enemy/
│       │   ├── ui/
│       │   └── spells/
│       │
│       ├── resources/                # 📦 Resources configuráveis
│       │   ├── enemies/
│       │   ├── weapons/
│       │   └── spells/
│       │
│       ├── art/                      # 🎨 Sprites e texturas
│       └── docs/                     # 📖 Documentação técnica
│
├── images/                           # 🖼️ Imagens gerais do projeto
└── road-map/                         # 🗺️ Planejamento
```

### 📋 Documentação Completa

Acesse a pasta do projeto para documentação detalhada:

- **[📖 README Completo](godot_projects/test_v02/README.md)** - Guia completo do projeto
- **[📊 Relatório Final](godot_projects/test_v02/RELATORIO_FINAL.md)** - Relatório acadêmico
- **[🎯 Game Features](godot_projects/test_v02/GAME_FEATURES.md)** - Todas as funcionalidades
- **[🔧 Docs Técnicas](godot_projects/test_v02/docs/)** - Documentação técnica detalhada

---

## 🚀 Versões e Branches

### 🌿 Branches Principais

- **`master`** - Branch estável com merge completo ✅
- **`thirdversion`** - Branch de desenvolvimento ativa 🔥
- **`secondversion`** - Versão anterior (legado)

### 📌 Versão Atual

**Versão**: test_v02 (thirdversion)  
**Godot**: 4.5.dev4  
**Último Update**: 28 de Outubro de 2025

### ✨ Últimas Atualizações

- ✅ Merge completo da `thirdversion` para `master`
- ✅ Documentação acadêmica completa (README + Relatório Final)
- ✅ Sistema de magias com cooldown
- ✅ Ice Beam como raio laser contínuo
- ✅ Sistema de stun opcional no dano
- ✅ Refatoração completa da estrutura de arquivos
- ✅ Organização de assets e scripts

---

## 👥 Equipe

> **Projeto Acadêmico** - Adicione os nomes da equipe antes de entregar

| Nome | Função | Responsabilidades |
|------|--------|-------------------|
| [Nome 1] | Desenvolvedor Principal | Arquitetura, sistema de combate |
| [Nome 2] | Desenvolvedor Backend | Sistema de inimigos, IA |
| [Nome 3] | Game Designer | Arte, sprites, animações |
| [Nome 4] | Tester/Documentação | Testes, documentação, relatórios |

---

## 📊 Estatísticas do Projeto

- **Linhas de Código**: ~5.000+ linhas GDScript
- **Scripts**: 30+ arquivos .gd
- **Cenas**: 25+ arquivos .tscn
- **Resources**: 15+ arquivos .tres
- **Documentação**: 10+ arquivos .md
- **Commits**: 50+
- **Sprites**: 50+ imagens

---

## 🛠️ Tecnologias Utilizadas

- **Engine**: Godot 4.5 (Dev4)
- **Linguagem**: GDScript
- **Versionamento**: Git & GitHub
- **Assets**: Aseprite (sprites), Audacity (áudio planejado)

---

## 🐛 Problemas Conhecidos

Verifique a [lista de issues](https://github.com/ghibhs/star_dream/issues) para bugs conhecidos e em desenvolvimento.

---

## 🎯 Roadmap

### ✅ Concluído
- [x] Sistema de movimento e dash
- [x] Sistema de combate corpo a corpo
- [x] 4 Magias funcionais
- [x] Sistema de inimigos com IA
- [x] Inventário e equipamentos
- [x] Menu principal, pause e game over
- [x] Documentação completa

### 🔄 Em Desenvolvimento
- [ ] Sistema de XP e Level Up
- [ ] Mais tipos de inimigos e bosses
- [ ] Sistema de quests
- [ ] Save/Load game
- [ ] Efeitos sonoros e música

### 📅 Futuro
- [ ] Sistema de crafting
- [ ] Skill tree
- [ ] Multiplayer co-op
- [ ] Modo história completo

---

## 📝 Licença

Este projeto é de código aberto para fins educacionais.

---

## 🙏 Agradecimentos

- **Professor**: [Nome do Professor]
- **Godot Community**: Pelos recursos e tutoriais
- **Equipe**: Pela dedicação e colaboração

---

## 📞 Contato

**Repositório**: [github.com/ghibhs/star_dream](https://github.com/ghibhs/star_dream)  
**Branch Ativa**: `thirdversion`

Para dúvidas, sugestões ou contribuições, abra uma [issue](https://github.com/ghibhs/star_dream/issues/new) ou entre em contato com a equipe.

---

<div align="center">

**Desenvolvido com ❤️ usando Godot Engine 4.5**

⭐ **Se este projeto foi útil, considere dar uma estrela no GitHub!** ⭐

</div>
