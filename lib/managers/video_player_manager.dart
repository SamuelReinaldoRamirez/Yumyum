import 'package:video_player/video_player.dart';

class VideoPlayerManager {
  static final VideoPlayerManager _instance = VideoPlayerManager._internal();
  factory VideoPlayerManager() => _instance;
  VideoPlayerManager._internal();

  final Map<String, VideoPlayerController> _controllers = {};
  bool _isDisposing = false;

  Future<VideoPlayerController> getController(String videoUrl) async {
    if (!_controllers.containsKey(videoUrl)) {
      final controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      _controllers[videoUrl] = controller;
    }
    return _controllers[videoUrl]!;
  }

  Future<void> initializeControllers(List<String> videoUrls) async {
    for (String videoUrl in videoUrls) {
      if (!_controllers.containsKey(videoUrl)) {
        final controller = VideoPlayerController.network(videoUrl);
        await controller.initialize();
        _controllers[videoUrl] = controller;
      }
    }
  }

  void play(String videoUrl) {
    _controllers[videoUrl]?.play();
  }

  void pause(String videoUrl) {
    _controllers[videoUrl]?.pause();
  }

  void pauseAll() {
    for (var controller in _controllers.values) {
      controller.pause();
    }
  }

  Future<void> pauseAllVideos() async {
    // Pause toutes les vidéos actives
    for (var controller in _controllers.values) {
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
      }
    }
  }

  Future<void> disposeControllers() async {
    // Nettoyer proprement les contrôleurs
    for (var controller in _controllers.values) {
      if (controller != null) {
        await controller.dispose();
      }
    }
    _controllers.clear();
  }

  void disposeController(String videoUrl) {
    if (!_isDisposing && _controllers.containsKey(videoUrl)) {
      _controllers[videoUrl]?.pause(); // Pause instead of dispose
    }
  }

  void disposeAllControllers() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear(); 
  }

  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose(); // Disposez tous les contrôleurs, qu'ils soient initialisés ou non
    }
    _controllers.clear(); 
  }

  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  bool hasController(String videoUrl) => _controllers.containsKey(videoUrl);
}
