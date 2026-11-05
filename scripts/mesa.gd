extends Area2D

signal cliente_foi_embora_signal(mesa)

enum EstadoMesa { VAZIA, COM_CLIENTE, AGUARDANDO_PRATO, SERVIDA }
var estado = EstadoMesa.VAZIA

var pedido = {}
var paciencia_atual = 100.0
var paciencia_maxima = 100.0
var paciencia_ativa = false
var velocidade_paciencia = 1.5

@onready var label_pedido    = $InfoBox/LabelPedido
@onready var label_pessoas   = $InfoBox/LabelPessoas
@onready var barra_paciencia = $InfoBox/BarraPaciencia
@onready var label_status    = $InfoBox/LabelStatus
@onready var som_aplausos    = $SomAplausos
@onready var som_moeda       = $SomMoeda

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	barra_paciencia.visible = false
	label_status.text = ""
	label_pessoas.text = ""

func _process(delta):
	if paciencia_ativa and estado == EstadoMesa.AGUARDANDO_PRATO:
		paciencia_atual -= velocidade_paciencia * delta
		paciencia_atual = max(0.0, paciencia_atual)
		barra_paciencia.value = paciencia_atual
		if paciencia_atual < 30:
			barra_paciencia.modulate = Color.RED
		elif paciencia_atual < 60:
			barra_paciencia.modulate = Color.YELLOW
		else:
			barra_paciencia.modulate = Color.GREEN
		if paciencia_atual <= 0:
			_cliente_foi_embora()

func receber_cliente(novo_pedido: Dictionary):
	pedido = novo_pedido
	estado = EstadoMesa.COM_CLIENTE
	paciencia_atual = paciencia_maxima
	barra_paciencia.visible = true
	barra_paciencia.value = paciencia_atual
	barra_paciencia.modulate = Color.GREEN
	label_pedido.text = pedido.get("nome", "?")
	label_pessoas.text = str(pedido.pedido_pessoas) + " pessoas"
	label_status.text = "[E] Anotar"

func iniciar_espera():
	estado = EstadoMesa.AGUARDANDO_PRATO
	paciencia_ativa = true
	label_status.text = "Preparando..."

func receber_prato(pontos: int):
	paciencia_ativa = false
	estado = EstadoMesa.SERVIDA
	barra_paciencia.visible = false
	label_pedido.text = "Servido!"
	label_pessoas.text = "+" + str(pontos) + " pts"
	label_status.text = ""
	som_aplausos.play()
	som_moeda.play()
	await get_tree().create_timer(2.5).timeout
	resetar_mesa()

func _cliente_foi_embora():
	paciencia_ativa = false
	estado = EstadoMesa.VAZIA
	barra_paciencia.visible = false
	label_pedido.text = "Foi embora"
	label_pessoas.text = "-50 pts"
	label_status.text = ""
	cliente_foi_embora_signal.emit(self)
	await get_tree().create_timer(2.5).timeout
	resetar_mesa()

func resetar_mesa():
	estado = EstadoMesa.VAZIA
	pedido = {}
	paciencia_atual = paciencia_maxima
	label_pedido.text = "Mesa Vazia"
	label_pessoas.text = ""
	label_status.text = ""

func _on_body_entered(body):
	if body.name == "Chef":
		if estado == EstadoMesa.COM_CLIENTE:
			label_status.text = "[E] Anotar"
		elif estado == EstadoMesa.AGUARDANDO_PRATO:
			label_status.text = "[E] Entregar"

func _on_body_exited(body):
	if body.name == "Chef":
		if estado == EstadoMesa.COM_CLIENTE:
			label_status.text = "[E] Anotar"
		elif estado == EstadoMesa.AGUARDANDO_PRATO:
			label_status.text = "Preparando..."
