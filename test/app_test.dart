import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabuleiro_infantil_aventura/game.dart';
import 'package:tabuleiro_infantil_aventura/game_audio.dart';
import 'package:tabuleiro_infantil_aventura/main.dart';
import 'package:tabuleiro_infantil_aventura/remove_ads_purchase.dart';

class _FixedDice implements Random {
  @override
  int nextInt(int max) => 4;

  @override
  bool nextBool() => true;

  @override
  double nextDouble() => .5;
}

class _FakeRemoveAdsPurchase extends RemoveAdsPurchaseController {
  @override
  final String price = 'R\$ 4,99';
  bool purchased = false;

  @override
  bool get canBuy => !purchased;

  @override
  String? get errorMessage => null;

  @override
  bool get isLoading => false;

  @override
  bool get isPurchased => purchased;

  @override
  Future<void> buy() async {
    purchased = true;
    notifyListeners();
  }

  @override
  Future<void> initialize() async {}
}

class _FakeGameAudio extends GameAudioController {
  bool _enabled = true;
  int dicePlays = 0;
  int stepPlays = 0;
  int victoryPlays = 0;
  int bonusPlays = 0;
  int setbackPlays = 0;

  @override
  bool get enabled => _enabled;

  @override
  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }

  @override
  Future<void> playDice() async {
    if (_enabled) dicePlays++;
  }

  @override
  Future<void> playStep() async {
    if (_enabled) stepPlays++;
  }

  @override
  Future<void> playVictory() async {
    if (_enabled) victoryPlays++;
  }

  @override
  Future<void> playBonus() async {
    if (_enabled) bonusPlays++;
  }

  @override
  Future<void> playSetback() async {
    if (_enabled) setbackPlays++;
  }
}

