import 'package:flutter/material.dart';
import 'package:validator/validator.dart';

typedef void SearchCallback(String stringToSearch);

class SearchBar extends StatefulWidget {
  SearchCallback _onSearch;

  SearchBar({SearchCallback onSearch}) {
    _onSearch = onSearch;
  }

  @override
  SearchBarState createState() => new SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  bool _isSearching = false;
  final GlobalKey<FormFieldState<String>> _textsearchFieldKey =
      new GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _searchValue = "";
  FocusNode _inputFocus = new FocusNode();

  // Event handlers
  _onSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    final FormState form = _formKey.currentState;
    form.save();
//    print("Search: '$_searchValue'");

    if (!isNull(_searchValue))
      setState(() {
        _isSearching = true;
        if (widget._onSearch != null) widget._onSearch(_searchValue);
      });
  }

  _onDelete() {
    final FormFieldState<String> _textsearchField =
        _textsearchFieldKey.currentState;
    _textsearchField.reset();

    FocusScope.of(context).requestFocus(_inputFocus);
    setState(() {
      _isSearching = false;
      _searchValue = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
        height: 40.0,
        child: new Form(
          key: _formKey,
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new SizedBox(
                width: 180.0,
                child: new TextFormField(
                  focusNode: _inputFocus,
                  key: _textsearchFieldKey,
                  style: new TextStyle(color: Colors.black),
                  decoration: new InputDecoration(
                    hintText: "Enter...",
                    hintStyle: new TextStyle(color: Colors.black),
                  ),
                  onSaved: (String value) {
                    _searchValue = value;
                  },
                ),
              ),
              new Expanded(
                  child: _isSearching
                      ? new IconButton(
                          icon: new Icon(Icons.clear),
                          onPressed: _onDelete,
                        )
                      : new IconButton(
                          icon: new Icon(Icons.search),
                          onPressed: _onSearch,
                        ))
            ],
          ),
        ));
  }
}

class _HeadingLayout extends MultiChildLayoutDelegate {
  _HeadingLayout();

  static final String searchBar = 'searchBar';

  @override
  void performLayout(Size size) {
    const double marginX = 16.0;
    const double marginY = 5.0;

    final double maxHeaderWidth = 200.0;
    final BoxConstraints headerBoxConstraints =
        new BoxConstraints(maxWidth: maxHeaderWidth);
    final Size headerSize = layoutChild(searchBar, headerBoxConstraints);

    final double searchbarX = (size.width - headerSize.width) / 2.0;
    positionChild(searchBar, new Offset(searchbarX, marginY));
  }

  @override
  bool shouldRelayout(_HeadingLayout oldDelegate) => false;
}

class Heading extends StatelessWidget {
  SearchCallback _searchCallback;

  Heading({Key key, SearchCallback searchCallback}) : super(key: key) {
    _searchCallback = searchCallback;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    return new MergeSemantics(
      child: new SizedBox(
        height: screenSize.width > screenSize.height
            ? (screenSize.height - kToolbarHeight) * 0.10
            : (screenSize.height - kToolbarHeight) * 0.08,
        child: new Container(
          decoration: new BoxDecoration(
            color: Theme.of(context).accentColor.withOpacity(0.015),
            border:
                new Border(bottom: new BorderSide(color: theme.dividerColor)),
          ),
          child: new CustomMultiChildLayout(
            delegate: new _HeadingLayout(),
            children: <Widget>[
              new LayoutId(
                id: _HeadingLayout.searchBar,
                child: new SearchBar(
                  onSearch: _searchCallback,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
