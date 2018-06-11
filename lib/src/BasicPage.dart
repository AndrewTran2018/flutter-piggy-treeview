import 'package:flutter/material.dart';
import 'package:piggy/common/Global.dart';

typedef dynamic ActionCallBack(dynamic inputParam);

enum ActionTypes { search, delete, manage, expandAll, collapseAll }

class BasicPage extends StatefulWidget {
  final String _title;
  bool _isLoading = false;
  bool _appBar;
  bool _enableFAB;
  bool _enableExpanCollap;
  bool _enableDelete;
  bool _enableSearch;
  List<ActionTypes> _actions;

  VoidCallback onFABressed;
  VoidCallback onSearch;
  VoidCallback onDelete;
  VoidCallback onManage;
  VoidCallback onExpandAll = null;
  VoidCallback onCollapseAll = null;

  // Properties
  String get title => _title;
  bool get isLoading => _isLoading;
  void set isLoading(bool value) => _isLoading = value;

  bool get enableFAB => _enableFAB;
  void set enableFAB(bool value) => _enableFAB = value;

  bool get enableExpandCollap => _enableExpanCollap;
  void set enableExpandCollap(bool value) => _enableExpanCollap = value;

  bool get enableSearch => _enableSearch;
  void set enableSearch(bool value) => _enableSearch = value;

  bool get enableDelete => _enableDelete;
  void set enableDelete(bool value) => _enableDelete = value;

  BasicPage(this._title,
      {Key key,
      List<ActionTypes> actions,
      appBar = false,
      enableFAB = true,
      enableExpanCollap = false,
      enableSearch = true,
      enableDelete = false})
      : super(key: key) {
    _enableFAB = enableFAB;
    _appBar = appBar;
    _actions = actions;
    _enableExpanCollap = enableExpanCollap;
    _enableDelete = enableDelete;
    _enableSearch = enableSearch;
  }

  @override
  State createState() => new BasicPageState();
}

class BasicPageState extends State<BasicPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Utils
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  List<Widget> _buildActions() {
    List<Widget> lstActions = [];
    int nIndex = 0;
    if (widget._actions != null)
      for (ActionTypes action in widget._actions) {
        if (action == ActionTypes.delete)
          lstActions.add(new IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: widget.enableDelete ? widget.onDelete : null,
          ));
        else if (action == ActionTypes.search)
          lstActions.add(new IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: widget.enableSearch ? widget.onSearch : null));
        else if (action == ActionTypes.manage)
          lstActions.add(new IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Manage people',
              onPressed: widget.onManage));
        else if ((action == ActionTypes.expandAll ||
                action == ActionTypes.collapseAll) &&
            nIndex == 0) {
          lstActions.add(new PopupMenuButton<ActionTypes>(
              itemBuilder: (BuildContext context) =>
                  <PopupMenuItem<ActionTypes>>[
                    new PopupMenuItem<ActionTypes>(
                        enabled: widget.enableExpandCollap,
                        value: ActionTypes.expandAll,
                        child: const Text('Expand all')),
                    new PopupMenuItem<ActionTypes>(
                        enabled: widget.enableExpandCollap,
                        value: ActionTypes.collapseAll,
                        child: const Text('Collapse all'))
                  ],
              onSelected: (ActionTypes doIt) {
                switch (doIt) {
                  case ActionTypes.collapseAll:
                    if (widget.onCollapseAll != null) widget.onCollapseAll();
                    break;
                  case ActionTypes.expandAll:
                    if (widget.onExpandAll != null) widget.onExpandAll();
                    break;
                  default:
                    break;
                }
              }));
          nIndex++;
        }
      }
    return lstActions;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = buildContent(context);

    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.subhead.copyWith(
        fontStyle: FontStyle.italic, color: theme.textTheme.caption.color);

    Widget loadingIndicatior = widget.isLoading
        ? new Column(
            children: <Widget>[
              const LinearProgressIndicator(),
              new Text("Wait for a moment...", style: titleStyle)
            ],
          )
        : new Container();

    Widget stack = new SizedBox.expand(
        child: new Stack(
      children: <Widget>[
        new Positioned.fill(child: content),
        new Positioned(
            bottom: Constants.VIEW_PADDING * 1.5,
            left: Constants.VIEW_PADDING * 5.2,
            right: Constants.VIEW_PADDING * 5.2,
            child: loadingIndicatior)
      ],
    ));

    Widget wrapperContainer;
    wrapperContainer = new Scaffold(
        appBar: widget._appBar
            ? new AppBar(
                title: new Text(widget.title), actions: _buildActions())
            : null,
        key: _scaffoldKey,
        floatingActionButton: widget._enableFAB
            ? new FloatingActionButton(
                onPressed: widget.onFABressed, child: const Icon(Icons.add))
            : null,
        body: new Container(child: stack));

    return wrapperContainer;
  }

  Widget buildContent(BuildContext context) {
    return null;
  }
}
