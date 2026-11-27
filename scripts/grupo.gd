extends RefCounted

# Descreve o tamanho do grupo em texto.
# Valores inteiros viram "5 pessoas". Valores com ",5" (3,5 ou 4,5) viram
# adultos + 1 criança (a criança conta como meia porção na receita).

static func tem_crianca(n: float) -> bool:
	return not is_equal_approx(n, floor(n))

static func adultos(n: float) -> int:
	return int(floor(n))

static func descricao(n: float) -> String:
	var a = adultos(n)
	if tem_crianca(n):
		return str(a) + (" adulto" if a == 1 else " adultos") + " e 1 criança"
	return str(a) + " pessoas"
