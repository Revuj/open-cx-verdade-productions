import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conferly/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'Email must not be empty!';
                    }
                    return null;
                  },
                  onSaved: (input) => _email = input,
                  decoration: InputDecoration(
                      labelText: 'Email'
                  ),
                ),
                TextFormField(
                  validator: (input) {
                    if (input.length < 6) {
                      return "Provide a password longer than 6!";
                    }
                    return null;
                  },
                  onSaved: (input) => _password = input,
                  decoration: InputDecoration(
                      labelText: 'Password'
                  ),
                  obscureText: true,
                ),
                RaisedButton(
                  onPressed: signUp,
                  child: Text('Sign Up'),
                )
              ],
            )
        )

    );
  }

  void signUp() async {
    // validate fields
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

     try {
       AuthResult auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
       Firestore.instance
           .collection('Users').document(auth.user.uid)
              .setData({
                  'email' : auth.user.email,
                  'name' : auth.user.displayName,
                  'uid' : auth.user.uid,
                  'events' : [],
                  'description' : '',
                  'location' : '',
                  'status' : '',
                  'interests' : [],
       });

       AuthResult login = await FirebaseAuth.instance
           .signInWithEmailAndPassword(email: _email, password: _password);

//       user.additionalUserInfo.providerId
       //user.sendEmailVerification();
       Navigator.of(context).pop();
       Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => MyApp()));
     } catch(e) {

     }

    }
  }
}
