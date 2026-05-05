import 'package:flutter/material.dart';
import 'services/api.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    scrollToBottom();

    String reply = await sendChatMessage(text);
    reply = reply.replaceAll("**", "");

    setState(() {
      messages.add({"role": "bot", "text": reply});
      isLoading = false;
    });

    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// 🔥 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff020617),
                  Color(0xff031b16),
                  Color(0xff000000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Column(
            children: [

              /// 🔥 APPBAR
              Container(
                padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(.4),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Cyber AI",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              /// CHAT
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {

                    bool isUser = messages[index]["role"] == "user";

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [

                        if (!isUser)
                          const CircleAvatar(
                            backgroundColor: Colors.greenAccent,
                            child: Icon(Icons.smart_toy, color: Colors.black),
                          ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.symmetric(vertical: 6),

                          constraints: const BoxConstraints(maxWidth: 320),

                          decoration: BoxDecoration(
                            gradient: isUser
                                ? const LinearGradient(
                                    colors: [
                                      Colors.greenAccent,
                                      Color(0xff22c55e),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xff0f172a),
                                      Color(0xff020617),
                                    ],
                                  ),

                            borderRadius: BorderRadius.circular(18),

                            boxShadow: [
                              BoxShadow(
                                color: isUser
                                    ? Colors.greenAccent.withOpacity(.6)
                                    : Colors.black,
                                blurRadius: 20,
                              )
                            ],
                          ),

                          child: Text(
                            messages[index]["text"]!,
                            style: TextStyle(
                              color: isUser ? Colors.black : Colors.white,
                              fontSize: 14.5,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        if (isUser)
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                      ],
                    );
                  },
                ),
              ),

              /// 🔥 TYPING ANIMATION
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        child: Icon(Icons.smart_toy, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: List.generate(3, (i) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),

              /// 🔥 INPUT BAR
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.greenAccent),
                  color: const Color(0xff0f172a),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(.3),
                      blurRadius: 20,
                    )
                  ],
                ),

                child: Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => sendMessage(),
                        decoration: const InputDecoration(
                          hintText: "Ask cybersecurity question...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.greenAccent),
                      onPressed: sendMessage,
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}