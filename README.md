# 🍳 Cozinha sob Medida

**Cozinha sob Medida** é um simulador educativo de restaurante em 2D (visão de cima), desenvolvido na **Godot Engine 4.7.2** pelo estúdio **High Pitch Studios**, formado por Elisa Maria Gomes, Mateus Corrêa de Mira e Otávio Rodolfo Roecker, estudantes de Engenharia de Software — PAC III.

Você assume o papel de um chef responsável por atender clientes em um restaurante. Cada grupo solicita um prato com base em uma receita originalmente dimensionada para 2 pessoas. Entretanto, o tamanho dos grupos varia entre 3, 4, 5, 3,5, 4,5 e 6 pessoas.

Para preparar os pratos corretamente, o jogador precisa calcular as quantidades proporcionais de cada ingrediente. Dessa forma, **proporção, frações e números decimais fazem parte das mecânicas principais do jogo**, tornando a matemática parte da experiência de gameplay, e não uma prova.

📄 **Documentação do projeto:**
[**Acessar o GDD — Game Design Document (PDF)**](docs/Cozinha%20sob%20Medida%20%E2%80%94%20Game%20Design%20Document.pdf)

---

## 1. Requisitos do sistema

| Item | Requisito |
|---|---|
| Engine | **Godot Engine 4.7.2** (versão padrão, não .NET/Mono) |
| Download da Engine | [Godot 4.7.2 — Arquivo de versões](https://godotengine.org/download/archive/) |
| Sistema operacional | Windows 10/11 ou Linux (64 bits) |
| Renderizador | GL Compatibility |
| Espaço em disco | Aproximadamente 200 MB |
| Periféricos | Teclado e mouse |
| Dependências adicionais | Nenhuma. Não são necessários plugins, bibliotecas ou instalações adicionais. |

> **Importante:** recomenda-se utilizar exatamente a Godot 4.7.2. Outras versões da série 4.x podem abrir o projeto, mas podem apresentar avisos de compatibilidade.

## 2. Como baixar o projeto

Existem duas maneiras de obter o código-fonte.

### Opção 1 — Clonar utilizando Git

Abra o terminal e execute:

```bash
git clone <URL-DO-REPOSITORIO>
```

Substitua `<URL-DO-REPOSITORIO>` pelo endereço HTTPS deste repositório.

### Opção 2 — Baixar pelo GitHub

1. Acesse o repositório no GitHub.
2. Clique no botão **Code**.
3. Selecione **Download ZIP**.
4. Extraia o arquivo baixado em uma pasta de sua preferência.

## 3. Como executar o projeto

1. Baixe a **Godot Engine 4.7.2**, na versão padrão (não .NET/Mono).
2. Abra o executável da Godot. Não é necessário realizar uma instalação tradicional.
3. Na tela inicial, selecione a opção **Importar**.
4. Localize e selecione o arquivo `project.godot`, presente na raiz do repositório.
5. Clique em **Importar e Editar**.
6. Aguarde a importação inicial dos recursos do projeto. Esse processo pode levar alguns segundos.
7. Com o projeto aberto, pressione **F5** ou clique no botão de execução (▶), localizado no canto superior direito.

A cena inicial do jogo é `scenes/menu.tscn`.

> **Observação:** a pasta `.godot/` contém arquivos de cache gerados automaticamente pela Engine e não precisa estar presente no repositório. A Godot recria esses arquivos durante a primeira abertura do projeto.

## 4. Como jogar

### 4.1. Iniciando uma partida

Ao abrir o jogo, será apresentado o menu principal.

- **Jogar:** inicia a partida e carrega o restaurante.
- **Sair:** encerra a aplicação.

### 4.2. Controles

| Tecla / Ação | Funcionalidade |
|---|---|
| `W` `A` `S` `D` | Movimentam o chef pelo cenário. |
| `Shift` (segurar) | Faz o chef correr. |
| `E` ou `Espaço` | Executa interações com os elementos do restaurante. |
| Teclas numéricas | Permitem inserir as quantidades dos ingredientes. |
| `,` ou `.` | Permitem inserir valores decimais. |
| Mouse | Permite selecionar os campos e clicar no botão **Confirmar** da interface de cálculo. |

### 4.3. Etapas de atendimento de um pedido

O atendimento de cada cliente segue cinco etapas:

**1. Anotar o pedido**

- Aproxime-se de uma mesa ocupada por um cliente.
- Quando aparecer a indicação `[E] Anotar`, pressione `E`.
- O pedido será registrado e a barra de paciência do cliente começará a diminuir.

**2. Calcular a receita**

- Dirija-se à bancada de preparo.
- Quando aparecer a indicação `[E] Calcular receita`, pressione `E`.
- Uma interface apresentará a receita-base, dimensionada para 2 pessoas, e a quantidade de pessoas do grupo.

**3. Informar as quantidades dos ingredientes**

- Calcule o fator de proporcionalidade dividindo a quantidade de pessoas do grupo por 2.
- Multiplique a quantidade original de cada ingrediente pelo fator encontrado.
- Digite os três resultados nos campos correspondentes.
- Clique em **Confirmar** para validar os valores.

O jogo aceita uma margem de erro de até **6% em cada ingrediente** e permite utilizar vírgula ou ponto como separador decimal.

**Exemplo de cálculo:**

Receita-base de Feijão Tropeiro para 2 pessoas:

| Ingrediente | Quantidade original |
|---|---:|
| Feijão | 200 g |
| Farinha | 100 g |
| Linguiça | 120 g |

Pedido para 5 pessoas:

- Fator de proporcionalidade: 5 ÷ 2 = 2,5.
- Feijão: 200 × 2,5 = **500 g**.
- Farinha: 100 × 2,5 = **250 g**.
- Linguiça: 120 × 2,5 = **300 g**.

**4. Buscar os ingredientes**

- Após acertar o cálculo, dirija-se à despensa.
- Quando aparecer a indicação `[E] Pegar ingredientes`, pressione `E`.
- Os ingredientes necessários serão coletados automaticamente.

**5. Entregar o prato**

- Retorne à mesa do cliente que realizou o pedido.
- Quando aparecer a indicação `[E] Entregar`, pressione `E`.
- O atendimento será concluído e a pontuação correspondente será adicionada.

### 4.4. Objetivos, regras e pontuação

O objetivo principal é atender o maior número possível de clientes, realizando corretamente os cálculos e entregando os pedidos dentro do tempo de paciência disponível.

| Situação | Consequência |
|---|---|
| Entrega correta | +100 pontos e +15 moedas |
| Cálculo incorreto | -10 pontos por tentativa |
| Paciência esgotada | -50 pontos e cancelamento do pedido |

**Regras adicionais:**

- Apenas um pedido pode ser atendido por vez.
- É possível tentar novamente quando um cálculo estiver incorreto.
- A interface indica qual ingrediente apresenta erro.
- A pontuação (Score) nunca fica abaixo de zero.
- A barra de paciência dos clientes muda de cor conforme o tempo restante:
  - Verde: paciência normal.
  - Amarela: menos de 60% de paciência.
  - Vermelha: menos de 30% de paciência.
- Novos clientes ocupam automaticamente as mesas disponíveis.
- O restaurante possui três mesas para atendimento simultâneo.

### 4.5. Vitória, derrota e progressão

Na versão atual, o jogo funciona em um ciclo contínuo de gameplay, sem condições de vitória ou derrota e sem progressão por fases.

O jogador pode continuar atendendo clientes enquanto desejar. Para encerrar a partida, basta fechar a janela do jogo.

O objetivo de longo prazo apresentado no GDD, que consiste em transformar o restaurante em um estabelecimento de 5 estrelas, ainda não está implementado nesta versão.

---

## 5. Limitações conhecidas e funcionalidades não implementadas

A versão entregue possui as principais mecânicas de atendimento e cálculo proporcional implementadas. Entretanto, algumas funcionalidades previstas no planejamento inicial ainda não fazem parte da versão atual.

| Funcionalidade | Situação atual |
|---|---|
| Tutorial integrado ao jogo | Não implementado. As instruções estão disponíveis neste README. |
| Condições de vitória e derrota | Não implementadas. |
| Progressão por fases | Não implementada. O GDD prevê quatro fases. |
| Loja e sistema de melhorias | Não implementados. As moedas são acumuladas, mas não podem ser utilizadas. |
| Etapa de cozimento no fogão | Não implementada. |
| Inventário de ingredientes | Não implementado. A coleta na despensa é instantânea. |
| Quantidade de mesas | Limitada a três mesas. |
| Receitas disponíveis | Nove receitas. |
| Culinárias disponíveis | Mineira, nordestina, baiana e gaúcha. |
| Culinária internacional | Não implementada. |
| Progressão de dificuldade | Não implementada. Os tamanhos dos grupos são sorteados aleatoriamente entre 3, 4, 5, 3,5, 4,5 e 6 pessoas. |
| Menu de pausa | Não implementado. |
| Retorno ao menu principal durante a partida | Não implementado. |
| Opções de acessibilidade | Modo para daltonismo e ajuste de fonte ainda não implementados. |
| Salvamento de progresso | Não implementado. |

---

## 6. Estrutura do repositório

A organização dos arquivos e diretórios do projeto está distribuída da seguinte maneira:

```text
/
├── project.godot
├── README.md
│
├── scenes/
│   ├── menu.tscn
│   ├── restaurante.tscn
│   ├── chef.tscn
│   ├── cliente.tscn
│   ├── mesa.tscn
│   └── interface_calculo.tscn
│
├── scripts/
│   └── Arquivos de lógica e comportamento em GDScript
│
├── assets/
│   ├── art/
│   │   └── Texturas e elementos visuais em Pixel Art
│   │
│   └── audio/
│       └── Músicas e efeitos sonoros
│
└── docs/
    └── Cozinha sob Medida — Game Design Document.pdf
```

> A estrutura acima apresenta a organização geral do projeto. A quantidade de arquivos e subdiretórios pode variar conforme a versão disponibilizada no repositório.

---

## 7. Tecnologias utilizadas

- **Godot Engine 4.7.2:** desenvolvimento e execução do jogo.
- **GDScript:** programação das mecânicas e comportamentos.
- **Pixel Art:** estilo visual dos personagens e cenários.
- **Git e GitHub:** controle de versão e disponibilização do código-fonte.

---

## 8. Equipe de desenvolvimento

Projeto desenvolvido pelo estúdio **High Pitch Studios**, como parte das atividades acadêmicas do curso de Engenharia de Software — PAC III.

| Integrante |
|---|
| Elisa Maria Gomes |
| Mateus Corrêa de Mira |
| Otávio Rodolfo Roecker |

---

**High Pitch Studios — Cozinha sob Medida**
