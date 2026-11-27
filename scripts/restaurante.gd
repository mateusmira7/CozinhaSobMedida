extends Node2D

const Grupo = preload("res://scripts/grupo.gd")
const Catalogo = preload("res://scripts/loja_catalogo.gd")
const MesaScene = preload("res://scenes/mesa.tscn")
const Tema = preload("res://assets/ui/tema_cozinha.tres")
const IconeLoja = preload("res://assets/ui/icone_loja.png")

# O progresso é salvo automaticamente e também pelo menu de pausa (Esc).
const Salvamento = preload("res://scripts/salvamento.gd")

# Entrada dos clientes: porta na lateral esquerda do salão
const PORTA_POS = Vector2(26, 205)

@onready var chef               = $Chef
@onready var bancada            = $Bancada
@onready var label_dica_bancada = $Bancada/LabelDica
@onready var despensa           = $Despensa
@onready var label_dica_despensa = $Despensa/LabelDica
@onready var interface_calculo  = $CanvasLayer/InterfaceCalculo
@onready var label_score        = $CanvasLayer/HUD/PainelScore/VBox/Fichas/FichaPontos/Linha/Texto/LabelScore
@onready var label_moedas       = $CanvasLayer/HUD/PainelScore/VBox/Fichas/FichaMoedas/Linha/Texto/LabelMoedas
@onready var label_instrucao    = $CanvasLayer/HUD/PainelScore/VBox/Recado/LabelInstrucoes
@onready var musica_ambiente    = $MusicaAmbiente
@onready var loja               = $CanvasLayer/Loja
@onready var menu_pausa         = $CanvasLayer/MenuPausa

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

# --- Lojinha ---
var comprados: Array = []
var toalha_atual: String = Catalogo.TOALHA_PADRAO
var pedido_pendente = null
var estado_jogo = "livre"

# --- Primeiro atendimento guiado (tutorial) ---
# Passos: 0 anotar | 1 ir à bancada | 2 calcular | 3 despensa | 4 entregar | 5 fim
var tutorial_ativo = false
var tutorial_concluido = false
var tutorial_passo = 0
var mesa_tutorial: Area2D = null
var banner_tutorial: PanelContainer = null
var label_banner: Label = null
var marcador: Node2D = null
var _tempo = 0.0

const TEXTOS_TUTORIAL = [
	"Bem-vindo(a) à cozinha! Um cliente chegou.\nAndar: WASD (segure Shift para correr). Vá até a mesa marcada e aperte E para ANOTAR o pedido.",
	"Pedido anotado! Leve-o até a BANCADA (marcada) e aperte E para abrir a receita.",
	"Na bancada, o fator é: pessoas do grupo ÷ pessoas da receita. Multiplique cada ingrediente por ele.",
	"Cálculo certo! Agora vá até a DESPENSA (marcada) e aperte E para pegar os ingredientes.",
	"Ingredientes na mão! Volte à mesa marcada e aperte E para ENTREGAR o prato.",
	"Primeiro atendimento concluído! A partir de agora os clientes chegam sozinhos e a paciência deles vai baixando: corra com Shift!"
]

