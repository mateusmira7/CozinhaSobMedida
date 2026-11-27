extends Control

const Grupo = preload("res://scripts/grupo.gd")

signal calculo_confirmado(correto: bool, pontos: int)
# Emitido quando o jogador passa de 3 erros no mesmo pedido: o cliente vai embora.
signal erros_excedidos

# Máximo de erros permitidos por pedido. O 4º erro faz o cliente ir embora.
const MAX_ERROS = 3

const BASE = "CenterContainer/Tampo/Corpo/Lousa/Conteudo/"

@onready var label_pedido    = get_node(BASE + "LabelPedido")
@onready var label_receita   = get_node(BASE + "Cartoes/CartaoReceita/Texto/LabelReceita")
@onready var label_mult      = get_node(BASE + "Cartoes/CartaoPedido/Texto/LabelMultiplicador")

@onready var label_ing1      = get_node(BASE + "Ingredientes/Linha1/Itens/LabelIngrediente1")
@onready var input_ing1      = get_node(BASE + "Ingredientes/Linha1/Itens/InputIngrediente1")
@onready var label_ing2      = get_node(BASE + "Ingredientes/Linha2/Itens/LabelIngrediente2")
@onready var input_ing2      = get_node(BASE + "Ingredientes/Linha2/Itens/InputIngrediente2")
@onready var label_ing3      = get_node(BASE + "Ingredientes/Linha3/Itens/LabelIngrediente3")
@onready var input_ing3      = get_node(BASE + "Ingredientes/Linha3/Itens/InputIngrediente3")

@onready var botao_confirmar = $CenterContainer/Tampo/Corpo/BotaoConfirmar
@onready var label_feedback  = get_node(BASE + "LabelFeedback")

@onready var som_ding    = $SomDing
@onready var som_erro    = $SomErro
@onready var som_sizzle  = $SomSizzle

var respostas_corretas = []
var receita_atual = {}
var tentativas = 0
var erros = 0
var _id_pedido = -1
var _guiado = false
# Cada abertura/cancelamento incrementa o token. Se o cliente for embora enquanto
# a interface espera o aviso de acerto terminar, o resultado antigo é descartado.
var _sessao = 0

const COR_TEXTO = Color(0.23, 0.12, 0.05)
const COR_OK = Color(0.10, 0.34, 0.08)
const COR_ERRO = Color(0.58, 0.08, 0.04)
# Fundo do aviso muda junto com a cor do texto (creme, verde ou rosa)
const FUNDOS = {
	COR_TEXTO: "aviso_neutro",
	COR_OK: "aviso_ok",
	COR_ERRO: "aviso_erro",
}
# [fundo, borda]
const CORES_AVISO = {
	"aviso_neutro": [Color(0.98, 0.94, 0.84), Color(0.55, 0.36, 0.20)],
	"aviso_ok": [Color(0.85, 0.95, 0.78), Color(0.25, 0.48, 0.16)],
	"aviso_erro": [Color(1.0, 0.85, 0.82), Color(0.66, 0.16, 0.10)],
}

# Formata números no padrão brasileiro (vírgula decimal), sem zeros sobrando.
func _fmt(n: float) -> String:
	if is_equal_approx(n, round(n)):
		return str(int(round(n)))
	return str(snapped(n, 0.01)).replace(".", ",")

func _fmt_qtd(n: float, unidade: String) -> String:
	return _fmt(n) + " " + unidade

func _texto_chances() -> String:
	var restantes = MAX_ERROS - erros
	if restantes > 1:
		return "Você ainda pode errar " + str(restantes) + " vezes."
	if restantes == 1:
		return "Atenção: você ainda pode errar só 1 vez."
	return "Cuidado: se errar de novo, o cliente vai embora!"

func _feedback(texto: String, cor: Color):
	label_feedback.text = texto
	label_feedback.add_theme_color_override("font_color", cor)
	label_feedback.add_theme_stylebox_override("normal", _fundo_aviso(FUNDOS.get(cor, "aviso_neutro")))

