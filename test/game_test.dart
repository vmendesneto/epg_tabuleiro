import 'package:flutter_test/flutter_test.dart';
import 'package:tabuleiro_infantil_aventura/game.dart';

void main() {
  AdventureBoardGame newGame() => AdventureBoardGame(
    mode: GameMode.local,
    playerOneAnimal: 0,
    playerTwoAnimal: 1,
  );

  test('dice movement visits each numbered house and alternates players', () {
    final game = newGame();
    final first = game.play(4);
    expect(first.dicePath, [1, 2, 3, 4]);
    expect(game.players[0].position, 4);
    expect(game.currentPlayerIndex, 1);

    final second = game.play(2);
    expect(second.dicePath, [1, 2]);
    expect(game.players[1].position, 2);
    expect(game.currentPlayerIndex, 0);
  });

  test('bonus and penalty move one house at a time', () {
    final game = newGame();
    final bonus = game.play(5);
    expect(bonus.dicePath, [1, 2, 3, 4, 5]);
    expect(bonus.effectPath, [6, 7]);
    expect(game.players[0].position, 7);

    game.players[1].position = 9;
    final penalty = game.play(2);
    expect(penalty.dicePath, [10, 11]);
    expect(penalty.effectPath, [10, 9]);
    expect(game.players[1].position, 9);
  });

  test('extra turn and skipped turn follow the special spaces', () {
    final game = newGame();
    game.players[0].position = 16;
    final extra = game.play(1);
    expect(extra.special?.kind, SpecialKind.extraTurn);
    expect(game.currentPlayerIndex, 0);

    game.players[0].position = 33;
    final skip = game.play(1);
    expect(skip.special?.kind, SpecialKind.skip);
    expect(game.currentPlayerIndex, 1);
    expect(game.players[0].skipNextTurn, isTrue);

    final next = game.play(1);
    expect(next.skippedPlayerIndex, 0);
    expect(game.currentPlayerIndex, 1);
    expect(game.players[0].skipNextTurn, isFalse);
  });

  test('landing on house 40 does not win; the next step reaches finish', () {
    final game = newGame();
    game.players[0].position = 39;
    final atForty = game.play(1);
    expect(atForty.dicePath, [40]);
    expect(atForty.winnerIndex, isNull);
    expect(game.players[0].position, 40);

    game.players[1].position = 40;
    final finish = game.play(1);
    expect(finish.dicePath, [41]);
    expect(finish.winnerIndex, 1);
    expect(game.players[1].position, finishPosition);
    expect(() => game.play(1), throwsStateError);
  });

  test('passing house 40 during a roll wins at finish', () {
    final game = newGame();
    game.players[0].position = 38;
    final result = game.play(5);
    expect(result.dicePath, [39, 40, finishPosition]);
    expect(result.winnerIndex, 0);
    expect(game.players[0].position, finishPosition);
  });
}
