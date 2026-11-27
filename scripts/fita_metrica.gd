@tool
extends Control
# Fita métrica desenhada em código, usada como enfeite da placa do menu
# (lembra o "sob medida" do nome do jogo).

const AMARELO = Color(1.0, 0.80, 0.22)
const TRACO = Color(0.23, 0.12, 0.04)

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), AMARELO)
	draw_rect(Rect2(Vector2.ZERO, size), TRACO, false, 2.0)
	var x = 8.0
	var i = 1
	while x < size.x - 4.0:
		var altura = size.y * (0.6 if i % 5 == 0 else 0.32)
		draw_rect(Rect2(x, 0, 2, altura), TRACO)
		x += 8.0
		i += 1
	# Ponta de metal
	draw_rect(Rect2(-6, -2, 8, size.y + 4), Color(0.72, 0.74, 0.78))
	draw_rect(Rect2(-6, -2, 8, size.y + 4), TRACO, false, 2.0)
