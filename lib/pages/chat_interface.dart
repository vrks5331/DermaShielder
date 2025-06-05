import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_gemini/flutter_gemini.dart';


class ChatInterface extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final bool isDarkMode;
  final String initialClassification;

  const ChatInterface({
    Key? key,
    required this.images,
    required this.isDarkMode,
    required this.initialClassification,
  }) : super(key: key);

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  int selectedIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final gemini = Gemini.instance;
  String buffer = ""; // This will accumulate streamed parts

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
  }

  void _sendInitialMessage() {
    final userInitialPrompt = "Tell me more about a ${widget.initialClassification} for research purposes only.";

    // 1) Add the initial prompt as a user message
    setState(() {
      messages.add({
        'sender': 'user',
        'text': userInitialPrompt,
      });
    });

    buffer = ""; // Clear buffer before a new stream
    gemini.promptStream(parts: [
      Part.text(userInitialPrompt) // Send the same prompt to Gemini
    ]).listen((value) {
      if (value?.output != null) {
        // Accumulate parts into the buffer
        buffer += value!.output!;
        // You might want to show a typing indicator here while streaming
      }
    }, onError: (error) {
      print('[_sendInitialMessage] Gemini stream encountered an ERROR: $error');
      setState(() {
        // Add error message as a bot response
        messages.add({
          'sender': 'bot',
          'text': 'Error from AI: $error'
        });
      });
    }, onDone: () {
      // 2) Add the consolidated buffer as a single bot message when done
      setState(() {
        if (buffer.isNotEmpty) {
          messages.add({
            'sender': 'bot',
            'text': buffer,
          });
        } else {
          // Handle case where Gemini returns nothing
          messages.add({
            'sender': 'bot',
            'text': 'I did not receive a response from the AI for this query.'
          });
        }
      });
      print('[_sendInitialMessage] Gemini stream completed. Final message added.');
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user's message immediately
    setState(() {
      messages.add({'sender': 'user', 'text': text});
      _controller.clear();
    });

    buffer = ""; // Clear buffer for the new message
    gemini.promptStream(parts: [Part.text(text)]).listen((value) {
      if (value?.output != null) {
        buffer += value!.output!;
        // No setState here while buffering, to prevent UI jumping
      }
    }, onError: (error) {
      print('[_sendMessage] Gemini stream encountered an ERROR: $error');
      setState(() {
        messages.add({
          'sender': 'bot',
          'text': 'Error from AI: $error'
        });
      });
    }, onDone: () {
      // Add the consolidated bot message when done
      setState(() {
        if (buffer.isNotEmpty) {
          messages.add({
            'sender': 'bot',
            'text': buffer,
          });
        } else {
          messages.add({
            'sender': 'bot',
            'text': 'I did not receive a response from the AI for this query.'
          });
        }
      });
      print('[_sendMessage] Gemini stream completed. Final message added.');
    });
  }

  void _selectImage(int index) {
    setState(() {
      selectedIndex = index;
      messages.clear();
    });
    // NOTE: This _sendInitialMessage call will use the *same* initialClassification
    // that was passed into the ChatInterface when it was first created.
    // If you need to re-analyze the newly selected image and get a *new*
    // classification for Gemini, you'd need to call TFLiteHelper.classifyImage here.
    // For this, you'd need to pass TFLiteHelper methods/instance or the image file
    // to ChatInterface and then call classifyImage here.
    // For now, this is kept as is, assuming initial chat is based on the first analyzed image.
    _sendInitialMessage();
    Navigator.pop(context); // Close the sidebar/drawer
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
          leading: isWideScreen
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          )
              : Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              );
            },
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
                  // FIXED: Use Colors.grey.shade700 (non-nullable) or conditional color
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  tail: true,
                  isSender: false,
                  textStyle: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16),
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
                  style: TextStyle(color: isDark ? Colors.white : Colors.black), // Text color in TextField
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