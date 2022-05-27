import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// A widget which displays the current position of the video.
class CurrentPosition extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;
  final Duration? startsAt;

  /// Creates [CurrentPosition] widget.
  CurrentPosition({this.controller, this.startsAt});

  @override
  _CurrentPositionState createState() => _CurrentPositionState();
}

class _CurrentPositionState extends State<CurrentPosition> {
  late YoutubePlayerController _controller;

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
    _controller.removeListener(listener);
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int milliseconds = _controller.value.position.inMilliseconds;
    if (widget.startsAt != null) {
      milliseconds = milliseconds - widget.startsAt!.inMilliseconds;
      if (milliseconds < 0) {
        milliseconds = 0;
      }
    }
    return Text(
      durationFormatter(
        milliseconds,
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      ),
    );
  }
}

/// A widget which displays the remaining duration of the video.
class RemainingDuration extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;
  final Duration? customEndsAt;
  final Duration? customDuration;

  /// Creates [RemainingDuration] widget.
  RemainingDuration({this.controller, this.customEndsAt, this.customDuration});

  @override
  _RemainingDurationState createState() => _RemainingDurationState();
}

class _RemainingDurationState extends State<RemainingDuration> {
  late YoutubePlayerController _controller;
  late Duration _customDuration;
  late Duration _customEndsAt;

  @override
  void initState() {
    super.initState();
    _customDuration = widget.customDuration ?? Duration.zero;
    _customEndsAt = widget.customEndsAt ?? Duration.zero;
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
    _controller.removeListener(listener);
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int milliseconds = 0;
    if (_controller.metadata.duration.inMilliseconds == 0 &&
        _customEndsAt != Duration.zero) {
      milliseconds = _customEndsAt.inMilliseconds;
    } else {
      milliseconds = (_customEndsAt != Duration.zero
              ? _customEndsAt.inMilliseconds
              : _controller.metadata.duration.inMilliseconds) -
          _controller.value.position.inMilliseconds;
    }

    return Text(
      "- ${durationFormatter(milliseconds)}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      ),
    );
  }
}
