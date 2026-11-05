# Cozinha sob Medida

Simulador de restaurante educativo em 2D (visão de cima) feito na **Godot 4.7.2** pelo estúdio **High Pitch Studios** (Elisa Maria Gomes, Mateus Corrêa de Mira e Otávio Rodolfo Roecker — Engenharia de Software, PAC III).

Você é um chef que atende clientes em um restaurante. Cada grupo pede um prato de uma receita-base feita para 2 pessoas, mas o grupo tem outro tamanho (3, 4, 5, 3,5, 4,5 ou 6 pessoas). Para preparar o prato, você precisa **calcular as quantidades proporcionais de cada ingrediente** — a matemática (proporção, frações e decimais) é a própria mecânica do jogo, não uma prova.

- **GDD (Game Design Document):** [`docs/CozinhaSobMedida_N3_GDD.pdf`](docs/CozinhaSobMedida_N3_GDD.pdf), neste repositório.

---

## 1. Requisitos

| Item | Requisito |
|---|---|
| Engine | **Godot 4.7.2** (padrão, **não** a versão .NET/Mono) — https://godotengine.org/download/archive/ |
| Sistema operacional | Windows 10/11 ou Linux (64 bits) |
| Renderizador | GL Compatibility (roda em hardware modesto) |
| Espaço em disco | ~200 MB |
| Periféricos | Teclado e mouse |
| Outras dependências | Nenhuma (sem plugins, bibliotecas ou instalação adicional) |

> Outras versões 4.x podem abrir o projeto, mas a Godot pode exibir avisos de incompatibilidade. Use a 4.7.2.

## 2. Como baixar o projeto

Com Git:

```bash
git clone <URL-DO-REPOSITORIO>
```

Ou, no GitHub, clique em **Code → Download ZIP** e extraia o arquivo.

## 3. Como executar

1. Baixe o Godot 4.7.2 e abra-o (não precisa instalar; é um executável único).
2. Na tela inicial, clique em **Importar**.
3. Selecione o arquivo **`project.godot`** (não a pasta), que fica na raiz do repositório, e clique em **Importar e Editar**.
4. Na primeira abertura a Godot reimporta os assets automaticamente (alguns segundos). É normal; a pasta `.godot/` de cache não é versionada.
5. Pressione **F5** (ou o botão ▶ no canto superior direito). A cena inicial é `scenes/menu.tscn`.

<!-- Se vocês exportarem um build: adicionar aqui "Alternativa sem editor: baixe o executável em Releases, extraia e execute CozinhaSobMedida.exe". -->

## 4. Como jogar

### Iniciar a partida
No menu principal, clique em **Jogar** (ou pressione Enter/Espaço com o botão focado). **Sair** fecha o jogo.

### Controles

| Tecla / ação | O que faz |
|---|---|
| `W` `A` `S` `D` | Move o chef |
| `Shift` (segurar) | Corre |
| `E` ou `Espaço` | Interage: anotar pedido, abrir/fechar a bancada, pegar ingredientes, entregar o prato |
| Teclado (números, `,` ou `.`) | Digita as quantidades na interface de cálculo |
| Mouse | Clica nos campos e no botão **Confirmar** da interface de cálculo |

### Passo a passo de um pedido
1. **Anotar o pedido:** vá até uma mesa com cliente (aparece `[E] Anotar`) e pressione `E`. A barra de paciência do cliente começa a esvaziar.
2. **Calcular:** vá até a **bancada** (aparece `[E] Calcular receita`) e pressione `E`. Abre a tela com a receita-base (para 2 pessoas) e o tamanho do grupo.
3. **Digitar as quantidades:** calcule o fator (pessoas do grupo ÷ 2) e multiplique cada ingrediente. Digite os 3 valores nos campos e clique em **Confirmar**. Aceita vírgula ou ponto.
   - *Exemplo:* Feijão Tropeiro, base 2 pessoas (200 g feijão, 100 g farinha, 120 g linguiça), grupo de 5 → fator 2,5 → **500 g, 250 g, 300 g**.
   - O jogo aceita erro de até **6%** em cada valor.
4. **Buscar ingredientes:** com o cálculo correto, vá até a **despensa** (`[E] Pegar ingredientes`) e pressione `E`.
5. **Entregar:** volte à mesa do pedido e pressione `E` (`[E] Entregar`).

### Objetivo, regras e pontuação
- Atender o máximo de clientes com o cálculo correto, acumulando **Score** e **Moedas** (mostrados no canto da tela).
- Só dá para atender **um pedido por vez**.
- Entrega correta: **+100 pontos** e **+15 moedas**.
- Cálculo errado: **−10 pontos** por tentativa (você pode tentar de novo; a tela indica qual ingrediente errou).
- Paciência esgotada: o cliente vai embora, **−50 pontos** (o Score nunca fica abaixo de 0) e o pedido em andamento é cancelado.
- A paciência de cada cliente fica verde → amarela (<60%) → vermelha (<30%).
- Novos clientes ocupam as mesas vazias automaticamente (3 mesas).

### Vitória, derrota e progressão
Nesta versão **não há condição de vitória, derrota nem fases**: o jogo é uma partida contínua (loop de gameplay validado). Para encerrar, feche a janela. O objetivo planejado no GDD (transformar o restaurante em 5 estrelas) ainda não está implementado.

## 5. Limitações conhecidas e o que ainda não foi implementado

- Sem tutorial dentro do jogo (por isso este guia).
- Sem condição de vitória/derrota, sem fim de partida e sem fases (o GDD prevê 4 fases).
- Sem Loja/upgrades: as moedas são acumuladas, mas ainda não podem ser gastas.
- Sem etapa de cozimento no fogão e sem inventário de ingredientes: coletar na despensa é instantâneo.
- Apenas 3 mesas e 9 receitas (culinárias mineira, nordestina, baiana e gaúcha, todas liberadas desde o início); a culinária Internacional não existe.
- Dificuldade fixa: tamanhos de grupo não progridem de inteiros para decimais; sorteio aleatório entre 3, 4, 5, 3,5, 4,5 e 6 pessoas.
- Sem menu de pausa, tecla Esc ou volta ao menu a partir do jogo.
- Sem opções de acessibilidade previstas no GDD (modo daltonismo, fonte ajustável).
- Sem salvamento de progresso.

## 6. Estrutura do repositório

```
/                      # raiz do repositório
  project.godot        # arquivo de projeto (importar na Godot)
  README.md            # este guia
  scenes/              # menu, restaurante, chef, cliente, mesa, interface_calculo
  scripts/             # lógica em GDScript
  assets/art/          # texturas pixel art
  assets/audio/        # música ambiente e efeitos sonoros
  docs/
    CozinhaSobMedida_N3_GDD.pdf
```
