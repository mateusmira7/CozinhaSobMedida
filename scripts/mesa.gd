extends Area2D

const Grupo = preload("res://scripts/grupo.gd")

signal cliente_foi_embora_signal(mesa)

# SAINDO = cliente acabou de ir embora (a mensagem "Foi embora" ainda aparece).
# Enquanto estiver nesse estado a mesa NÃO é considerada vazia, para que um novo
# cliente não seja sentado e depois apagado pelo reset da mesa.
enum EstadoMesa { VAZIA, COM_CLIENTE, AGUARDANDO_PRATO, SERVIDA, SAINDO }
var estado = EstadoMesa.VAZIA

var pedido = {}
var paciencia_atual = 100.0
var paciencia_maxima = 100.0
var paciencia_ativa = false
var velocidade_paciencia = 1.5
# Usado no primeiro pedido guiado: a paciência não diminui.
var paciencia_pausada = false
# Incrementado a cada reset/novo cliente; evita que um "await" antigo apague
# o estado de um cliente mais novo.
var _geracao = 0

const COR_PACIENCIA_ALTA = Color(0.25, 0.54, 0.15)
const COR_PACIENCIA_MEDIA = Color(0.87, 0.60, 0.05)
const COR_PACIENCIA_BAIXA = Color(0.80, 0.16, 0.10)
var _barra_cheia: StyleBoxFlat

@onready var comanda         = $InfoBox/Comanda
@onready var label_pedido    = $InfoBox/Comanda/VBox/LabelPedido
@onready var label_pessoas   = $InfoBox/Comanda/VBox/LabelPessoas
@onready var barra_paciencia = $InfoBox/Comanda/VBox/BarraPaciencia
@onready var label_status    = $InfoBox/Comanda/VBox/LabelStatus
@onready var som_aplausos    = $SomAplausos
@onready var som_moeda       = $SomMoeda

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	barra_paciencia.visible = false
	label_status.text = ""
	label_pessoas.text = ""
	_barra_cheia = barra_paciencia.get_theme_stylebox("fill").duplicate()
	barra_paciencia.add_theme_stylebox_override("fill", _barra_cheia)
	_atualizar_comanda()

# Esconde as linhas vazias, destaca as ações ("[E] ...") e ajusta a altura do cartão
func _atualizar_comanda():
	label_pessoas.visible = label_pessoas.text != ""
	label_status.visible = label_status.text != ""
	label_status.theme_type_variation = &"ChipAcao" if label_status.text.begins_with("[E]") else &"ChipCalmo"
	comanda.reset_size.call_deferred()

func _process(delta):
	if paciencia_ativa and not paciencia_pausada and estado == EstadoMesa.AGUARDANDO_PRATO:
		paciencia_atual -= velocidade_paciencia * delta
		paciencia_atual = max(0.0, paciencia_atual)
		_atualizar_barra()
		if paciencia_atual <= 0:
			_cliente_foi_embora()

func _atualizar_barra():
	barra_paciencia.value = paciencia_atual
	if paciencia_atual < 30:
		_barra_cheia.bg_color = COR_PACIENCIA_BAIXA
	elif paciencia_atual < 60:
		_barra_cheia.bg_color = COR_PACIENCIA_MEDIA
	else:
		_barra_cheia.bg_color = COR_PACIENCIA_ALTA

# --- Salvamento ---
# Só mesas com cliente esperando são guardadas; as demais voltam vazias.
func exportar() -> Dictionary:
	if estado != EstadoMesa.COM_CLIENTE and estado != EstadoMesa.AGUARDANDO_PRATO:
		return {}
	return {"estado": estado, "pedido": pedido, "paciencia": paciencia_atual}

func restaurar(dados):
	if not (dados is Dictionary):
		return
	var novo_pedido = dados.get("pedido", {})
	if not (novo_pedido is Dictionary) or not novo_pedido.has_all(["nome", "base_pessoas", "pedido_pessoas", "ingredientes"]):
		return
	receber_cliente(novo_pedido)
	if int(dados.get("estado", EstadoMesa.COM_CLIENTE)) == EstadoMesa.AGUARDANDO_PRATO:
		iniciar_espera()
		paciencia_atual = clampf(float(dados.get("paciencia", paciencia_maxima)), 1.0, paciencia_maxima)
		_atualizar_barra()

func receber_cliente(novo_pedido: Dictionary):
	_geracao += 1
	pedido = novo_pedido
	estado = EstadoMesa.COM_CLIENTE
	paciencia_atual = paciencia_maxima
	barra_paciencia.visible = true
	_atualizar_barra()
	label_pedido.text = pedido.get("nome", "?")
	label_pessoas.text = Grupo.descricao(pedido.pedido_pessoas)
	label_status.text = "[E] Anotar"
	_atualizar_comanda()

func iniciar_espera():
	estado = EstadoMesa.AGUARDANDO_PRATO
	paciencia_ativa = true
	label_status.text = "Sem pressa" if paciencia_pausada else "Preparando..."
	_atualizar_comanda()

func receber_prato(pontos: int):
	paciencia_ativa = false
	estado = EstadoMesa.SERVIDA
	barra_paciencia.visible = false
	label_pedido.text = "Servido!"
	label_pessoas.text = "+" + str(pontos) + " pts"
	label_status.text = ""
	_atualizar_comanda()
	som_aplausos.play()
	som_moeda.play()
	var geracao = _geracao
	await get_tree().create_timer(2.5, false).timeout
	if geracao == _geracao:
		resetar_mesa()

func _cliente_foi_embora():
	paciencia_ativa = false
	estado = EstadoMesa.SAINDO
	barra_paciencia.visible = false
	label_pedido.text = "Foi embora"
	label_pessoas.text = "-50 pts"
	label_status.text = ""
	_atualizar_comanda()
	var geracao = _geracao
	cliente_foi_embora_signal.emit(self)
	await get_tree().create_timer(2.5, false).timeout
	if geracao == _geracao:
		resetar_mesa()

# O cliente desiste porque o jogador errou o cálculo mais de 3 vezes.
# Não emite cliente_foi_embora_signal: a penalidade de -50 não se aplica,
# o jogador só perde os pontos das tentativas erradas.
func desistir_por_erros(pontos_perdidos: int):
	paciencia_ativa = false
	estado = EstadoMesa.SAINDO
	barra_paciencia.visible = false
	label_pedido.text = "Foi embora"
	label_pessoas.text = "-" + str(pontos_perdidos) + " pts"
	label_status.text = "Muitos erros"
	_atualizar_comanda()
	var geracao = _geracao
	await get_tree().create_timer(2.5, false).timeout
	if geracao == _geracao:
		resetar_mesa()

func resetar_mesa():
	_geracao += 1
	estado = EstadoMesa.VAZIA
	paciencia_ativa = false
	paciencia_pausada = false
	pedido = {}
	paciencia_atual = paciencia_maxima
	label_pedido.text = "Mesa livre"
	label_pessoas.text = ""
	label_status.text = ""
	barra_paciencia.visible = false
	_atualizar_comanda()

func _on_body_entered(body):
	if body.name == "Chef":
		if estado == EstadoMesa.COM_CLIENTE:
			label_status.text = "[E] Anotar"
		elif estado == EstadoMesa.AGUARDANDO_PRATO:
			label_status.text = "[E] Entregar"
		_atualizar_comanda()

func _on_body_exited(body):
	if body.name == "Chef":
		if estado == EstadoMesa.COM_CLIENTE:
			label_status.text = "[E] Anotar"
		elif estado == EstadoMesa.AGUARDANDO_PRATO:
			label_status.text = "Preparando..."
		_atualizar_comanda()