# Reaproveita a moldura do tema, trocando apenas as cores
func _fundo_aviso(tipo: String) -> StyleBox:
	var estilo: StyleBoxFlat = label_feedback.get_theme_stylebox("normal", "Aviso").duplicate()
	var cores = CORES_AVISO[tipo]
	estilo.bg_color = cores[0]
	estilo.border_color = cores[1]
	return estilo

# Usados pelo salvamento: a contagem de erros vale por pedido.
func erros_do_pedido(pedido: Dictionary) -> int:
	return erros if pedido.get("_id", -1) == _id_pedido else 0

func restaurar_erros(pedido: Dictionary, quantidade: int):
	_id_pedido = pedido.get("_id", -1)
	erros = max(0, quantidade)

# Fecha a interface sem emitir resultado (usado quando o pedido expira).
func cancelar():
	_sessao += 1
	botao_confirmar.disabled = false
	visible = false

func _ready():
	visible = false
	botao_confirmar.pressed.connect(_on_confirmar)
	for entrada in [input_ing1, input_ing2, input_ing3]:
		entrada.text_changed.connect(_on_input_text_changed.bind(entrada))
		entrada.gui_input.connect(_on_input_gui_input.bind(entrada))

# Impede que a tecla "E" (ou qualquer outra tecla usada para interagir no
# cenário) chegue a ser digitada dentro do campo numérico, e bloqueia
# qualquer caractere que não seja número/vírgula/ponto.
func _on_input_gui_input(event: InputEvent, _entrada: LineEdit):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			accept_event()

func _on_input_text_changed(novo_texto: String, entrada: LineEdit):
	var filtrado = ""
	for c in novo_texto:
		if c.is_valid_int() or c == "." or c == ",":
			filtrado += c
	if filtrado != novo_texto:
		var pos = entrada.caret_column
		entrada.text = filtrado
		entrada.caret_column = min(pos - 1, filtrado.length())

func abrir_interface(pedido: Dictionary, guiado: bool = false):
	_sessao += 1
	botao_confirmar.disabled = false
	receita_atual = pedido
	tentativas = 0
	_guiado = guiado
	# Os erros valem por pedido: fechar e reabrir a bancada não zera a contagem
	var id_novo = pedido.get("_id", -1)
	if id_novo != _id_pedido:
		_id_pedido = id_novo
		erros = 0
	var mult = float(pedido.pedido_pessoas) / float(pedido.base_pessoas)

	var pessoas = float(pedido.pedido_pessoas)
	var crianca = Grupo.tem_crianca(pessoas)
	var desc_grupo = Grupo.descricao(pessoas)
	if crianca:
		label_pedido.text = pedido.nome + ": o grupo tem " + desc_grupo + " (a criança come meia porção, então são " + _fmt(pessoas) + " porções), mas a receita é para " + _fmt(pedido.base_pessoas) + " pessoas. Calcule as quantidades!"
	else:
		label_pedido.text = pedido.nome + ": o grupo é de " + desc_grupo + ", mas a receita é para " + _fmt(pedido.base_pessoas) + " pessoas. Calcule as quantidades!"

	# Cartão da receita: lista TODOS os ingredientes da receita-base
	var ing = pedido.ingredientes
	var linhas_receita = pedido.nome + "  (base: " + _fmt(pedido.base_pessoas) + " pessoas)"
	for i in ing:
		linhas_receita += "\n•  " + i.nome + ": " + _fmt_qtd(i.quantidade_base, i.unidade)
	label_receita.text = linhas_receita

	# Cartão do pedido: fator explícito
	var linha_grupo = "Grupo: " + desc_grupo
	if crianca:
		linha_grupo += "\n(criança = meia porção; total: " + _fmt(pessoas) + " porções)"
	label_mult.text = linha_grupo + "\nFator: " + _fmt(pedido.pedido_pessoas) + " ÷ " + _fmt(pedido.base_pessoas) + " = " + _fmt(mult) + "×\n(multiplique cada ingrediente por " + _fmt(mult) + ")"

	var rotulos = [label_ing1, label_ing2, label_ing3]
	var campos = [input_ing1, input_ing2, input_ing3]
	for i in range(3):
		rotulos[i].text = ing[i].nome + "  (base: " + _fmt_qtd(ing[i].quantidade_base, ing[i].unidade) + ")"
		campos[i].text = ""
		campos[i].placeholder_text = "digite aqui"
		campos[i].get_parent().get_node("Unidade" + str(i + 1)).text = ing[i].unidade

	respostas_corretas = [
		ing[0].quantidade_base * mult,
		ing[1].quantidade_base * mult,
		ing[2].quantidade_base * mult
	]

	if guiado:
		_feedback("Primeiro pedido guiado: o fator é " + _fmt(mult) + "×. Multiplique cada quantidade da receita por " + _fmt(mult) + ", digite nos campos e clique em Confirmar.", COR_TEXTO)
	else:
		_feedback("Digite a quantidade calculada de cada ingrediente e confirme.\n" + _texto_chances(), COR_TEXTO)
	visible = true
	input_ing1.grab_focus()

