library piggy_treeview;

import 'package:flutter/material.dart';
import './CustomExpansionTile.dart';
import './CustomListTile.dart';
import './Global.dart';

typedef void NodeCallback<T>(T node);
typedef void EditNodeCallback<T>(T node);
typedef void ManageCallback<T>(T node);

///
///  T: any data passed to the node
///

class TreeNodeData<T> {
  T _data;
  Widget _bindedWidget;

  String _id;
  String _title;
  String _subtitle;

  TreeNodeData<T> _parent;
  List<TreeNodeData<T>> _children = [];

  bool _hidden;
  bool _expanded;
  bool _checked;
  bool _hilited;

  // Constructors
  TreeNodeData();

  TreeNodeData.root(this._title, this._subtitle, this._id,
      [this._data,
      this._checked = false,
      this._expanded = true,
      this._hidden = false,
      this._hilited = false]) {
    _checkInit();
  }

  TreeNodeData.node(this._parent, this._title, this._subtitle, this._id,
      [this._data,
      this._checked = false,
      this._expanded = false,
      this._hidden = false,
      this._hilited = false]) {
    _checkInit();
    _parent._children.add(this);
  }

  void _checkInit() {
    if (this._checked == null) this._checked = false;
    if (this._expanded == null) this._expanded = false;
    if (this._hidden == null) this._hidden = false;
    if (this._hilited == null) this._hilited = false;
  }

  // Properties
  T get data => _data;

  set data(T nodeData) => _data = nodeData;

  String get id => _id;

  String get title => _title;

  String get subTitle => _subtitle;

  bool get isRoot => _parent == null;

  bool get isLeaf => !hasChildren;

  bool get hasChildren => _children.isNotEmpty;

  bool get isExpanded => _expanded;

  bool get isChecked => _checked;

  bool get isHidden => _hidden;

  bool get isHilited => _hilited;

  set checked(bool checked) => _checked = checked;

  set expanded(bool expanded) => _expanded = expanded;

  set hidden(bool hidden) => _hidden = hidden;

  set hilited(bool hilite) => _hilited = hilite;

  set bindedWidget(Widget widget) => _bindedWidget = widget;

  List<TreeNodeData<T>> get children => _children;

  TreeNodeData<T> get parent => _parent;

  Widget get bindedWidget => _bindedWidget;

  // Methods
  TreeNodeData<T> getNodeByID(String id) {
    if (this.id == id) return this;

    for (var node in _children) {
      var found = node.getNodeByID(id);
      if (found != null) return found;
    }

    return null;
  }

  List<TreeNodeData<T>> getAllSubNodes([bool addThisNode = true]) {
    List<TreeNodeData<T>> all = [];

    if (addThisNode) all.add(this);

    _addAllSubNodes(all);

    return all;
  }

  void _addAllSubNodes(List<TreeNodeData<T>> all) {
    for (var node in _children) {
      all.add(node);
      node._addAllSubNodes(all);
    }
  }

  TreeNodeData<T> getRoot() {
    TreeNodeData<T> cursor = this;
    do {
      if (cursor.isRoot) return cursor;
      cursor = cursor.parent;
    } while (cursor != null);

    throw new StateError("Invalid tree structure.");
  }

  TreeNodeData<T> createChild(String title, String subTitle, String id, T data,
      [bool expanded = false]) {
    var child =
        new TreeNodeData.node(this, title, subTitle, id, data, expanded);
    return child;
  }

  String toString() =>
      "title: id=${title} id:${id} subTittle:${subTitle} isExpanded:${isExpanded} checked: $isChecked";
}

class TreeNode extends StatefulWidget {
  TreeView _treeComponent;
  TreeNodeData _nodeData;
  NodeCallback onSelectNode;
  NodeCallback onHiliteNode;
  EditNodeCallback onEditNode;
  ManageCallback onManage;
  // Constructor
  TreeNode(this._treeComponent, this._nodeData, {Key key}) : super(key: key);
  TreeNodeState _state;

  void toggle(bool bExpand) => _state?.toggle(bExpand);

