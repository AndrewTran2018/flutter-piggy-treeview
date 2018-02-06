import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piggy/common/BasicPage.dart';
import 'package:piggy/common/Global.dart';
import 'package:piggy/common/TreeView.dart';
import 'package:piggy/model/Account.dart';
import 'AccountNodeData.dart';
import 'AccountDetail.dart';
import 'package:piggy/common/SearchBar.dart';

class AccountList extends BasicPage {
  AccountList(String title, {Key key})
      : super(title,
            key: key,
            actions: [
              ActionTypes.delete,
              ActionTypes.expandAll,
              ActionTypes.collapseAll
            ],
            enableFAB: true,
            appBar: true);

  @override
  AccountListState createState() => new AccountListState();
}

class AccountListState extends BasicPageState {
  List<Account> _lstAccount;

  //Callback as highlighting a node
  void _onHiliteNode(dynamic node) {
    assert(null != node);

    bool isExist = _mapHilitedNodes.containsKey(node.id);
    if (isExist)
      // flip/flop hilited state
      _mapHilitedNodes.remove(node.id);
    else if (_mapHilitedNodes.length > 0) {
      _mapHilitedNodes.forEach((key, value) {
        value.hilited = false;
      });
      _treeComponent.broadcast(_mapHilitedNodes);

      _mapHilitedNodes.clear();
      // add it
      // node id is actually the full path
      _mapHilitedNodes[node.id] = node;
    } else
      _mapHilitedNodes[node.id] = node;

//    print("On hilte node call back:${_mapHilitedNodes.length}");
  }

  //Callback as selecting a node by ticking the respective checkbox
  void _onSelectNode(dynamic node) {
    assert(null != node);
    setState(() {
      bool isExist = _mapSelectNodes.containsKey(node.id);
      if (node.isChecked)
        // add it
        // node id is actually the full path
        _mapSelectNodes[node.id] = node;
      else if (isExist) _mapSelectNodes.remove(node.id);

      widget.enableDelete = _mapSelectNodes.length > 0 ? true : false;
    });

    print("On select node call back:${_mapSelectNodes.length}");
  }

  void _onCollapseAll() {
    _treeComponent.toggle(false);
  }

  void _onExpandAll() {
    _treeComponent.toggle(true);
  }

  void _onAddNew() {
    Util.alert(context);
  }

  void _onDelete() {
    Util.alert(context, content: "Delete");
  }

  void _onSearch(String textToSearch) {
    setState(() {
      widget.isLoading = true;
    });

    Iterable<AccountNodeData> foundNodes = this | textToSearch;

    // Turn off hilited nodes
    if (_mapHilitedNodes.length > 0) {
      _mapHilitedNodes.forEach((key, value) {
        value.hilited = false;
      });
      _treeComponent.broadcast(_mapHilitedNodes);
    }
    // Hilite new found nodes
    _mapHilitedNodes.clear();
    foundNodes?.forEach((element) {
      _mapHilitedNodes[element.id] = element;
    });

    _treeComponent.expandOnTo(_mapHilitedNodes);

    setState(() {
      widget.isLoading = false;
    });
  }

