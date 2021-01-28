import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_api_rest/api/authentication_api.dart';
import 'package:flutter_api_rest/data/authentication_client.dart';
import 'package:flutter_api_rest/pages/home_page.dart';
import 'package:flutter_api_rest/pages/register_page.dart';
import 'package:flutter_api_rest/utils/dialogs.dart';
import 'package:flutter_api_rest/utils/responsive.dart';
import 'package:flutter_api_rest/widgets/input_text.dart';
import 'package:get_it/get_it.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authenticationAPI = GetIt.instance<AuthenticationAPI>();
  final _authenticationClient = GetIt.instance<AuthenticationClient>();

  String _email = '';
  String _password = '';
  _submit() async {
    if (_formKey.currentState.validate()) {
      ProgressDialog.show(context);
      final response = await _authenticationAPI.login(
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
          case 403:
            message = 'Invalid password';
            break;
          case 404:
            message = 'User not found';
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
                label: 'EMAIL ADDRESS',
                keyboardType: TextInputType.emailAddress,
                fontSize: responsive.dp(responsive.isTablet ? 1.3 : 1.8),
                onChanged: (text) => _email = text,
                validator: (text) =>
                    !text.contains('@') ? 'invalid email' : null,
              ),
              SizedBox(
                height: responsive.dp(2),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InputText(
                        label: 'PASSWORD',
                        obscureText: true,
                        borderEnabled: false,
                        fontSize:
                            responsive.dp(responsive.isTablet ? 1.3 : 1.8),
                        onChanged: (text) => _password = text,
                        validator: (text) =>
                            text.trim().length == 0 ? 'Invalid password' : null,
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      onPressed: () {},
                      child: Text(
                        'Forgot password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              responsive.dp(responsive.isTablet ? 1.3 : 1.8),
                        ),
                      ),
                    ),
                  ],
                ),
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
                      'Sign in',
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
                    'New to Friendly Design?',
                    style: TextStyle(
                      fontSize: responsive.dp(1.8),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RegisterPage.routeName);
                    },
                    child: Text(
                      'Sign up',
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
