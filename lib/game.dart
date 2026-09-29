import 'dart:math';

enum GameMode { local, robot }

enum SpecialKind { bonus, penalty, skip, extraTurn }

const finishPosition = 41;

class SpecialSpace {
  const SpecialSpace({
    required this.kind,
    required this.amount,
    required this.title,
    required this.story,
    required this.action,
    required this.icon,
  });

  final SpecialKind kind;
  final int amount;
  final String title;
  final String story;
  final String action;
  final String icon;
}

const specialSpaces = <int, SpecialSpace>{
  5: SpecialSpace(
    kind: SpecialKind.bonus,
    amount: 2,
    title: 'A ponte de folhas',
    story: 'O esquilo mostrou uma ponte de folhas!',
    action: 'Avance 2 casas!',
    icon: '🌿',
  ),
  11: SpecialSpace(
    kind: SpecialKind.penalty,
    amount: 2,
    title: 'Chuva na trilha',
    story: 'Choveu! A trilha ficou escorregadia.',
    action: 'Volte 2 casas!',
    icon: '🌧️',
  ),
  17: SpecialSpace(
    kind: SpecialKind.extraTurn,
    amount: 0,
    title: 'O passarinho agradeceu',
    story: 'Você salvou um passarinho! Ele trouxe o dado.',
    action: 'Jogue de novo!',
    icon: '🐦',
  ),
  21: SpecialSpace(
    kind: SpecialKind.bonus,
    amount: 3,
    title: 'Um atalho secreto',
    story: 'A coruja mostrou um atalho entre as árvores!',
    action: 'Avance 3 casas!',
    icon: '🦉',
  ),
  25: SpecialSpace(
    kind: SpecialKind.penalty,
    amount: 3,
    title: 'Ops, uma casca de banana!',
    story: 'Ops! Uma casca deixou a trilha escorregadia.',
    action: 'Volte 3 casas!',
    icon: '🍌',
  ),
  30: SpecialSpace(
    kind: SpecialKind.bonus,
    amount: 3,
    title: 'Amigos da floresta',
    story: 'Você ajudou o coelhinho. Ele mostrou um atalho!',
    action: 'Avance 3 casas!',
    icon: '🐰',
  ),
  34: SpecialSpace(
    kind: SpecialKind.skip,
    amount: 0,
    title: 'Hora de descansar',
    story: 'Você correu muito. Descanse na sombra da árvore.',
    action: 'Fique uma rodada sem jogar.',
    icon: '🌳',
  ),
  38: SpecialSpace(
    kind: SpecialKind.penalty,
    amount: 1,
    title: 'A mochila ficou para trás',
    story: 'A mochila ficou para trás. Vamos buscá-la!',
    action: 'Volte 1 casa!',
    icon: '🎒',
  ),
};

const animalNames = <String>[
  'Cachorro',
  'Coelho',
  'Raposa',
  'Gato',
  'Esquilo',
  'Urso',
  'Tartaruga',
  'Porco',
  'Ouriço',
  'Capivara',
];

const animalIds = <String>[
  'cachorro',
  'coelho',
  'raposa',
  'gato',
  'esquilo',
  'urso',
  'tartaruga',
  'porco',
  'ourico',
  'capivara',
];

class PlayerState {
  PlayerState(this.animalIndex);

  final int animalIndex;
  int position = 0;
  bool skipNextTurn = false;
}

class TurnResult {
  const TurnResult({
    required this.playerIndex,
    required this.dice,
    required this.dicePath,
    required this.effectPath,
    required this.special,
    required this.winnerIndex,
    required this.skippedPlayerIndex,
  });

  final int playerIndex;
  final int dice;
  final List<int> dicePath;
  final List<int> effectPath;
  final SpecialSpace? special;
  final int? winnerIndex;
  final int? skippedPlayerIndex;
}

class AdventureBoardGame {
  AdventureBoardGame({
    required this.mode,
    required int playerOneAnimal,
    required int playerTwoAnimal,
    Random? random,
  }) : players = [PlayerState(playerOneAnimal), PlayerState(playerTwoAnimal)],
       _random = random ?? Random();

  final GameMode mode;
  final List<PlayerState> players;
  final Random _random;
  int currentPlayerIndex = 0;
  int? winnerIndex;

  int roll() => _random.nextInt(6) + 1;

  TurnResult play(int dice) {
    if (winnerIndex != null) throw StateError('A partida terminou.');
    if (dice < 1 || dice > 6) throw ArgumentError.value(dice, 'dice');

    final playerIndex = currentPlayerIndex;
    final player = players[playerIndex];
    final diceEnd = min(finishPosition, player.position + dice);
    final dicePath = <int>[
      for (var cell = player.position + 1; cell <= diceEnd; cell++) cell,
    ];
    player.position = diceEnd;

    final special = specialSpaces[diceEnd];
    final effectPath = <int>[];
    if (diceEnd < finishPosition && special != null) {
      if (special.kind == SpecialKind.bonus ||
          special.kind == SpecialKind.penalty) {
        final direction = special.kind == SpecialKind.bonus ? 1 : -1;
        for (var i = 0; i < special.amount; i++) {
          player.position = (player.position + direction).clamp(
            0,
            finishPosition,
          );
          effectPath.add(player.position);
        }
      } else if (special.kind == SpecialKind.skip) {
        player.skipNextTurn = true;
      }
    }

    if (player.position == finishPosition) {
      winnerIndex = playerIndex;
    }

    int? skippedPlayerIndex;
    if (winnerIndex == null && special?.kind != SpecialKind.extraTurn) {
      currentPlayerIndex = 1 - playerIndex;
      if (players[currentPlayerIndex].skipNextTurn) {
        skippedPlayerIndex = currentPlayerIndex;
        players[currentPlayerIndex].skipNextTurn = false;
        currentPlayerIndex = playerIndex;
      }
    }

    return TurnResult(
      playerIndex: playerIndex,
      dice: dice,
      dicePath: dicePath,
      effectPath: effectPath,
      special: special,
      winnerIndex: winnerIndex,
      skippedPlayerIndex: skippedPlayerIndex,
    );
  }
}
