import 'dart:async';
import 'package:flutter/material.dart';


class Constants {
 
  static const VIEW_PADDING = 15.0;
  static const LIST_ITEM_INDENT = 16.0;
  static const VERTICAL_PADDING = 15.0;
  static const HORIZONTAL_PADDING = 48.0;
  static const VERTICAL_PADDING_FORM = 10.0;
  static const HORIZONTAL_PADDING_FORM = 8.0;
}
class Util {
  static String getKey() {
    List<String> strings = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    strings.shuffle();
    String randId = strings.join("");
    return randId;
  }

  static Future<dynamic> alert(BuildContext context,
      {String title = "Thông báo",
      String content = "Chi tiết thông báo",
      bool allowCancel = false}) async {
    var alert = new AlertDialog(
      title: new Text(title),
      content: new Text(content),
      actions: <Widget>[
        new FlatButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        allowCancel
            ? new FlatButton(
                child: const Text('Thôi'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            : new Container()
      ],
    );

    return await showDialog(
        context: context, child: alert, barrierDismissible: false);
  }
}
// Stack emulator
class StackEmul<T> {
  List<T> _internalList;

  StackEmul({List<T> list}) {
    if (list != null)
      _internalList = list;
    else
      _internalList = [];
  }

  void push(T object) {
    assert(_internalList != null);
    _internalList.add(object);
  }

  T pop() {
    assert(_internalList != null);
    if(_internalList.length>0)
      return _internalList.removeLast();
    else
      return null;
  }

  int get count=> _internalList?.length;
}


