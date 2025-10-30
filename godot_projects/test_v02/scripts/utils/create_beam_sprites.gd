# Script para criar sprites placeholder para o beam
# Execute este script no Godot Editor: Tools > Execute Script

@tool
extends EditorScript

func _run():
	create_beam_sprite()
	create_impact_sprite()
	print("✅ Sprites placeholder criados com sucesso!")

func create_beam_sprite():
	# Criar imagem 64x32 para o raio
	var img = Image.create(64, 32, false, Image.FORMAT_RGBA8)
	
	# Desenhar gradiente azul
	for x in range(64):
		for y in range(32):
			var dist_from_center = abs(y - 16)
			var alpha = 1.0 - (dist_from_center / 16.0)
			alpha = clamp(alpha * 1.5, 0.0, 1.0)
			
			# Cor azul brilhante
			var color = Color(0.3, 0.8, 1.0, alpha * 0.8)
			
			# Borda mais brilhante
			if dist_from_center < 4:
				color = Color(0.8, 1.0, 1.0, alpha)
			
			img.set_pixel(x, y, color)
	
	# Salvar como PNG
	var path = "res://art/placeholder_beam.png"
	img.save_png(path)
	print("Beam sprite criado em: ", path)

func create_impact_sprite():
	# Criar imagem 64x64 para o impacto
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	
	var center = Vector2(32, 32)
	
	# Desenhar círculo com raios
	for x in range(64):
		for y in range(64):
			var pos = Vector2(x, y)
			var dist = center.distance_to(pos)
			
			if dist < 20:
				# Centro brilhante
				var alpha = 1.0 - (dist / 20.0)
				var color = Color(1.0, 1.0, 0.5, alpha)
				img.set_pixel(x, y, color)
			elif dist < 28:
				# Borda azul
				var alpha = 1.0 - ((dist - 20) / 8.0)
				var color = Color(0.3, 0.8, 1.0, alpha * 0.7)
				img.set_pixel(x, y, color)
	
	# Adicionar raios (linhas irradiando)
	for angle in range(0, 360, 45):
		var rad = deg_to_rad(angle)
		for r in range(20, 35):
			var x = int(center.x + cos(rad) * r)
			var y = int(center.y + sin(rad) * r)
			if x >= 0 and x < 64 and y >= 0 and y < 64:
				var alpha = 1.0 - ((r - 20) / 15.0)
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha * 0.8))
	
	# Salvar como PNG
	var path = "res://art/placeholder_impact.png"
	img.save_png(path)
	print("Impact sprite criado em: ", path)