func _on_confirmar():
	if not visible:
		return
	var sessao = _sessao
	tentativas += 1
	var t1 = input_ing1.text.replace(",", ".")
	var t2 = input_ing2.text.replace(",", ".")
	var t3 = input_ing3.text.replace(",", ".")
	var r1 = float(t1) if t1.is_valid_float() else -1.0
	var r2 = float(t2) if t2.is_valid_float() else -1.0
	var r3 = float(t3) if t3.is_valid_float() else -1.0

	var tol = 0.06  # 6% de tolerância
	var ok1 = abs(r1 - respostas_corretas[0]) <= respostas_corretas[0] * tol
	var ok2 = abs(r2 - respostas_corretas[1]) <= respostas_corretas[1] * tol
	var ok3 = abs(r3 - respostas_corretas[2]) <= respostas_corretas[2] * tol

	if ok1 and ok2 and ok3:
		_feedback("CORRETO! Agora pegue os ingredientes na despensa.", COR_OK)
		som_ding.play()
		som_sizzle.play()
		botao_confirmar.disabled = true
		await get_tree().create_timer(1.2, false).timeout
		# O pedido expirou (ou a bancada foi reaberta) durante a espera: descarta.
		if sessao != _sessao:
			return
		botao_confirmar.disabled = false
		visible = false
		calculo_confirmado.emit(true, 100)
	else:
		var quais_erradas: Array[String] = []
		if not ok1:
			quais_erradas.append(receita_atual.ingredientes[0].nome)
		if not ok2:
			quais_erradas.append(receita_atual.ingredientes[1].nome)
		if not ok3:
			quais_erradas.append(receita_atual.ingredientes[2].nome)
		erros += 1
		som_erro.play()
		# Penalidade de -10 por tentativa errada
		calculo_confirmado.emit(false, -10)
		if not _guiado and erros > MAX_ERROS:
			# Passou de 3 erros: o cliente desiste. Só perde os pontos dos erros (-10 cada).
			_feedback("Mais de " + str(MAX_ERROS) + " erros! O cliente cansou de esperar e foi embora. Você perdeu só os " + str(erros * 10) + " pontos das tentativas erradas.", COR_ERRO)
			botao_confirmar.disabled = true
			await get_tree().create_timer(2.2, false).timeout
			if sessao != _sessao:
				return
			botao_confirmar.disabled = false
			visible = false
			erros_excedidos.emit()
			return
		var msg = "Incorreto! Confira o cálculo de: " + ", ".join(quais_erradas) + ". (-10 pontos)"
		if not _guiado:
			msg += "\n" + _texto_chances()
		_feedback(msg, COR_ERRO)
