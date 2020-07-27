import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterforum/bloc/chat_page/chat_page_bloc.dart';
import 'package:flutterforum/model/chat.dart';
import 'package:flutterforum/model/chat_message.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/services/chat_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatPage({Key key, @required this.chatId, @required this.currentUserId})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<DocumentSnapshot> _messagesSnapshots;
  ChatMessage lastMessage;
  bool _isLoading = false;
  bool areMoreMessagesAvailable = true;
  static const int LOAD_PER_PAGE = 15;
  int _loaded = LOAD_PER_PAGE;
  final TextEditingController _messageInput = TextEditingController();
  final FocusNode _messageInputFocus = FocusNode();

  Chat _chat;
  ChatService _chatService;
  UserService _userService;
  ChatPageBloc _chatPageBloc;
  StreamSubscription _chatSub;
  ScrollController _scrollController =
      ScrollController(); // for loading more messages
  StreamSubscription<QuerySnapshot> onChangeSubscription;

  @override
  void initState() {
    _chatService = Provider.of<ChatService>(context, listen: false);
    _userService = Provider.of<UserService>(context, listen: false);
    _chatPageBloc = ChatPageBloc(_chatService, _userService);

    // scroll down when user focuses message input
    _messageInputFocus.addListener(() {
      if (_messageInputFocus.hasFocus) if (_messagesSnapshots.length > 0)
        _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 400), curve: Curves.ease);
    });

    _initChat();
    loadToTrue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_messageInputFocus.hasFocus) {
          _messageInputFocus.unfocus();
          return false;
        } else
          return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: _chat != null ? _updateAppBarTitle() : Text(""),
        ),
        body: SafeArea(
          child: _buildPage(),
        ),
      ),
    );
  }

  _initChat() {
    _chatSub = _chatPageBloc.getChatById(widget.chatId).listen((event) {
      if (event.exists) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _chat = Chat.fromMap(event.data);
            _chat.id = event.documentID;
          });
        });
      } else
        Navigator.of(context).pop();
    });
    _chatSub.resume();
  }

  _buildPage() => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _isLoading
                      ? null
                      : _chatPageBloc.getMoreChatMessages(
                          widget.chatId, _loaded),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return _showLoadingLayout();
                    _messagesSnapshots = snapshot.data.documents;
                    if (_messagesSnapshots.length > 0) {
                      return _showMessagesLayout(_messagesSnapshots);
                    } else
                      return _showNoMessagesLayout();
                  }),
            ),
            Divider(
              color: Colors.black,
            ),
            _buildFooter()
          ],
        ),
      );

  _buildFooter() => Container(
        constraints: new BoxConstraints(
          minHeight: 40.0,
          maxHeight: 100.0,
        ),
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        //color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            Expanded(
                flex: 4,
                child: TextField(
                  controller: _messageInput,
                  focusNode: _messageInputFocus,
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(10.0),
                      fillColor: Colors.grey[100],
                      hintText: "Say something.."),
                )),
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () => _messageInput.value.text.trim().length > 0
                  ? _addMessage()
                  : null,
              icon: Icon(
                Icons.send,
                color: Colors.blue.shade800,
              ),
            )
          ],
        ),
      );

  _addMessage() {
    Timestamp sentAt = Timestamp.now();
    final ChatMessage message = ChatMessage(
        _messageInput.value.text.trim(), sentAt, widget.currentUserId);
    _chatPageBloc
        .updateLastChatMessageTime(widget.chatId, sentAt)
        .then((value) {});
    _chatPageBloc.addNewMessage(widget.chatId, message).then((value) {
      message.id = value.documentID;
      message.isSent = true;
      _chatPageBloc.markMessageAsSent(widget.chatId, message).then((value) {});
    });
    _messageInput.clear();
    if (_messagesSnapshots.length > 0)
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  _showMessagesLayout(List<DocumentSnapshot> snapshot) {
    _messagesSnapshots = snapshot;
    if (snapshot.isNotEmpty) {
      lastMessage = ChatMessage.fromMap(snapshot[0].data);
      lastMessage.id = snapshot[0].documentID;
    }
    return ListView.builder(
        controller: _scrollController,
        reverse: true,
        itemCount: _messagesSnapshots.length + 1,
        itemBuilder: (context, i) {
          if (i == _messagesSnapshots.length) {
            return areMoreMessagesAvailable
                ? _buildLoadMoreButton()
                : Container();
          } else {
            return _buildMessageItem(_messagesSnapshots[i]);
          }
        });
  }

  _buildLoadMoreButton() => FlatButton(
        onPressed: () => _loadMoreMessages(),
        child: Text("LOAD MORE"),
      );

  _buildMessageItem(DocumentSnapshot doc) {
    ChatMessage message = ChatMessage.fromMap(doc.data);
    message.id = doc.documentID;

    return message.sentBy == widget.currentUserId
        ? _buildMessageItemLayout(message: message, isMe: true)
        : _buildMessageItemLayout(message: message, isMe: false);
  }

  _buildMessageItemLayout(
          {@required ChatMessage message, @required bool isMe}) =>
      Container(
        margin: EdgeInsets.only(
            left: isMe ? 100 : 10, right: isMe ? 10 : 100, top: 10, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: StreamBuilder<DocumentSnapshot>(
                  stream: _chatPageBloc.streamFirestoreUser(message.sentBy),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.exists) {
                        User user = User.fromMap(snapshot.data.data);
                        return Text(
                          user.username,
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              .copyWith(color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      } else
                        return Text("");
                    } else
                      return Text("");
                  }),
            ),
            SizedBox(
              height: 3,
            ),
            Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isMe ? Colors.blue.shade800 : Colors.grey[100],
                ),
                child: Text(
                  message.content,
                  style: Theme.of(context).textTheme.headline4.copyWith(
                      color: isMe ? Colors.white : Colors.blue.shade800),
                ),
              ),
            ),
            message.sentBy == widget.currentUserId && !message.isSent
                ? Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Icon(
                      Icons.signal_cellular_connected_no_internet_4_bar,
                      color: Colors.red,
                      size: 11,
                    ),
                  )
                : Container(),
          ],
        ),
      );

  _showLoadingLayout() => Center(
        child: CircularProgressIndicator(),
      );

  _showNoMessagesLayout() => Center(
        child: Text("No messages yet"),
      );

  _updateAppBarTitle() => FutureBuilder(
      future: _initChatParticipantsAsString(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data);
        } else
          return Text("");
      });

  Future<String> _initChatParticipantsAsString() async {
    String part = "";
    List<String> listOfPartId =
        List<String>(); // list of participants without current user
    for (int i = 0; i < _chat.participants.length; i++) {
      if (_chat.participants[i] != widget.currentUserId)
        listOfPartId.add(_chat.participants[i]);
    }

    for (int i = 0; i < listOfPartId.length; i++) {
      if (listOfPartId[i] != widget.currentUserId) {
        DocumentSnapshot doc =
            await _chatPageBloc.getFirestoreUser(listOfPartId[i]);
        if (doc.exists) {
          User user = User.fromMap(doc.data);
          part = part + user.username.toString();
          if (i < listOfPartId.length - 1) part = part + ", ";
        }
      }
    }
    return part;
  }

  _loadMoreMessages() {
    final message = ChatMessage.fromMap(
        _messagesSnapshots[_messagesSnapshots.length - 1].data);
    message.id = _messagesSnapshots[_messagesSnapshots.length - 1].documentID;
    // Query old messages
    _chatPageBloc
        .getPreviousChatMessages(widget.chatId, message.sentAt, LOAD_PER_PAGE)
        .then((snapshot) {
      setState(() {
        if (snapshot.documents.length == 0) areMoreMessagesAvailable = false;
        _loaded += snapshot.documents.length;
        loadToTrue();
        // And add to the list
        _messagesSnapshots.addAll(snapshot.documents);
      });
    });
    // For debug purposes
//      key.currentState.showSnackBar(new SnackBar(
//        content: new Text("Top reached"),
//      ));
  }

  loadToTrue() {
    _isLoading = true;
    if (onChangeSubscription != null) onChangeSubscription.cancel();
    onChangeSubscription = _chatPageBloc
        .checkForChatMessageUpdates(widget.chatId)
        .listen((onData) {
      if (onData.documents.length > 0) {
        if (onData.documents[0].exists) {
          ChatMessage result = ChatMessage.fromMap(onData.documents[0].data);
          result.id = onData.documents[0].documentID;
          // Here i check if last array message is the last of the FireStore DB
          if (lastMessage == null) {
            setState(() {
              _isLoading = false;
            });
          } else {
            bool equal = lastMessage.id == result.id;
            if (equal) {
              setState(() {
                _isLoading = false;
              });
            } else
              setState(() {
                _loaded += 1;
              });
          }
        }
      } else {
        _loaded = LOAD_PER_PAGE;
        setState(() {
          _isLoading = false;
        });
      }
    });
    onChangeSubscription.resume();
  }

  @override
  void dispose() {
    _chatSub.cancel();
    if (onChangeSubscription != null) onChangeSubscription.cancel();
    super.dispose();
  }
}
