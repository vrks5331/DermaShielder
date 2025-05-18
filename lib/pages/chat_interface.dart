import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatInterface extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final bool isDarkMode;

  const ChatInterface({
    Key? key,
    required this.images,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  int selectedIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        'sender': 'user',
        'text': _controller.text.trim(),
      });
      messages.add({
        'sender': 'bot',
        'text': 'Thanks! I will provide insights shortly.',
      });
      _controller.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    // Initial auto-analysis message
    messages.add({
      'sender': 'bot',
      'text':
      'This appears to be a ${widget.images[selectedIndex]['label']}. Would you like treatment advice?',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 220,
              color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[300],
              child: ListView.builder(
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  String label = widget.images[index]['label'] ?? 'Image $index';
                  return ListTile(
                    selected: index == selectedIndex,
                    selectedTileColor: Colors.blue.withOpacity(0.2),
                    title: Text(label),
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        messages.clear();
                        messages.add({
                          'sender': 'bot',
                          'text':
                          'This appears to be a ${widget.images[selectedIndex]['label']}. Would you like treatment advice?',
                        });
                      });
                    },
                  );
                },
              ),
            ),

            // Chat window
            Expanded(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.grey[600],
                    title: Text(widget.images[selectedIndex]['label']),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return msg['sender'] == 'user'
                            ? BubbleSpecialThree(
                          text: msg['text']!,
                          color: Colors.blue,
                          tail: true,
                          isSender: true,
                        )
                            : BubbleSpecialThree(
                          text: msg['text']!,
                          color: Colors.grey.shade300,
                          tail: true,
                          isSender: false,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Talk to Doc",
                              filled: true,
                              fillColor: widget.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
