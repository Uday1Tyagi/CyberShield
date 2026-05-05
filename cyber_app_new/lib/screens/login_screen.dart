import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String message = "";
  bool loading = false;

  Future login() async {

    setState(()=>loading=true);

    var result = await ApiService.login(

      emailController.text.trim(),
      passwordController.text.trim()

    );

    setState(()=>loading=false);

    if(result["status"]=="success"){

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool("isLoggedIn", true);

      await prefs.setString(
        "email",
        emailController.text.trim()
      );

      Navigator.pop(context,true);

    }

    else{

      message="Incorrect email or password";

    }

    setState((){});

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: Icon(Icons.arrow_back),

          onPressed: (){
            Navigator.pop(context);
          },

        ),

        title: Text("Login"),

      ),

      body: Row(

        children: [

          Expanded(

            child: Center(

              child: Container(

                width: 400,

                padding: EdgeInsets.all(30),

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      "CyberShield Login",

                      style: TextStyle(

                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,

                      ),

                    ),

                    SizedBox(height: 10),

                    Text(
                      "Secure authentication system",
                      style: TextStyle(color: Colors.grey),
                    ),

                    SizedBox(height: 30),

                    TextField(

                      controller: emailController,

                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),

                    ),

                    SizedBox(height: 15),

                    TextField(

                      controller: passwordController,
                      obscureText: true,

                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),

                    ),

                    SizedBox(height: 25),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: login,
                        child: Text("Login"),

                      ),

                    ),

                    SizedBox(height: 10),

                    if(loading)
                      Center(child:CircularProgressIndicator()),

                    SizedBox(height: 10),

                    Text(
                      message,
                      style: TextStyle(color: Colors.orange),
                    ),

                    SizedBox(height: 20),

                    Center(

                      child: TextButton(

                        onPressed: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(
                              builder:(_)=>SignupScreen()
                            ),

                          );

                        },

                        child: Text("Create Account"),

                      ),

                    ),

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

          ),

        ],

      ),

    );

  }

}