  void broadcast(Map<String, TreeNodeData> map) => _state?.broadcast(map);

  void openIt() => _state?.openIt();

  @override
  TreeNodeState createState() {
    _state = new TreeNodeState();
    return _state;
  }
}

class TreeNodeState extends State<TreeNode> {
  CustomExpansionTile _wExpand;
  List<TreeNode> _lstNodes;

  void openIt() {
    _wExpand?.toggle(true);
  }

  void toggle(bool bExpand) {
    _wExpand?.toggle(bExpand);
    if (_lstNodes != null)
      for (TreeNode node in _lstNodes) {
        node?.toggle(bExpand);
      }
  }

  void broadcast(Map<String, TreeNodeData> map) {
    TreeNodeData tempNode = map[widget._nodeData.id];
    if (tempNode != null && mounted)
      setState(() => widget._nodeData.hilited = tempNode.isHilited);
    _lstNodes?.forEach((node) => node.broadcast(map));
  }

  @override
  void initState() {
    super.initState();
    _lstNodes = widget._nodeData.hasChildren
        ? widget._nodeData.children.map((TreeNodeData subNode) {
            TreeNode treeNode = new TreeNode(widget._treeComponent, subNode,
                key: new Key(subNode.id));
            treeNode.onSelectNode = widget.onSelectNode;
            treeNode.onEditNode = widget.onEditNode;
            treeNode.onManage = widget.onManage;
            treeNode.onHiliteNode = widget.onHiliteNode;
            // Make sure to store a reference to the associated widget
            subNode.bindedWidget = treeNode;
            return treeNode;
          }).toList()
        : null;
  }

  @override
  void dispose() {
    super.dispose();
    _wExpand = null;
    _lstNodes?.clear();
    _lstNodes = null;
  }

  @override
  Widget build(BuildContext context) {
    return _buildNode();
  }

  Widget _buildNode() {
    var currentNode = widget._nodeData;
    if (currentNode.isLeaf) {
      return buildNormalNode(currentNode);
    } else {
      return buildExpandedNode(currentNode);
    }
  }

  // Handlers
  void selectNodes(TreeNodeData currentNode, bool value) {
    currentNode.checked = value;

    if (widget.onSelectNode != null) widget.onSelectNode(currentNode);

    if (currentNode.hasChildren) {
      for (var node in currentNode.children) {
        selectNodes(node, value);
      }
    }
  }

  /// The subclass has to override the two methods below to display a node
  Widget buildNormalNode(TreeNodeData currentNode) {
    return new Container(
        padding: new EdgeInsets.only(left: Constants.LIST_ITEM_INDENT),
        child: new CustomListTile(
          key: new Key(currentNode.id),
          leading: new Checkbox(
              value: currentNode.isChecked,
              onChanged: (bool value) {
                setState(() => currentNode.checked = value);
                if (widget.onSelectNode != null)
                  widget.onSelectNode(currentNode);
              }),
          title: new Text(
            currentNode.title,
          ),
          subtitle: new Text(currentNode.subTitle),
          selected: currentNode.isHilited,
          onTap: () {
            setState(() => currentNode.hilited = !currentNode.isHilited);
            if (widget.onHiliteNode != null) widget.onHiliteNode(currentNode);
          },
          onLongPress: () {
            setState(() {
              if (widget.onEditNode != null) widget.onEditNode(currentNode);
            });
          },
        ));
  }

