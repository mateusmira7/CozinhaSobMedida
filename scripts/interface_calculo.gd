extends Control

signal calculo_confirmado(correto: bool, pontos: int)

const BASE = "CenterContainer/Painel/Main/BodyMargin/Body"

@onready var label_pedido    = $"CenterContainer/Painel/Main/BodyMargin/Body/LabelPedido"
@onready var label_receita   = $"CenterContainer/Painel/Main/BodyMargin/Body/Cards/CardReceita/VBoxReceita/LabelReceita"
@onready var label_mult      = $"CenterContainer/Painel/Main/BodyMargin/Body/Cards/CardPedido/VBoxPedido/LabelMultiplicador"

@onready var label_ing1      = $"CenterContainer/Painel/Main/BodyMargin/Body/InputsBox/Linha1/LabelIngrediente1"
@onready var input_ing1      = $"CenterContainer/Painel/Main/BodyMargin/Body/InputsBox/Linha1/InputIngrediente1"
@onready var label_ing2      = $"CenterContainer/Painel/Main/BodyMargin/Body/InputsBox/Linha2/LabelIngrediente2"
@onready var input_ing2      = $"CenterContainer/Painel/Main/BodyMargin/Body/InputsBox/Linha2/InputIngrediente2"
@onready var label_ing3      = $"CenterContainer/Painel/Main/BodyMargin/Body/InputsBox/Linha3/LabelIngrediente3"
@onready var input_ing3      = $"CenterContainer/Painel/Main/BodyMargin/Body/InputsBox/Linha3/InputIngrediente3"

@onready var botao_confirmar = $"CenterContainer/Painel/Main/BodyMargin/Body/BotaoConfirmar"
@onready var label_feedback  = $"CenterContainer/Painel/Main/BodyMargin/Body/LabelFeedback"

@onready var som_ding    = $SomDing
@onready var som_erro    = $SomErro
@onready var som_sizzle  = $SomSizzle

var respostas_corretas = []
var receita_atual = {}
var tentativas = 0

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

func abrir_interface(pedido: Dictionary):
	receita_atual = pedido
	tentativas = 0
	var mult = float(pedido.pedido_pessoas) / float(pedido.base_pessoas)

	label_pedido.text = "⚠️  " + pedido.nome + " — o grupo quer para " + str(pedido.pedido_pessoas) + " pessoas! Calcule as quantidades:"
	label_receita.text = pedido.nome + "\nBase: " + str(pedido.base_pessoas) + " pessoas"
	label_mult.text = "Para " + str(pedido.pedido_pessoas) + " pessoas  (" + str(snapped(mult, 0.01)) + "x)"

	var ing = pedido.ingredientes
	label_ing1.text = ing[0].nome + "\n(base: " + str(ing[0].quantidade_base) + ing[0].unidade + ")"
	label_ing2.text = ing[1].nome + "\n(base: " + str(ing[1].quantidade_base) + ing[1].unidade + ")"
	label_ing3.text = ing[2].nome + "\n(base: " + str(ing[2].quantidade_base) + ing[2].unidade + ")"

	input_ing1.text = ""
	input_ing2.text = ""
	input_ing3.text = ""
	input_ing1.placeholder_text = "em " + ing[0].unidade
	input_ing2.placeholder_text = "em " + ing[1].unidade
	input_ing3.placeholder_text = "em " + ing[2].unidade

	respostas_corretas = [
		ing[0].quantidade_base * mult,
		ing[1].quantidade_base * mult,
		ing[2].quantidade_base * mult
	]

	label_feedback.text = "Digite a quantidade calculada de cada ingrediente e confirme."
	label_feedback.modulate = Color(0.3, 0.19, 0.12)
	visible = true
	input_ing1.grab_focus()

func _on_confirmar():
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
		label_feedback.text = "✅ CORRETO! Volte à mesa e entregue o prato!"
		label_feedback.modulate = Color(0.2, 0.5, 0.2)
		som_ding.play()
		som_sizzle.play()
		botao_confirmar.disabled = true
		await get_tree().create_timer(1.2).timeout
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
		var msg = "❌ Incorreto! Confira o cálculo de: " + ", ".join(quais_erradas) + ". Tente novamente!"
		label_feedback.text = msg
		label_feedback.modulate = Color(0.65, 0.15, 0.1)
		som_erro.play()
		# Penalidade por tentativa errada mas não fecha — pode tentar de novo
		calculo_confirmado.emit(false, -10)