  void _onEdit(AccountNodeData node) {
    setState(() {
      print(node.toString());
    });
    _toggleFAB();

    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new AccountDetail(
                Constants.TITLE_ACCOUNT_DETAIL_PAGE,
                account: node),
            fullscreenDialog: true));
    _toggleFAB();
  }

  void _toggleFAB() {
    setState(() => widget.enableFAB = !widget.enableFAB);
  }

  void initListItems() {
    _lstAccount = <Account>[
      new Account(
          "Root", "root@gmail.com", "0988877766", "root", "0", "", "\$0"),
      new Account("Master1", "master1@gmail.com", "0988877766", "master", "1",
          "0", "\$0\$1"),
      new Account("Master11", "master11@gmail.com", "0988877766", "master",
          "11", "1", "\$0\%1\$11"),
      new Account("Master12", "master12@gmail.com", "0988877766", "master",
          "12", "1", "\$0\$1\$12"),
      new Account("Slaver13", "slaver13@gmail.com", "0988877766", "slaver",
          "13", "1", "\$0\$1\$13"),
      new Account("Master2", "master2@gmail.com", "0988877766", "master", "2",
          "0", "\$0\$2"),
      new Account("Slaver21", "slaver21@gmail.com", "0988877766", "slaver",
          "21", "2", "\$0\$2\$21"),
      new Account("Slaver22", "slaver22@gmail.com", "0988877766", "slaver",
          "22", "2", "\$0\$2\$22"),
      new Account("Master23", "master23@gmail.com", "0988877766", "master",
          "23", "2", "\$0\$2\$23"),
      new Account("Master30", "master30@gmail.com", "0988877766", "master",
          "30", "23", "\$0\$2\$23\$30"),
    ];
  }

  @override
  void initState() {
    super.initState();

    initListItems();

    // Call API to get the list of accounts
    Future<List> future = _getAccountList();

    future.then((value) {
      _treeComponent = new TreeView.multipleRoots(_lstTreeNode,
          header: new Heading(
            key: new Key("PiggyHeader"),
            searchCallback: _onSearch,
          ));
      _treeComponent.onSelectNode = _onSelectNode;
      _treeComponent.onEditNode = _onEdit;
      _treeComponent.onHiliteNode = _onHiliteNode;
    })
      ..catchError((error) => print(error));

    _displayLongPressGuide();
  }

  Future<Null> _displayLongPressGuide() async {
    showInSnackBar("Press long on an item to edit.");
  }

  @override
  void didUpdateWidget(covariant AccountList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_onDelete != null && widget.onDelete == null)
      widget.onDelete = _onDelete;
    if (_onExpandAll != null && widget.onExpandAll == null)
      widget.onExpandAll = _onExpandAll;
    if (_onCollapseAll != null && widget.onCollapseAll == null)
      widget.onCollapseAll = _onCollapseAll;
    if (_onAddNew != null && widget.onFABressed == null)
      widget.onFABressed = _onAddNew;
    if (_lstTreeNode.length > 0) widget.enableExpandCollap = true;
  }

  @override
  Widget buildContent(BuildContext context) {
    return new Container(
      child: new Scrollbar(child: _treeComponent),
    );
  }

  TreeView _treeComponent;
  List<AccountNodeData> _lstTreeNode;

  Map<String, AccountNodeData> _mapSelectNodes = {};
  Map<String, AccountNodeData> get selectedNodes => _mapSelectNodes;

  Map<String, AccountNodeData> _mapHilitedNodes = {};
  Map<String, AccountNodeData> get hilitedNodes => _mapHilitedNodes;

  _AccountMap _mapAccount;
  // API calls
  Future<Null> _getAccountList() async {
    setState(() => widget.isLoading = true);

    _mapAccount = new _AccountMap(_lstAccount);

    _processTreeData();

    setState(() => widget.isLoading = false);
  }

  void _processTreeData() {
    // Make sure the list is empty
    if (_lstTreeNode != null) {
      _lstTreeNode.clear();
      _lstTreeNode = null;
    }
    _lstTreeNode = [];

    // Get all roots first
    _mapAccount.interMap?.forEach((String key, Account account) {
      if (account.parent_id == null || account.parent_id.isEmpty) {
        // root _lstTreeNode: e.g. "$1"
        AccountNodeData root = new AccountNodeData.root(account);
        _lstTreeNode.add(root);
      }
    });

    void _continueBuildTree(AccountNodeData node) {
      List<AccountNodeData> lstAccountNodeDataTemp = [];

      Iterable<Account> children = _mapAccount ^ node.id;

      children?.forEach((Account account) {
        var theChild = node.createChild(
            account.username, account.email, account.full_path, account);
        lstAccountNodeDataTemp.add(theChild);
      });

      // Recursively build tree.
      lstAccountNodeDataTemp.forEach((node) => _continueBuildTree(node));
    }

    _lstTreeNode.forEach((node) => _continueBuildTree(node));
  }

  // Util
  // Search the tree for the text
  Iterable operator |(String textToSearch) sync* {
    if (_lstTreeNode?.length > 0) {
      for (AccountNodeData account in _lstTreeNode) {
        String cat =
            "${account.data.username} ${account.data.email} ${account.data.type} ${account.data.phone}";
        if (cat.indexOf(textToSearch) > -1) {
          account.expanded = true;
          account.hilited = true;
          yield account;
        }
        if (account.hasChildren)
          for (AccountNodeData acc in account.children)
            yield* acc | textToSearch;
      }
    } else
      yield null;
  }
}

class _AccountMap {
  Map<String, Account> _mAccount;

  _AccountMap(List<Account> lstAccount) {
    if (lstAccount?.length > 0) {
      _mAccount = new Map.fromIterable(lstAccount,
          key: (Account account) => account.full_path);
    }
  }
  // Return all the direct children of this key
  Iterable operator ^(String thisKey) sync* {
    if (_mAccount?.length > 0) {
      if (_mAccount[thisKey] == null) yield null;
      String pattern = "$thisKey\$";
      for (Account account in _mAccount.values) {
        if (account.full_path.replaceFirst(pattern, '') == account.id)
          yield account;
      }
    } else
      yield null;
  }

  Account operator [](String key) {
    if (_mAccount?.length > 0)
      return _mAccount[key];
    else
      return null;
  }

  void operator []=(String key, Account value) {
    if (_mAccount != null) _mAccount[key] = value;
  }

  void clear() {
    if (_mAccount != null) {
      _mAccount.clear();
      _mAccount = null;
    }
  }

  void remove(String key) {
    if (_mAccount != null) _mAccount.remove(key);
  }

  int get length => _mAccount?.length;

  Map<String, Account> get interMap => _mAccount;
}
