extends Node2D

# Cliente visual que caminha da borda até a mesa usando Tween puro
# Sem física — só animação, não interfere em nada do jogo

var _perna_d
var _perna_e
var _tempo = 0.0

# Paleta de roupas variada (tons quentes, estilo Stardew Valley) para dar
# vida e diversidade visual aos clientes que chegam ao restaurante
var _paleta_roupas = [
	Color(0.28, 0.52, 0.85, 1.0),  # azul
	Color(0.80, 0.34, 0.24, 1.0),  # terracota
	Color(0.36, 0.58, 0.30, 1.0),  # verde
	Color(0.86, 0.62, 0.20, 1.0),  # mostarda
	Color(0.55, 0.34, 0.62, 1.0),  # roxo suave
	Color(0.78, 0.45, 0.55, 1.0),  # rosa velho
]

func _ready():
	modulate.a = 0.0
	scale = Vector2(0.4, 0.4)
	_perna_d = $ClienteSprite/PernaDireita
	_perna_e = $ClienteSprite/PernaEsquerda
	_variar_aparencia()

func _variar_aparencia():
	var cor_base = _paleta_roupas[randi() % _paleta_roupas.size()]
	var cor_escura = cor_base.darkened(0.25)
	$ClienteSprite/Corpo.color = cor_base
	$ClienteSprite/Camisa.color = cor_escura
	$ClienteSprite/BracoDireito.color = cor_base
	$ClienteSprite/BracoEsquerdo.color = cor_base
	# Pequena variação no tom de pele/cabelo para diversidade
	var peles = [Color(1.0, 0.80, 0.60, 1.0), Color(0.87, 0.63, 0.42, 1.0), Color(0.62, 0.42, 0.28, 1.0)]
	var pele = peles[randi() % peles.size()]
	$ClienteSprite/Cabeca.color = pele
	$ClienteSprite/Pescoco.color = pele
	var cabelos = [Color(0.22, 0.14, 0.06, 1.0), Color(0.08, 0.08, 0.08, 1.0), Color(0.45, 0.28, 0.12, 1.0), Color(0.65, 0.62, 0.58, 1.0)]
	$ClienteSprite/Cabelo.color = cabelos[randi() % cabelos.size()]

func iniciar_chegada(mesa_pos: Vector2):
	# 1) Aparece com pop
	var tw_entrada = create_tween().set_parallel(true)
	tw_entrada.tween_property(self, "modulate:a", 1.0, 0.35)
	tw_entrada.tween_property(self, "scale", Vector2(1.0, 1.0), 0.35)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tw_entrada.finished

	# 2) Caminha até a mesa
	var distancia = global_position.distance_to(mesa_pos)
	var duracao = distancia / 160.0  # 160 px/s

	# Animação de passos nas pernas (paralela ao movimento)
	_animar_passos(duracao)

	var tw_andar = create_tween()
	tw_andar.tween_property(self, "global_position", mesa_pos, duracao)\
		.set_trans(Tween.TRANS_LINEAR)
	await tw_andar.finished

	# 3) Chegou — encolhe e some
	var tw_saida = create_tween().set_parallel(true)
	tw_saida.tween_property(self, "modulate:a", 0.0, 0.2)
	tw_saida.tween_property(self, "scale", Vector2(0.0, 0.0), 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw_saida.finished
	queue_free()

func _animar_passos(duracao: float):
	# Alterna as pernas subindo/descendo enquanto caminha
	var ciclos = int(duracao / 0.22)
	for i in range(ciclos):
		if not is_inside_tree():
			return
		var tw = create_tween().set_parallel(true)
		if i % 2 == 0:
			tw.tween_property(_perna_d, "position:y", -5.0, 0.11)
			tw.tween_property(_perna_e, "position:y",  0.0, 0.11)
		else:
			tw.tween_property(_perna_d, "position:y",  0.0, 0.11)
			tw.tween_property(_perna_e, "position:y", -5.0, 0.11)
		await tw.finished
	# Reseta posição das pernas
	if is_inside_tree():
		_perna_d.position.y = 0.0
		_perna_e.position.y = 0.0
