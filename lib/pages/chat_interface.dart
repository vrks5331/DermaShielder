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

  @override
  void initState() {
    super.initState();
    _addBotIntro();
  }

  void _addBotIntro() {
    messages.add({
      'sender': 'bot',
      'text':
      'This appears to be a ${widget.images[selectedIndex]['label']}. Would you like treatment advice?',
    });
  }

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

  void _selectImage(int index) {
    setState(() {
      selectedIndex = index;
      messages.clear();
      _addBotIntro();
    });
    Navigator.pop(context); // Closes drawer on mobile
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
          title: Text(widget.images[selectedIndex]['label']),
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
