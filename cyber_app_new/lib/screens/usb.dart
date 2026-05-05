import 'package:flutter/material.dart';
import 'services/api.dart';

class UsbAuthPage extends StatefulWidget {
  const UsbAuthPage({super.key});

  @override
  State<UsbAuthPage> createState() => _UsbAuthPageState();
}

class _UsbAuthPageState extends State<UsbAuthPage> {
  final TextEditingController _controller = TextEditingController();

  String message = "";
  bool loading = false;
  List logs = [];

  bool glow = false;

  int success = 0;
  int failed = 0;
  int locked = 0;

  @override
  void initState() {
    super.initState();
    loadLogs();

    // 🔄 Auto refresh logs
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      loadLogs();
      return true;
    });

    // ⚡ Glow animation
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        glow = !glow;
      });
      return true;
    });
  }

  void loadLogs() async {
    try {
      final data = await getUsbLogs();

      int s = 0, f = 0, l = 0;

      for (var log in data) {
        if (log['action'].contains("Granted")) s++;
        if (log['action'].contains("Wrong")) f++;
        if (log['action'].contains("Locked")) l++;
      }

      setState(() {
        logs = data;
        success = s;
        failed = f;
        locked = l;
      });
    } catch (e) {
      print("Log error: $e");
    }
  }

  void verify() async {
    setState(() {
      loading = true;
      message = "";
    });

    try {
      final res = await verifyUsbPassword(_controller.text);

      setState(() {
        message = res['status'] == "granted"
            ? "✅ Access Granted"
            : "❌ Access Denied";
      });

      loadLogs();
    } catch (e) {
      setState(() {
        message = "⚠️ Error";
      });
    }

    setState(() {
      loading = false;
    });
  }

  Color getLogColor(String action) {
    if (action.contains("Granted")) return Colors.green;
    if (action.contains("Wrong")) return Colors.red;
    if (action.contains("Locked")) return Colors.orange;
    return Colors.blueAccent;
  }

  IconData getIcon(String action) {
    if (action.contains("Granted")) return Icons.check_circle;
    if (action.contains("Wrong")) return Icons.cancel;
    if (action.contains("Locked")) return Icons.lock;
    return Icons.usb;
  }

  Widget buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: Colors.green),
          SizedBox(width: 8),
          Text("System Secure", style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget statCard(String title, int value, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1226),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text("$value",
              style: TextStyle(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("SecureVault Protection System"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildStatusBar(),
              const SizedBox(height: 20),

              // 🔐 AUTH CARD
              Container(
                width: 400,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1226),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: glow
                          ? Colors.blueAccent.withOpacity(0.4)
                          : Colors.blueAccent.withOpacity(0.1),
                      blurRadius: 25,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.usb,
                        size: 50, color: Colors.blueAccent),
                    const SizedBox(height: 10),
                    const Text("Secure USB Access",
                        style:
                            TextStyle(fontSize: 20, color: Colors.white)),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _controller,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle:
                            const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1A2238),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: verify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15),
                            ),
                            child: const Text("Verify"),
                          ),

                    const SizedBox(height: 20),

                    Text(
                      message,
                      style: TextStyle(
                        color: message.contains("Granted")
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 📊 STATS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  statCard("Success", success, Colors.green),
                  const SizedBox(width: 15),
                  statCard("Failed", failed, Colors.red),
                  const SizedBox(width: 15),
                  statCard("Locked", locked, Colors.orange),
                ],
              ),

              const SizedBox(height: 30),

              // 📊 LOGS
              Container(
                width: 600,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1226),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Recent Activity (DB)",
                          style: TextStyle(
                              color: Colors.white, fontSize: 18)),
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];

                          return Container(
                            margin:
                                const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2238),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(getIcon(log['action']),
                                    color:
                                        getLogColor(log['action'])),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(log['action'],
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text("User: ${log['user']}",
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}