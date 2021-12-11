import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

late String verID;
late String phone;
bool codeSent = false;

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: codeSent
                  ? OTPTextField(
                      length: 6,
                      width: MediaQuery.of(context).size.width,
                      fieldWidth: 30,
                      style: TextStyle(fontSize: 20),
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldStyle: FieldStyle.underline,
                      onCompleted: (pin) {
                        verifyPin(pin);
                      },
                    )
                  : IntlPhoneField(
                      initialCountryCode: 'IN',
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (phoneNumber) {
                        setState(() {
                          phone = phoneNumber.completeNumber;
                        });
                      },
                    ),
            ),
            ElevatedButton(
                onPressed: () {
                  verifyPhone(context);
                },
                child: const Text('Verify'))
          ],
        ),
      ),
    );
  }

  Future<void> verifyPhone(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          const snackbar = SnackBar(content: Text('Login Succeeded'));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        verificationFailed: (FirebaseAuthException e) {
          final snackbar = SnackBar(content: Text("${e.message}"));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            codeSent = true;
            verID = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            verID = verificationId;
          });
        },
        timeout: const Duration(seconds: 60));
  }

  Future<void> verifyPin(String pin) async {
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verID, smsCode: pin);

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      const snackbar = SnackBar(content: Text('Login Succeeded'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } on FirebaseAuthException catch (e) {
      final snackbar = SnackBar(content: Text("${e.message}"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }
}
