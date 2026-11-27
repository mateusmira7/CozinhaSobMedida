@tool
extends Control
# Duas correntes que penduram a placa do menu na viga do teto.

const FERRO = Color(0.16, 0.13, 0.12)
const BRILHO = Color(0.55, 0.52, 0.50)

func _draw():
	for x in [40.0, size.x - 40.0]:
		var y = 0.0
		var i = 0
		while y < size.y:
			var largura = 14.0 if i % 2 == 0 else 6.0
			var elo = Rect2(x - largura / 2.0, y, largura, 14.0)
			draw_rect(elo, FERRO, false, 4.0)
			draw_rect(Rect2(elo.position, Vector2(3, 3)), BRILHO)
			y += 10.0
			i += 1
