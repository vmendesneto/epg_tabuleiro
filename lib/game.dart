import 'dart:math';

enum GameMode { local, robot }

enum SpecialKind { bonus, penalty, skip, extraTurn }

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

class BoardRules {
  const BoardRules({required this.houseCount, required this.specialSpaces});

  final int houseCount;
  final Map<int, SpecialSpace> specialSpaces;

  int get finishPosition => houseCount + 1;
}

const _leafBridge = SpecialSpace(
  kind: SpecialKind.bonus,
  amount: 2,
  title: 'A ponte de folhas',
  story: 'O esquilo mostrou uma ponte de folhas!',
  action: 'Avance 2 casas!',
  icon: '🌿',
);
const _rainyTrail = SpecialSpace(
  kind: SpecialKind.penalty,
  amount: 2,
  title: 'Chuva na trilha',
  story: 'Choveu! A trilha ficou escorregadia.',
  action: 'Volte 2 casas!',
  icon: '🌧️',
);
const _gratefulBird = SpecialSpace(
  kind: SpecialKind.extraTurn,
  amount: 0,
  title: 'O passarinho agradeceu',
  story: 'Você salvou um passarinho! Ele trouxe o dado.',
  action: 'Jogue de novo!',
  icon: '🐦',
);
const _secretShortcut = SpecialSpace(
  kind: SpecialKind.bonus,
  amount: 3,
  title: 'Um atalho secreto',
  story: 'A coruja mostrou um atalho entre as árvores!',
  action: 'Avance 3 casas!',
  icon: '🦉',
);
const _bananaPeel = SpecialSpace(
  kind: SpecialKind.penalty,
  amount: 3,
  title: 'Ops, uma casca de banana!',
  story: 'Ops! Uma casca deixou a trilha escorregadia.',
  action: 'Volte 3 casas!',
  icon: '🍌',
);
const _forestFriends = SpecialSpace(
  kind: SpecialKind.bonus,
  amount: 3,
  title: 'Amigos da floresta',
  story: 'Você ajudou o coelhinho. Ele mostrou um atalho!',
  action: 'Avance 3 casas!',
  icon: '🐰',
);
const _restingTree = SpecialSpace(
  kind: SpecialKind.skip,
  amount: 0,
  title: 'Hora de descansar',
  story: 'Você correu muito. Descanse na sombra da árvore.',
  action: 'Fique uma rodada sem jogar.',
  icon: '🌳',
);
const _forgottenBackpack = SpecialSpace(
  kind: SpecialKind.penalty,
  amount: 1,
  title: 'A mochila ficou para trás',
  story: 'A mochila ficou para trás. Vamos buscá-la!',
  action: 'Volte 1 casa!',
  icon: '🎒',
);
const _butterflyRide = SpecialSpace(
  kind: SpecialKind.bonus,
  amount: 1,
  title: 'Dança das borboletas',
  story: 'As borboletas coloridas mostraram o caminho mais curto!',
  action: 'Avance 1 casa!',
  icon: '🦋',
);
const _mudPuddle = SpecialSpace(
  kind: SpecialKind.penalty,
  amount: 1,
  title: 'Poça de lama',
  story: 'Ploft! Você entrou numa poça e precisou limpar as patas.',
  action: 'Volte 1 casa!',
  icon: '💦',
);
const _happyPicnic = SpecialSpace(
  kind: SpecialKind.extraTurn,
  amount: 0,
  title: 'Piquenique dos amigos',
  story: 'Seus amigos dividiram um lanche e deram energia para continuar!',
  action: 'Jogue de novo!',
  icon: '🧺',
);
const _rainbowPath = SpecialSpace(
  kind: SpecialKind.bonus,
  amount: 2,
  title: 'Caminho do arco-íris',
  story: 'Um arco-íris iluminou uma passagem mágica!',
  action: 'Avance 2 casas!',
  icon: '🌈',
);

const board20Rules = BoardRules(
  houseCount: 20,
  specialSpaces: {
    3: _butterflyRide,
    7: _mudPuddle,
    12: _gratefulBird,
    17: _restingTree,
  },
);

const board30Rules = BoardRules(
  houseCount: 30,
  specialSpaces: {
    4: _leafBridge,
    9: _rainyTrail,
    14: _happyPicnic,
    19: _secretShortcut,
    24: _restingTree,
    28: _forgottenBackpack,
  },
);

const board40Rules = BoardRules(
  houseCount: 40,
  specialSpaces: {
    5: _leafBridge,
    11: _rainyTrail,
    17: _gratefulBird,
    21: _secretShortcut,
    25: _bananaPeel,
    30: _forestFriends,
    34: _restingTree,
    38: _forgottenBackpack,
  },
);

const board50Rules = BoardRules(
  houseCount: 50,
  specialSpaces: {
    6: _rainbowPath,
    10: _rainyTrail,
    15: _gratefulBird,
    20: _secretShortcut,
    26: _bananaPeel,
    31: _restingTree,
    36: _forestFriends,
    41: _forgottenBackpack,
    45: _butterflyRide,
    48: _mudPuddle,
  },
);

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
    this.rules = board40Rules,
    Random? random,
  }) : players = [PlayerState(playerOneAnimal), PlayerState(playerTwoAnimal)],
       _random = random ?? Random();

  final GameMode mode;
  final BoardRules rules;
  final List<PlayerState> players;
  final Random _random;
  int currentPlayerIndex = 0;
  int? winnerIndex;

  int get finishPosition => rules.finishPosition;

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

    final special = rules.specialSpaces[diceEnd];
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
