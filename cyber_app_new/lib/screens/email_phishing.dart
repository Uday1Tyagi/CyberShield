import 'package:flutter/material.dart';
import 'dart:async';
import 'services/api.dart';

class EmailPhishingPage extends StatefulWidget {
  const EmailPhishingPage({super.key});

  @override
  State<EmailPhishingPage> createState() => _EmailPhishingPageState();
}

class _EmailPhishingPageState extends State<EmailPhishingPage> {

  String status = "Press Start to Monitor";
  String sender = "";
  String subject = "";

  bool monitoring = false;
  Timer? timer;

  // 🔥 START monitoring
  void startMonitoring() {

    setState(() {
      monitoring = true;
      status = "Monitoring...";
    });

    timer = Timer.periodic(Duration(seconds: 3), (timer) async {

      try {
        var data = await getEmail();

        setState(() {
          sender = data['from'] ?? "";
          subject = data['subject'] ?? "";
          status = data['status'] ?? "No Data";
        });

      } catch (e) {
        setState(() {
          status = "Backend Error";
        });
      }

    });

  }

  // 🛑 STOP monitoring
  void stopMonitoring() {

    timer?.cancel();

    setState(() {
      monitoring = false;
      status = "Stopped";
    });

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {

      Color statusColor = status == "Phishing"
          ? Colors.redAccent
          : status == "Safe"
              ? Colors.greenAccent
              : Colors.orangeAccent;

      return Scaffold(

          backgroundColor: Color(0xff020617),

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,

            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.greenAccent),
              onPressed: () {
                Navigator.pop(context); // 🔥 back
              },
            ),

            title: Text(
              "Email Live Monitor",
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),

          body: Stack(

          children: [

            /// 🔥 BACKGROUND GLOW
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      statusColor.withOpacity(0.15),
                      Colors.transparent
                    ],
                    radius: 1.2,
                  ),
                ),
              ),
            ),

            /// 🔥 MAIN CONTENT
            Center(

              child: AnimatedContainer(

                duration: Duration(milliseconds: 600),

                width: 520,
                padding: EdgeInsets.all(30),

                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(25),

                  gradient: LinearGradient(
                    colors: [
                      Color(0xff020617),
                      Color(0xff0f172a)
                    ]
                  ),

                  border: Border.all(
                    color: statusColor.withOpacity(.6),
                    width: 1.5,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(.4),
                      blurRadius: 40,
                      spreadRadius: 2,
                    )
                  ],

                ),

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    /// 🔥 TITLE
                    Text(
                      "LIVE EMAIL MONITOR",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 22,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 25),

                    /// 🔘 BUTTON
                    GestureDetector(
                      onTap: monitoring ? stopMonitoring : startMonitoring,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                            horizontal: 35, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: monitoring
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          boxShadow: [
                            BoxShadow(
                              color: (monitoring
                                      ? Colors.redAccent
                                      : Colors.greenAccent)
                                  .withOpacity(.6),
                              blurRadius: 15,
                            )
                          ],
                        ),
                        child: Text(
                          monitoring
                              ? "STOP MONITORING"
                              : "START MONITORING",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 35),

                    /// 🔥 STATUS (ANIMATED)
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: Column(
                        key: ValueKey(status),

                        children: [

                          Text(
                            "STATUS",
                            style: TextStyle(
                              color: Colors.white54,
                              letterSpacing: 2,
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              shadows: [
                                Shadow(
                                  color: statusColor.withOpacity(.8),
                                  blurRadius: 20,
                                )
                              ],
                            ),
                          ),

                        ],

                      ),
                    ),

                    SizedBox(height: 30),

                    /// 📧 EMAIL CARD
                    Container(

                      padding: EdgeInsets.all(18),

                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(18),

                        color: Colors.black.withOpacity(.4),

                        border: Border.all(color: Colors.white12),

                      ),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          buildLabel("FROM"),
                          SizedBox(height: 5),
                          buildValue(sender),

                          SizedBox(height: 15),

                          buildLabel("SUBJECT"),
                          SizedBox(height: 5),
                          buildValue(subject),

                        ],

                      ),

                    ),

                  ],

                ),

              ),

            ),

          ],

        ),

      );

    }

    /// 🔥 Helper Widgets
    Widget buildLabel(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      );
    }

    Widget buildValue(String text) {
      return Text(
        text.isEmpty ? "Waiting for email..." : text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      );
    }

}

