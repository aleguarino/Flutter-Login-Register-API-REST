import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_api_rest/api/authentication_api.dart';
import 'package:flutter_api_rest/data/authentication_client.dart';
import 'package:flutter_api_rest/pages/home_page.dart';
import 'package:flutter_api_rest/utils/dialogs.dart';
import 'package:flutter_api_rest/utils/responsive.dart';
import 'package:flutter_api_rest/widgets/input_text.dart';
import 'package:get_it/get_it.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authenticationAPI = GetIt.instance<AuthenticationAPI>();
  final _authenticationClient = GetIt.instance<AuthenticationClient>();

  String _email = '';
  String _password = '';
  String _username = '';

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      ProgressDialog.show(context);
      final response = await _authenticationAPI.register(
        username: _username,
        email: _email,
        password: _password,
      );
      ProgressDialog.dismiss(context);
      if (response.data != null) {
        await _authenticationClient.saveSession(response.data);
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomePage.routeName,
          (_) => false,
        );
      } else {
        String message;

        switch (response.error.statusCode) {
          case -1:
            message = 'Network error, check your connection';
            break;
          case 409:
            message =
                'Duplicated user ${jsonEncode(response.error.data['duplicatedFields'])}';
            break;
          default:
            message = response.error.message;
        }
        Dialogs.alert(
          context,
          title: 'ERROR',
          description: message,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);

    return Positioned(
      bottom: 30,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: responsive.isTablet ? 500 : 360,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputText(
                label: 'USERNAME',
                fontSize: responsive.dp(responsive.isTablet ? 1.3 : 1.8),
                onChanged: (text) => _username = text,
                validator: (text) =>
                    text.trim().length < 5 ? 'Invalid username' : null,
              ),
              SizedBox(
                height: responsive.dp(2),
              ),
              InputText(
                label: 'EMAIL ADDRESS',
                keyboardType: TextInputType.emailAddress,
                fontSize: responsive.dp(responsive.isTablet ? 1.3 : 1.8),
                onChanged: (text) => _email = text,
                validator: (text) =>
                    !text.contains('@') ? 'Invalid email' : null,
              ),
              SizedBox(
                height: responsive.dp(2),
              ),
              InputText(
                label: 'PASSWORD',
                fontSize: responsive.dp(responsive.isTablet ? 1.3 : 1.8),
                obscureText: true,
                onChanged: (text) => _password = text,
                validator: (text) =>
                    text.trim().length < 6 ? 'Invalid password' : null,
              ),
              SizedBox(
                height: responsive.dp(3),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.dp(1),
                    ),
                    onPressed: this._submit,
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.dp(1.8),
                      ),
                    ),
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
              SizedBox(height: responsive.dp(2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: responsive.dp(1.8),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: responsive.dp(1.8),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: responsive.dp(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
