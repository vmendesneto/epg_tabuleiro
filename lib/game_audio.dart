import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'game.dart';

abstract class GameAudioController extends ChangeNotifier {
  bool get enabled;

  void toggle();
  Future<void> playDice();
  Future<void> playStep();
  Future<void> playVictory();
  Future<void> playBonus();
  Future<void> playSetback();

  Future<void> playSpecial(SpecialKind kind) => switch (kind) {
    SpecialKind.bonus || SpecialKind.extraTurn => playBonus(),
    SpecialKind.penalty || SpecialKind.skip => playSetback(),
  };
}

class AssetGameAudioController extends GameAudioController {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  bool _disposed = false;

  @override
  bool get enabled => _enabled;

  @override
  void toggle() {
    _enabled = !_enabled;
    if (!_enabled) unawaited(_player.stop());
    notifyListeners();
  }

  @override
  Future<void> playDice() => _play('sounds/dado.wav');

  @override
  Future<void> playStep() => _play('sounds/passo.wav');

  @override
  Future<void> playVictory() => _play('sounds/vitoria.wav');

  @override
  Future<void> playBonus() => _play('sounds/bonus.wav');

  @override
  Future<void> playSetback() => _play('sounds/onus.wav');

  Future<void> _play(String asset) async {
    if (!_enabled || _disposed) return;
    await _player.stop();
    if (!_enabled || _disposed) return;
    await _player.play(AssetSource(asset), mode: PlayerMode.lowLatency);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_player.dispose());
    super.dispose();
  }
}
