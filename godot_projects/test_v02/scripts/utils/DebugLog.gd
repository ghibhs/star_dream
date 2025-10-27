# DebugLog.gd
# Sistema de logging configurável para facilitar debug
# Uso: DebugLog.log("Mensagem", DebugLog.LogLevel.INFO)
class_name DebugLog
extends Node

enum LogLevel {
	NONE = 0,      # Não mostra nada
	ERROR = 1,     # Apenas erros críticos
	WARNING = 2,   # Avisos e erros
	INFO = 3,      # Informações gerais + warnings + errors
	VERBOSE = 4    # TUDO (incluindo detalhes)
}

# ⚙️ CONFIGURE AQUI O NÍVEL DE DEBUG
# NONE - Desliga todos os logs (produção)
# ERROR - Apenas erros
# WARNING - Avisos e erros
# INFO - Informações importantes (recomendado para desenvolvimento)
# VERBOSE - Tudo (muito verboso, use apenas para debug específico)
static var current_level: LogLevel = LogLevel.INFO

# Prefixos coloridos para cada nível
static var level_prefixes = {
	LogLevel.ERROR: "❌ [ERROR]",
	LogLevel.WARNING: "⚠️ [WARN]",
	LogLevel.INFO: "ℹ️ [INFO]",
	LogLevel.VERBOSE: "🔍 [DEBUG]"
}

## Log uma mensagem se o nível for adequado
static func print_log(message: String, level: LogLevel = LogLevel.INFO, category: String = "") -> void:
	if level > current_level:
		return  # Não mostra se o nível for maior que o configurado
	
	var prefix = level_prefixes.get(level, "")
	var cat = ("[" + category + "]") if category != "" else ""
	print("%s%s %s" % [prefix, cat, message])


## Atalhos para níveis específicos
static func error(message: String, category: String = "") -> void:
	print_log(message, LogLevel.ERROR, category)

static func warning(message: String, category: String = "") -> void:
	print_log(message, LogLevel.WARNING, category)

static func info(message: String, category: String = "") -> void:
	print_log(message, LogLevel.INFO, category)

static func verbose(message: String, category: String = "") -> void:
	print_log(message, LogLevel.VERBOSE, category)


## Função especial para logs de sistema (sempre mostra, independente do nível)
static func system(message: String) -> void:
	print("🔧 [SYSTEM] %s" % message)


## Helper para debug de valores formatados
static func debug_var(var_name: String, value: Variant, category: String = "") -> void:
	verbose("%s = %s" % [var_name, str(value)], category)


## Helper para debug de posições
static func debug_position(node_name: String, position: Vector2, category: String = "") -> void:
	verbose("%s position: (%.1f, %.1f)" % [node_name, position.x, position.y], category)


## Helper para separadores visuais (apenas em VERBOSE)
static func separator(category: String = "") -> void:
	verbose("═══════════════════════════════════════════", category)
