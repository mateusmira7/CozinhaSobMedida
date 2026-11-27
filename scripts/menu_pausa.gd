extends Control
# Menu de pausa (tecla Esc). Pausa o jogo e permite salvar, voltar ao menu
# inicial ou sair. Quem sabe o que salvar é o restaurante.gd, que preenche as
# três funções abaixo.

const CENA_MENU = "res://scenes/menu.tscn"
const COR_NEUTRA = Color(0.75, 0.84, 0.76)
const COR_OK = Color(0.62, 0.96, 0.55)
const COR_ERRO = Color(1.0, 0.55, 0.48)

var salvar: Callable            # -> bool (true se gravou)
var resumo: Callable            # -> String
var pode_abrir: Callable        # -> bool

@onready var label_resumo    = $Centro/Lousa/Opcoes/Resumo
@onready var label_aviso     = $Centro/Lousa/Opcoes/Aviso
@onready var botao_continuar = $Centro/Lousa/Opcoes/BotaoContinuar
@onready var botao_salvar    = $Centro/Lousa/Opcoes/BotaoSalvar
@onready var botao_menu      = $Centro/Lousa/Opcoes/BotaoMenu
@onready var botao_sair      = $Centro/Lousa/Opcoes/BotaoSair

var _foco_anterior: Control = null
var _falhou_ao_salvar = false

func _ready():
	botao_continuar.pressed.connect(fechar)
	botao_salvar.pressed.connect(_on_salvar)
	botao_menu.pressed.connect(_on_voltar_ao_menu)
	botao_sair.pressed.connect(_on_sair)
	for botao in [botao_continuar, botao_salvar, botao_menu, botao_sair]:
		botao.mouse_entered.connect(botao.grab_focus)

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode != KEY_ESCAPE:
		return
	if visible:
		fechar()
		get_viewport().set_input_as_handled()
	elif not pode_abrir.is_valid() or pode_abrir.call():
		abrir()
		get_viewport().set_input_as_handled()

func abrir():
	_foco_anterior = get_viewport().gui_get_focus_owner()
	_falhou_ao_salvar = false
	get_tree().paused = true
	label_resumo.text = resumo.call() if resumo.is_valid() else ""
	_avisar("Esc para voltar ao jogo", COR_NEUTRA)
	visible = true
	botao_continuar.grab_focus()

func fechar():
	visible = false
	get_tree().paused = false
	# Devolve o cursor ao campo da bancada, se ela estava aberta
	if is_instance_valid(_foco_anterior) and _foco_anterior.is_visible_in_tree():
		_foco_anterior.grab_focus()
	else:
		get_viewport().gui_release_focus()

func _avisar(texto: String, cor: Color):
	label_aviso.text = texto
	label_aviso.add_theme_color_override("font_color", cor)

func _tentar_salvar() -> bool:
	if salvar.is_valid() and salvar.call():
		return true
	_avisar("Não foi possível salvar o jogo!", COR_ERRO)
	return false

func _on_salvar():
	if _tentar_salvar():
		_avisar("Jogo salvo!", COR_OK)

# Se a gravação falhar, o primeiro clique só avisa; o segundo sai assim mesmo.
func _pode_deixar_a_partida() -> bool:
	if _tentar_salvar() or _falhou_ao_salvar:
		return true
	_falhou_ao_salvar = true
	_avisar("Não foi possível salvar! Clique de novo para sair sem salvar.", COR_ERRO)
	return false

func _on_voltar_ao_menu():
	if _pode_deixar_a_partida():
		get_tree().paused = false
		get_tree().change_scene_to_file(CENA_MENU)

func _on_sair():
	if _pode_deixar_a_partida():
		get_tree().quit()
