import 'package:flutter/cupertino.dart';

class CachingFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function() futureFactory;
  final AsyncWidgetBuilder<T> builder;

  const CachingFutureBuilder(
      {Key key, @required this.futureFactory, @required this.builder})
      : super(key: key);
  @override
  _CachingFutureBuilderState createState() => _CachingFutureBuilderState<T>();
}

class _CachingFutureBuilderState<T> extends State<CachingFutureBuilder<T>> {
  Future<T> _future;

  @override
  void initState() {
    _future = widget.futureFactory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: widget.builder,
    );
  }
}
