import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeLiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Live App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YouTubeLiveScreen(),
    );
  }
}

class YouTubeLiveScreen extends StatefulWidget {
  @override
  _YouTubeLiveScreenState createState() => _YouTubeLiveScreenState();
}

class _YouTubeLiveScreenState extends State<YouTubeLiveScreen> {
  late List<dynamic> _liveStreams;

  @override
  void initState() {
    super.initState();
    _getLiveStreams();
  }

  Future<void> _getLiveStreams() async {
    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&eventType=live&type=video&key=AIzaSyDt6Q_YdTOQ_U1ah6INnMMYC_SKfh42QFo'));

    if (response.statusCode == 200) {
      setState(() {
        _liveStreams = json.decode(response.body)['items'];
      });
    } else {
      throw Exception('Failed to load live streams');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Live Streams'),
      ),
      body: _liveStreams == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _liveStreams.length,
              itemBuilder: (context, index) {
                final liveStream = _liveStreams[index];
                return ListTile(
                  title: Text(liveStream['snippet']['title']),
                  onTap: () {
                    String videoId = liveStream['id']['videoId'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LiveStreamPlayer(videoId: videoId),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class LiveStreamPlayer extends StatelessWidget {
  final String videoId;

  LiveStreamPlayer({required this.videoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Stream'),
      ),
      body: YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        ),
        showVideoProgressIndicator: true,
      ),
    );
  }
}
