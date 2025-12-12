import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:streaming_bola_app/models/match.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Match match;
  final VoidCallback onWatchComplete;

  const VideoPlayerScreen({
    super.key,
    required this.match,
    required this.onWatchComplete,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      String videoUrl = widget.match.streamUrl.isNotEmpty
          ? widget.match.streamUrl
          : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

      _videoPlayerController = VideoPlayerController.network(videoUrl);

      await _videoPlayerController.initialize();

      // Untuk Web pakai Chewie, untuk mobile bisa langsung VideoPlayer
      if (kIsWeb) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          showControls: true,
          autoInitialize: true,
        );
      } else {
        _videoPlayerController.play();
      }

      _videoPlayerController.addListener(() {
        if (!_videoPlayerController.value.isPlaying &&
            _videoPlayerController.value.position >=
                _videoPlayerController.value.duration) {
          widget.onWatchComplete();
        }
      });

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.match.matchTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      const Text('Gagal memuat video',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('URL: ${widget.match.streamUrl}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeVideoPlayer,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: kIsWeb
                      ? Chewie(controller: _chewieController!)
                      : AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                ),
      floatingActionButton: !_isLoading && !_hasError
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _videoPlayerController.value.isPlaying
                      ? _videoPlayerController.pause()
                      : _videoPlayerController.play();
                });
              },
              child: Icon(
                _videoPlayerController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
