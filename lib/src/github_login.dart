import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

class GithubLoginWidget extends StatefulWidget {
  const GithubLoginWidget({super.key, required this.builder});

  final AuthenticatedBuilder builder;

  @override
  State<GithubLoginWidget> createState() => _GithubLoginWidgetState();
}

typedef AuthenticatedBuilder = Widget Function(
    BuildContext context, oauth2.Client client);

class _GithubLoginWidgetState extends State<GithubLoginWidget> {
  HttpServer? _redirectServer;
  oauth2.Client? _client;

  @override
  Widget build(BuildContext context) {
    if (_client != null) {
      return widget.builder(context, _client!);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Github Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _redirectServer?.close();
            _redirectServer = await HttpServer.bind('localhost', 0);
            final redirectUri =
                Uri.parse('http://localhost:${_redirectServer!.port}/auth');
            final authenticatedHttpClient = await _getOAuth2Client(redirectUri);
            setState(() => _client = authenticatedHttpClient);
          },
          child: const Text('Login to Github'),
        ),
      ),
    );
  }

  Future<oauth2.Client> _getOAuth2Client(Uri redirectUri) async {
    final grant = oauth2.AuthorizationCodeGrant(
      Env.githubClientId,
      Uri.parse(Env.githubAuthUrl),
      Uri.parse(Env.githubTokenUrl),
      secret: Env.githubClientSecret,
      httpClient: _JsonAcceptingHttpClient(),
    );

    final authUri =
        grant.getAuthorizationUrl(redirectUri, scopes: Env.githubAuthScopes);

    await _redirect(authUri);

    final responseQueryParams = await _listen();
    var client = await grant.handleAuthorizationResponse(responseQueryParams);
    return client;
  }

  Future<void> _redirect(Uri authUri) async {
    final canLaunch = await canLaunchUrl(authUri);

    if (canLaunch) {
      await launchUrl(authUri);
    } else {
      throw GithubLoginException('Could not launch ${authUri.toString()}');
    }
  }

  Future<Map<String, String>> _listen() async {
    final request = await _redirectServer!.first;
    final params = request.uri.queryParameters;
    request.response
      ..statusCode = 200
      ..headers.set('content-type', 'text/plain')
      ..writeln('Authenticated! You can close this tab.');
    await request.response.close();
    await _redirectServer!.close();
    _redirectServer = null;
    return params;
  }
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _client.send(request);
  }
}

class GithubLoginException implements Exception {
  const GithubLoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
