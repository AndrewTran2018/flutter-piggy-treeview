# piggy treeview

A Treeview component for Flutter, featuring expand/collapse all, search, hilite, checkbox.

## Getting Started

How to use? 
1. Import TreeView.dart. (see details below to import directly from github)
2. Derive TreeNodeData to publish your own data.
3. See AccountList.dart for the example detail.


<img src="https://raw.githubusercontent.com/AndrewTran2018/flutter-piggy-treeview/screenshot/Screenshot_1517923304.png" width="540" height="960">

## Importing directly from Github

Edit your pubspec.yaml and add piggy to your dependencies:

```yaml
dependencies:
  piggy:
    git: git@github.com:AndrewTran2018/flutter-piggy-treeview.git
  flutter:
    sdk: flutter
```

run `flutter package get` to install the new dependency

You will now have the following imports available to you:

```dart
import 'package:piggy/src/Global.dart';
import 'package:piggy/src/BasicPage.dart';
import 'package:piggy/src/SearchBar.dart';
import 'Package:piggy/src/TreeView.dart';
```