import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email_phishing.dart';
import 'malware.dart';
import 'url.dart';
import 'usb.dart';
import 'landing_screen.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  Widget cyberCard(

    BuildContext context,
    String title,
    IconData icon,
    Widget page,
    Color color

  ){

    return InkWell(

      onTap:(){

        Navigator.push(

          context,
          MaterialPageRoute(builder:(_)=>page),

        );

      },

      child: Card(

        elevation:8,

        shape:RoundedRectangleBorder(

          borderRadius:BorderRadius.circular(15),

        ),

        child:Container(

          padding:EdgeInsets.all(20),

          decoration:BoxDecoration(

            borderRadius:BorderRadius.circular(15),

            gradient:LinearGradient(

              colors:[

                Color(0xff020617),
                Color(0xff0f172a)

              ]

            )

          ),

          child:Column(

            mainAxisAlignment:MainAxisAlignment.center,

            children:[

              Icon(icon,size:45,color:color),

              SizedBox(height:15),

              Text(

                title,

                textAlign:TextAlign.center,

                style:TextStyle(

                  fontSize:16,
                  fontWeight:FontWeight.bold

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar:AppBar(

        title:Text("CyberShield Dashboard"),

        actions:[

          IconButton(

            icon:Icon(Icons.logout),

            onPressed:() async{

              final prefs = await SharedPreferences.getInstance();

              await prefs.clear();

              Navigator.pushAndRemoveUntil(

                context,

                MaterialPageRoute(
                  builder:(_)=>LandingScreen()
                ),

                (route)=>false

              );

            },

          )

        ],

      ),

      body:Padding(

        padding:EdgeInsets.all(20),

        child:GridView.count(

          crossAxisCount:2,

          crossAxisSpacing:20,

          mainAxisSpacing:20,

          children:[

            cyberCard(

              context,
              "Email Phishing Scanner",
              Icons.email,
              EmailPhishingPage(),
              Colors.orange

            ),

            cyberCard(

              context,
              "Malware Detection",
              Icons.security,
              MalwareDetectionPage(),
              Colors.red

            ),

            cyberCard(

              context,
              "URL Phishing Checker",
              Icons.link,
              UrlScannerPage(),
              Colors.blue

            ),

            cyberCard(

              context,
              "USB Protection",
              Icons.usb,
              UsbAuthPage(),
              Colors.green

            ),

          ],

        ),

      ),

    );

  }

}