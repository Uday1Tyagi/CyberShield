import 'package:flutter/material.dart';
import 'services/api.dart';

class ChatbotDialog extends StatefulWidget {
  const ChatbotDialog({super.key});

  @override
  State<ChatbotDialog> createState() => _ChatbotDialogState();
}

class _ChatbotDialogState extends State<ChatbotDialog> {

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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: Colors.transparent,

      child: Container(
        width: 450,
        height: 550,
        decoration: BoxDecoration(
          color: const Color(0xff020617),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.greenAccent),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(.4),
              blurRadius: 25,
            )
          ],
        ),

        child: Column(
          children: [

            /// 🔥 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.greenAccent),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cyber AI",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),

            /// CHAT AREA
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (_, i) {

                  bool isUser = messages[i]["role"] == "user";

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,

                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.greenAccent
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Text(
                        messages[i]["text"]!,
                        style: TextStyle(
                          color: isUser ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// INPUT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.greenAccent),
                ),
              ),
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "Ask something...",
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
        ),
      ),
    );
  }
}