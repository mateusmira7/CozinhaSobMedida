extends Node2D

@onready var chef               = $Chef
@onready var bancada            = $Bancada
@onready var label_dica_bancada = $Bancada/LabelDica
@onready var despensa           = $Despensa
@onready var label_dica_despensa = $Despensa/LabelDica
@onready var interface_calculo  = $CanvasLayer/InterfaceCalculo
@onready var label_score        = $CanvasLayer/HUD/PainelScore/MarginContainer/VBoxContainer/LabelScore
@onready var label_moedas       = $CanvasLayer/HUD/PainelScore/MarginContainer/VBoxContainer/LabelMoedas
@onready var label_instrucao    = $CanvasLayer/HUD/PainelScore/MarginContainer/VBoxContainer/LabelInstrucoes
@onready var musica_ambiente    = $MusicaAmbiente

var mesas = []

# Cena do cliente para instanciar o boneco chegando
var cliente_scene = preload("res://scenes/cliente.tscn")

# Receitas reais do GDD — culinária brasileira regional
var receitas_mineiras = [
	{
		"nome": "Feijão Tropeiro",
		"regiao": "Mineira",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Feijão carioca", "quantidade_base": 200, "unidade": "g"},
			{"nome": "Farinha de mandioca", "quantidade_base": 100, "unidade": "g"},
			{"nome": "Linguiça calabresa", "quantidade_base": 120, "unidade": "g"}
		]
	},
	{
		"nome": "Frango com Quiabo",
		"regiao": "Mineira",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Frango", "quantidade_base": 400, "unidade": "g"},
			{"nome": "Quiabo", "quantidade_base": 200, "unidade": "g"},
			{"nome": "Cebola", "quantidade_base": 80, "unidade": "g"}
		]
	},
	{
		"nome": "Tutu de Feijão",
		"regiao": "Mineira",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Feijão preto", "quantidade_base": 250, "unidade": "g"},
			{"nome": "Farinha de mandioca", "quantidade_base": 80, "unidade": "g"},
			{"nome": "Torresmo", "quantidade_base": 100, "unidade": "g"}
		]
	}
]

var receitas_nordestinas = [
	{
		"nome": "Feijoada",
		"regiao": "Nordestina",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Feijão preto", "quantidade_base": 200, "unidade": "g"},
			{"nome": "Costelinha", "quantidade_base": 150, "unidade": "g"},
			{"nome": "Linguiça", "quantidade_base": 100, "unidade": "g"}
		]
	},
	{
		"nome": "Carne de Sol",
		"regiao": "Nordestina",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Carne de sol", "quantidade_base": 350, "unidade": "g"},
			{"nome": "Manteiga de garrafa", "quantidade_base": 40, "unidade": "ml"},
			{"nome": "Macaxeira", "quantidade_base": 200, "unidade": "g"}
		]
	}
]

var receitas_baianas = [
	{
		"nome": "Moqueca de Peixe",
		"regiao": "Baiana",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Peixe", "quantidade_base": 500, "unidade": "g"},
			{"nome": "Leite de coco", "quantidade_base": 200, "unidade": "ml"},
			{"nome": "Azeite de dendê", "quantidade_base": 30, "unidade": "ml"}
		]
	},
	{
		"nome": "Acarajé",
		"regiao": "Baiana",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Feijão fradinho", "quantidade_base": 300, "unidade": "g"},
			{"nome": "Camarão seco", "quantidade_base": 100, "unidade": "g"},
			{"nome": "Azeite de dendê", "quantidade_base": 50, "unidade": "ml"}
		]
	}
]

var receitas_gauchas = [
	{
		"nome": "Arroz com Frango Gaúcho",
		"regiao": "Gaúcha",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Arroz", "quantidade_base": 300, "unidade": "g"},
			{"nome": "Frango", "quantidade_base": 400, "unidade": "g"},
			{"nome": "Chimichurri", "quantidade_base": 20, "unidade": "g"}
		]
	},
	{
		"nome": "Churrasco Gaúcho",
		"regiao": "Gaúcha",
		"base_pessoas": 2,
		"pedido_pessoas": 0,
		"ingredientes": [
			{"nome": "Picanha", "quantidade_base": 400, "unidade": "g"},
			{"nome": "Costela", "quantidade_base": 300, "unidade": "g"},
			{"nome": "Sal grosso", "quantidade_base": 15, "unidade": "g"}
		]
	}
]

var todas_receitas = []

var score = 0
var moedas = 0
var mesa_com_pedido: Area2D = null
var pedido_pendente = null
var estado_jogo = "livre"

func _ready():
	mesas = [$Mesa1, $Mesa2, $Mesa3]
	todas_receitas = receitas_mineiras + receitas_nordestinas + receitas_baianas + receitas_gauchas

	label_dica_bancada.visible = false
	label_dica_despensa.visible = false

	# Música ambiente em loop contínuo
	if musica_ambiente.stream is AudioStreamWAV:
		musica_ambiente.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	musica_ambiente.finished.connect(func(): musica_ambiente.play())

	# Conecta sinais
	interface_calculo.calculo_confirmado.connect(_on_calculo_confirmado)
	for mesa in mesas:
		mesa.cliente_foi_embora_signal.connect(_on_cliente_foi_embora)

	_atualizar_score()
	_atualizar_hud("WASD = Mover  |  Shift = Correr  |  E = Interagir")

	await get_tree().create_timer(0.5).timeout
	_sentar_em_todas_vazias()
	_loop_clientes()

