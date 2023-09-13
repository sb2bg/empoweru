import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/constants.dart';

_generateRandomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  return base64Url.encode(values);
}

final rawNonce = _generateRandomString();
final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

const androidClientId = 'YOUR_ANDROID_CLIENT_ID'; // TODO
final clientId = Platform.isIOS ? iosClientId : androidClientId; // TODO
const packageName = 'me.sullivan.ageSync';

const redirectUrl = '$packageName:/google_auth';
const discoveryUrl =
    'https://accounts.google.com/.well-known/openid-configuration';

const appAuth = FlutterAppAuth();

signInWithGoogle() async {
  final result = await appAuth.authorize(
    AuthorizationRequest(
      clientId,
      redirectUrl,
      discoveryUrl: discoveryUrl,
      nonce: hashedNonce,
      scopes: [
        'openid',
        'email',
        'profile',
      ],
    ),
  );

  if (result == null) {
    throw const AuthException(
        'Could not find AuthorizationResponse after authorizing');
  }

  final tokenResponse = await appAuth.token(
    TokenRequest(
      clientId,
      redirectUrl,
      authorizationCode: result.authorizationCode,
      discoveryUrl: discoveryUrl,
      codeVerifier: result.codeVerifier,
      nonce: result.nonce,
      scopes: [
        'openid',
        'email',
        'profile',
      ],
    ),
  );

  final idToken = tokenResponse?.idToken;

  if (idToken == null) {
    throw const AuthException('Could not find idToken from the token response');
  }

  await supabase.auth.signInWithIdToken(
    provider: Provider.google,
    idToken: idToken,
    accessToken: tokenResponse?.accessToken,
    nonce: rawNonce,
  );
}
