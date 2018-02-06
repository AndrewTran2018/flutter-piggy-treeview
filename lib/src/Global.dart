import 'dart:async';
import 'package:flutter/material.dart';

class Constants {
 
  // Array length of main tabs
  static const VIEW_PADDING = 15.0;
  static const LIST_ITEM_INDENT = 16.0;
  static const VERTICAL_PADDING = 15.0;
  static const HORIZONTAL_PADDING = 48.0;
  static const VERTICAL_PADDING_FORM = 10.0;
  static const HORIZONTAL_PADDING_FORM = 8.0;

  // All string constan

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
