// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../enums/player_state.dart';
import '../utils/youtube_player_controller.dart';

/// A widget to display play/pause button.
class PlayPauseButton extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines placeholder widget to show when player is in buffering state.
  final Widget? bufferIndicator;

  /// Creates [PlayPauseButton] widget.
  PlayPauseButton({
    this.controller,
    this.bufferIndicator,
  });

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with TickerProviderStateMixin {
  late YoutubePlayerController _controller;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = YoutubePlayerController.of(context);
    if (controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller!;
    } else {
      _controller = controller;
    }
    _controller.removeListener(_playPauseListener);
    _controller.addListener(_playPauseListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_playPauseListener);
    _animController.dispose();
    super.dispose();
  }

  void _playPauseListener() => _controller.value.isPlaying
      ? _animController.forward()
      : _animController.reverse();

  @override
  Widget build(BuildContext context) {
    final _playerState = _controller.value.playerState;
    if ((!_controller.flags.autoPlay && _controller.value.isReady) ||
        _playerState == PlayerState.playing ||
        _playerState == PlayerState.paused) {
      return Visibility(
        visible: _playerState == PlayerState.cued ||
            !_controller.value.isPlaying ||
            _controller.value.isControlsVisible,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () => _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play(),
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _animController.view,
              color: Colors.white,
              size: 60.0,
            ),
          ),
        ),
      );
    }
    if (_controller.value.hasError) return const SizedBox();
    if (_controller.value.isReady && _playerState == PlayerState.ended) {
      if (_controller.flags.replayableOnEnd)
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () {
              _controller.seekTo(Duration(seconds: _controller.flags.startAt));
            },
            child: Icon(
              Icons.replay,
              color: Colors.white,
              size: 60.0,
            ),
          ),
        );
      else
        return const SizedBox();
    }
    return widget.bufferIndicator ??
        Container(
          width: 70.0,
          height: 70.0,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
  }
}

class SkipButton extends StatefulWidget {
  final bool forward;

  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;
  const SkipButton({required this.forward, this.controller});

  @override
  State<SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<SkipButton> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = YoutubePlayerController.of(context);
    if (controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller!;
    } else {
      _controller = controller;
    }
    _controller.removeListener(_onPlayerUpdate);
    _controller.addListener(_onPlayerUpdate);
  }

  void _onPlayerUpdate() {}

  void dispose() {
    _controller.removeListener(_onPlayerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _playerState = _controller.value.playerState;
    if ((!_controller.flags.autoPlay && _controller.value.isReady) ||
        _playerState == PlayerState.playing ||
        _playerState == PlayerState.paused) {
      return Visibility(
        visible:
            _controller.value.isPlaying && _controller.value.isControlsVisible,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () {
              var newPosition = _controller.value.position;
              if (widget.forward == true) {
                newPosition += Duration(seconds: 15);
                if (newPosition > _controller.value.metaData.duration)
                  newPosition = _controller.value.metaData.duration;
              } else {
                newPosition -= Duration(seconds: 15);
                if (newPosition.inSeconds < 0)
                  newPosition = Duration(seconds: 0);
              }
              _controller.seekTo(newPosition);
            },
            child: Icon(
              widget.forward ? Icons.fast_forward : Icons.fast_rewind,
              color: Colors.white,
              size: 60.0,
            ),
          ),
        ),
      );
    }
    return Container();
  }
}
