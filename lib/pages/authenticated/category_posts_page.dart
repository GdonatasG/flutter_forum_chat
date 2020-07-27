import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterforum/bloc/posts_page/posts_page_bloc.dart';
import 'package:flutterforum/model/category.dart';
import 'package:flutterforum/model/comment.dart';
import 'package:flutterforum/model/post.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/pages/authenticated/add_post_page.dart';
import 'package:flutterforum/pages/authenticated/post_detail_page.dart';
import 'package:flutterforum/services/comment_service.dart';
import 'package:flutterforum/services/post_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CategoryPostsPage extends StatefulWidget {
  final FirebaseUser user;
  final Category category;

  const CategoryPostsPage(
      {Key key, @required this.category, @required this.user})
      : super(key: key);

  @override
  _CategoryPostsPageState createState() => _CategoryPostsPageState();
}

class _CategoryPostsPageState extends State<CategoryPostsPage> {
  PostsPageBloc _postsPageBloc;
  PostService _postService;
  CommentService _commentService;
  UserService _userService;
  List<Post> _listOfPosts;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _postService = Provider.of<PostService>(context, listen: false);
    _userService = Provider.of<UserService>(context, listen: false);
    _commentService = Provider.of<CommentService>(context, listen: false);
    _postsPageBloc = PostsPageBloc(_postService, _userService, _commentService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            onPressed: () => _moveToAddPostPage(),
            icon: Icon(Icons.add_circle_outline),
          )
        ],
      ),
      body: SafeArea(
        child: _buildPosts(),
      ),
    );
  }

  _buildPosts() => StreamBuilder<QuerySnapshot>(
        stream: _postsPageBloc.getCategoryPosts(widget.category.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length > 0) {
              _listOfPosts = List<Post>();
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                _listOfPosts.add(Post.fromMap(snapshot.data.documents[i].data));
                _listOfPosts[_listOfPosts.length - 1].id =
                    snapshot.data.documents[i].documentID;
              }
              return _buildPostsLayout();
            } else {
              _listOfPosts = List<Post>();
              return _buildEmptyListLayout();
            }
          } else
            return _showLoadingLayout();
        },
      );

  _buildPostsLayout() => ListView.builder(
      itemCount: _listOfPosts.length,
      itemBuilder: (context, i) {
        return _buildPostItem(_listOfPosts[i]);
      });

  _buildPostItem(Post post) => GestureDetector(
        onTap: () => _moveToPostDetailPage(post.id),
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: _postsPageBloc.streamFirestoreUser(post.ownerId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.exists) {
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
                    } else
                      return Text("");
                  } else
                    return Container();
                },
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                post.title,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                post.content,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.grey.shade900),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat.yMEd().add_jms().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            post.createdAt.millisecondsSinceEpoch)),
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.grey.shade900, fontSize: 13),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  post.listOfLikedBy.contains(widget.user.uid)
                      ? Icon(
                          Icons.thumb_up,
                          color: Colors.blue.shade800,
                          size: 13,
                        )
                      : Icon(
                          Icons.thumb_up,
                          size: 13,
                        ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    post.listOfLikedBy.length.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _postsPageBloc.getCommentsOfPost(post.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Comment> listOfComments = List<Comment>();
                        for (int i = 0;
                            i < snapshot.data.documents.length;
                            i++) {
                          listOfComments.add(
                              Comment.fromMap(snapshot.data.documents[i].data));
                        }
                        return _buildCommentsNumber(listOfComments);
                      } else
                        // just passing an empty list, because of no data from snapshot
                        return _buildCommentsNumber(List<Comment>());
                    },
                  )
                ],
              )
            ],
          ),
        ),
      );

  _moveToPostDetailPage(String postId) =>
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => PostDetailPage(
                currentUserId: widget.user.uid,
                category: widget.category,
                postId: postId,
              )));

  bool _isUserCommented(List<Comment> listOfComments) {
    for (Comment c in listOfComments)
      if (c.ownerId == widget.user.uid) return true;
    return false;
  }

  _buildCommentsNumber(List<Comment> listOfComments) => Row(
        children: [
          _isUserCommented(listOfComments)
              ? Icon(
                  Icons.mode_comment,
                  size: 13,
                  color: Colors.blue.shade800,
                )
              : Icon(
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
      );

  _buildEmptyListLayout() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No posts in category ${widget.category.name}"),
            SizedBox(
              height: 15,
            ),
            FlatButton(
              color: Colors.blue.shade800,
              onPressed: () => _moveToAddPostPage(),
              child: Text(
                "Post now",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      );

  _moveToAddPostPage() => Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) => AddPostPage(
                  currentUserId: widget.user.uid,
                  category: widget.category,
                ),
            fullscreenDialog: true),
      );

  _showLoadingLayout() => Center(
        child: CircularProgressIndicator(),
      );
}
