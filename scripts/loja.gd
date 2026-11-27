extends Control
# Tela da Lojinha. Só cuida da interface: quem valida a compra, desconta as moedas
# e coloca o item no restaurante é o restaurante.gd (ele escuta os sinais abaixo).

const Catalogo = preload("res://scripts/loja_catalogo.gd")
const Tema = preload("res://assets/ui/tema_cozinha.tres")
const IconeMoeda = preload("res://assets/ui/icone_moeda.png")
const IconeLoja = preload("res://assets/ui/icone_loja.png")
const FitaMetrica = preload("res://scripts/fita_metrica.gd")
const CATEGORIAS = ["Mesas", "Toalhas", "Tapetes", "Vasos", "Quadros"]

signal comprar_pedido(id: String)
signal equipar_pedido(id: String)
signal fechada

var _moedas: int = 0
var _comprados: Array = []
var _equipada: String = ""
var _label_moedas: Label
var _label_aviso: Label
var _botoes: Dictionary = {}
var _precos: Dictionary = {}

func _ready():
	# A loja precisa funcionar com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_construir()

func _input(event):
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_L:
			fechar()
			get_viewport().set_input_as_handled()

func abrir(moedas: int, comprados: Array, equipada: String):
	_label_aviso.text = ""
	atualizar(moedas, comprados, equipada)
	visible = true

func fechar():
	visible = false
	fechada.emit()

func mostrar_aviso(texto: String, sucesso: bool):
	_label_aviso.text = texto
	_label_aviso.add_theme_color_override("font_color",
		Color(0.62, 0.96, 0.55) if sucesso else Color(1.0, 0.6, 0.52))

func atualizar(moedas: int, comprados: Array, equipada: String):
	_moedas = moedas
	_comprados = comprados
	_equipada = equipada
	_label_moedas.text = str(moedas)
	for item in Catalogo.ITENS:
		var botao: Button = _botoes[item.id]
		var preco: Dictionary = _precos[item.id]
		var possui = _possui(item)
		preco.icone.visible = not possui
		botao.theme_type_variation = &""
		if item.tipo == "toalha" and possui:
			preco.texto.text = "Já é sua"
			botao.text = "Em uso" if item.id == equipada else "Usar nas mesas"
			botao.disabled = item.id == equipada
		elif possui:
			preco.texto.text = "Já é sua"
			botao.text = "Comprado"
			botao.disabled = true
		elif item.get("requer", "") != "" and not (item.requer in comprados):
			preco.texto.text = str(item.preco)
			botao.text = "Antes: " + str(Catalogo.buscar(item.requer).nome)
			botao.disabled = true
		else:
			var falta = item.preco - moedas
			preco.texto.text = str(item.preco) + ("" if falta <= 0 else "  (faltam " + str(falta) + ")")
			botao.text = "Comprar"
			botao.disabled = falta > 0
			if not botao.disabled:
				botao.theme_type_variation = &"BotaoConfirmar"

func _possui(item: Dictionary) -> bool:
	return item.preco == 0 or item.id in _comprados

func _ao_clicar(item: Dictionary):
	if item.tipo == "toalha" and _possui(item):
		equipar_pedido.emit(item.id)
	else:
		comprar_pedido.emit(item.id)

# ---------------- Construção da interface ----------------
# As cores, fontes e molduras vêm de assets/ui/tema_cozinha.tres.

