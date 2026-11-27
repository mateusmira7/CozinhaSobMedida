extends RefCounted
# Salvamento do progresso. Este script só lê e grava o arquivo; quem decide o que
# entra no save é o restaurante.gd.
#
# O arquivo fica em user://progresso.cfg (no Windows:
# %APPDATA%\Godot\app_userdata\CozinhaSobMedida\progresso.cfg).

# Para jogar sempre do zero (útil em testes), troque para false.
const PERSISTIR_PROGRESSO = true
const ARQUIVO = "user://progresso.cfg"
const ARQUIVO_TEMPORARIO = "user://progresso.tmp"
const VERSAO = 2

# Devolve {} quando não há jogo salvo (ou o arquivo não pode ser lido).
static func carregar() -> Dictionary:
	if not PERSISTIR_PROGRESSO or not FileAccess.file_exists(ARQUIVO):
		return {}
	var cfg = ConfigFile.new()
	if cfg.load(ARQUIVO) != OK or not cfg.has_section("jogo"):
		return {}
	# Saves antigos (sem "versao") guardavam só moedas e compras. Quem tem um
	# deles já fez o primeiro atendimento, então o tutorial não se repete.
	var comprados = cfg.get_value("jogo", "comprados", [])
	var partida = cfg.get_value("jogo", "partida", {})
	return {
		"score": int(cfg.get_value("jogo", "score", 0)),
		"moedas": int(cfg.get_value("jogo", "moedas", 0)),
		"comprados": comprados if comprados is Array else [],
		"toalha": str(cfg.get_value("jogo", "toalha", "")),
		"tutorial_concluido": bool(cfg.get_value("jogo", "tutorial_concluido", true)),
		"partida": partida if partida is Dictionary else {},
	}

static func salvar(dados: Dictionary) -> bool:
	if not PERSISTIR_PROGRESSO:
		return false
	var cfg = ConfigFile.new()
	cfg.set_value("jogo", "versao", VERSAO)
	for chave in dados:
		cfg.set_value("jogo", chave, dados[chave])
	# Grava num arquivo temporário e só então substitui o save, para que uma
	# queda no meio da gravação não corrompa o progresso.
	if cfg.save(ARQUIVO_TEMPORARIO) != OK:
		return false
	return DirAccess.rename_absolute(ARQUIVO_TEMPORARIO, ARQUIVO) == OK

static func apagar():
	if FileAccess.file_exists(ARQUIVO):
		DirAccess.remove_absolute(ARQUIVO)
