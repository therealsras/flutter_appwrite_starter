import 'package:flutter/material.dart';
import 'package:flutter_appwrite_starter/core/presentation/providers/providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/user_repository.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextStyle style = TextStyle(fontSize: 20.0);
  TextEditingController _email;
  TextEditingController _password;
  FocusNode _passwordField;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: "");
    _password = TextEditingController(text: "");
    _passwordField = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final user = watch(userRepoProvider);
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(0),
                child: TextFormField(
                  key: Key("email-field"),
                  controller: _email,
                  validator: (value) => (value.isEmpty)
                      ? AppLocalizations.of(context).emailValidationError
                      : null,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).emailFieldlabel,
                  ),
                  style: style,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(_passwordField);
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(0),
                child: TextFormField(
                  focusNode: _passwordField,
                  key: Key("password-field"),
                  controller: _password,
                  obscureText: true,
                  validator: (value) => (value.isEmpty)
                      ? AppLocalizations.of(context).passwordValidationError
                      : null,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).passwordFieldLabel,
                  ),
                  style: style,
                  onEditingComplete: _login,
                ),
              ),
              SizedBox(height: 10.0),
              if (user.status == Status.Authenticating)
                Center(child: CircularProgressIndicator()),
              if (user.status != Status.Authenticating)
                Center(
                  child: RaisedButton(
                    elevation: 0,
                    highlightElevation: 0,
                    onPressed: _login,
                    child: Text(AppLocalizations.of(context).loginButtonText),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  _login() async {
    if (_formKey.currentState.validate()) {
      if (!await context
          .read(userRepoProvider)
          .signIn(_email.text, _password.text)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.read(userRepoProvider).error),
        ));
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