func _ready():
	mesas = [$Mesa1, $Mesa2, $Mesa3]
	var salvo = Salvamento.carregar()
	_carregar_progresso(salvo)
	todas_receitas = receitas_mineiras + receitas_nordestinas + receitas_baianas + receitas_gauchas

	label_dica_bancada.visible = false
	label_dica_despensa.visible = false

	# Música ambiente em loop contínuo
	if musica_ambiente.stream is AudioStreamWAV:
		musica_ambiente.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	musica_ambiente.finished.connect(func(): musica_ambiente.play())
	# A música não para quando a loja pausa o jogo
	musica_ambiente.process_mode = Node.PROCESS_MODE_ALWAYS

	# Conecta sinais
	interface_calculo.calculo_confirmado.connect(_on_calculo_confirmado)
	interface_calculo.erros_excedidos.connect(_on_erros_excedidos)
	for mesa in mesas:
		mesa.cliente_foi_embora_signal.connect(_on_cliente_foi_embora)

	# Lojinha: itens já comprados voltam para o restaurante
	loja.comprar_pedido.connect(_on_loja_comprar)
	loja.equipar_pedido.connect(_on_loja_equipar)
	loja.fechada.connect(_on_loja_fechada)
	_criar_botao_loja()
	_aplicar_progresso()

	_atualizar_score()
	_atualizar_hud("WASD: andar   Shift: correr\nE: interagir   Esc: menu")

	_criar_ui_tutorial()

	# Menu de pausa (Esc)
	menu_pausa.salvar = _salvar_progresso
	menu_pausa.resumo = func(): return "Pontos: %d   |   Moedas: %d" % [score, moedas]
	# Com a loja aberta, o Esc apenas fecha a loja
	menu_pausa.pode_abrir = func(): return not loja.visible

	# Jogo salvo: devolve mesas, pedido em andamento e posição do chef
	if tutorial_concluido:
		_restaurar_partida(salvo.partida)

	await get_tree().create_timer(0.5, false).timeout
	if not tutorial_concluido:
		_iniciar_tutorial()
	_loop_clientes()

# Fechar a janela também salva o jogo
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_node_ready():
		_salvar_progresso()

func _process(delta):
	_tempo += delta
	_atualizar_marcador()
	# Rede de segurança: se o atendimento ficou sem pedido válido (ex.: a mesa foi
	# resetada), libera o jogador em vez de deixá-lo preso num estado sem saída.
	if estado_jogo != "livre":
		if mesa_com_pedido == null or mesa_com_pedido.estado != mesa_com_pedido.EstadoMesa.AGUARDANDO_PRATO:
			_resetar_atendimento()

	var perto_bancada = chef.global_position.distance_to(bancada.global_position) < 120
	label_dica_bancada.visible = perto_bancada and estado_jogo == "com_pedido"
	if label_dica_bancada.visible:
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
		elif event.keycode == KEY_L:
			if _abrir_loja():
				get_viewport().set_input_as_handled()

func _tentar_interagir():
	# Interface aberta + perto bancada → fecha
	if estado_jogo == "calculando":
		if chef.global_position.distance_to(bancada.global_position) < 120:
			interface_calculo.cancelar()
			estado_jogo = "com_pedido"
			chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
			_atualizar_hud("Pedido anotado! Vá à BANCADA (E)")
			if tutorial_ativo:
				_tutorial_ir_para(1)
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
			interface_calculo.abrir_interface(pedido_pendente, tutorial_ativo)
			if tutorial_ativo:
				_tutorial_ir_para(2)
			return

	# Perto da despensa com o cálculo já confirmado → coleta os ingredientes
	if chef.global_position.distance_to(despensa.global_position) < 120:
		if estado_jogo == "buscando_ingredientes":
			_coletar_ingredientes()

func _anotar_pedido(mesa: Area2D):
	var receita = mesa.pedido.duplicate(true)
	receita["_id"] = Time.get_ticks_usec()  # identifica o pedido (contagem de erros)
	pedido_pendente = receita
	mesa_com_pedido = mesa
	mesa.iniciar_espera()
	estado_jogo = "com_pedido"
	chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
	chef.animar_interacao()
	_atualizar_hud(receita.nome + " para " + Grupo.descricao(receita.pedido_pessoas) + "! Vá à BANCADA (E)")
	if tutorial_ativo and mesa == mesa_tutorial:
		_tutorial_ir_para(1)
	_salvar_progresso()

func _on_calculo_confirmado(correto: bool, pontos: int):
	# Resultado atrasado de um pedido que já foi cancelado: ignora
	if estado_jogo != "calculando" or pedido_pendente == null:
		return
	if correto:
		estado_jogo = "buscando_ingredientes"
		chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
		_atualizar_hud("Certo! Pegue os ingredientes na DESPENSA (E)")
		if tutorial_ativo:
			_tutorial_ir_para(3)
	else:
		score = max(0, score + pontos)
		_atualizar_score()
	_salvar_progresso()