func _construir():
	theme = Tema

	var fundo = ColorRect.new()
	fundo.color = Color(0.08, 0.04, 0.02, 0.65)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var centro = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var painel = _painel(&"Tampo")
	painel.custom_minimum_size = Vector2(960, 580)
	centro.add_child(painel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	painel.add_child(vbox)

	# Cabeçalho: ícone, título, saldo e botão de fechar
	var topo = HBoxContainer.new()
	topo.add_theme_constant_override("separation", 14)
	vbox.add_child(topo)
	topo.add_child(_imagem(IconeLoja, Vector2(48, 48)))
	var nomes = VBoxContainer.new()
	nomes.add_theme_constant_override("separation", 2)
	nomes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topo.add_child(nomes)
	nomes.add_child(_rotulo("Lojinha do restaurante", &"TituloPlaca"))
	var fita = FitaMetrica.new()
	fita.custom_minimum_size = Vector2(300, 10)
	fita.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	nomes.add_child(fita)

	var saldo = _painel(&"Ficha")
	saldo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topo.add_child(saldo)
	var linha_saldo = HBoxContainer.new()
	linha_saldo.add_theme_constant_override("separation", 8)
	saldo.add_child(linha_saldo)
	linha_saldo.add_child(_imagem(IconeMoeda, Vector2(32, 32)))
	_label_moedas = _rotulo("0", &"Numero")
	_label_moedas.custom_minimum_size = Vector2(56, 0)
	linha_saldo.add_child(_label_moedas)

	var fechar_btn = Button.new()
	fechar_btn.text = "Fechar (Esc)"
	fechar_btn.add_theme_font_size_override("font_size", 24)
	fechar_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fechar_btn.focus_mode = Control.FOCUS_NONE
	fechar_btn.pressed.connect(fechar)
	topo.add_child(fechar_btn)

	var dica = _rotulo("Gaste as moedas dos pratos entregues para decorar e ampliar o salão. O jogo fica pausado enquanto você está aqui.", &"TextoClaro")
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dica.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(dica)

	# Abas por categoria
	var abas = TabContainer.new()
	abas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(abas)
	var grades = {}
	for categoria in CATEGORIAS:
		var rolagem = ScrollContainer.new()
		rolagem.name = categoria
		rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		abas.add_child(rolagem)
		var grade = GridContainer.new()
		grade.columns = 5
		grade.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
		grade.add_theme_constant_override("h_separation", 10)
		grade.add_theme_constant_override("v_separation", 12)
		rolagem.add_child(grade)
		grades[categoria] = grade

	for item in Catalogo.ITENS:
		grades[item.categoria].add_child(_criar_card(item))

	# Aviso de compra
	_label_aviso = _rotulo("", &"TextoClaro")
	_label_aviso.custom_minimum_size = Vector2(0, 24)
	_label_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_aviso.add_theme_font_size_override("font_size", 23)
	vbox.add_child(_label_aviso)

func _criar_card(item: Dictionary) -> Control:
	var card = _painel(&"Papel")
	card.custom_minimum_size = Vector2(172, 290)

	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	card.add_child(v)

	v.add_child(_imagem(load(item.icone), Vector2(0, 90)))

	var nome = _rotulo(item.nome, &"TituloPapel")
	nome.add_theme_font_size_override("font_size", 22)
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(nome)

	var desc = _rotulo(item.desc, &"TextoPapel")
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(142, 52)
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc.add_theme_font_size_override("font_size", 17)
	v.add_child(desc)

	var linha_preco = HBoxContainer.new()
	linha_preco.alignment = BoxContainer.ALIGNMENT_CENTER
	linha_preco.add_theme_constant_override("separation", 6)
	v.add_child(linha_preco)
	var moeda = _imagem(IconeMoeda, Vector2(22, 22))
	linha_preco.add_child(moeda)
	var preco = _rotulo("", &"TextoPapel")
	linha_preco.add_child(preco)
	_precos[item.id] = {"icone": moeda, "texto": preco}

	var botao = Button.new()
	botao.custom_minimum_size = Vector2(0, 46)
	botao.add_theme_font_size_override("font_size", 22)
	botao.focus_mode = Control.FOCUS_NONE
	botao.pressed.connect(_ao_clicar.bind(item))
	v.add_child(botao)
	_botoes[item.id] = botao
	return card

func _painel(variacao: StringName) -> PanelContainer:
	var painel = PanelContainer.new()
	painel.theme_type_variation = variacao
	return painel

func _rotulo(texto: String, variacao: StringName) -> Label:
	var rotulo = Label.new()
	rotulo.text = texto
	rotulo.theme_type_variation = variacao
	return rotulo

func _imagem(textura: Texture2D, tamanho: Vector2) -> TextureRect:
	var imagem = TextureRect.new()
	imagem.texture = textura
	imagem.custom_minimum_size = tamanho
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return imagem
