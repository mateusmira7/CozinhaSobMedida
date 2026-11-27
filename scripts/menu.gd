extends Control
# Menu inicial. Se existir um jogo salvo, oferece "Continuar" e "Novo jogo";
# caso contrário, mostra apenas "Jogar" e "Sair".

const Salvamento = preload("res://scripts/salvamento.gd")
const ChefScene = preload("res://scenes/chef.tscn")
const CENA_JOGO = "res://scenes/restaurante.tscn"

@onready var botao_jogar    = $Centro/Lousa/Opcoes/BotaoJogar
@onready var botao_novo     = $Centro/Lousa/Opcoes/BotaoNovo
@onready var botao_sair     = $Centro/Lousa/Opcoes/BotaoSair
@onready var resumo_salvo   = $Centro/Lousa/Opcoes/ResumoSalvo
@onready var confirmacao    = $Confirmacao
@onready var label_aviso    = $Confirmacao/Centro/Lousa/Opcoes/Aviso
@onready var botao_cancelar = $Confirmacao/Centro/Lousa/Opcoes/Botoes/BotaoCancelar
@onready var botao_apagar   = $Confirmacao/Centro/Lousa/Opcoes/Botoes/BotaoApagar
@onready var musica         = $MusicaMenu

var _mascote: Node2D
var _tempo = 0.0
var _proximo_piscar = 2.0

func _ready():
	botao_jogar.pressed.connect(_on_jogar)
	botao_novo.pressed.connect(_on_novo_jogo)
	botao_sair.pressed.connect(_on_sair)
	botao_cancelar.pressed.connect(_fechar_confirmacao)
	botao_apagar.pressed.connect(_on_apagar_e_comecar)
	# Passar o mouse move o destaque: nunca ficam dois botões marcados
	for botao in [botao_jogar, botao_novo, botao_sair, botao_cancelar, botao_apagar]:
		botao.mouse_entered.connect(botao.grab_focus)

	if musica.stream is AudioStreamWAV:
		musica.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	var salvo = Salvamento.carregar()
	if not salvo.is_empty():
		var resumo = "Pontos: %d   |   Moedas: %d" % [salvo.score, salvo.moedas]
		botao_jogar.text = "Continuar"
		botao_novo.visible = true
		resumo_salvo.text = resumo
		resumo_salvo.visible = true
		label_aviso.text = "O progresso salvo será apagado.\n" + resumo

	_criar_mascote()
	botao_jogar.grab_focus()

# Reaproveita o desenho do chef (sem a física nem o controle do jogador)
func _criar_mascote():
	var chef = ChefScene.instantiate()
	_mascote = chef.get_node("ChefSprite").duplicate()
	chef.free()
	_mascote.scale = Vector2(4.5, 4.5)
	_mascote.position = $Cenario/PosicaoChef.position
	$Cenario.add_child(_mascote)

func _process(delta):
	if _mascote == null:
		return
	_tempo += delta
	_mascote.position.y = $Cenario/PosicaoChef.position.y + sin(_tempo * 2.2) * 5.0
	_mascote.get_node("BracoDireito").rotation = sin(_tempo * 2.2) * 0.06
	_mascote.get_node("BracoEsquerdo").rotation = -sin(_tempo * 2.2) * 0.06
	# Piscar de olhos (os polígonos dos olhos ficam em y = -14)
	if _tempo >= _proximo_piscar:
		var fechado = _tempo < _proximo_piscar + 0.14
		for nome in ["OlhoE", "OlhoD"]:
			var olho: Polygon2D = _mascote.get_node(nome)
			olho.scale.y = 0.15 if fechado else 1.0
			olho.position.y = -14.0 * 0.85 if fechado else 0.0
		if not fechado:
			_proximo_piscar = _tempo + randf_range(2.2, 4.5)

func _unhandled_input(event):
	if confirmacao.visible and event.is_action_pressed("ui_cancel"):
		_fechar_confirmacao()
		get_viewport().set_input_as_handled()

func _on_jogar():
	get_tree().change_scene_to_file(CENA_JOGO)

func _on_novo_jogo():
	_permitir_foco(false)
	confirmacao.visible = true
	botao_cancelar.grab_focus()

func _fechar_confirmacao():
	confirmacao.visible = false
	_permitir_foco(true)
	botao_novo.grab_focus()

# Com a confirmação aberta, os botões de trás não podem receber o teclado
func _permitir_foco(sim: bool):
	for botao in [botao_jogar, botao_novo, botao_sair]:
		botao.focus_mode = Control.FOCUS_ALL if sim else Control.FOCUS_NONE

func _on_apagar_e_comecar():
	Salvamento.apagar()
	_on_jogar()

func _on_sair():
	get_tree().quit()