# Mais de 3 erros no cálculo: o cliente vai embora (sem a penalidade extra de -50;
# o jogador só perde os 10 pontos de cada tentativa errada).
func _on_erros_excedidos():
	if estado_jogo != "calculando" or mesa_com_pedido == null:
		return
	var mesa = mesa_com_pedido
	var perdidos = interface_calculo.erros * 10
	_resetar_atendimento()
	mesa.desistir_por_erros(perdidos)
	_salvar_progresso()
	_atualizar_hud("Muitos erros! O cliente foi embora (-" + str(perdidos) + " pts). Pegue outro pedido")

func _coletar_ingredientes():
	chef.animar_interacao()
	estado_jogo = "entregando"
	chef.set_estado(chef.EstadoChef.ENTREGANDO)
	_atualizar_hud("Ingredientes na mão! Entregue na mesa (E)")
	if tutorial_ativo:
		_tutorial_ir_para(4)
	_salvar_progresso()

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
	_atualizar_hud("Entregue! +100 pontos e +15 moedas")
	if tutorial_ativo:
		_tutorial_ir_para(5)
	_salvar_progresso()

func _on_cliente_foi_embora(mesa: Area2D):
	score = max(0, score - 50)
	_atualizar_score()

	if mesa == mesa_com_pedido:
		_resetar_atendimento()
		_atualizar_hud("Cliente foi embora! -50 pts. Pegue outro pedido")
	_salvar_progresso()

# Cancela o atendimento em andamento (bancada fechada, estado e pedido zerados).
func _resetar_atendimento():
	interface_calculo.cancelar()
	mesa_com_pedido = null
	pedido_pendente = null
	estado_jogo = "livre"
	chef.set_estado(chef.EstadoChef.LIVRE)

func _atualizar_score():
	label_score.text = str(score)
	label_moedas.text = str(moedas)

func _atualizar_hud(msg: String):
	label_instrucao.text = msg
	# O painel volta a encolher quando o recado fica mais curto
	$CanvasLayer/HUD/PainelScore.reset_size.call_deferred()

# Tempo entre um cliente e outro entrando pela porta (evita que um saia de dentro do outro)
const INTERVALO_CHEGADA = 2.2
var _sentando = false

func _sentar_em_todas_vazias():
	if _sentando:
		return
	_sentando = true
	var ordem = mesas.duplicate()
	ordem.shuffle()
	var primeiro = true
	for mesa in ordem:
		if mesa.estado == mesa.EstadoMesa.VAZIA:
			# Só espera entre um cliente e o seguinte
			if not primeiro:
				await get_tree().create_timer(INTERVALO_CHEGADA, false).timeout
			primeiro = false
			# Depois da espera a mesa pode ter sido ocupada por outro caminho
			if mesa.estado == mesa.EstadoMesa.VAZIA:
				_sentar_cliente(mesa)
	_sentando = false

func _sentar_cliente(mesa: Area2D):
	var receita = todas_receitas[randi() % todas_receitas.size()].duplicate(true)
	var opcoes = [3, 4, 5, 3.5, 4.5, 6]
	receita.pedido_pessoas = opcoes[randi() % opcoes.size()]
	mesa.receber_cliente(receita)
	# Spawna boneco cliente chegando pela porta
	_spawnar_cliente(mesa)

func _spawnar_cliente(mesa: Node2D):
	var cliente = cliente_scene.instantiate()
	# Sai da porta na lateral esquerda, anda pelo corredor e sobe até a mesa
	var destino = mesa.global_position
	cliente.global_position = PORTA_POS
	add_child(cliente)
	cliente.iniciar_chegada(destino, Vector2(destino.x, PORTA_POS.y))

func _loop_clientes():
	while true:
		await get_tree().create_timer(4.0, false).timeout
		# Durante o primeiro atendimento guiado só existe o cliente do tutorial
		if not tutorial_ativo and not get_tree().paused:
			_sentar_em_todas_vazias()

# ---------------- Lojinha ----------------

