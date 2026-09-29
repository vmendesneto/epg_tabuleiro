import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'remove_ads_purchase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TabuleiroInfantilAventuraApp());
}

const playerColors = <Color>[Color(0xFF1685E9), Color(0xFFE83F91)];
const _ink = Color(0xFF193C29);
const _specialHouseColor = Color(0xFFEAD9FF);
const _skyBlue = Color(0xFF25AEEA);
const _deepBlue = Color(0xFF124F78);
const _sunYellow = Color(0xFFFFD447);
const _adventureOrange = Color(0xFFF58A2A);
const _adventureRed = Color(0xFFED513F);
const _selectionGreen = Color(0xFF168A3B);

enum BoardBackdrop {
  map1('assets/mapas/mapa_1.png'),
  map2('assets/mapas/mapa_2.png'),
  map3('assets/mapas/mapa_3.png'),
  map4('assets/mapas/mapa_4.png');

  const BoardBackdrop(this.assetPath);

  final String assetPath;
}

String animalAsset(int index) => 'assets/animals/${animalIds[index]}.gif';
String animalStillAsset(int index) => 'assets/animals/${animalIds[index]}.png';

bool animalFacesRightAtPosition(double position) {
  if (position <= 5) return true;
  if (position <= 12) return false;
  if (position <= 19) return true;
  if (position <= 26) return false;
  if (position <= 33) return true;
  if (position <= 40) return false;
  return true;
}

double animalWalkLiftAtPosition(double position, double markerSize) =>
    -sin(pi * position).abs() * markerSize * .1;

double animalWalkSwayAtPosition(double position) =>
    sin(pi * 2 * position) * .055;

class TabuleiroInfantilAventuraApp extends StatelessWidget {
  const TabuleiroInfantilAventuraApp({super.key, this.removeAdsPurchase});

  final RemoveAdsPurchaseController? removeAdsPurchase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabuleiro infantil: Aventura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _skyBlue),
        scaffoldBackgroundColor: const Color(0xFFD9F5FF),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: _ink,
          displayColor: _ink,
          fontFamily: 'Roboto',
        ),
      ),
      home: SetupPage(removeAdsPurchase: removeAdsPurchase),
    );
  }
}

class ForestBackground extends StatelessWidget {
  const ForestBackground({
    super.key,
    required this.child,
    this.colorful = false,
    this.imageAsset,
  });

