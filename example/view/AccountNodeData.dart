import 'package:piggy/common/TreeView.dart' show TreeNodeData;
import 'package:piggy/model/Account.dart';

class AccountNodeData extends TreeNodeData<Account> {
  AccountNodeData.root(Account data)
      : super.root(data.username, data.email, data.full_path, data);

  AccountNodeData.node(Account data, AccountNodeData parent)
      : super.node(parent, data.username, data.email, data.full_path, data);

  @override
  AccountNodeData createChild(
      String title, String subTitle, String id, Account data,
      [bool expanded = false]) {
    var child = new AccountNodeData.node(data, this);
    return child;
  }

  @override
  String get title => data.username;

  @override
  String get subTitle =>
      "${data.email}  ${data.phone}\n${data.type=='root' || data.type=='master'?"Agent":"Player"}\n";

  @override
  String toString() {
    return "${super.toString()}"
        "\nfullpath:${data.full_path} belongs to:${data.parent_id}";
  }

  @override
  Iterable operator |(String textToSearch) sync* {
    String cat = "${data.username} ${data.email} ${data.type} ${data.phone}";
    if (cat.toLowerCase().indexOf(textToSearch.toLowerCase()) > -1) {
      hilited = true;
      yield this;
    }
    if (hasChildren)
      for (AccountNodeData account in children) yield* account | textToSearch;
  }
}