func _criar_botao_loja():
	var botao = Button.new()
	botao.name = "BotaoLoja"
	botao.theme = Tema
	botao.text = "Loja (L)"
	botao.icon = IconeLoja
	botao.focus_mode = Control.FOCUS_NONE  # evita que E/Espaço "cliquem" nele
	botao.position = Vector2(10, 8)
	botao.custom_minimum_size = Vector2(178, 66)
	botao.add_theme_constant_override("h_separation", 10)
	botao.pressed.connect(_abrir_loja)
	$CanvasLayer/HUD.add_child(botao)

# Devolve true se a loja abriu. O jogo é pausado enquanto ela está aberta
# (a paciência dos clientes não diminui e o chef fica parado).
func _abrir_loja() -> bool:
	if loja.visible or get_tree().paused:
		return false
	if estado_jogo == "calculando":
		_atualizar_hud("Feche a bancada (E) antes de abrir a loja")
		return false
	get_tree().paused = true
	loja.abrir(moedas, comprados, toalha_atual)
	return true

func _on_loja_fechada():
	get_tree().paused = false

func _on_loja_comprar(id: String):
	var item = Catalogo.buscar(id)
	if item.is_empty() or id in comprados or item.preco == 0:
		return
	if item.get("requer", "") != "" and not (item.requer in comprados):
		loja.mostrar_aviso("Compre antes: " + str(Catalogo.buscar(item.requer).nome), false)
		return
	if item.preco > moedas:
		loja.mostrar_aviso("Moedas insuficientes!", false)
		return
	moedas -= item.preco
	comprados.append(id)
	if item.tipo == "toalha":
		toalha_atual = id  # comprou, já usa nas mesas
		_aplicar_toalha()
	else:
		_colocar_item(item, true)
	_atualizar_score()
	_salvar_progresso()
	loja.atualizar(moedas, comprados, toalha_atual)
	loja.mostrar_aviso(str(item.nome) + " comprado!", true)

func _on_loja_equipar(id: String):
	var item = Catalogo.buscar(id)
	if item.is_empty() or item.tipo != "toalha":
		return
	if item.preco > 0 and not (id in comprados):
		return
	toalha_atual = id
	_aplicar_toalha()
	_salvar_progresso()
	loja.atualizar(moedas, comprados, toalha_atual)
	loja.mostrar_aviso("Toalha trocada em todas as mesas!", true)

# Recoloca no restaurante tudo o que já foi comprado (ao iniciar a partida)
func _aplicar_progresso():
	for item in Catalogo.ITENS:
		if item.id in comprados and item.tipo != "toalha":
			_colocar_item(item, false)
	_aplicar_toalha()

func _aplicar_toalha():
	var item = Catalogo.buscar(toalha_atual)
	if item.is_empty():
		return
	var textura = load(item.textura)
	for mesa in mesas:
		mesa.get_node("MesaVisual").texture = textura

func _colocar_item(item: Dictionary, animar: bool):
	var no: CanvasItem = null
	match item.tipo:
		"mesa":
			no = _criar_mesa_extra(item)
			_aplicar_toalha()
		"tapete":
			no = _criar_imagem_plana(item, item.tam)
		"quadro":
			no = _criar_imagem_plana(item, Vector2(64, 64))
		"vaso":
			no = _criar_vaso(item)
	if no != null and animar:
		no.modulate.a = 0.0
		create_tween().tween_property(no, "modulate:a", 1.0, 0.5)

func _criar_mesa_extra(item: Dictionary) -> Area2D:
	var mesa = MesaScene.instantiate()
	mesa.position = item.pos
	add_child(mesa)
	mesa.cliente_foi_embora_signal.connect(_on_cliente_foi_embora)
	mesas.append(mesa)
	return mesa

# Tapetes e quadros: imagens "coladas" no chão/parede, atrás de chef e móveis
func _criar_imagem_plana(item: Dictionary, tamanho: Vector2) -> TextureRect:
	var imagem = TextureRect.new()
	imagem.texture = load(item.textura)
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_SCALE
	imagem.position = item.pos
	imagem.size = tamanho
	imagem.z_index = -9
	add_child(imagem)
	return imagem

