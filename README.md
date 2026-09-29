# Tabuleiro infantil: Aventura

Jogo de tabuleiro para Android feito em Flutter. Duas pessoas jogam no mesmo aparelho ou uma pessoa joga contra o robô. Cada participante escolhe um dos dez animais animados e recebe uma cor própria.

## Rodar e testar

```sh
flutter pub get
flutter run
flutter test
flutter analyze
flutter build apk --debug
```

O tabuleiro cabe inteiro na tela do telefone, sem rolagem. Antes de jogar, é possível escolher por miniatura entre os quatro cenários de `assets/mapas/`. A imagem escolhida aparece atrás da estrada sinuosa, dividida em 40 trechos coloridos numerados. A “CHEGADA” fica fora da estrada, em uma nuvem acima da casa 40, assim como a largada fica separada das casas. O dado mostra uma animação central, para no resultado e permanece visível por 1,5 segundo. O animal passa por cada casa individualmente. As casas 5, 21 e 30 avançam; 11, 25 e 38 fazem voltar; 17 concede outra jogada; 34 tira a próxima vez. Cada casa especial conta uma pequena história em uma cena animada que fica na tela por quatro segundos. Uma barra mostra o tempo restante; depois a cena fecha sozinha e o efeito acontece. Parar na casa 40 não encerra a partida: vence quem passa dela e alcança a “CHEGADA”.

## Remoção de propagandas

A tela inicial consulta na Play Store o produto permanente `remove_ads` e exibe o preço localizado no botão. Para ativar a compra, crie um produto único não consumível com esse identificador no app `com.vmendesneto.tabuleiro_infantil`, defina o preço e publique-o em uma faixa de testes da Play Store.

## Arte dos animais

Os dez PNGs originais estão em `art/source/`. Os GIFs de caminhada e as miniaturas estáticas usadas pela tela de escolha estão em `assets/animals/`. Para gerar esses arquivos novamente, instale Pillow e NumPy (`python3 -m pip install Pillow numpy`) e execute:

```sh
python3 tools/make_gifs.py
```

Cada GIF tem 12 quadros em um ciclo de 0,96 segundo, fundo transparente e patas que se movem alternadamente enquanto o corpo permanece no lugar. No tabuleiro, uma estrada sinuosa contínua passa pelas 40 casas; os marcadores seguem suas curvas ao avançar ou voltar.

Os PNGs foram criados com a ferramenta integrada de geração de imagens. Prompt base: personagem individual de jogo infantil, animal de corpo inteiro voltado à direita em pose de caminhada, estilo de ilustração colorida de livro infantil, olhos expressivos, silhueta clara, fundo genuinamente transparente, sem cenário, texto ou outros personagens. Sujeitos: cachorro dourado com lenço vermelho; coelho branco; raposa laranja; gato tigrado cinza com coleira azul; esquilo vermelho; filhote de urso marrom; tartaruga verde; porquinho rosa; ouriço marrom; capivara caramelo.

O ícone Android e `art/play_store_icon.png` podem ser refeitos com `python3 tools/make_launcher_icon.py`.

## Publicação Android

O identificador Android é `com.vmendesneto.tabuleiro_infantil`. Ele deve ser usado ao criar o aplicativo na Play Store.

Para assinar uma versão de distribuição, crie seu próprio keystore e copie `android/key.properties.example` para `android/key.properties`, preenchendo os quatro campos. O arquivo de propriedades e o keystore estão no `.gitignore`.

```sh
flutter build appbundle --release
```

O projeto não contém credenciais de assinatura nem foi enviado à Play Store. A publicação requer uma conta Play Console, ficha do aplicativo e o arquivo AAB assinado.
