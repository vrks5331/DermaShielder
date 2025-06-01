import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

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
  final gemini = Gemini.instance;
  String buffer = "";

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
  }

  void _sendInitialMessage() {
    final label = widget.images[selectedIndex]['label'] ?? 'lesion';
    gemini.promptStream(parts: [
      Part.text("Tell me more about a $label for research purposes only.")
    ]).listen((value) {
      if (value?.output != null) {
        setState(() {
          messages.add({
            'sender': 'bot',
            'text': value!.output!
          });
        });
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'text': text});
      _controller.clear();
    });

    buffer = "";
    gemini.promptStream(parts: [Part.text(text)]).listen((value) {
      if (value?.output != null) {
        buffer += value!.output!;
        setState(() {
          if (messages.isNotEmpty && messages.last['sender'] == 'bot') {
            messages[messages.length - 1]['text'] = buffer;
          } else {
            messages.add({'sender': 'bot', 'text': buffer});
          }
        });
      }
    });
  }

  void _selectImage(int index) {
    setState(() {
      selectedIndex = index;
      messages.clear();
    });
    _sendInitialMessage();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final theme = isDark ? ThemeData.dark() : ThemeData.light();
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    Widget sidebar = Container(
      width: 220,
      color: isDark ? Colors.grey[900] : Colors.grey[300],
      child: ListView.builder(
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          String label = widget.images[index]['label'] ?? 'Image $index';
          return ListTile(
            selected: index == selectedIndex,
            selectedTileColor: Colors.blue.withOpacity(0.2),
            title: Text(label),
            onTap: () => _selectImage(index),
          );
        },
      ),
    );

    Widget chatArea = Column(
      children: [
        AppBar(
          backgroundColor: Colors.grey[600],
          title: Text(widget.images[selectedIndex]['label'] ?? 'Skin Lesion'),
          leading: !isWideScreen
              ? Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
              : IconButton(
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: msg['sender'] == 'user'
                    ? BubbleSpecialThree(
                  text: msg['text']!,
                  color: Colors.blue,
                  tail: true,
                  isSender: true,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                )
                    : BubbleSpecialThree(
                  text: msg['text']!,
                  color: Colors.grey.shade300,
                  tail: true,
                  isSender: false,
                  textStyle: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
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
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
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
    );

    return Theme(
      data: theme,
      child: Scaffold(
        drawer: !isWideScreen ? Drawer(child: sidebar) : null,
        body: isWideScreen
            ? Row(
          children: [
            sidebar,
            Expanded(child: chatArea),
          ],
        )
            : chatArea,
      ),
    );
  }
}