# Vasos são sólidos (o chef não atravessa) e entram na ordem de profundidade
func _criar_vaso(item: Dictionary) -> Node2D:
	var raiz = Node2D.new()
	raiz.position = item.pos
	var imagem = TextureRect.new()
	imagem.texture = load(item.textura)
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_SCALE
	imagem.position = Vector2(-36, -70)
	imagem.size = Vector2(72, 96)
	raiz.add_child(imagem)
	var corpo = StaticBody2D.new()
	var colisao = CollisionShape2D.new()
	var forma = RectangleShape2D.new()
	forma.size = Vector2(40, 28)
	colisao.shape = forma
	corpo.add_child(colisao)
	raiz.add_child(corpo)
	add_child(raiz)
	return raiz

# ---------------- Salvar e carregar ----------------

# Moedas, pontos e compras. Precisa rodar antes de _aplicar_progresso().
func _carregar_progresso(salvo: Dictionary):
	if salvo.is_empty():
		return
	score = max(0, salvo.score)
	moedas = max(0, salvo.moedas)
	tutorial_concluido = salvo.tutorial_concluido
	comprados = []
	for id in salvo.comprados:
		var item = Catalogo.buscar(str(id))
		if not item.is_empty() and item.preco > 0 and not (str(id) in comprados):
			comprados.append(str(id))
	var item_toalha = Catalogo.buscar(salvo.toalha)
	if not item_toalha.is_empty() and item_toalha.tipo == "toalha" and (item_toalha.preco == 0 or salvo.toalha in comprados):
		toalha_atual = salvo.toalha

func _salvar_progresso() -> bool:
	return Salvamento.salvar({
		"score": score,
		"moedas": moedas,
		"comprados": comprados,
		"toalha": toalha_atual,
		"tutorial_concluido": tutorial_concluido,
		# O primeiro atendimento guiado recomeça do início se for interrompido
		"partida": _exportar_partida() if tutorial_concluido else {},
	})

# Foto do salão neste momento: mesas, pedido em andamento e chef
func _exportar_partida() -> Dictionary:
	var dados_mesas = []
	for mesa in mesas:
		dados_mesas.append(mesa.exportar())

	var estado = estado_jogo
	var indice = mesas.find(mesa_com_pedido)
	var erros = 0
	if pedido_pendente != null:
		erros = interface_calculo.erros_do_pedido(pedido_pendente)
	# A tela de cálculo não é salva aberta: ao voltar, é só ir à bancada
	if estado == "calculando":
		estado = "com_pedido"
		# Já estourou o limite de erros (o cliente está de saída)
		if erros > interface_calculo.MAX_ERROS and indice >= 0:
			dados_mesas[indice] = {}
			estado = "livre"

	return {
		"chef": chef.position,
		"mesas": dados_mesas,
		"estado": estado,
		"mesa_pedido": indice,
		"pedido": pedido_pendente if pedido_pendente != null else {},
		"erros": erros,
	}

func _restaurar_partida(partida: Dictionary):
	if partida.is_empty():
		return
	var posicao = partida.get("chef")
	if posicao is Vector2:
		chef.position = posicao

	var dados_mesas = partida.get("mesas", [])
	for i in range(min(dados_mesas.size(), mesas.size())):
		mesas[i].restaurar(dados_mesas[i])

	var estado = str(partida.get("estado", "livre"))
	var indice = int(partida.get("mesa_pedido", -1))
	var pedido = partida.get("pedido", {})
	if estado in ["com_pedido", "buscando_ingredientes", "entregando"] \
			and indice >= 0 and indice < mesas.size() \
			and pedido is Dictionary and not pedido.is_empty() \
			and mesas[indice].estado == mesas[indice].EstadoMesa.AGUARDANDO_PRATO:
		mesa_com_pedido = mesas[indice]
		pedido_pendente = pedido
		estado_jogo = estado
		interface_calculo.restaurar_erros(pedido, int(partida.get("erros", 0)))
		match estado:
			"com_pedido":
				chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
				_atualizar_hud(str(pedido.nome) + " anotado! Vá à BANCADA (E)")
			"buscando_ingredientes":
				chef.set_estado(chef.EstadoChef.CARREGANDO_PEDIDO)
				_atualizar_hud("Pegue os ingredientes na DESPENSA (E)")
			"entregando":
				chef.set_estado(chef.EstadoChef.ENTREGANDO)
				_atualizar_hud("Entregue o prato na mesa (E)")

	# Mesa esperando um prato que não é o pedido atual não teria como ser atendida
	for mesa in mesas:
		if mesa.estado == mesa.EstadoMesa.AGUARDANDO_PRATO and mesa != mesa_com_pedido:
			mesa.resetar_mesa()

