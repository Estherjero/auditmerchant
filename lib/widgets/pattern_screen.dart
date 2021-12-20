import 'dart:convert';

import 'package:auditmerchant/providers/merchant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../../utils.dart' as utils;

enum Pattern {
  GENERAL,
  OTHER,
}

class PatternScreen extends StatefulWidget {
  @override
  _PatternScreenState createState() => _PatternScreenState();
}

class _PatternScreenState extends State<PatternScreen> {
  late MerchantProvider _merchantProvider;
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode _patternFocusNode = FocusNode();
  FocusNode _initFocusNode = FocusNode();
  FocusNode _jumpFocusNode = FocusNode();
  FocusNode _thresholdFocusNode = FocusNode();
  FocusNode _limitFocusNode = FocusNode();
  FocusNode _resistanceFocusNode = FocusNode();
  FocusNode _supportFocusNode = FocusNode();
  FocusNode _symbolFocusNode = FocusNode();
  FocusNode _maxHedgesFocusNode = FocusNode();
  TextEditingController _patternController = TextEditingController();
  Pattern _accPattern = Pattern.GENERAL;
  Map arguments = {};
  Map _formData = {};
  Map _config = {};
  Map _configData = {};
  List _patternList = [
    'GENERAL',
    'OTHER',
  ];
  List _filteredList = [];

  @override
  void dispose() {
    _patternFocusNode.dispose();
    _initFocusNode.dispose();
    _jumpFocusNode.dispose();
    _thresholdFocusNode.dispose();
    _limitFocusNode.dispose();
    _resistanceFocusNode.dispose();
    _supportFocusNode.dispose();
    _symbolFocusNode.dispose();
    _maxHedgesFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _merchantProvider = Provider.of<MerchantProvider>(context);
    if (ModalRoute.of(context)!.settings.arguments != null) {
      arguments = ModalRoute.of(context)!.settings.arguments as Map;
      if (arguments['pattern'] != null) {
        _patternController.text = arguments['pattern'];
        _getPattern(arguments['pattern'].toUpperCase());
      } else
        _patternController.text = '';
      if (arguments['config']!.isNotEmpty)
        _config = json.decode(arguments['config']);
    }
    super.didChangeDependencies();
  }

  Future<List> _getPatternList(String query) async {
    _filteredList.clear();
    if (query.toString().isNotEmpty) {
      for (int i = 0; i < _patternList.length; i++)
        if (_patternList[i]
            .replaceAll(RegExp('[^a-zA-Z0-9\\\\s+]'), '')
            .toLowerCase()
            .startsWith(query.toLowerCase()))
          _filteredList.add(_patternList[i]);
    } else
      _patternList.forEach((elm) => _filteredList.add(elm));
    return _filteredList;
  }