func _process(_delta):
	var perto_bancada = chef.global_position.distance_to(bancada.global_position) < 120
	label_dica_bancada.visible = perto_bancada and (estado_jogo == "com_pedido" or estado_jogo == "calculando")
	if perto_bancada and estado_jogo == "calculando":
		label_dica_bancada.text = "[E] Fechar bancada"
	elif perto_bancada and estado_jogo == "com_pedido":
		label_dica_bancada.text = "[E] Calcular receita"

	var perto_despensa = chef.global_position.distance_to(despensa.global_position) < 120
	label_dica_despensa.visible = perto_despensa and estado_jogo == "buscando_ingredientes"
	if perto_despensa and estado_jogo == "buscando_ingredientes":
		label_dica_despensa.text = "[E] Pegar ingredientes"

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			_tentar_interagir()
			get_viewport().set_input_as_handled()

func _tentar_interagir():
	# Interface aberta + perto bancada → fecha
	if estado_jogo == "calculando":
		if chef.global_position.distance_to(bancada.global_position) < 120:
			interface_calculo.visible = false
			estado_jogo = "com_pedido"
			chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
			_atualizar_hud("📋 Pedido anotado! Vá à BANCADA (E)")
		return

	# Perto de mesa → anotar ou entregar
	for mesa in mesas:
		if chef.global_position.distance_to(mesa.global_position) < 90:
			if mesa.estado == mesa.EstadoMesa.COM_CLIENTE and estado_jogo == "livre":
				_anotar_pedido(mesa)
				return
			if mesa.estado == mesa.EstadoMesa.AGUARDANDO_PRATO and estado_jogo == "entregando" and mesa == mesa_com_pedido:
				_entregar_prato()
				return

	# Perto da bancada com pedido → abre cálculo
	if chef.global_position.distance_to(bancada.global_position) < 120:
		if estado_jogo == "com_pedido" and pedido_pendente != null:
			estado_jogo = "calculando"
			chef.set_estado(chef.EstadoChef.CALCULANDO)
			interface_calculo.abrir_interface(pedido_pendente)
			return

	# Perto da despensa com o cálculo já confirmado → coleta os ingredientes
	if chef.global_position.distance_to(despensa.global_position) < 120:
		if estado_jogo == "buscando_ingredientes":
			_coletar_ingredientes()

func _anotar_pedido(mesa: Area2D):
	var receita = mesa.pedido.duplicate(true)
	pedido_pendente = receita
	mesa_com_pedido = mesa
	mesa.iniciar_espera()
	estado_jogo = "com_pedido"
	chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
	chef.animar_interacao()
	_atualizar_hud("📋 " + receita.nome + " para " + str(receita.pedido_pessoas) + " pessoas!\nVá à BANCADA e pressione E")

func _on_calculo_confirmado(correto: bool, pontos: int):
	if correto:
		estado_jogo = "buscando_ingredientes"
		chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
		_atualizar_hud("✅ Certo! Vá até a DESPENSA (E) buscar os ingredientes")
	else:
		score = max(0, score + pontos)
		_atualizar_score()

func _coletar_ingredientes():
	chef.animar_interacao()
	estado_jogo = "entregando"
	chef.set_estado(chef.EstadoChef.ENTREGANDO)
	_atualizar_hud("🧺 Ingredientes coletados! Volte à mesa e pressione E para entregar")

func _entregar_prato():
	if mesa_com_pedido == null:
		return
	score += 100
	moedas += 15
	_atualizar_score()
	chef.animar_interacao()
	mesa_com_pedido.receber_prato(100)
	mesa_com_pedido = null
	pedido_pendente = null
	estado_jogo = "livre"
	chef.set_estado(chef.EstadoChef.LIVRE)
	_atualizar_hud("🍽️ Entregue! +100 pts | +15 moedas  |  WASD = Mover | E = Interagir")

func _on_cliente_foi_embora(mesa: Area2D):
	score = max(0, score - 50)
	_atualizar_score()

	if mesa == mesa_com_pedido:
		mesa_com_pedido = null
		pedido_pendente = null
		interface_calculo.visible = false
		estado_jogo = "livre"
		chef.set_estado(chef.EstadoChef.LIVRE)
		_atualizar_hud("😤 Cliente foi embora! -50 pts  |  Pegue outro pedido")

func _atualizar_score():
	label_score.text = "Score: " + str(score)
	label_moedas.text = "Moedas: " + str(moedas)

func _atualizar_hud(msg: String):
	label_instrucao.text = msg

func _sentar_em_todas_vazias():
	for mesa in mesas:
		if mesa.estado == mesa.EstadoMesa.VAZIA:
			var receita = todas_receitas[randi() % todas_receitas.size()].duplicate(true)
			var opcoes = [3, 4, 5, 3.5, 4.5, 6]
			receita.pedido_pessoas = opcoes[randi() % opcoes.size()]
			mesa.receber_cliente(receita)
			# Spawna boneco cliente chegando da borda superior
			_spawnar_cliente(mesa)

func _spawnar_cliente(mesa: Node2D):
	var cliente = cliente_scene.instantiate()
	# Posição inicial: borda de cima, x alinhado com a mesa
	var destino = mesa.global_position
	cliente.global_position = Vector2(destino.x, -40)
	add_child(cliente)
	cliente.iniciar_chegada(destino)

func _loop_clientes():
	while true:
		await get_tree().create_timer(4.0).timeout
		_sentar_em_todas_vazias()