# ---------------- Primeiro atendimento guiado ----------------

func _criar_ui_tutorial():
	# Faixa de instruções no topo da tela
	banner_tutorial = PanelContainer.new()
	banner_tutorial.theme = Tema
	banner_tutorial.theme_type_variation = &"Papel"
	banner_tutorial.position = Vector2(255, 8)
	banner_tutorial.visible = false
	label_banner = Label.new()
	label_banner.theme_type_variation = &"TextoPapel"
	label_banner.custom_minimum_size = Vector2(626, 0)
	label_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_tutorial.add_child(label_banner)
	$CanvasLayer/HUD.add_child(banner_tutorial)

	# Seta que pula sobre o próximo alvo (mesa, bancada ou despensa)
	marcador = Node2D.new()
	marcador.z_index = 100
	marcador.visible = false
	var contorno = Polygon2D.new()
	contorno.color = Color(0.25, 0.09, 0.02)
	contorno.polygon = PackedVector2Array([Vector2(-12, -36), Vector2(12, -36), Vector2(12, -18), Vector2(24, -18), Vector2(0, 8), Vector2(-24, -18), Vector2(-12, -18)])
	marcador.add_child(contorno)
	var seta = Polygon2D.new()
	seta.color = Color(1, 0.84, 0.2)
	seta.polygon = PackedVector2Array([Vector2(-8, -32), Vector2(8, -32), Vector2(8, -14), Vector2(15, -14), Vector2(0, 2), Vector2(-15, -14), Vector2(-8, -14)])
	marcador.add_child(seta)
	add_child(marcador)

func _iniciar_tutorial():
	tutorial_ativo = true
	mesa_tutorial = $Mesa2
	# Primeiro pedido fácil: Feijão Tropeiro para 4 pessoas (fator 2×), sem pressa
	var receita = receitas_mineiras[0].duplicate(true)
	receita.pedido_pessoas = 4
	mesa_tutorial.receber_cliente(receita)
	mesa_tutorial.paciencia_pausada = true
	_spawnar_cliente(mesa_tutorial)
	_tutorial_ir_para(0)

func _tutorial_ir_para(passo: int):
	tutorial_passo = passo
	label_banner.text = TEXTOS_TUTORIAL[passo]
	banner_tutorial.reset_size.call_deferred()
	# Na bancada a tela de cálculo já traz a explicação, então a faixa some
	banner_tutorial.visible = passo != 2
	if passo == 5:
		tutorial_concluido = true
		_tutorial_encerrar()

func _tutorial_encerrar():
	await get_tree().create_timer(6.0, false).timeout
	tutorial_ativo = false
	mesa_tutorial = null
	banner_tutorial.visible = false
	marcador.visible = false
	_sentar_em_todas_vazias()

func _alvo_tutorial() -> Node2D:
	if not tutorial_ativo:
		return null
	match tutorial_passo:
		0, 4:
			return mesa_tutorial
		1:
			return bancada
		3:
			return despensa
	return null

func _atualizar_marcador():
	if marcador == null:
		return
	var alvo = _alvo_tutorial()
	marcador.visible = alvo != null
	if alvo != null:
		var altura = 90.0 if alvo == mesa_tutorial else 125.0
		marcador.global_position = alvo.global_position + Vector2(0, -altura + sin(_tempo * 6.0) * 7.0)
