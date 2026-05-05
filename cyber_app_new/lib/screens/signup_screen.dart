import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  bool otpSent = false;
  bool loading = false;

  String message = "";

  Future sendOtp() async {

    setState(()=>loading=true);

    var result = await ApiService.sendOtp(
      emailController.text.trim()
    );

    setState(()=>loading=false);

    if(result["status"]=="success"){

      otpSent=true;
      message="OTP sent to email 📧";

    }
    else{

      message="Email already registered";

    }

    setState((){});

  }


  Future verifyOtp() async {

    setState(()=>loading=true);

    var result = await ApiService.verifyOtp(

      emailController.text.trim(),
      otpController.text.trim(),
      passwordController.text.trim()

    );

    setState(()=>loading=false);

    if(result["status"]=="verified"){

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool("isLoggedIn", true);

      await prefs.setString(
        "email",
        emailController.text.trim()
      );

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder:(_)=>HomeScreen()
        ),

      );

    }
    else{

      message="Wrong OTP";

    }

    setState((){});

  }



  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: Icon(Icons.arrow_back),

          onPressed:(){

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(
                builder:(_)=>LoginScreen()
              ),

            );

          },

        ),

        title: Text("Signup"),

      ),


      body: Row(

        children:[

          Expanded(

            child: Center(

              child: Container(

                width:400,

                padding: EdgeInsets.all(30),

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children:[

                    Text(

                      "Create Account",

                      style: TextStyle(

                        fontSize:28,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,

                      ),

                    ),

                    SizedBox(height:30),

                    TextField(

                      controller: emailController,

                      decoration: InputDecoration(
                        labelText:"Email",
                        border: OutlineInputBorder(),
                      ),

                    ),

                    SizedBox(height:15),

                    TextField(

                      controller: passwordController,

                      decoration: InputDecoration(
                        labelText:"Password",
                        border: OutlineInputBorder(),
                      ),

                    ),

                    SizedBox(height:20),

                    ElevatedButton(

                      onPressed: sendOtp,

                      child: Text("Send OTP"),

                    ),

                    if(otpSent)...[

                      SizedBox(height:20),

                      TextField(

                        controller: otpController,

                        decoration: InputDecoration(
                          labelText:"Enter OTP",
                          border: OutlineInputBorder(),
                        ),

                      ),

                      SizedBox(height:15),

                      ElevatedButton(

                        onPressed: verifyOtp,

                        child: Text("Verify OTP"),

                      )

                    ],

                    SizedBox(height:20),

                    if(loading)
                      CircularProgressIndicator(),

                    SizedBox(height:10),

                    Text(
                      message,
                      style: TextStyle(color: Colors.orange),
                    ),

                    SizedBox(height:20),

                    TextButton(

                      onPressed:(){

                        Navigator.pushReplacement(

                          context,

                          MaterialPageRoute(
                            builder:(_)=>LoginScreen()
                          ),

                        );

                      },

                      child: Text("Already account? Login"),

                    )

                  ],

                ),

              ),

            ),

          ),


          Expanded(

            child: Container(

              decoration: BoxDecoration(

                image: DecorationImage(

                  image: NetworkImage(
"https://images.unsplash.com/photo-1550751827-4bd374c3f58b"
                  ),

                  fit: BoxFit.cover,

                ),

              ),

            ),

          )

        ],

      ),

    );

  }

}