import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterforum/bloc/post_detail_page/post_detail_page_bloc.dart';
import 'package:flutterforum/model/category.dart';
import 'package:flutterforum/model/comment.dart';
import 'package:flutterforum/model/post.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/services/comment_service.dart';
import 'package:flutterforum/services/post_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PostDetailPage extends StatefulWidget {
  final Category category;
  final String postId;
  final String currentUserId;

  const PostDetailPage(
      {Key key,
      @required this.category,
      @required this.postId,
      @required this.currentUserId})
      : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Post _post;
  User _postAuthor;
  List<Comment> listOfComments = List<Comment>();
  bool likeInProcess = false;
  String appBarTitlePrefix;
  String appBarTitle = "";
  TextEditingController _commentInput = TextEditingController();
  FocusNode _commentInputFocus = FocusNode();
  ItemScrollController _pageScrollController = ItemScrollController();

  bool isCommentRecentlyAdded = false;
  String recentlyAddedCommentId;

  PostService _postService;
  UserService _userService;
  CommentService _commentService;

  PostDetailPageBloc _postDetailPageBloc;

  @override
  void initState() {
    appBarTitlePrefix = "${widget.category.name} / ";
    appBarTitle = appBarTitlePrefix;

    _postService = Provider.of<PostService>(context, listen: false);
    _userService = Provider.of<UserService>(context, listen: false);
    _commentService = Provider.of<CommentService>(context, listen: false);
    _postDetailPageBloc =
        PostDetailPageBloc(_postService, _userService, _commentService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: SafeArea(
        child: _buildPage(),
      ),
    );
  }

  _buildPage() => StreamBuilder<DocumentSnapshot>(
        stream: _postDetailPageBloc.getPostById(widget.postId),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.exists) {
              _post = Post.fromMap(snapshot.data.data);
              _post.id = snapshot.data.documentID;
              _updateAppBarTitle();
              return _buildPostPage();
            } else
              return _showNoPostLayout();
          } else
            return _showLoadingLayout();
        },
      );

  _updateAppBarTitle() =>
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          appBarTitle = appBarTitlePrefix + _post.title;
        });
      });

  _getPostOwnerAsFirestoreUser() => StreamBuilder<DocumentSnapshot>(
      stream: _postDetailPageBloc.streamFirestoreUser(_post.ownerId),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.exists) {
            User user = User.fromMap(snapshot.data.data);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setState(() {
                _postAuthor = user;
                _postAuthor.id = snapshot.data.documentID;
              });
            });
            return Text(
              user.username,
              style: Theme.of(context).textTheme.headline4.copyWith(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }
        }
        return Text("");
      });

  _getPostComments() => StreamBuilder<QuerySnapshot>(
        stream: _postDetailPageBloc.getCommentsOfPost(_post.id),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setState(() {
                listOfComments = List<Comment>();
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  listOfComments
                      .add(Comment.fromMap(snapshot.data.documents[i].data));
                  listOfComments[i].id = snapshot.data.documents[i].documentID;
                  if (isCommentRecentlyAdded &&
                      listOfComments[i].id == recentlyAddedCommentId) {
                    isCommentRecentlyAdded = false;
                    _pageScrollController.scrollTo(
                        index: i,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.ease);
                  }
                }
              });
            });
          }
          return _buildCommentsNumber();
        },
      );

  _buildPostPage() => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: _buildPostPageLayout(),
            ),
            Container(
              constraints: new BoxConstraints(
                minHeight: 50.0,
                maxHeight: 100.0,
              ),
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _commentInput,
                        focusNode: _commentInputFocus,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            fillColor: Colors.grey[100],
                            hintText: "What do you think?"),
                      )),
                  IconButton(
                    onPressed: () => _commentInput.value.text.length > 0
                        ? _addComment()
                        : null,
                    icon: Icon(
                      Icons.send,
                      color: Colors.grey[100],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  _buildPostPageLayout() => listOfComments.length > 0
      ? ScrollablePositionedList.builder(
          itemScrollController: _pageScrollController,
          itemCount: listOfComments.length + 1,
          itemBuilder: (context, index) {
            if (index == 0)
              return _buildPostWithCommentsNumber();
            else {
              return _buildCommentLayout(listOfComments[index - 1]);
            }
          })
      : SingleChildScrollView(
          child: Column(
            children: [
              _buildPostWithCommentsNumber(),
              SizedBox(
                height: 20,
              ),
              Text("Be first who commented!")
            ],
          ),
        );

  _buildPostWithCommentsNumber() => Column(children: [
        _buildPostLayout(),
        Divider(),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Comments (${listOfComments.length})",
                style: Theme.of(context).textTheme.subtitle1,
              )),
        ),
      ]);

  _addComment() {
    Comment c = Comment(
        widget.currentUserId,
        _post.id,
        _commentInput.value.text.trim(),
        Timestamp.now(),
        false,
        Timestamp.now());
    FocusScope.of(context).unfocus();
    _commentInput.clear();

    // adding comment to the list to make sure than list is not empty (for scrolling)
    _commentService.addNewComment(c).then((value) {
      recentlyAddedCommentId = value.documentID;
      isCommentRecentlyAdded = true;
    });
  }

  _buildPostLayout() => Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _getPostOwnerAsFirestoreUser(),
            SizedBox(
              height: 5,
            ),
            Text(
              _post.title,
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 3,
            ),
            Divider(),
            SizedBox(
              height: 5,
            ),
            Text(
              _post.content,
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.grey.shade900),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Created at: " +
                    DateFormat.yMEd().add_jms().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            _post.createdAt.millisecondsSinceEpoch)),
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.grey.shade900, fontSize: 13),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Last update: " +
                    DateFormat.yMEd().add_jms().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            _post.updatedAt.millisecondsSinceEpoch)),
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.grey.shade900, fontSize: 13),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                _buildLikesNumber(),
                SizedBox(
                  width: 10,
                ),
                _getPostComments()
                // builds number of comments if any comments exists
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: _buildLikeButton(),
                ),
                Expanded(
                  child: _buildCommentButton(),
                )
              ],
            )
          ],
        ),
      );

  _buildCommentLayout(Comment c) => Container(
        margin: EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.grey.shade200),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: StreamBuilder<DocumentSnapshot>(
                stream: _postDetailPageBloc.streamFirestoreUser(c.ownerId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) if (snapshot.data.exists) {
                    User user = User.fromMap(snapshot.data.data);
                    return Text(
                      user.username,
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return Text(
                    "",
                    style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              subtitle: Text(c.content,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.black, fontSize: 13.5)),
              isThreeLine: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat.yMEd().add_jms().format(
                    DateTime.fromMillisecondsSinceEpoch(
                        c.createdAt.millisecondsSinceEpoch)),
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.grey.shade900, fontSize: 13),
              ),
            ),
            c.ownerId == widget.currentUserId
                ? Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _commentService.deleteCommentById(c.id),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.delete,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      );

  _hasUserLiked() => _post.listOfLikedBy.contains(widget.currentUserId);

  _buildLikeButton() {
    Color color = _hasUserLiked() ? Colors.blue.shade800 : Colors.black;
    return FlatButton(
      onPressed: () => !likeInProcess ? _doLikeOrUnlikeAction() : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.thumb_up,
            size: 18,
            color: color,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            _hasUserLiked() ? "Unlike" : "Like",
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: color, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  _doLikeOrUnlikeAction() async {
    likeInProcess = true;
    if (_hasUserLiked())
      _post.listOfLikedBy.remove(widget.currentUserId);
    else
      _post.listOfLikedBy.add(widget.currentUserId);
    _postDetailPageBloc
        .updateLikedList(_post.id, _post.listOfLikedBy)
        .then((value) {});
    likeInProcess = false;
  }

  _buildCommentsNumber() => listOfComments.length > 0
      ? Row(
          children: [
            Icon(
              Icons.mode_comment,
              size: 13,
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              listOfComments.length.toString(),
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.grey.shade900, fontSize: 13),
            )
          ],
        )
      : Container();

  _buildLikesNumber() => _post.listOfLikedBy.length > 0
      ? Row(
          children: [
            Icon(
              Icons.thumb_up,
              size: 13,
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              _post.listOfLikedBy.length.toString(),
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.grey.shade900, fontSize: 13),
            ),
          ],
        )
      : Text("Be first who likes it!");

  bool _isUserCommented() {
    for (Comment c in listOfComments)
      if (c.ownerId == widget.currentUserId) return true;
    return false;
  }

  _buildCommentButton() {
    Color color = _isUserCommented() ? Colors.blue.shade800 : Colors.black;
    return FlatButton(
      onPressed: () => FocusScope.of(context).requestFocus(_commentInputFocus),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mode_comment,
            size: 18,
            color: color,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Comment",
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: color, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  _showLoadingLayout() => Center(
        child: CircularProgressIndicator(),
      );

  _showNoPostLayout() => Center(
        child: Text("Post not found ;("),
      );
}
