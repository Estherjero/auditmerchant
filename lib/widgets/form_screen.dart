import 'package:auditmerchant/providers/merchant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils.dart' as utils;

class FormScreen extends StatefulWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  late BuildContext _screenContext;
  late MerchantProvider _merchantProvider;
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _loginFocusNode = FocusNode();
  FocusNode _serverFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _submitButtonFocusNode = FocusNode();
  late Future _future;
  bool _passwordObscureText = true;
  Map? arguments = {};
  Map _accountDetail = {};
  Map _formData = {};
  String accountId = '';
  String accountName = '';
  bool _isLoading = false;
  bool status = false;
  bool _editMode = true;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _loginFocusNode.dispose();
    _serverFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _future = _getAccount();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _merchantProvider = Provider.of<MerchantProvider>(context);
    if (ModalRoute.of(context)!.settings.arguments != null) {
      arguments = ModalRoute.of(context)!.settings.arguments as Map;
      accountId = arguments!['id'];
      accountName = arguments!['name'];
      _editMode = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _getAccount() async {
    await Future.delayed(Duration(milliseconds: 7));
    if (ModalRoute.of(context)!.settings.arguments != null) {
      try {
        _accountDetail = await _merchantProvider.getAccount(arguments!['id']);
        if (_accountDetail['status'] != null) status = _accountDetail['status'];
      } catch (error) {
        utils.handleErrorResponse(_screenContext, (error as dynamic).message);
      }
    }
  }

  void _passwordVisibilityToggle() {
    setState(() {
      _passwordObscureText = !_passwordObscureText;
    });
  }

  Future<void> _onStartOrStop([bool? force]) async {
    setState(() {
      _isLoading = true;
    });
    try {
      status
          ? await _merchantProvider
              .stopAccount(accountId, {'force': force ?? false})
          : await _merchantProvider.startAccount(accountId);
      setState(() {
        _isLoading = false;
      });
      utils.showSuccessSnackbar(
        _screenContext,
        status ? 'Stopped successfully' : 'Started successfully',
      );
      Navigator.of(_screenContext)
          .pushNamedAndRemoveUntil('/list', (route) => false);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      utils.handleErrorResponse(_screenContext, (error as dynamic).message);
    }
  }

  Future<void> _onSubmit(bool next) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        if (accountId.isEmpty) {
          await _merchantProvider.createAccount(_formData);
          utils.showSuccessSnackbar(
              _screenContext, 'Account Created Successfully');
        } else {
          await _merchantProvider.updateAccount(accountId, _formData);
          utils.showSuccessSnackbar(
              _screenContext, 'Account updated Successfully');
        }
        setState(() {
          _isLoading = false;
        });
        !next
            ? Navigator.of(_screenContext)
                .pushNamedAndRemoveUntil('/list', (route) => false)
            : Navigator.of(_screenContext)
                .pushNamedAndRemoveUntil('/form', (route) => false);
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        utils.handleErrorResponse(_screenContext, (error as dynamic).message);
      }
    }
  }

  Widget _generalInfoContainer() {
    return Card(
      shape: Border(
        left: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 3,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GENERAL INFO',
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                initialValue: _accountDetail['name'] ?? '',
                focusNode: _nameFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Name *',
                ),
                keyboardType: TextInputType.text,
                style: Theme.of(context).textTheme.subtitle1,
                textInputAction: TextInputAction.next,
                enabled: _editMode,
                onEditingComplete: () {
                  _nameFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_loginFocusNode);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name should not be empty!';
                  }
                  return null;
                },
                onSaved: (val) {
                  if (val!.isNotEmpty) {
                    _formData.addAll({'name': val});
                  }
                },
              ),
              TextFormField(
                initialValue: _accountDetail['server'] ?? '',
                focusNode: _serverFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Server *',
                ),
                keyboardType: TextInputType.text,
                style: Theme.of(context).textTheme.subtitle1,
                textInputAction: TextInputAction.next,
                enabled: _editMode,
                onEditingComplete: () {
                  _serverFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Server should not be empty!';
                  }
                  return null;
                },
                onSaved: (val) {
                  if (val!.isNotEmpty) {
                    _formData.addAll({'server': val});
                  }
                },
              ),
              TextFormField(
                initialValue: _accountDetail['login'] ?? '',
                focusNode: _loginFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Login *',
                ),
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.subtitle1,
                textInputAction: TextInputAction.next,
                enabled: _editMode && accountId.isEmpty,
                onEditingComplete: () {
                  _loginFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_serverFocusNode);
                },
                validator: (value) {
                  if (value!.isEmpty && accountId.isEmpty) {
                    return 'Login should not be empty!';
                  }
                  return null;
                },
                onSaved: (val) {
                  if (val!.isNotEmpty) _formData.addAll({'login': val});
                },
              ),
              TextFormField(
                initialValue: _accountDetail['password'] ?? '',
                autofocus: false,
                enabled: _editMode,
                decoration: InputDecoration(
                  labelText: accountId.isEmpty ? 'Password *' : 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_passwordObscureText
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => _passwordVisibilityToggle(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.text,
                obscureText: _passwordObscureText,
                style: Theme.of(context).textTheme.subtitle1,
                onEditingComplete: () {
                  _passwordFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_submitButtonFocusNode);
                },
                validator: (value) {
                  if (value!.isEmpty && accountId.isEmpty) {
                    return 'Password should not be empty!';
                  }
                  if (value.trim().length < 8 && accountId.isEmpty) {
                    return 'Password should be 8 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value!.isNotEmpty) _formData.addAll({'password': value});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _startStopWidget() {
    return Visibility(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: status ? null : () => _onStartOrStop(),
            child: Text(
              'START',
              style: TextStyle(
                fontSize: 16.0,
                color: status
                    ? Colors.grey.shade400
                    : Theme.of(context).primaryColor,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColorLight,
              ),
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.all(10),
              ),
            ),
          ),
          TextButton(
            onPressed: status ? () => _onStartOrStop() : null,
            child: Text(
              'STOP',
              style: TextStyle(
                fontSize: 16.0,
                color: status
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColorLight,
              ),
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.all(10),
              ),
            ),
          ),
          TextButton(
            onPressed: status ? () => _onStartOrStop(true) : null,
            child: Text(
              'FORCE STOP',
              style: TextStyle(
                fontSize: 16.0,
                color: status
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColorLight,
              ),
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
      visible: accountId.isNotEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: _future,
            builder: (context, snapShot) {
              _screenContext = context;
              return snapShot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            Container(
                              height: 55.0,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 7.0, right: 7.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_back),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: Text(
                                            accountId.isEmpty
                                                ? 'Add Account'
                                                : accountName,
                                            softWrap: false,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'Pattern')
                                            Navigator.of(context).pushNamed(
                                                '/pattern',
                                                arguments: {
                                                  'id': accountId,
                                                  'name': accountName,
                                                  'pattern':
                                                      _accountDetail['pattern'],
                                                  'config':
                                                      _accountDetail['config'],
                                                });
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            ['Pattern']
                                                .map(
                                                  (e) => PopupMenuItem<String>(
                                                    value: e,
                                                    child: Text(e),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                      visible: accountId.isNotEmpty,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      _generalInfoContainer(),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      _startStopWidget(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
            },
          ),
        ),
        bottomNavigationBar: FutureBuilder(
          future: _future,
          builder: (context, snapShot) {
            _screenContext = context;
            return snapShot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: _editMode
                        ? Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  focusNode: _submitButtonFocusNode,
                                  onPressed: () => _onSubmit(false),
                                  child: Text(
                                    'SAVE',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Theme.of(context).primaryColor,
                                  child: TextButton(
                                    onPressed: () => _onSubmit(true),
                                    child: Text(
                                      'SAVE & NEW',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            color: Theme.of(context).primaryColor,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _editMode = !_editMode;
                                });
                              },
                              child: Text(
                                'EDIT',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  );
          },
        ),
      ),
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
    );
  }
}
