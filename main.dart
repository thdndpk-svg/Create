import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final trends = [
    {"title":"NMIXX - Heavy Serenade", "views":"5.4M"},
    {"title":"BABYMONSTER - 춤 (CHOOM)", "views":"4.4M"},
    {"title":"Drake - National Treasures", "views":"2.3M"},
  ];
  String script = "";
  late VideoPlayerController _controller;
  bool videoReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/sample_shorts.mp4')
      ..initialize().then((_) => setState(()=> videoReady = true))
      ..setLooping(true);
  }

  void genScript() {
    setState(() {
      script = "0-3초: NMIXX 꽃잎 클로즈업\n3-10초: 내 손으로 템플릿 스와이프\n10-15초: '3천원, 프로필 링크' 자막";
    });
  }

  void openMeta() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const WebScreen()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Shorts Maker')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('1) 트렌드 가져오기', style: TextStyle(fontWeight: FontWeight.bold)),
        ...trends.map((t)=> ListTile(
          leading: const Icon(Icons.trending_up),
          title: Text(t['title']!),
          trailing: Text(t['views']!),
        )),
        const SizedBox(height: 16),
        const Text('2) 15초 대본', style: TextStyle(fontWeight: FontWeight.bold)),
        FilledButton(onPressed: genScript, child: const Text('로컬 대본 생성')),
        OutlinedButton(onPressed: openMeta, child: const Text('Meta AI로 받기')),
        if(script.isNotEmpty) Container(
          margin: const EdgeInsets.only(top:8),
          padding: const EdgeInsets.all(12),
          color: Colors.pink.shade50,
          child: Text(script),
        ),
        const SizedBox(height: 16),
        const Text('3) 자동 영상', style: TextStyle(fontWeight: FontWeight.bold)),
        if(videoReady) AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        Row(children: [
          IconButton(onPressed: ()=> setState(()=> _controller.value.isPlaying ? _controller.pause() : _controller.play()), 
            icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow)),
          const Spacer(),
          IconButton(onPressed: ()=> Share.share('내가 만든 쇼츠 테스트'), icon: const Icon(Icons.share))
        ])
      ]),
    );
  }
}

class WebScreen extends StatelessWidget {
  const WebScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = WebViewController()..loadRequest(Uri.parse('https://meta.ai'));
    return Scaffold(appBar: AppBar(title: const Text('Meta AI')), body: WebViewWidget(controller: c));
  }
}
