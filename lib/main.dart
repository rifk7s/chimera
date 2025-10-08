import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription? _sub;
  String _status = 'Waiting for link...';

  @override
  void initState() {
    super.initState();
    initAppLinks();
  }

  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    // 1. Handle initial link if app was launched by a deep link
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleIncomingLink(initialUri);

    // 2. Handle links while app is running
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleIncomingLink(uri);
    }, onError: (err) {
      setState(() => _status = 'Failed to receive link: $err');
    });
  }

  void _handleIncomingLink(Uri uri) {
    setState(() => _status = 'Received link: $uri');

    if (uri.host == 'details') {
      // Example link: myapp://details/42
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : 'unknown';
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => DetailScreen(id: id)),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Deep Link Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Center(
          child: Text(_status),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String id;
  const DetailScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(child: Text('You opened item ID: $id')),
    );
  }
}
