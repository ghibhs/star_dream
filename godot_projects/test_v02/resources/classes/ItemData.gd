# ItemData.gd
class_name ItemData
extends Resource

## Tipos de itens disponíveis
enum ItemType {
	CONSUMABLE,    # Poções, comida, etc
	EQUIPMENT,     # Armaduras, capacetes, botas, etc
	WEAPON,        # Armas (usa WeaponData como base)
	MATERIAL,      # Materiais de craft
	QUEST,         # Itens de quest
	COLLECTIBLE,   # Moedas, etc (item coletável no mundo)
	MISC           # Diversos
}

## Slots de equipamento possíveis
enum EquipmentSlot {
	NONE,
	HEAD,          # Capacete
	CHEST,         # Peitoral
	LEGS,          # Calças
	BOOTS,         # Botas
	GLOVES,        # Luvas
	RING,          # Anel
	AMULET,        # Amuleto
	WEAPON_PRIMARY,   # Arma principal
	WEAPON_SECONDARY  # Arma secundária
}

@export_group("Basic Info")
@export var item_id: String = ""
@export var item_name: String = "Item"
@export var description: String = "Um item qualquer"
@export var icon: Texture2D  # Para UI do inventário
@export var item_type: ItemType = ItemType.MISC

@export_group("World Item (Collectible)")
## Dados visuais do item coletável no mundo
@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item

@export_group("Stack")
@export var is_stackable: bool = true
@export var max_stack_size: int = 99

@export_group("Equipment")
@export var is_equippable: bool = false
@export var equipment_slot: EquipmentSlot = EquipmentSlot.NONE
## Referência para WeaponData se for uma arma
@export var weapon_data: WeaponData

@export_group("Value & Effects")
@export var value: int = 0  # Valor em moedas
@export var weight: float = 0.1
@export var sound_effect: AudioStream
@export var hit_effect: PackedScene

@export_group("Consumable Effects")
## Efeitos quando consumido (poções, comida, etc)
@export var restore_health: float = 0.0
@export var restore_mana: float = 0.0
@export var restore_stamina: float = 0.0
@export var apply_buff_duration: float = 0.0  # Duração do buff em segundos
@export var buff_speed_multiplier: float = 1.0  # Multiplicador de velocidade durante buff
@export var buff_damage_multiplier: float = 1.0  # Multiplicador de dano durante buff

## Bônus quando equipado
@export_group("Equipment Bonuses")
@export var bonus_health: float = 0.0
@export var bonus_defense: float = 0.0
@export var bonus_speed: float = 0.0
@export var bonus_damage: float = 0.0


func get_display_name() -> String:
	return item_name


func get_tooltip_text() -> String:
	var text = "[b]%s[/b]\n%s" % [item_name, description]
	
	# Efeitos de consumível
	if item_type == ItemType.CONSUMABLE:
		text += "\n\n[color=lime]Consumível[/color]"
		if restore_health > 0:
			text += "\n+%.0f HP" % restore_health
		if restore_mana > 0:
			text += "\n+%.0f Mana" % restore_mana
		if restore_stamina > 0:
			text += "\n+%.0f Stamina" % restore_stamina
		if apply_buff_duration > 0:
			text += "\n\n[color=cyan]Buff (%.1fs):[/color]" % apply_buff_duration
			if buff_speed_multiplier != 1.0:
				text += "\nVelocidade x%.1f" % buff_speed_multiplier
			if buff_damage_multiplier != 1.0:
				text += "\nDano x%.1f" % buff_damage_multiplier
	
	# Bônus de equipamento
	if item_type == ItemType.EQUIPMENT or item_type == ItemType.WEAPON:
		text += "\n\n[color=yellow]Equipável[/color]"
		if bonus_health > 0:
			text += "\n+%.0f HP" % bonus_health
		if bonus_defense > 0:
			text += "\n+%.0f Defesa" % bonus_defense
		if bonus_speed > 0:
			text += "\n+%.0f Velocidade" % bonus_speed
		if bonus_damage > 0:
			text += "\n+%.0f Dano" % bonus_damage
	
	if is_stackable:
		text += "\n\n[color=gray]Empilhável (máx: %d)[/color]" % max_stack_size
	
	if value > 0:
		text += "\n\n[color=gold]Valor: %d moedas[/color]" % value
	
	return text


## Verifica se o item pode ser usado/consumido
func is_usable() -> bool:
	return item_type == ItemType.CONSUMABLE
