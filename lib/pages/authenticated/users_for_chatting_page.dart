import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/users_for_chatting_page/users_for_chatting_page_bloc_export.dart';
import 'package:flutterforum/model/chat.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/pages/authenticated/chat_page.dart';
import 'package:flutterforum/services/chat_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:provider/provider.dart';

class UsersForChattingPage extends StatefulWidget {
  final String currentUserId;

  const UsersForChattingPage({Key key, @required this.currentUserId})
      : super(key: key);

  @override
  _UsersForChattingPageState createState() => _UsersForChattingPageState();
}

class _UsersForChattingPageState extends State<UsersForChattingPage> {
  UserService _userService;
  ChatService _chatService;
  UsersForChattingPageBloc _usersForChattingPageBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isNotBusy = false;

  @override
  void initState() {
    _userService = Provider.of<UserService>(context, listen: false);
    _chatService = Provider.of<ChatService>(context, listen: false);
    _usersForChattingPageBloc =
        UsersForChattingPageBloc(_userService, _chatService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("New chat"),
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.all(10),
              width: 20,
              height: 20,
              child: StreamBuilder(
                  stream: _usersForChattingPageBloc.progressIndicatorStream,
                  builder: (_, snapshot) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      setState(() {
                        isNotBusy = snapshot.hasData ? !snapshot.data : true;
                      });
                    });
                    return Visibility(
                      visible: snapshot.hasData ? snapshot.data : false,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        backgroundColor: Colors.blue.shade800,
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
      body: SafeArea(
        child:
            BlocListener<UsersForChattingPageBloc, UsersForChattingPageState>(
          bloc: _usersForChattingPageBloc,
          listener: (_, state) {
            if (state is NoInternet) {
              showSnackbar(_scaffoldKey, state.error);
            } else if (state is ChatAlreadyExists) {
              _changePage(ChatPage(
                chatId: state.chatId,
                currentUserId: widget.currentUserId,
              ));
            } else if (state is ChatSuccessfullyCreated) {
              _changePage(ChatPage(
                chatId: state.chatId,
                currentUserId: widget.currentUserId,
              ));
            }
          },
          child:
              BlocBuilder<UsersForChattingPageBloc, UsersForChattingPageState>(
            bloc: _usersForChattingPageBloc,
            builder: (_, state) {
              return _getListOfUsers();
            },
          ),
        ),
      ),
    );
  }

  _getListOfUsers() => StreamBuilder<QuerySnapshot>(
        stream: _usersForChattingPageBloc.getAvailableChatUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length > 0) {
              List<User> listOfAvailableParticipants = List<User>();
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                if (snapshot.data.documents[i].documentID !=
                    widget.currentUserId) {
                  listOfAvailableParticipants
                      .add(User.fromMap(snapshot.data.documents[i].data));
                  listOfAvailableParticipants[
                          listOfAvailableParticipants.length - 1]
                      .id = snapshot.data.documents[i].documentID;
                }
              }
              return _showUsersListView(listOfAvailableParticipants);
            } else
              return _showNoUsersLayout();
          } else
            return _showLoadingLayout();
        },
      );

  _showUsersListView(List<User> listOfAvailableParticipants) =>
      ListView.separated(
          itemBuilder: (context, i) =>
              _buildUserItem(listOfAvailableParticipants[i]),
          separatorBuilder: (context, index) => Divider(),
          itemCount: listOfAvailableParticipants.length);

  _buildUserItem(User u) => GestureDetector(
        onTap: () => isNotBusy ? _startChat(u.id) : null,
        child: Container(
          color: Colors.grey[100],
          child: ListTile(
            title: Text(
              u.username,
              style: Theme.of(context).textTheme.headline4.copyWith(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.navigate_next),
          ),
        ),
      );

  _startChat(String uid) {
    final Chat c = Chat(Timestamp.now(), [widget.currentUserId, uid]);
    _usersForChattingPageBloc.add(StartNewChat(widget.currentUserId, uid, c));
  }

  _showLoadingLayout() => Center(
        child: CircularProgressIndicator(),
      );

  _showNoUsersLayout() => Center(
        child: Text("No users found ;( \n Check your internet connection"),
      );

  _changePage(Widget page) =>
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        changePageWithReplacement(context, page);
      });
}
