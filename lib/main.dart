import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TikTokFeedScreen(),
    );
  }
}

class TikTokFeedScreen extends StatefulWidget {
  const TikTokFeedScreen({super.key});

  @override
  State<TikTokFeedScreen> createState() => _TikTokFeedScreenState();
}

class _TikTokFeedScreenState extends State<TikTokFeedScreen> {
  // Giả lập danh sách video có các mức độ nét (URL khác nhau cho từng độ phân giải)
  final List<Map<String, String>> videoQualities = [
    {
      'quality': '244p (Tiết kiệm Pin/Wifi)',
      'url': 'https://flutter.github.io/assets-for-web-docs/assets/videos/bee.mp4',
    },
    {
      'quality': '480p (Độ nét cao)',
      'url': 'https://flutter.github.io/assets-for-web-docs/assets/videos/butterfly.mp4',
    },
  ];

  int currentQualityIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Màn hình phát video
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 1,
            itemBuilder: (context, index) {
              return VideoPlayerItem(
                videoUrl: videoQualities[currentQualityIndex]['url']!,
              );
            },
          ),
          
          // Nút bấm ở góc phải để người dùng tự chỉnh độ nét
          Positioned(
            top: 50,
            right: 20,
            child: PopupMenuButton<int>(
              initialValue: currentQualityIndex,
              onSelected: (int index) {
                setState(() {
                  currentQualityIndex = index;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem(
                  enabled: false,
                  child: Text("Chọn độ nét video:", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...List.generate(videoQualities.length, (index) {
                  return PopupMenuItem<int>(
                    value: index,
                    child: Text(videoQualities[index]['quality']!),
                  );
                }),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      videoQualities[currentQualityIndex]['quality']!.split(' ')[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  // Cập nhật lại video nếu người dùng đổi độ nét
  @override
  void didUpdateWidget(covariant VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _initVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ],
    );
  }
}