  void _getPattern(String pattern) {
    setState(() {
      switch (pattern) {
        case 'GENERAL':
          _accPattern = Pattern.GENERAL;
          break;
        case 'OTHER':
          _accPattern = Pattern.OTHER;
          break;
      }
    });
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _formData.addAll({'config': _configData});
      try {
        await _merchantProvider.applyPattern(arguments['id'], _formData);
        utils.showSuccessSnackbar(context, 'Pattern successfully applied');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/list', (route) => false);
      } catch (error) {
        utils.handleErrorResponse(context, (error as dynamic).message);
      }
    }
  }

  Widget _patternWidget() {
    return Card(
      shape: Border(
        left: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 3,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PATTERN',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
            SizedBox(
              height: 10.0,
            ),
            TypeAheadFormField(
              hideSuggestionsOnKeyboardHide: true,
              hideOnError: true,
              textFieldConfiguration: TextFieldConfiguration(
                textInputAction: TextInputAction.next,
                focusNode: _patternFocusNode,
                controller: _patternController,
                onEditingComplete: () {
                  _patternFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_initFocusNode);
                },
                decoration: InputDecoration(
                  labelText: 'Pattern *',
                  contentPadding:
                      EdgeInsets.only(top: 10.0, bottom: 10.0, right: -10.0),
                  suffixIcon: Visibility(
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _patternController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).primaryColor,
                        size: 18.0,
                      ),
                    ),
                    visible: _patternController.text.isNotEmpty,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                shadowColor: Colors.blue,
              ),
              onSaved: (val) {
                _formData.addAll({'pattern': val!.toUpperCase()});
              },
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Pattern should not be empty!';
                }
                return null;
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  _patternController.text = suggestion as String;
                  _getPattern(suggestion);
                });
              },
              itemBuilder: (_, suggestion) => Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                        right: 10.0,
                      ),
                      child: Text(
                        suggestion as String,
                        style: TextStyle(fontSize: 13.0),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              autoFlipDirection: true,
              noItemsFoundBuilder: (context) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No items found',
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontSize: 12.0,
                  ),
                ),
              ),
              transitionBuilder: (context, suggestionsBox, controller) =>
                  suggestionsBox,
              suggestionsCallback: (pattern) async {
                return await _getPatternList(pattern.trim());
              },
            ),
            SizedBox(
              height: 25.0,
            ),
            Text(
              'CONFIG',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _config['initial'] != null
                        ? _config['initial'].toString()
                        : '',
                    focusNode: _initFocusNode,
                    decoration: InputDecoration(labelText: 'Initial'),
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.subtitle1,
                    onEditingComplete: () {
                      _initFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_jumpFocusNode);
                    },
                    onSaved: (val) {
                      _configData.addAll(
                          {'initial': val!.isNotEmpty ? double.parse(val) : 0});
                    },
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: _config['jump'] != null
                        ? _config['jump'].toString()
                        : '',
                    focusNode: _jumpFocusNode,
                    decoration: InputDecoration(labelText: 'Jump'),
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.subtitle1,
                    onEditingComplete: () {
                      _jumpFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_thresholdFocusNode);
                    },
                    onSaved: (val) {
                      _configData.addAll(
                          {'jump': val!.isNotEmpty ? double.parse(val) : 0});
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _config['threshold'] != null
                        ? _config['threshold'].toString()
                        : '',
                    focusNode: _thresholdFocusNode,
                    decoration: InputDecoration(labelText: 'Threshold'),
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.subtitle1,
                    onEditingComplete: () {
                      _thresholdFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_limitFocusNode);
                    },
                    onSaved: (val) {
                      _configData.addAll({
                        'threshold': val!.isNotEmpty ? double.parse(val) : 0
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: _config['limit'] != null
                        ? _config['limit'].toString()
                        : '',
                    focusNode: _limitFocusNode,
                    decoration: InputDecoration(labelText: 'Limit'),
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.subtitle1,
                    onEditingComplete: () {
                      _limitFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_resistanceFocusNode);
                    },
                    onSaved: (val) {
                      _configData.addAll(
                          {'limit': val!.isNotEmpty ? int.parse(val) : 0});
                    },
                  ),
                ),
              ],
            ),
            Visibility(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _config['resistance'] != null
                          ? _config['resistance'].toString()
                          : '',
                      focusNode: _resistanceFocusNode,
                      decoration: InputDecoration(labelText: 'Resistance'),
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context).textTheme.subtitle1,
                      onEditingComplete: () {
                        _resistanceFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(_supportFocusNode);
                      },
                      onSaved: (val) {
                        _configData.addAll({
                          'resistance': val!.isNotEmpty ? double.parse(val) : 0
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: _config['support'] != null
                          ? _config['support'].toString()
                          : '',
                      focusNode: _supportFocusNode,
                      decoration: InputDecoration(labelText: 'Support'),
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context).textTheme.subtitle1,
                      onEditingComplete: () {
                        _supportFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(_symbolFocusNode);
                      },
                      onSaved: (val) {
                        _configData.addAll({
                          'support': val!.isNotEmpty ? double.parse(val) : 0
                        });
                      },
                    ),
                  ),
                ],
              ),
              visible: _accPattern == Pattern.GENERAL,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _config['symbol'] != null
                        ? _config['symbol'].toString()
                        : '',
                    focusNode: _symbolFocusNode,
                    decoration: InputDecoration(labelText: 'Symbol'),
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.subtitle1,
                    onEditingComplete: () {
                      _symbolFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_maxHedgesFocusNode);
                    },
                    onSaved: (val) {
                      _configData.addAll({'symbol': val});
                    },
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: _config['maxHedges'] != null
                        ? _config['maxHedges'].toString()
                        : '',
                    focusNode: _maxHedgesFocusNode,
                    decoration: InputDecoration(labelText: 'Max Hedges'),
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.subtitle1,
                    onEditingComplete: () {
                      _maxHedgesFocusNode.unfocus();
                    },
                    onSaved: (val) {
                      _configData.addAll({
                        'maxHedges': val!.isNotEmpty ? double.parse(val) : 0
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 55.0,
                child: Container(
                  padding: const EdgeInsets.only(left: 7.0, right: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Text(
                            arguments['name'],
                            softWrap: false,
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _onSubmit(),
                        child: Text(
                          'Apply Pattern',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Form(
                      key: _formKey,
                      child: _patternWidget(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
    );
  }
}
