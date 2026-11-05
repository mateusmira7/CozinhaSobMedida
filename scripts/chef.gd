extends CharacterBody2D

const SPEED = 250.0
const SPEED_RUN = 400.0

enum EstadoChef { LIVRE, CARREGANDO_PEDIDO, CALCULANDO, ENTREGANDO }
var estado_atual = EstadoChef.LIVRE

@onready var sprite = $ChefSprite
@onready var som_passo = $SomPasso
@onready var braco_d = $ChefSprite/BracoDireito
@onready var braco_e = $ChefSprite/BracoEsquerdo
@onready var anim_rosto = $AnimacoesRosto
@onready var timer_piscar = $TimerPiscar

var _tempo_anim = 0.0
var _intervalo_passo = 0.34
var _cronometro_passo = 0.0
var _pos_base_sprite = Vector2.ZERO
var _interagindo = false

func _ready():
	_pos_base_sprite = sprite.position
	if timer_piscar:
		timer_piscar.timeout.connect(_on_timer_piscar)

func _on_timer_piscar():
	if anim_rosto and not anim_rosto.is_playing():
		anim_rosto.play("piscar")
	# Próximo piscar em tempo aleatório, para parecer natural
	timer_piscar.wait_time = randf_range(2.2, 5.0)
	timer_piscar.start()

func _physics_process(delta):
	if estado_atual == EstadoChef.CALCULANDO:
		velocity = Vector2.ZERO
		move_and_slide()
		_animar_idle(delta)
		return

	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	var correndo = Input.is_key_pressed(KEY_SHIFT)

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		sprite.scale.x = -1.0 if direction.x < 0 else 1.0

	velocity = direction * (SPEED_RUN if correndo else SPEED)
	move_and_slide()

	if direction != Vector2.ZERO:
		_animar_andar(delta, correndo)
		_processar_passos(delta, correndo)
	else:
		_animar_idle(delta)
		_cronometro_passo = 0.0

func _animar_andar(delta, correndo: bool):
	_tempo_anim += delta * (14.0 if correndo else 9.0)
	var bob = abs(sin(_tempo_anim)) * (5.0 if correndo else 3.0)
	sprite.position = _pos_base_sprite + Vector2(0, -bob)
	var balanco = sin(_tempo_anim) * 0.35
	braco_d.rotation = balanco
	braco_e.rotation = -balanco

func _animar_idle(delta):
	_tempo_anim += delta * 2.2
	var bob = sin(_tempo_anim) * 1.2
	sprite.position = _pos_base_sprite + Vector2(0, -bob)
	braco_d.rotation = lerp(braco_d.rotation, 0.0, delta * 6.0)
	braco_e.rotation = lerp(braco_e.rotation, 0.0, delta * 6.0)

func _processar_passos(delta, correndo: bool):
	_cronometro_passo -= delta
	if _cronometro_passo <= 0.0:
		_cronometro_passo = _intervalo_passo / (1.5 if correndo else 1.0)
		if som_passo:
			som_passo.pitch_scale = randf_range(0.92, 1.08)
			som_passo.play()

func animar_interacao():
	# Pequeno gesto de "aceno/curvar-se" ao interagir (mesa/bancada)
	var tw = create_tween()
	tw.tween_property(sprite, "rotation", -0.12, 0.09)
	tw.tween_property(sprite, "rotation", 0.0, 0.16)

func animar_acao_principal():
	# Gesto de "mexer a panela" ao confirmar o cálculo corretamente
	var tw = create_tween()
	for i in range(3):
		tw.tween_property(braco_d, "rotation", 0.6, 0.12)
		tw.tween_property(braco_d, "rotation", -0.2, 0.12)
	tw.tween_property(braco_d, "rotation", 0.0, 0.1)

func set_estado(novo):
	estado_atual = novo
	if novo == EstadoChef.CALCULANDO:
		animar_acao_principal()

