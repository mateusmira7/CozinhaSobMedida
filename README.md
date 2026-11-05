# Cozinha sob Medida — Vertical Slice (N3)

Protótipo visual (Vertical Slice) construído sobre o Core Loop validado no N2,
usando Godot 4.6.2.

## O que foi adicionado nesta entrega em relação ao N2

- **Animações do Chef:** idle (respiração), caminhada (balanço de pernas/braços
  com base na velocidade), corrida (Shift), gesto de interação (mesa/bancada)
  e gesto de "ação principal" ao calcular a receita.
- **Animação do Cliente:** já existia no N2 (chegada com Tween + passos), mantida.
- **Áudio:** música ambiente em loop, som de passos, "ding" de acerto, som
  dissonante de erro, sizzle de fritura ao acertar, aplausos + moeda na entrega.
  Todos os arquivos em `assets/audio/` foram gerados proceduralmente (sem uso de
  bibliotecas de terceiros) — ver `N3_Documento_VerticalSlice.pdf` para detalhes.
- **Cenário:** elementos decorativos (janelas, quadros/azulejos, vasos, tapete)
  adicionados ao Salão para reforçar a identidade visual quente/aconchegante do GDD.
- **UI:** HUD com Score + Moedas, e um Menu Principal simples (`menu.tscn`) como
  tela inicial, com botão "Jogar" levando ao restaurante.
- **Visual pixel art (estilo Stardew Valley):** o piso, a parede de fundo, a
  bancada e as mesas agora usam texturas pixel art geradas em `assets/art/`
  (piso de madeira, azulejo de cozinha, parede com rodapé, janelas, quadros,
  vaso de planta e tapete), todas com filtro "Nearest" configurado no
  `project.godot` para manter o pixel nítido, sem borrão. O chef ganhou
  sapatos, lenço no pescoço e uma animação de piscar de olhos aleatória
  (`AnimationPlayer` em `chef.tscn`). Os clientes agora sorteiam roupa, pele e
  cabelo em uma paleta quente a cada chegada, para dar mais variedade visual
  à sala. Uma bancada com vapor animado (`GPUParticles2D`) dá vida à cozinha.
  Os geradores de textura ficam em `assets/art/` — se quiser recriá-las ou
  ajustar cores, o script Python usado está descrito no changelog da entrega.

## Como abrir o projeto

1. Abra o Godot Engine **4.6.2** (mesma versão do projeto).
2. `Importar` → selecione a pasta do projeto (arquivo `project.godot`).
3. Ao abrir pela primeira vez, o Godot vai reimportar todos os assets
   automaticamente (a pasta `.godot/` de cache foi removida de propósito para
   evitar conflitos — isso é normal e não indica erro).
4. Rode com F5. A cena inicial é `scenes/menu.tscn`.

## Como gerar o Build Executável (obrigatório para a entrega)

Isso precisa ser feito localmente no editor, pois exportar um binário depende
da plataforma/templates de export do Godot instalados na máquina de vocês:

1. `Project → Export...`
2. Adicione um preset (Windows Desktop ou Web, conforme a plataforma-alvo do GDD).
3. Se for a primeira vez, o Godot vai pedir para baixar os **Export Templates**
   (`Editor → Manage Export Templates`).
4. Clique em `Export Project`, escolha uma pasta de saída (ex.: `build/`) e gere
   o executável (ou o `index.html` se for exportar para Web).
5. Teste o build gerado antes de entregar — ele deve rodar sem precisar abrir o editor.

## Controles

- `WASD` — mover o chef
- `Shift` — correr
- `E` ou `Espaço` — interagir (anotar pedido / abrir bancada / entregar prato)

## Estrutura de assets

```
assets/
  audio/
    sfx/     -> passo, ding_correto, erro_dissonante, sizzle, aplausos, moeda
    music/   -> musica_ambiente (loop)
```

Consulte `N3_Documento_VerticalSlice.pdf` para a comparação completa com o GDD,
lista de assets, sons e animações exigida na entrega.
