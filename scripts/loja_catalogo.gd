extends RefCounted
# Catálogo da Lojinha. Para criar um item novo basta acrescentar um dicionário
# em ITENS (o id precisa ser único). Campos:
#   id, categoria (aba da loja), tipo, nome, desc, preco, icone (prévia na loja)
#   tipo "mesa"   -> pos: onde a mesa nova aparece | requer: id que precisa ser comprado antes
#   tipo "toalha" -> textura: aplicada em TODAS as mesas (a de preço 0 já vem liberada)
#   tipo "tapete" -> textura, pos (canto superior esquerdo) e tam
#   tipo "quadro" -> textura, pos (canto superior esquerdo, na parede)
#   tipo "vaso"   -> textura, pos (centro da base do vaso; ele é sólido)

const TOALHA_PADRAO = "toalha_vermelha"
const ART = "res://assets/art/"

const ITENS = [
	# ---------------- Mesas ----------------
	{"id": "mesa_4", "categoria": "Mesas", "tipo": "mesa", "nome": "Mesa 4",
	 "desc": "Mais uma mesa no salão: mais clientes ao mesmo tempo.",
	 "preco": 150, "icone": ART + "toalha_mesa.png", "pos": Vector2(400, 165), "requer": ""},
	{"id": "mesa_5", "categoria": "Mesas", "tipo": "mesa", "nome": "Mesa 5",
	 "desc": "A quinta mesa deixa o salão lotado!",
	 "preco": 250, "icone": ART + "toalha_mesa.png", "pos": Vector2(800, 165), "requer": "mesa_4"},

	# ---------------- Toalhas ----------------
	{"id": "toalha_vermelha", "categoria": "Toalhas", "tipo": "toalha", "nome": "Xadrez Vermelha",
	 "desc": "A toalha original do restaurante.",
	 "preco": 0, "icone": ART + "toalha_mesa.png", "textura": ART + "toalha_mesa.png"},
	{"id": "toalha_azul", "categoria": "Toalhas", "tipo": "toalha", "nome": "Xadrez Azul",
	 "desc": "Visual fresquinho para todas as mesas.",
	 "preco": 60, "icone": ART + "toalha_azul.png", "textura": ART + "toalha_azul.png"},
	{"id": "toalha_verde", "categoria": "Toalhas", "tipo": "toalha", "nome": "Xadrez Verde",
	 "desc": "Cara de fazenda: combina com comida caseira.",
	 "preco": 60, "icone": ART + "toalha_verde.png", "textura": ART + "toalha_verde.png"},
	{"id": "toalha_lilas", "categoria": "Toalhas", "tipo": "toalha", "nome": "Xadrez Lilás",
	 "desc": "Um toque de cor diferente no salão.",
	 "preco": 60, "icone": ART + "toalha_lilas.png", "textura": ART + "toalha_lilas.png"},

	# ---------------- Tapetes ----------------
	{"id": "tapete_azul", "categoria": "Tapetes", "tipo": "tapete", "nome": "Tapete Azul",
	 "desc": "Vai no canto esquerdo do salão.",
	 "preco": 80, "icone": ART + "tapete_azul.png", "textura": ART + "tapete_azul.png",
	 "pos": Vector2(115, 373), "tam": Vector2(230, 115)},
	{"id": "tapete_verde", "categoria": "Tapetes", "tipo": "tapete", "nome": "Tapete Verde",
	 "desc": "Vai no canto direito do salão.",
	 "preco": 80, "icone": ART + "tapete_verde.png", "textura": ART + "tapete_verde.png",
	 "pos": Vector2(855, 373), "tam": Vector2(230, 115)},
	{"id": "capacho_roxo", "categoria": "Tapetes", "tipo": "tapete", "nome": "Capacho da Entrada",
	 "desc": "Recebe os clientes logo na porta.",
	 "preco": 40, "icone": ART + "tapete_roxo.png", "textura": ART + "tapete_roxo.png",
	 "pos": Vector2(50, 185), "tam": Vector2(80, 40)},

	# ---------------- Vasos ----------------
	{"id": "vaso_azul", "categoria": "Vasos", "tipo": "vaso", "nome": "Vaso Azul",
	 "desc": "Planta no vaso azul, ao lado do tapete central.",
	 "preco": 50, "icone": ART + "vaso_azul.png", "textura": ART + "vaso_azul.png",
	 "pos": Vector2(400, 460)},
	{"id": "vaso_roxo", "categoria": "Vasos", "tipo": "vaso", "nome": "Vaso Roxo",
	 "desc": "Planta no vaso roxo, do outro lado do tapete central.",
	 "preco": 50, "icone": ART + "vaso_roxo.png", "textura": ART + "vaso_roxo.png",
	 "pos": Vector2(800, 460)},
	{"id": "vaso_florido", "categoria": "Vasos", "tipo": "vaso", "nome": "Planta Florida",
	 "desc": "Cheia de florzinhas rosa.",
	 "preco": 50, "icone": ART + "vaso_florido.png", "textura": ART + "vaso_florido.png",
	 "pos": Vector2(1119, 290)},

	# ---------------- Quadros ----------------
	{"id": "quadro_azul", "categoria": "Quadros", "tipo": "quadro", "nome": "Quadro Azul",
	 "desc": "Azulejo azul na parede.",
	 "preco": 40, "icone": ART + "quadro_azul.png", "textura": ART + "quadro_azul.png",
	 "pos": Vector2(240, 15)},
	{"id": "quadro_verde", "categoria": "Quadros", "tipo": "quadro", "nome": "Quadro Verde",
	 "desc": "Azulejo verde na parede.",
	 "preco": 40, "icone": ART + "quadro_verde.png", "textura": ART + "quadro_verde.png",
	 "pos": Vector2(330, 15)},
	{"id": "quadro_rosa", "categoria": "Quadros", "tipo": "quadro", "nome": "Quadro Rosa",
	 "desc": "Fica no centro da parede.",
	 "preco": 40, "icone": ART + "quadro_rosa.png", "textura": ART + "quadro_rosa.png",
	 "pos": Vector2(568, 15)},
	{"id": "quadro_roxo", "categoria": "Quadros", "tipo": "quadro", "nome": "Quadro Roxo",
	 "desc": "Azulejo roxo na parede.",
	 "preco": 40, "icone": ART + "quadro_roxo.png", "textura": ART + "quadro_roxo.png",
	 "pos": Vector2(790, 15)},
	{"id": "quadro_turquesa", "categoria": "Quadros", "tipo": "quadro", "nome": "Quadro Turquesa",
	 "desc": "Azulejo turquesa na parede.",
	 "preco": 40, "icone": ART + "quadro_turquesa.png", "textura": ART + "quadro_turquesa.png",
	 "pos": Vector2(874, 15)},
]

static func buscar(id: String) -> Dictionary:
	for item in ITENS:
		if item.id == id:
			return item
	return {}
