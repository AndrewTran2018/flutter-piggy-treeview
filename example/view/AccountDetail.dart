import 'package:flutter/material.dart';
import 'package:piggy/common/BasicPage.dart';
import 'package:piggy/common/Global.dart';
import 'package:validator/validator.dart';
import 'AccountNodeData.dart';

class AccountDetail extends BasicPage {
  AccountNodeData _account;

  AccountNodeData get currentAccount => _account;

  AccountDetail(String title, {AccountNodeData account})
      : super(title, appBar: true, enableFAB: false) {
    _account = account;
  }

  @override
  AccountDetailState createState() => new AccountDetailState();
}

class AccountDetailState extends BasicPageState {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    AccountDetail theWidget = widget as AccountDetail;

    Widget requiredHint = new Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: new Text('* means the field is required',
            style: Theme
                .of(context)
                .textTheme
                .caption
                .copyWith(color: Colors.indigo)));

    Widget inputUserName = new TextFormField(
      decoration: new InputDecoration(
        hintText: "Type in account name",
        hintStyle: new TextStyle(color: Colors.black26),
        labelText: "Account Name *",
        labelStyle: new TextStyle(color: Colors.black),
        errorStyle: new TextStyle(color: Colors.red),
      ),
      initialValue: theWidget.currentAccount.data.username,
      onSaved: (String value) {
        theWidget.currentAccount.data.username = value;
      },
      validator: null,
    );

    Widget inputEmail = new TextFormField(
      decoration: new InputDecoration(
        hintText: "Email",
        hintStyle: new TextStyle(color: Colors.black26),
        labelText: "Email",
        labelStyle: new TextStyle(color: Colors.black),
        errorStyle: new TextStyle(color: Colors.red),
      ),
      initialValue: theWidget.currentAccount.data.email,
      onSaved: (String value) {
        theWidget.currentAccount.data.email = value;
      },
      validator: null,
    );

    Widget inputPhone = new TextFormField(
      decoration: new InputDecoration(
        hintText: "Contact number",
        hintStyle: new TextStyle(color: Colors.black26),
        labelText: "Contact Number *",
        labelStyle: new TextStyle(color: Colors.black),
        errorStyle: new TextStyle(color: Colors.red),
      ),
      initialValue: theWidget.currentAccount.data.phone,
      onSaved: (String value) {
        theWidget.currentAccount.data.phone = value;
      },
      validator: null,
    );

    Widget _getDropDownType() {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text("Account type"),
          new DropdownButton<String>(
            value: isNull(theWidget.currentAccount.data.type)
                ? ""
                : theWidget.currentAccount.data.type,
            onChanged: (String newValue) {
              setState(() {
                theWidget.currentAccount.data.type = newValue;
              });
            },
            items: <String>["master", "slaver", "root"].map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value == 'master' || value == "root"
                    ? "Master"
                    : 'Slaver'),
              );
            }).toList(),
          ),
        ],
      );
    }

    Widget inputType = _getDropDownType();

    Widget _getDropDownParent() {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text("Direct master"),
          new DropdownButton<String>(
            value: isNull(theWidget.currentAccount.data.parent_id)
                ? ""
                : theWidget.currentAccount.data.parent_id,
            onChanged: (String newValue) {
              setState(() {
                theWidget.currentAccount.data.parent_id = newValue;
              });
            },
            items: <String>[
              isNull(theWidget.currentAccount.data.parent_id)
                  ? ""
                  : theWidget.currentAccount.data.parent_id
            ].map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
          ),
        ],
      );
    }

    Widget inputParent = _getDropDownParent();

    Widget cmdButtons = new Padding(
      padding: new EdgeInsets.symmetric(vertical: Constants.VERTICAL_PADDING),
      child:
          new Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        new RaisedButton(child: const Text("Save"), onPressed: _onDone),
        const SizedBox(
          width: 12.0,
        ),
        new RaisedButton(child: const Text("Cancel"), onPressed: _onCancel)
      ]),
    );

    return new Container(
        padding: new EdgeInsets.symmetric(
            vertical: Constants.VERTICAL_PADDING_FORM,
            horizontal: Constants.HORIZONTAL_PADDING_FORM),
        child: new Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: new Scrollbar(
                child: new ListView(children: [
              requiredHint,
              inputUserName,
              inputEmail,
              inputPhone,
              inputType,
              inputParent,
              cmdButtons
            ]))));
  }

  // Event handlers
  _onDone() {
    Navigator.pop(context);
  }

  _onCancel() {
    Navigator.pop(context);
  }
}