void main() {
  test('uses the Play Console remove-ads product ID', () {
    expect(removeAdsProductId, 'remover_ads');
  });

  test('special houses use positive and setback sound categories', () async {
    final audio = _FakeGameAudio();
    addTearDown(audio.dispose);
    await audio.playSpecial(SpecialKind.bonus);
    await audio.playSpecial(SpecialKind.extraTurn);
    await audio.playSpecial(SpecialKind.penalty);
    await audio.playSpecial(SpecialKind.skip);
    expect(audio.bonusPlays, 2);
    expect(audio.setbackPlays, 2);
  });

  test('animated animal faces the direction of each board section', () {
    for (final position in <double>[0, 1, 5, 13, 19, 27, 33, 41]) {
      expect(
        animalFacesRightAtPosition(position),
        isTrue,
        reason: 'The animal should face right at position $position.',
      );
    }
    for (final position in <double>[6, 12, 20, 26, 34, 40]) {
      expect(
        animalFacesRightAtPosition(position),
        isFalse,
        reason: 'The animal should face left at position $position.',
      );
    }
  });

  test('animal walks inside its marker between houses', () {
    expect(animalWalkLiftAtPosition(1, 40), closeTo(0, .0001));
    expect(animalWalkLiftAtPosition(1.5, 40), closeTo(-4, .0001));
    expect(animalWalkSwayAtPosition(1), closeTo(0, .0001));
    expect(animalWalkSwayAtPosition(1.25), closeTo(.055, .0001));
  });

  testWidgets('forest background tolerates a zero-size startup frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 0,
            height: 0,
            child: ForestBackground(child: SizedBox.shrink()),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(CustomPaint)), Size.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sound button in the game header toggles game audio', (
    tester,
  ) async {
    final audio = _FakeGameAudio();
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(
          mode: GameMode.local,
          animals: const [0, 1],
          audio: audio,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('sound-toggle')), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sound-toggle')));
    await tester.pump();
    expect(audio.enabled, isFalse);
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
  });

  testWidgets(
    'players can choose animals and open the selected 40-house board',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final purchase = _FakeRemoveAdsPurchase();
      addTearDown(purchase.dispose);
      await tester.pumpWidget(
        TabuleiroInfantilAventuraApp(removeAdsPurchase: purchase),
      );
      expect(find.text('Remover propagandas'), findsOneWidget);
      expect(find.text('Tirar propagandas por R\$ 4,99'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('remove-ads-banner'))).height,
        lessThan(100),
      );
      final setupScrollable = find.descendant(
        of: find.byKey(const ValueKey('setup-scroll')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      );
      expect(setupScrollable, findsOneWidget);
      expect(
        tester.state<ScrollableState>(setupScrollable).position.maxScrollExtent,
        0,
      );
      await tester.tap(find.byKey(const ValueKey('remove-ads-button')));
      await tester.pump();
      expect(find.byKey(const ValueKey('remove-ads-banner')), findsNothing);
      expect(find.text('Escolha os animais'), findsOneWidget);
      final animalList = tester.widget<ListView>(
        find.byKey(const ValueKey('animal-list')),
      );
      expect(animalList.scrollDirection, Axis.horizontal);
      expect(find.byKey(const ValueKey('animal-scroll-hint')), findsOneWidget);
      final scrollHintIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const ValueKey('animal-scroll-hint')),
          matching: find.byType(Icon),
        ),
      );
      expect(scrollHintIcon.icon, Icons.arrow_forward_rounded);
      expect(find.byType(GridView), findsNothing);

      const selectionGreen = Color(0xFF168A3B);
      final modeChoice = tester.widget<SegmentedButton<GameMode>>(
        find.byKey(const ValueKey('game-mode-choice')),
      );
      expect(
        modeChoice.style!.side!.resolve({WidgetState.selected})!.color,
        selectionGreen,
      );
      final animalCard = tester.widget<Container>(
        find.byKey(const ValueKey('animal-card-0')),
      );
      expect(
        ((animalCard.decoration! as BoxDecoration).border! as Border).top.color,
        selectionGreen,
      );
      final backdropCard = tester.widget<Container>(
        find.byKey(const ValueKey('backdrop-card-map1')),
      );
      expect(
        ((backdropCard.decoration! as BoxDecoration).border! as Border)
            .top
            .color,
        selectionGreen,
      );

      expect(animalList.controller!.offset, 0);
      await tester.tap(find.byKey(const ValueKey('animal-scroll-hint')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(animalList.controller!.offset, greaterThan(0));

      await tester.drag(
        find.byKey(const ValueKey('animal-list')),
        const Offset(-500, 0),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('animal-option-9')), findsOneWidget);

      BoxBorder playerBorder(int index) {
        final card = tester.widget<Container>(
          find.byKey(ValueKey('player-choice-$index')),
        );
        return (card.decoration! as BoxDecoration).border!;
      }

      expect((playerBorder(0) as Border).top.color, selectionGreen);
      expect((playerBorder(0) as Border).top.width, 4);
      expect((playerBorder(1) as Border).top.color, const Color(0xFFCAD8CB));

      await tester.tap(find.byKey(const ValueKey('player-choice-1')));
      await tester.pump();
      expect((playerBorder(0) as Border).top.color, const Color(0xFFCAD8CB));
      expect((playerBorder(1) as Border).top.color, selectionGreen);
      expect((playerBorder(1) as Border).top.width, 4);

      for (final backdrop in BoardBackdrop.values) {
        final option = find.byKey(ValueKey('backdrop-${backdrop.name}'));
        expect(option, findsOneWidget);
        final thumbnail = tester.getSize(option);
        expect(thumbnail.height, closeTo(thumbnail.width, 1));
        final image = tester.widget<Image>(
          find.descendant(of: option, matching: find.byType(Image)),
        );
        expect((image.image as AssetImage).assetName, backdrop.assetPath);
      }
      expect(find.text('Floresta'), findsNothing);
      expect(find.text('Lago'), findsNothing);
      expect(find.text('Pôr do sol'), findsNothing);
      expect(find.text('Estrelas'), findsNothing);

      expect(find.text('20 casas'), findsOneWidget);
      expect(find.text('30 casas'), findsOneWidget);
      expect(find.text('40 casas'), findsOneWidget);
      expect(find.text('50 casas'), findsOneWidget);

      final mapOption = find.byKey(const ValueKey('backdrop-map3'));
      await tester.ensureVisible(mapOption);
      await tester.tap(mapOption);

      await tester.ensureVisible(find.text('COMEÇAR A JOGAR'));
      await tester.tap(find.text('COMEÇAR A JOGAR'));
      await tester.pumpAndSettle();

      expect(find.text('JOGAR DADO'), findsOneWidget);
      final boardMap = tester.widget<Image>(
        find.byKey(const ValueKey('selected-board-map')),
      );
      expect(
        (boardMap.image as AssetImage).assetName,
        BoardBackdrop.map3.assetPath,
      );
      expect(find.text('40'), findsOneWidget);
      expect(find.text('CHEGADA'), findsOneWidget);
      final finishCloud = find.byKey(const ValueKey('finish-cloud'));
      expect(finishCloud, findsOneWidget);
      expect(
        tester.getBottomLeft(finishCloud).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('house-40'))).dy),
      );
      expect(find.text('LARGADA'), findsOneWidget);
      expect(find.text('Vez do Jogador 1'), findsOneWidget);
      final statusCard = tester.widget<Container>(
        find.byKey(const ValueKey('status-card')),
      );
      expect(statusCard.alignment, Alignment.center);
      expect((statusCard.decoration! as BoxDecoration).color, Colors.white);
      expect(find.textContaining('CASA 40'), findsNothing);
      expect(find.textContaining('Casa '), findsNothing);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byKey(const ValueKey('house-1')), findsOneWidget);
      for (final number in BoardBackdrop.map3.rules.specialSpaces.keys) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('house-$number')),
            matching: find.text('$number'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(ValueKey('house-$number')),
            matching: find.text(
              BoardBackdrop.map3.rules.specialSpaces[number]!.icon,
            ),
          ),
          findsOneWidget,
        );
      }
      expect(
        tester.getBottomLeft(find.byKey(const ValueKey('house-1'))).dy,
        lessThan(tester.getTopLeft(find.text('JOGAR DADO')).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the full board fits a small phone without scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final purchase = _FakeRemoveAdsPurchase();
    addTearDown(purchase.dispose);
    await tester.pumpWidget(
      TabuleiroInfantilAventuraApp(removeAdsPurchase: purchase),
    );
    await tester.ensureVisible(find.text('COMEÇAR A JOGAR'));
    await tester.tap(find.text('COMEÇAR A JOGAR'));
    await tester.pumpAndSettle();

    final board = tester.getRect(find.byKey(const ValueKey('game-board')));
    expect(board.top, greaterThanOrEqualTo(0));
    expect(board.bottom, lessThanOrEqualTo(640));
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byKey(const ValueKey('house-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('house-20')), findsOneWidget);
    expect(find.byKey(const ValueKey('house-21')), findsNothing);
    final finishCloud = find.byKey(const ValueKey('finish-cloud'));
    expect(finishCloud, findsOneWidget);
    expect(tester.getTopLeft(finishCloud).dy, greaterThan(board.top + 3));
    final startCard = tester.getRect(find.byKey(const ValueKey('start-card')));
    final statusCard = tester.getRect(
      find.byKey(const ValueKey('status-card')),
    );
    expect(statusCard.left, greaterThan(startCard.right));
    expect(statusCard.bottom, lessThanOrEqualTo(board.bottom));
    final label = tester.getRect(find.text('LARGADA'));
    expect(label.left, greaterThan(startCard.left + 8));
    expect(board.bottom - startCard.bottom, greaterThan(8));
    for (var player = 0; player < 2; player++) {
      final marker = find.byKey(ValueKey('token-marker-$player'));
      final markerRect = tester.getRect(marker);
      expect(markerRect.left, greaterThan(label.right + 5));
      expect(markerRect.right, lessThan(startCard.right - 5));
      final animalImage = tester.widget<Image>(
        find.descendant(of: marker, matching: find.byType(Image)),
      );
      expect(animalImage.image, isA<AssetImage>());
      expect((animalImage.image as AssetImage).assetName, endsWith('.gif'));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('all four maps render their own route and special houses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final backdrop in BoardBackdrop.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            key: ValueKey(backdrop),
            mode: GameMode.local,
            animals: const [0, 1],
            backdrop: backdrop,
          ),
        ),
      );
      await tester.pump();

      final houseCount = backdrop.rules.houseCount;
      expect(
        find.byKey(ValueKey('house-$houseCount')),
        findsOneWidget,
        reason: '${backdrop.name} deve terminar na casa $houseCount.',
      );
      expect(find.byKey(ValueKey('house-${houseCount + 1}')), findsNothing);
      for (final entry in backdrop.rules.specialSpaces.entries) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('house-${entry.key}')),
            matching: find.text(entry.value.icon),
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('special house tells its story before moving the animal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final audio = _FakeGameAudio();
    addTearDown(audio.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(
          mode: GameMode.local,
          animals: const [0, 1],
          random: _FixedDice(),
          audio: audio,
          backdrop: BoardBackdrop.map3,
        ),
      ),
    );
    await tester.tap(find.text('JOGAR DADO'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1500));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 410));
    }
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('A ponte de folhas'), findsOneWidget);
    expect(find.text('O esquilo mostrou uma ponte de folhas!'), findsOneWidget);
    expect(find.text('Avance 2 casas!'), findsOneWidget);
    expect(find.text('CONTINUAR A AVENTURA'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('A ponte de folhas'), findsOneWidget);
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, greaterThan(.4));
    expect(progress.value, lessThan(1));

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('A ponte de folhas'), findsNothing);
    for (var i = 0; i < 2; i++) {
      await tester.pump(const Duration(milliseconds: 410));
    }
    expect(find.text('Vez do Jogador 2'), findsOneWidget);
    expect(audio.dicePlays, 1);
    expect(audio.stepPlays, 7);
    expect(audio.victoryPlays, 0);
    expect(audio.bonusPlays, 1);
    expect(audio.setbackPlays, 0);
    expect(tester.takeException(), isNull);
  });
}
