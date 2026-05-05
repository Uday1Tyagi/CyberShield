import 'package:flutter/material.dart';

class UrlScannerPage extends StatefulWidget {
  const UrlScannerPage({super.key});

  @override
  State<UrlScannerPage> createState() => _UrlScannerPageState();
}

class _UrlScannerPageState extends State<UrlScannerPage> {
  String status = "System Active";
  bool isOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "URL Protection System",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 🔴 LIVE STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isOn ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isOn
                              ? Colors.green.withOpacity(0.8)
                              : Colors.grey,
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isOn ? "LIVE PROTECTION ACTIVE" : "PROTECTION OFF",
                    style: TextStyle(
                      color: isOn ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 25),

              // 🧠 MAIN TITLE
              const Text(
                "AI URL Shield",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                status,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // START
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isOn = true;
                        status = "Scanner Activated";
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.greenAccent,
                            Colors.green,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.6),
                            blurRadius: 12,
                          )
                        ],
                      ),
                      child: const Text(
                        "START",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // STOP
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isOn = false;
                        status = "Scanner Paused";
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.redAccent,
                            Colors.red,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            blurRadius: 12,
                          )
                        ],
                      ),
                      child: const Text(
                        "STOP",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔍 FOOT TEXT
              Text(
                "Real-time phishing detection is running in background via browser extension",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}