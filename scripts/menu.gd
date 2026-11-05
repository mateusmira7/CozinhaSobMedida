extends Control

@onready var botao_jogar = $CenterContainer/Painel/MarginContainer/VBox/BotaoJogar
@onready var botao_sair  = $CenterContainer/Painel/MarginContainer/VBox/BotaoSair

func _ready():
	botao_jogar.pressed.connect(_on_jogar)
	botao_sair.pressed.connect(_on_sair)
	botao_jogar.grab_focus()

func _on_jogar():
	get_tree().change_scene_to_file("res://scenes/restaurante.tscn")

func _on_sair():
	get_tree().quit()
