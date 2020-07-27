import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterforum/bloc/user_chats_page/user_chats_page_bloc.dart';
import 'package:flutterforum/model/chat.dart';
import 'package:flutterforum/model/chat_message.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/pages/authenticated/chat_page.dart';
import 'package:flutterforum/pages/authenticated/users_for_chatting_page.dart';
import 'package:flutterforum/services/chat_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:provider/provider.dart';

class UserChatsPage extends StatefulWidget {
  final String currentUserId;

  const UserChatsPage({Key key, @required this.currentUserId})
      : super(key: key);

  @override
  _UserChatsPageState createState() => _UserChatsPageState();
}

class _UserChatsPageState extends State<UserChatsPage> {
  ChatService _chatService;
  UserService _userService;
  List<Chat> listOfUserChats = List<Chat>();
  UserChatsPageBloc _userChatsPageBloc;
  StreamSubscription _userChatsSub;

  @override
  void initState() {
    _chatService = Provider.of<ChatService>(context, listen: false);
    _userService = Provider.of<UserService>(context, listen: false);
    _userChatsPageBloc = UserChatsPageBloc(_chatService, _userService);

    // Getting Chats as a subscription
    _userChatsSub =
        _userChatsPageBloc.getUserChats(widget.currentUserId).listen((event) {
      List<Chat> list = List<Chat>();
      for (int i = 0; i < event.documents.length; i++) {
        list.add(Chat.fromMap(event.documents[i].data));
        list[i].id = event.documents[i].documentID;
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          listOfUserChats = list;
        });
      });
    });
    // starting
    _userChatsSub.resume();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          IconButton(
            onPressed: () => _startChatting(),
            icon: Icon(Icons.add_circle_outline),
          )
        ],
      ),
      body: SafeArea(
        child: _buildUserChatsListView(listOfUserChats),
      ),
    );
  }

  _buildUserChatsListView(List<Chat> loadedList) => FutureBuilder(
        future: _buildChatsListViewWidgets(loadedList),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.length > 0) {
              return ListView(
                children: snapshot.data,
              );
            } else
              return _emptyListLayout();
          } else
            return _showLoadingLayout();
        },
      );

  Future<List<Widget>> _buildChatsListViewWidgets(List<Chat> list) async {
    List<Widget> listOfUserChatsAsWidgets = List<Widget>();

    for (int i = 0; i < list.length; i++) {
      String participants = await _initChatParticipantsAsString(list[i]);
      listOfUserChatsAsWidgets.add(_buildChatItem(list[i], participants));
    }

    return listOfUserChatsAsWidgets;
  }

  _buildChatItem(Chat c, String participants) => GestureDetector(
        onTap: () => _openChat(c),
        child: Column(
          children: [
            Container(
              color: Colors.grey[100],
              child: ListTile(
                title: Text(
                  participants,
                  style: Theme.of(context).textTheme.headline4.copyWith(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: StreamBuilder<QuerySnapshot>(
                    stream: _userChatsPageBloc.getLastChatMessage(c.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length > 0) {
                          ChatMessage message = ChatMessage.fromMap(
                              snapshot.data.documents[0].data);
                          message.id = snapshot.data.documents[0].documentID;

                          if (widget.currentUserId == message.sentBy) {
                            return Row(
                              children: [
                                Text("You: "),
                                Expanded(
                                  child: Text(
                                    message.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            );
                          } else
                            return Text(message.content,
                                maxLines: 1, overflow: TextOverflow.ellipsis);
                        } else
                          return Text("");
                      } else
                        return Text("");
                    }),
              ),
            ),
            Divider()
          ],
        ),
      );

  _openChat(Chat c) => Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => ChatPage(
            chatId: c.id,
            currentUserId: widget.currentUserId,
          )));

  Future<String> _initChatParticipantsAsString(Chat c) async {
    String part = "";
    List<String> listOfPartId =
        List<String>(); // list of participants without current user
    for (int i = 0; i < c.participants.length; i++) {
      if (c.participants[i] != widget.currentUserId)
        listOfPartId.add(c.participants[i]);
    }

    for (int i = 0; i < listOfPartId.length; i++) {
      if (listOfPartId[i] != widget.currentUserId) {
        DocumentSnapshot doc =
            await _userChatsPageBloc.getFirestoreUser(listOfPartId[i]);
        if (doc.exists) {
          User user = User.fromMap(doc.data);
          part = part + user.username.toString();
          if (i < listOfPartId.length - 1) part = part + ", ";
        }
      }
    }
    return part;
  }

  _startChatting() => Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => UsersForChattingPage(
            currentUserId: widget.currentUserId,
          )));

  _emptyListLayout() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("You don't have any chats!"),
            SizedBox(
              height: 15,
            ),
            FlatButton(
              color: Colors.blue.shade800,
              onPressed: () => print("clicked start now"),
              child: Text(
                "Chat now",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      );

  _showLoadingLayout() => Center(
        child: CircularProgressIndicator(),
      );

  @override
  void dispose() {
    _userChatsSub.cancel();
    super.dispose();
  }
}
