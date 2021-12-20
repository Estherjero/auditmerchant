import 'package:auditmerchant/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils.dart' as utils;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthProvider _authProvider;
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _submitButtonFocus = FocusNode();
  bool _passwordObscureText = true;
  bool _isLoading = false;
  Map _authData = {};

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _submitButtonFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _authProvider = Provider.of<AuthProvider>(context);
    super.didChangeDependencies();
  }

  void _passwordVisibilityToggle() {
    setState(() {
      _passwordObscureText = !_passwordObscureText;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _authProvider
            .login(_authData['username'], _authData['password'])
            .then(
              (value) => Navigator.of(context).pushReplacementNamed('/list'),
            );
      } catch (error) {
        utils.handleErrorResponse(context, (error as dynamic).message);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.only(left: 25.0, right: 25.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.public,
                    size: 200.0,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  TextFormField(
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      filled: true,
                      fillColor: Theme.of(context).primaryColorLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.subtitle1,
                    textInputAction: TextInputAction.next,
                    controller: _usernameController,
                    onEditingComplete: () {
                      _usernameFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Username should not be empty!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['username'] = value!.trim();
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Theme.of(context).primaryColorLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
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
                    controller: _passwordController,
                    style: Theme.of(context).textTheme.subtitle1,
                    onEditingComplete: () {
                      _passwordFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_submitButtonFocus);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password should not be empty!';
                      }
                      if (value.trim().length < 4) {
                        return 'Password should be 4 characters';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  SizedBox(
                    height: 35.0,
                  ),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    Container(
                      height: 45.0,
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: ElevatedButton(
                        focusNode: _submitButtonFocus,
                        child: Text(
                          'LOGIN',
                        ),
                        onPressed: _submit,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
