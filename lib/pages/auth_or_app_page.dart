import 'package:arena_soccer/core/models/chat_user.dart';
import 'package:arena_soccer/pages/auth_page.dart';
import 'package:arena_soccer/pages/chat_page.dart';
import 'package:arena_soccer/pages/loading_page.dart';
import 'package:flutter/material.dart';

import '../core/services/auth/auth_service.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ChatUser?>(
        stream: AuthService().userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          } else {
            return snapshot.hasData ? ChatPage() : AuthPage();
          }
        },
      ),
    );
  }
}