  Widget buildExpandedNode(TreeNodeData currentNode) {
    _wExpand = new CustomExpansionTile(
        initiallyExpanded:
            currentNode.parent == null ? true : currentNode.isExpanded,
        onExpansionChanged: (bool value) {
          currentNode.expanded = value;
        },
        key: new Key(currentNode.id)),
        title: new CustomListTile(
          key: new Key(currentNode.id),
          leading: new Checkbox(
              value: currentNode.isChecked,
              onChanged: (bool value) {
                setState(() {
                  selectNodes(currentNode, value);
                });
              }),
          title: new Text(currentNode.title),
          subtitle: new Text(currentNode.subTitle),
          selected: currentNode.isHilited,
          onTap: () {
            if (mounted) {
              setState(() => currentNode.hilited = !currentNode.isHilited);
              if (widget.onHiliteNode != null) widget.onHiliteNode(currentNode);
            }
          },
          onLongPress: () {
            setState(() {
              if (widget.onEditNode != null) widget.onEditNode(currentNode);
            });
          },
        ),
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.015),
        children: [
          new Container(
              padding:
                  new EdgeInsets.only(left: Constants.LIST_ITEM_INDENT * 2),
              child: new Column(
                  mainAxisSize: MainAxisSize.min, children: _lstNodes))
        ]);
    return _wExpand;
  }
}

class TreeView extends StatefulWidget {
  List<TreeNodeData> _roots;
  Widget _header;

  NodeCallback onSelectNode;
  NodeCallback onHiliteNode;
  EditNodeCallback onEditNode;
  ManageCallback onManage;

  // Constructors
  TreeView(TreeNodeData roots) {
    _roots = [roots];
  }

  TreeView.multipleRoots(this._roots, {Widget header}) {
    _header = header;
  }

  // Methods
  TreeNodeData getNodeByID(String id) {
    for (var root in _roots) {
      var found = root.getNodeByID(id);
      if (found != null) return found;
    }
    return null;
  }

  TreeViewState _state;

  void toggle(bool bExpand) => _state?.toggle(bExpand);

  void broadcast(Map<String, TreeNodeData> map) => _state?.broadcast(map);

  void expandOnTo(Map<String, TreeNodeData> map) => _state?.expandOnTo(map);

  // Overrides
  @override
  TreeViewState createState() {
    _state = new TreeViewState();
    return _state;
  }
}

class TreeViewState extends State<TreeView> {
  List<TreeNode> _lstNodes;

  void toggle(bool bExpand) {
    for (TreeNode node in _lstNodes) {
      node?.toggle(bExpand);
    }
  }

  void broadcast(Map<String, TreeNodeData> map) {
    _lstNodes?.forEach((node) {
      TreeNodeData tempNode = map[node._nodeData.id];
      if (tempNode != null)
        setState(() => node._nodeData.hilited = tempNode.isHilited);
      node.broadcast(map);
    });
  }

  void expandOnTo(Map<String, TreeNodeData> map) {
    _openIt(TreeNodeData node) {
      // Try to expand the tree to this node
      TreeNodeData parent = node.parent;
      StackEmul<TreeNode> stackWidget = new StackEmul();
      while (parent != null) {
        TreeNode parentWidget = parent.bindedWidget as TreeNode;
        assert(parentWidget != null);
        stackWidget.push(parentWidget);
        parent = parent.parent;
      }
      // Now expand the tree the top-down way
      TreeNode openWidget = stackWidget.pop();
      while (openWidget != null) {
        openWidget.openIt();
        openWidget = stackWidget.pop();
      }
    }

    map.forEach((key, node) {
      _openIt(node);
      node.hilited = true;
    });
    broadcast(map);
  }

  @override
  void initState() {
    super.initState();
    _lstNodes = widget._roots?.length > 0
        ? widget._roots.map((TreeNodeData root) {
            TreeNode treeNode =
                new TreeNode(widget, root, key: new Key(root.id));
            treeNode.onSelectNode = widget.onSelectNode;
            treeNode.onEditNode = widget.onEditNode;
            treeNode.onManage = widget.onManage;
            treeNode.onHiliteNode = widget.onHiliteNode;
            // Make sure to store a reference to the associated widget
            root.bindedWidget = treeNode;
            return treeNode;
          }).toList()
        : null;
  }

  @override
  void dispose() {
    super.dispose();
    _lstNodes?.clear();
    _lstNodes = null;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _lstWidget = [];
    if (widget._header != null) _lstWidget.add(widget._header);

    _lstWidget.addAll(_lstNodes);

    return new ListView(children: _lstWidget);
  }
}
