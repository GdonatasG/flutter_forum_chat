import 'package:flutter/material.dart';
import 'package:flutterforum/pages/wrapper_page.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/category_service.dart';
import 'package:flutterforum/services/chat_service.dart';
import 'package:flutterforum/services/comment_service.dart';
import 'package:flutterforum/services/post_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final CategoryService _categoryService = CategoryService();
  final PostService _postService = PostService();
  final CommentService _commentService = CommentService();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider(create: (_) => _authService),
          Provider(
            create: (_) => _userService,
          ),
          Provider(
            create: (_) => _categoryService,
          ),
          Provider(
            create: (_) => _postService,
          ),
          Provider(
            create: (_) => _commentService,
          ),
          Provider(
            create: (_) => _chatService,
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Firebase',
          theme: ThemeData(
              backgroundColor: Colors.grey.shade200,
              dividerColor: Colors.grey,
              dividerTheme: DividerThemeData(
                  color: Colors.grey, thickness: 0.4, space: 1),
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: TextTheme(
                  headline4: TextStyle(color: Colors.white, fontSize: 15)),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: Colors.blue,
              )),
          home: WrapperPage(),
        ));
  }
}