  final Widget child;
  final bool colorful;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colorful
              ? const [Color(0xFF58C9F5), Color(0xFFCFF4FF), Color(0xFFFFEEA3)]
              : const [Color(0xFFB6EDFD), Color(0xFFE0F8D4), Color(0xFF8ACB68)],
        ),
        image: imageAsset == null
            ? null
            : DecorationImage(
                image: AssetImage(imageAsset!),
                fit: BoxFit.cover,
              ),
      ),
      child: Stack(
        children: [
          if (imageAsset == null)
            Positioned.fill(
              child: CustomPaint(
                painter: colorful ? _AdventurePainter() : _ForestPainter(),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _AdventurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas.drawCircle(
      Offset(size.width * .86, size.height * .08),
      min(size.width, size.height) * .13,
      Paint()..color = _sunYellow.withValues(alpha: .72),
    );

    const accentColors = [_adventureRed, _sunYellow, _skyBlue];
    for (var i = 0; i < 15; i++) {
      final color = accentColors[i % accentColors.length];
      final x = (i * 83.0 + 24) % size.width;
      final y = (i * 149.0 + 92) % size.height;
      canvas.drawCircle(
        Offset(x, y),
        i.isEven ? 10 : 6,
        Paint()..color = color.withValues(alpha: .16),
      );
    }

    final hill = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .72,
        size.width * .58,
        size.height * .84,
      )
      ..quadraticBezierTo(
        size.width * .82,
        size.height * .91,
        size.width,
        size.height * .76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()..color = const Color(0xFF48AE50).withValues(alpha: .25),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final hill = Paint()
      ..color = const Color(0xFF7DBD72).withValues(alpha: .45);
    final path = Path()
      ..moveTo(0, size.height * .39)
      ..quadraticBezierTo(
        size.width * .3,
        size.height * .26,
        size.width * .6,
        size.height * .38,
      )
      ..quadraticBezierTo(
        size.width * .82,
        size.height * .45,
        size.width,
        size.height * .31,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, hill);
    final leaf = Paint()..color = const Color(0xFF2C8B53).withValues(alpha: .3);
    for (var i = 0; i < 17; i++) {
      final x = (i * 79.0) % (size.width + 30);
      final y = (i * 137.0) % (size.height + 30);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 40, height: 17),
        leaf,
      );
    }
    final flower = Paint()..color = Colors.white.withValues(alpha: .78);
    for (var i = 0; i < 14; i++) {
      final x = (i * 113.0 + 37) % size.width;
      final y = (i * 181.0 + 70) % size.height;
      canvas.drawCircle(Offset(x, y), 3, flower);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SetupPage extends StatefulWidget {
  const SetupPage({super.key, this.removeAdsPurchase});

  final RemoveAdsPurchaseController? removeAdsPurchase;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage>
    with SingleTickerProviderStateMixin {
  GameMode _mode = GameMode.robot;
  BoardBackdrop _backdrop = BoardBackdrop.map1;
  final _chosen = <int>[0, 1];
  final _animalScrollController = ScrollController();
  late final RemoveAdsPurchaseController _removeAdsPurchase;
  late final bool _ownsRemoveAdsPurchase;
  late final AnimationController _startButtonPulseController;
  int _editingPlayer = 0;

  @override
  void initState() {
    super.initState();
    _startButtonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _ownsRemoveAdsPurchase = widget.removeAdsPurchase == null;
    _removeAdsPurchase =
        widget.removeAdsPurchase ?? PlayRemoveAdsPurchaseController();
    _removeAdsPurchase.addListener(_onRemoveAdsPurchaseChanged);
    unawaited(_removeAdsPurchase.initialize());
  }

  void _onRemoveAdsPurchaseChanged() {
    if (mounted) setState(() {});
  }

  void _scrollAnimalsForward() {
    if (!_animalScrollController.hasClients) return;
    final position = _animalScrollController.position;
    final target = min(
      position.pixels + position.viewportDimension * .7,
      position.maxScrollExtent,
    );
    unawaited(
      _animalScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _selectAnimal(int index) {
    setState(() {
      if (_chosen[1 - _editingPlayer] == index) {
        _chosen[1 - _editingPlayer] = _chosen[_editingPlayer];
      }
      _chosen[_editingPlayer] = index;
    });
  }

  @override
  void dispose() {
    _removeAdsPurchase.removeListener(_onRemoveAdsPurchaseChanged);
    if (_ownsRemoveAdsPurchase) _removeAdsPurchase.dispose();
    _animalScrollController.dispose();
    _startButtonPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ForestBackground(
        imageAsset: 'assets/inicial.png',
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                key: const ValueKey('setup-scroll'),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_removeAdsPurchase.isPurchased) ...[
                      _RemoveAdsBanner(
                        price: _removeAdsPurchase.price,
                        loading: _removeAdsPurchase.isLoading,
                        enabled: _removeAdsPurchase.canBuy,
                        onPressed: _removeAdsPurchase.buy,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '🎲 Tabuleiro infantil: Aventura',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          color: _deepBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .4,
                          shadows: [
                            Shadow(
                              color: Color(0xAAFFFFFF),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Como vamos jogar?',
                            style: TextStyle(
                              color: _deepBlue,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          SegmentedButton<GameMode>(
                            key: const ValueKey('game-mode-choice'),
                            segments: const [
                              ButtonSegment(
                                value: GameMode.robot,
                                icon: Icon(Icons.smart_toy),
                                label: Text('Contra robô'),
                              ),
                              ButtonSegment(
                                value: GameMode.local,
                                icon: Icon(Icons.people),
                                label: Text('2 pessoas'),
                              ),
                            ],
                            selected: {_mode},
                            onSelectionChanged: (value) =>
                                setState(() => _mode = value.first),
                            showSelectedIcon: false,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                return states.contains(WidgetState.selected)
                                    ? _skyBlue
                                    : Colors.white;
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                return states.contains(WidgetState.selected)
                                    ? Colors.white
                                    : _deepBlue;
                              }),
                              side: WidgetStateProperty.resolveWith((states) {
                                return BorderSide(
                                  color: states.contains(WidgetState.selected)
                                      ? _selectionGreen
                                      : const Color(0xFF9BCFE8),
                                  width: states.contains(WidgetState.selected)
                                      ? 2
                                      : 1,
                                );
                              }),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Escolha os animais',
                            style: TextStyle(
                              color: _deepBlue,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: List.generate(2, (i) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: i == 0 ? 6 : 0,
                                    left: i == 1 ? 6 : 0,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () =>
                                        setState(() => _editingPlayer = i),
                                    child: Container(
                                      key: ValueKey('player-choice-$i'),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: playerColors[i].withValues(
                                          alpha: _editingPlayer == i
                                              ? .19
                                              : .07,
                                        ),
                                        border: Border.all(
                                          color: _editingPlayer == i
                                              ? _selectionGreen
                                              : const Color(0xFFCAD8CB),
                                          width: _editingPlayer == i ? 4 : 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 19,
                                            backgroundColor: Colors.white,
                                            child: Image.asset(
                                              animalStillAsset(_chosen[i]),
                                              width: 34,
                                              height: 34,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              i == 1 && _mode == GameMode.robot
                                                  ? 'Robô\n${animalNames[_chosen[i]]}'
                                                  : 'Jogador ${i + 1}\n${animalNames[_chosen[i]]}',
                                              maxLines: 2,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Animal para ${_editingPlayer == 1 && _mode == GameMode.robot ? 'o robô' : 'o jogador ${_editingPlayer + 1}'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                key: const ValueKey('animal-scroll-hint'),
                                onPressed: _scrollAnimalsForward,
                                tooltip: 'Ver mais animais',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFE89B),
                                  foregroundColor: _adventureOrange,
                                  minimumSize: const Size(40, 32),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 76,
                            child: ListView.separated(
                              key: const ValueKey('animal-list'),
                              controller: _animalScrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: animalNames.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                final selected =
                                    _chosen[_editingPlayer] == index;
                                return SizedBox(
                                  width: 60,
                                  child: InkWell(
                                    key: ValueKey('animal-option-$index'),
                                    borderRadius: BorderRadius.circular(13),
                                    onTap: () => _selectAnimal(index),
                                    child: Container(
                                      key: ValueKey('animal-card-$index'),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? playerColors[_editingPlayer]
                                                  .withValues(alpha: .19)
                                            : const Color(0xFFEEF9FF),
                                        borderRadius: BorderRadius.circular(13),
                                        border: Border.all(
                                          color: selected
                                              ? _selectionGreen
                                              : const Color(0xFFB9DEEF),
                                          width: selected ? 2.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Image.asset(
                                                animalStillAsset(index),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 3,
                                              right: 3,
                                              bottom: 3,
                                            ),
                                            child: FittedBox(
                                              child: Text(
                                                animalNames[index],
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Escolha o cenário',
                            style: TextStyle(
                              color: _deepBlue,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final size = ((constraints.maxWidth - 18) / 4)
                                  .clamp(54.0, 68.0);
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (
                                    var index = 0;
                                    index < BoardBackdrop.values.length;
                                    index++
                                  ) ...[
                                    if (index > 0) const SizedBox(width: 6),
                                    SizedBox(
                                      width: size,
                                      child: _BackdropChoice(
                                        backdrop: BoardBackdrop.values[index],
                                        selected:
                                            _backdrop ==
                                            BoardBackdrop.values[index],
                                        onTap: () => setState(
                                          () => _backdrop =
                                              BoardBackdrop.values[index],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    AnimatedBuilder(
                      animation: _startButtonPulseController,
                      builder: (context, child) {
                        final animationsDisabled =
                            MediaQuery.disableAnimationsOf(context);
                        final pulse = animationsDisabled
                            ? 0.0
                            : Curves.easeInOutSine.transform(
                                _startButtonPulseController.value,
                              );
                        return Transform.scale(
                          scale: 1 + pulse * .035,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              boxShadow: [
                                BoxShadow(
                                  color: _selectionGreen.withValues(
                                    alpha: .18 + pulse * .3,
                                  ),
                                  blurRadius: 8 + pulse * 12,
                                  spreadRadius: 1 + pulse * 2,
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: FilledButton.icon(
                        key: const ValueKey('start-game-button'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => GamePage(
                              mode: _mode,
                              animals: List<int>.of(_chosen),
                              backdrop: _backdrop,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 26),
                        label: const Text(
                          'COMEÇAR A JOGAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _selectionGreen,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: const Color(0x770D4F77),
                          side: const BorderSide(color: _sunYellow, width: 3),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .95),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x402C75A3),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

class _RemoveAdsBanner extends StatelessWidget {
  const _RemoveAdsBanner({
    required this.price,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final String? price;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonText = switch ((loading, price)) {
      (true, null) => 'Buscando preço...',
      (true, _) => 'Processando...',
      (false, final value?) => 'Tirar propagandas por $value',
      _ => 'Preço indisponível',
    };

    return Container(
      key: const ValueKey('remove-ads-banner'),
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3B8), Color(0xFFFFD96A)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _adventureOrange, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332C75A3),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 4,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Remover propagandas',
                maxLines: 1,
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: FilledButton(
              key: const ValueKey('remove-ads-button'),
              onPressed: enabled ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: _deepBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF7995A5),
                disabledForegroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  buttonText,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropChoice extends StatelessWidget {
  const _BackdropChoice({
    required this.backdrop,
    required this.selected,
    required this.onTap,
  });

  final BoardBackdrop backdrop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cenário ${backdrop.index + 1}',
    selected: selected,
    button: true,
    child: InkWell(
      key: ValueKey('backdrop-${backdrop.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        key: ValueKey('backdrop-card-${backdrop.name}'),
        padding: EdgeInsets.all(selected ? 3 : 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? _selectionGreen : const Color(0xFFB9DDEA),
            width: selected ? 3 : 1.5,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              backdrop.assetPath,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    ),
  );
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.mode,
    required this.animals,
    this.backdrop = BoardBackdrop.map1,
    this.random,
  });
  final GameMode mode;
  final List<int> animals;
  final BoardBackdrop backdrop;
  final Random? random;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late AdventureBoardGame _game;
  late AnimationController _diceController;
  final _random = Random();
  final _displayPositions = <int>[0, 0];
  Timer? _diceTimer;
  Completer<void>? _eventDismissed;
  bool _busy = false;
  bool _showDice = false;
  bool _showEvent = false;
  bool _showWinner = false;
  int? _actingPlayerIndex;
  int _dieFace = 1;
  SpecialSpace? _event;
  String _status = 'Vez do Jogador 1';

  @override
  void initState() {
    super.initState();
    _newGame();
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 580),
    );
  }

  void _newGame() {
    _game = AdventureBoardGame(
      mode: widget.mode,
      playerOneAnimal: widget.animals[0],
      playerTwoAnimal: widget.animals[1],
      random: widget.random,
    );
    _displayPositions[0] = 0;
    _displayPositions[1] = 0;
    _busy = false;
    _showDice = false;
    _showEvent = false;
    _showWinner = false;
    _actingPlayerIndex = null;
    _event = null;
    _status = 'Vez do Jogador 1';
  }

  @override
  void dispose() {
    _diceTimer?.cancel();
    if (_eventDismissed != null && !_eventDismissed!.isCompleted) {
      _eventDismissed!.complete();
    }
    _diceController.dispose();
    super.dispose();
  }

  String _playerName(int index) => index == 1 && widget.mode == GameMode.robot
      ? 'Robô'
      : 'Jogador ${index + 1}';

  Future<void> _roll({bool fromRobot = false}) async {
    if (_busy ||
        _game.winnerIndex != null ||
        (widget.mode == GameMode.robot &&
            _game.currentPlayerIndex == 1 &&
            !fromRobot)) {
      return;
    }
    final player = _game.currentPlayerIndex;
    final rolled = _game.roll();
    setState(() {
      _busy = true;
      _showDice = true;
      _actingPlayerIndex = player;
      _status = '${_playerName(player)} está jogando o dado...';
    });
    _diceController.repeat();
    _diceTimer = Timer.periodic(const Duration(milliseconds: 75), (_) {
      if (mounted) setState(() => _dieFace = _random.nextInt(6) + 1);
    });
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _diceTimer?.cancel();
    _diceController.stop();
    setState(() {
      _dieFace = rolled;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _showDice = false);

    final turn = _game.play(rolled);
    for (final position in turn.dicePath) {
      await _moveTo(player, position);
      if (!mounted) return;
    }
    if (turn.special != null && turn.winnerIndex == null) {
      _eventDismissed = Completer<void>();
      setState(() {
        _event = turn.special;
        _showEvent = true;
        _status = '${_playerName(player)}: ${turn.special!.action}';
      });
      await _eventDismissed!.future;
      if (!mounted) return;
      setState(() {
        _showEvent = false;
        _eventDismissed = null;
      });
      for (final position in turn.effectPath) {
        await _moveTo(player, position);
        if (!mounted) return;
      }
    }
    if (turn.winnerIndex != null) {
      setState(() {
        _busy = false;
        _showWinner = true;
        _actingPlayerIndex = null;
        _status = '${_playerName(player)} venceu!';
      });
      return;
    }
    setState(() {
      _busy = false;
      _actingPlayerIndex = null;
      _status = turn.skippedPlayerIndex != null
          ? '${_playerName(turn.skippedPlayerIndex!)} perdeu a vez!'
          : 'Vez do ${_playerName(_game.currentPlayerIndex)}';
    });
    if (widget.mode == GameMode.robot && _game.currentPlayerIndex == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 850));
      if (!mounted ||
          _busy ||
          _game.winnerIndex != null ||
          _game.currentPlayerIndex != 1) {
        return;
      }
      await _roll(fromRobot: true);
    }
  }

  Future<void> _moveTo(int player, int position) async {
    setState(() {
      _displayPositions[player] = position;
      _status = position == finishPosition
          ? '${_playerName(player)} chegou à CHEGADA!'
          : '${_playerName(player)} chegou à casa $position';
    });
    await Future<void>.delayed(const Duration(milliseconds: 410));
  }

  void _restart() => setState(_newGame);

  @override
  Widget build(BuildContext context) {
    final current = _actingPlayerIndex ?? _game.currentPlayerIndex;
    final winner = _showWinner ? _game.winnerIndex : null;
    return Scaffold(
      body: ForestBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 570),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new),
                              tooltip: 'Voltar',
                            ),
                            const Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '🌿 Tabuleiro infantil: Aventura',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _Board(
                            animals: widget.animals,
                            positions: _displayPositions,
                            status: _status,
                            turnColor: playerColors[current],
                            backdrop: widget.backdrop,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 5, 16, 12),
                        child: FilledButton.icon(
                          onPressed:
                              _busy ||
                                  winner != null ||
                                  (widget.mode == GameMode.robot &&
                                      current == 1)
                              ? null
                              : () => _roll(),
                          icon: const Icon(Icons.casino_rounded, size: 29),
                          label: Text(
                            widget.mode == GameMode.robot && current == 1
                                ? 'ROBÔ JOGANDO...'
                                : 'JOGAR DADO',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: playerColors[current],
                            disabledBackgroundColor: playerColors[current]
                                .withValues(alpha: .55),
                            minimumSize: const Size.fromHeight(58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showDice)
                _DiceOverlay(
                  face: _dieFace,
                  color: playerColors[current],
                  controller: _diceController,
                ),
              if (_showEvent && _event != null)
                _EventOverlay(
                  event: _event!,
                  house: _displayPositions[current],
                  animal: widget.animals[current],
                  onFinished: () {
                    if (_eventDismissed != null &&
                        !_eventDismissed!.isCompleted) {
                      _eventDismissed!.complete();
                    }
                  },
                ),
              if (winner != null)
                _WinnerOverlay(
                  name: _playerName(winner),
                  animal: widget.animals[winner],
                  color: playerColors[winner],
                  onRestart: _restart,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({
    required this.animals,
    required this.positions,
    required this.status,
    required this.turnColor,
    required this.backdrop,
  });
  final List<int> animals;
  final List<int> positions;
  final String status;
  final Color turnColor;
  final BoardBackdrop backdrop;

  static const _startAreaHeight = 70.0;
  static const _startCardHeight = 55.0;
  static const _startLabelWidth = 90.0;

  static const houseColors = <Color>[
    Color(0xFF2DA9F0),
    Color(0xFFFFD844),
    Color(0xFFFF9C48),
    Color(0xFF83D93F),
    Color(0xFFFF7DAF),
    Color(0xFFB877E7),
  ];

  Path _roadPath(
    double width,
    double boardHeight,
    double roadWidth,
    double finishAreaHeight,
  ) {
    final inset = roadWidth + 12;
    final left = inset;
    final right = width - inset;
    final bottom = boardHeight - _startAreaHeight - roadWidth / 2 - 8;
    final top = finishAreaHeight + roadWidth / 2 + 8;
    final laneStep = (bottom - top) / 5;
    final bend = roadWidth * .64;
    final path = Path()..moveTo(left, bottom);

    for (var lane = 0; lane < 6; lane++) {
      final y = bottom - lane * laneStep;
      final endX = lane.isEven ? right : left;
      path.lineTo(endX, y);
      if (lane < 5) {
        final bendX = lane.isEven ? right + bend : left - bend;
        final nextY = y - laneStep;
        path.cubicTo(bendX, y, bendX, nextY, endX, nextY);
      }
    }
    return path;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final boardHeight = constraints.maxHeight;
      final finishAreaHeight = (boardHeight * .11).clamp(72.0, 84.0);
      final cloudWidth = (width * .43).clamp(120.0, 150.0);
      final cloudHeight = finishAreaHeight - 3;
      const cloudLeft = 4.0;
      const cloudTop = 4.0;
      final availableLaneHeight =
          (boardHeight - finishAreaHeight - _startAreaHeight - 16) / 5;
      final roadWidth = min(
        (width * .13).clamp(32.0, 50.0),
        (availableLaneHeight - 9).clamp(28.0, 50.0),
      );
      final path = _roadPath(width, boardHeight, roadWidth, finishAreaHeight);
      final metric = path.computeMetrics().first;
      final step = metric.length / (finishPosition - 1);
      final finishCenter = Offset(
        cloudLeft + cloudWidth / 2,
        cloudTop + cloudHeight / 2,
      );
      final token = roadWidth * .78;
      final startWidth = _startLabelWidth + token * 2 + 24;
      final sharedHouse = positions[0] == positions[1] && positions[0] > 0;
      double markerSizeForPlayer(int player) {
        if (sharedHouse) return roadWidth * .44;
        if (positions[player] > 0) return roadWidth * .88;
        return token;
      }

      Offset houseCenter(int number) =>
          metric.getTangentForOffset((number - .5) * step)!.position;

      Offset onRoad(double progress, int player) {
        final offset = ((progress - .5) * step).clamp(0.0, metric.length);
        final tangent = metric.getTangentForOffset(offset)!;
        if (!sharedHouse) return tangent.position;
        final direction = tangent.vector / tangent.vector.distance;
        final normal = Offset(-direction.dy, direction.dx);
        final side = player == 0 ? -1.0 : 1.0;
        return tangent.position + normal * (side * roadWidth * .18);
      }

      Offset tokenCenter(double progress, int player) {
        final start = Offset(
          4 + _startLabelWidth + 8 + token / 2 + player * (token + 8),
          boardHeight - _startAreaHeight + 2 + _startCardHeight / 2,
        );
        if (progress <= 0) return start;
        if (progress < 1) {
          return Offset.lerp(start, onRoad(1, player), progress)!;
        }
        if (progress > finishPosition - 1) {
          return Offset.lerp(
            onRoad((finishPosition - 1).toDouble(), player),
            finishCenter,
            (progress - (finishPosition - 1)).clamp(0.0, 1.0),
          )!;
        }
        return onRoad(progress, player);
      }

      return Container(
        key: const ValueKey('game-board'),
        decoration: BoxDecoration(
          color: const Color(0xFF69B476),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x440A5227),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  backdrop.assetPath,
                  key: const ValueKey('selected-board-map'),
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoadPainter(path: path, roadWidth: roadWidth),
                ),
              ),
              for (var number = 1; number < finishPosition; number++)
                Positioned(
                  left: houseCenter(number).dx - roadWidth * .38,
                  top: houseCenter(number).dy - roadWidth * .40,
                  width: roadWidth * .76,
                  height: roadWidth * .80,
                  child: _RoadHouseLabel(number: number, roadWidth: roadWidth),
                ),
              Positioned(
                left: cloudLeft,
                top: cloudTop,
                width: cloudWidth,
                height: cloudHeight,
                child: const _FinishCloud(),
              ),
              Positioned(
                left: 4,
                top: boardHeight - _startAreaHeight + 2,
                width: startWidth,
                child: Container(
                  key: const ValueKey('start-card'),
                  height: _startCardHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF76501E),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFFFFD17D),
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: _startLabelWidth,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 6),
                          child: Center(
                            child: Text(
                              'LARGADA',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: startWidth + 12,
                right: 5,
                top: boardHeight - _startAreaHeight + 2,
                height: _startCardHeight,
                child: Container(
                  key: const ValueKey('status-card'),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFD7E8D3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330A5227),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: status.startsWith('Vez do ')
                          ? Colors.black
                          : turnColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < 2; i++)
                TweenAnimationBuilder<double>(
                  key: ValueKey('token-$i'),
                  tween: Tween<double>(begin: 0, end: positions[i].toDouble()),
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.easeInOut,
                  builder: (context, progress, child) {
                    final markerSize = markerSizeForPlayer(i);
                    final center = tokenCenter(progress, i);
                    return Positioned(
                      left: center.dx - markerSize / 2,
                      top: center.dy - markerSize / 2,
                      width: markerSize,
                      height: markerSize,
                      child: Container(
                        key: ValueKey('token-marker-$i'),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: playerColors[i],
                            width: sharedHouse ? 2 : 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x55000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Transform.translate(
                            key: ValueKey('token-animal-motion-$i'),
                            offset: Offset(
                              0,
                              animalWalkLiftAtPosition(progress, markerSize),
                            ),
                            child: Transform.rotate(
                              angle: animalWalkSwayAtPosition(progress),
                              child: Transform.flip(
                                flipX: !animalFacesRightAtPosition(progress),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Transform.scale(
                    scale: !sharedHouse && positions[i] > 0 ? 1.14 : 1.08,
                    child: Image.asset(
                      animalAsset(animals[i]),
                      key: ValueKey('token-gif-$i'),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter({required this.path, required this.roadWidth});

  final Path path;
  final double roadWidth;

  Color _houseColor(int number) {
    if (specialSpaces.containsKey(number)) return _specialHouseColor;
    return _Board.houseColors[(number - 1) % _Board.houseColors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x550A5227)
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadWidth + 15
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFFCED)
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadWidth + 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _houseColor(1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = roadWidth
        ..strokeCap = StrokeCap.round,
    );

    final metric = path.computeMetrics().first;
    final step = metric.length / (finishPosition - 1);
    for (var index = 0; index < finishPosition - 1; index++) {
      canvas.drawPath(
        metric.extractPath(
          max(0, index * step - .7),
          min(metric.length, (index + 1) * step + .7),
        ),
        Paint()
          ..color = _houseColor(index + 1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = roadWidth
          ..strokeCap = StrokeCap.butt,
      );
    }
    canvas.drawCircle(
      metric.getTangentForOffset(metric.length - .01)!.position,
      roadWidth / 2,
      Paint()..color = _houseColor(finishPosition - 1),
    );
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) =>
      oldDelegate.path != path || oldDelegate.roadWidth != roadWidth;
}

class _FinishCloud extends StatelessWidget {
  const _FinishCloud();

  @override
  Widget build(BuildContext context) => CustomPaint(
    key: const ValueKey('finish-cloud'),
    painter: _CloudPainter(),
    child: const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏁', style: TextStyle(fontSize: 26, height: 1)),
            Text(
              'CHEGADA',
              style: TextStyle(
                color: _ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cloud = Path()
      ..moveTo(w * .20, h * .79)
      ..cubicTo(w * .07, h * .82, w * .02, h * .64, w * .10, h * .49)
      ..cubicTo(w * .14, h * .39, w * .18, h * .37, w * .25, h * .39)
      ..cubicTo(w * .22, h * .22, w * .36, h * .12, w * .48, h * .20)
      ..cubicTo(w * .58, h * .05, w * .78, h * .13, w * .81, h * .34)
      ..cubicTo(w * .95, h * .32, w * 1.00, h * .47, w * .95, h * .62)
      ..cubicTo(w * .95, h * .76, w * .85, h * .84, w * .74, h * .79)
      ..cubicTo(w * .66, h * .91, w * .53, h * .92, w * .45, h * .82)
      ..cubicTo(w * .34, h * .94, w * .23, h * .90, w * .20, h * .79)
      ..close();
    canvas.drawShadow(cloud, const Color(0x770D4931), 7, true);
    canvas.drawPath(cloud, Paint()..color = const Color(0xFFFFFEED));
    canvas.drawPath(
      cloud,
      Paint()
        ..color = const Color(0xFFFFD244)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}

class _RoadHouseLabel extends StatelessWidget {
  const _RoadHouseLabel({required this.number, required this.roadWidth});
  final int number;
  final double roadWidth;

  @override
  Widget build(BuildContext context) {
    final special = specialSpaces[number];
    return SizedBox(
      key: ValueKey('house-$number'),
      child: special == null
          ? Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: (roadWidth * .36).clamp(12.0, 17.0),
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
            )
          : Semantics(
              label: 'Casa $number: ${special.title}',
              excludeSemantics: true,
              child: Center(
                child: Text(
                  special.icon,
                  style: TextStyle(
                    fontSize: (roadWidth * .56).clamp(20.0, 28.0),
                    height: 1,
                  ),
                ),
              ),
            ),
    );
  }
}

class _DiceOverlay extends StatelessWidget {
  const _DiceOverlay({
    required this.face,
    required this.color,
    required this.controller,
  });
  final int face;
  final Color color;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xB9001C13),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎲 ROLANDO O DADO...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 25),
            AnimatedBuilder(
              animation: controller,
              builder: (_, child) => Transform.rotate(
                angle: controller.isAnimating ? controller.value * pi * 3 : 0,
                child: child,
              ),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: color, width: 9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 25,
                      offset: Offset(0, 11),
                    ),
                  ],
                ),
                child: _DiePips(face: face, color: color),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$face',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DiePips extends StatelessWidget {
  const _DiePips({required this.face, required this.color});
  final int face;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const spots = <int, List<int>>{
      1: [4],
      2: [0, 8],
      3: [0, 4, 8],
      4: [0, 2, 6, 8],
      5: [0, 2, 4, 6, 8],
      6: [0, 2, 3, 5, 6, 8],
    };
    return Padding(
      padding: const EdgeInsets.all(19),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          9,
          (index) => Center(
            child: spots[face]!.contains(index)
                ? CircleAvatar(radius: 10, backgroundColor: color)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _EventOverlay extends StatefulWidget {
  const _EventOverlay({
    required this.event,
    required this.house,
    required this.animal,
    required this.onFinished,
  });

  final SpecialSpace event;
  final int house;
  final int animal;
  final VoidCallback onFinished;

  @override
  State<_EventOverlay> createState() => _EventOverlayState();
}

class _EventOverlayState extends State<_EventOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void initState() {
    super.initState();
    _progress.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _bounce.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final happy =
        widget.event.kind == SpecialKind.bonus ||
        widget.event.kind == SpecialKind.extraTurn;
    final accent = happy ? const Color(0xFF287A42) : const Color(0xFF9A4B20);
    final pale = happy ? const Color(0xFFE7FFE4) : const Color(0xFFFFEBD8);

    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xC6001C13),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 28,
              ),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 480),
                  curve: Curves.easeOutBack,
                  builder: (_, progress, child) => Transform.scale(
                    scale: .86 + .14 * progress,
                    child: Opacity(opacity: progress.clamp(0, 1), child: child),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 430),
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFEF3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: accent, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x88000000),
                          blurRadius: 26,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CASA ${widget.house} • SURPRESA DA FLORESTA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _bounce,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, -8 * _bounce.value),
                            child: child,
                          ),
                          child: Container(
                            width: 94,
                            height: 94,
                            decoration: BoxDecoration(
                              color: pale,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.event.icon,
                              style: const TextStyle(fontSize: 55),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.event.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Row(
                          children: [
                            SizedBox(
                              width: 78,
                              height: 92,
                              child: Image.asset(
                                animalAsset(widget.animal),
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: pale,
                                  borderRadius: BorderRadius.circular(19),
                                ),
                                child: Text(
                                  widget.event.story,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 17),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: pale,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: accent, width: 2),
                          ),
                          child: Text(
                            widget.event.action,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accent,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'A aventura continua em instantes...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 9),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedBuilder(
                            animation: _progress,
                            builder: (context, _) => LinearProgressIndicator(
                              value: _progress.value,
                              minHeight: 12,
                              backgroundColor: pale,
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WinnerOverlay extends StatelessWidget {
  const _WinnerOverlay({
    required this.name,
    required this.animal,
    required this.color,
    required this.onRestart,
  });
  final String name;
  final int animal;
  final Color color;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xD9002817),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: .3, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.elasticOut,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            margin: const EdgeInsets.all(22),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9DC),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFFFC838), width: 5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏁🏆🏁', style: TextStyle(fontSize: 50)),
                const Text(
                  'CHEGADA!',
                  style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
                ),
                Container(
                  width: 130,
                  height: 130,
                  margin: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .14),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 4),
                  ),
                  child: Image.asset(animalAsset(animal)),
                ),
                Text(
                  '$name venceu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh),
                  label: const Text('NOVA PARTIDA'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2F9A4C),
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
