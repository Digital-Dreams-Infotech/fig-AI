import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FigAIDashboard());
}

class FigAIDashboard extends StatelessWidget {
  const FigAIDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedOption = 'AI Prompt Finder';
  bool _showChat = false;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _showPromptMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('What is AI?', style: TextStyle(color: Colors.white)),
                onTap: () => _selectPrompt("What is AI?"),
              ),
              ListTile(
                title: Text('How does blockchain work?', style: TextStyle(color: Colors.white)),
                onTap: () => _selectPrompt("How does blockchain work?"),
              ),
              ListTile(
                title: Text('Tell me a joke', style: TextStyle(color: Colors.white)),
                onTap: () => _selectPrompt("Tell me a joke"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectPrompt(String prompt) {
    Navigator.pop(context); // Close the popup
    setState(() {
      _messages.add(ChatMessage(
        text: prompt,
        isUser: true,
        onEdit: (text) => _editMessage(_messages.length - 1, text),
      ));

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(ChatMessage(
            text: "Here’s my response to: '$prompt'",
            isUser: false,
          ));
        });
      });
    });
  }


  void _editMessage(int index, String newText) {
    setState(() {
      _messages[index] = ChatMessage(
        text: newText,
        isUser: true,
        onEdit: (text) => _editMessage(index, text),
      );

      if (index + 1 < _messages.length && !_messages[index + 1].isUser) {
        _messages.removeAt(index + 1);
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _messages.insert(index + 1, ChatMessage(
              text: "I've updated my response based on your edit.",
              isUser: false,
            ));
          });
        }
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      int newIndex = _messages.length;
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUser: true,
        onEdit: (text) => _editMessage(newIndex, text),
      ));
      _messageController.clear();
      _showChat = true;

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(ChatMessage(
            text: "I'm your AI assistant. How can I help you further?",
            isUser: false,
          ));
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1B0B25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/image/Logo.png', height: 30),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'Fig '),
                  TextSpan(
                    text: 'AI',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFFF2E9D8),
                            Color(0xFFD0A197),
                            Color(0xFFC2797A),
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 100, 40)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(
                  'assets/image/Drawer.png', // Ensure this path is correct
                  height: 28,
                  width: 28,
                  color: Colors.white, // Optional: Adjust color if needed
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: Padding(
        padding: const EdgeInsets.only(top: 100, bottom: 470),
        child: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF2E9D8), // Light Red/Pink
                        Color(0xFFD0A197), // Light Red/Pink
                        Color(0xFFC2797A), // Soft Pink
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white38,
                          child: Image.asset('assets/image/person.png'),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Jemin Y",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),

              ),
              ListTile(
                title: const Text('History', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: const Text('About Us', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              const Divider(color: Colors.white38, endIndent: 15, indent: 15),
              ListTile(
                title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.black45,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Container(
                        width: 150,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedOption,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            dropdownColor: Colors.black,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedOption = newValue!;
                              });
                            },
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'AI Prompt Finder',
                                child: Text(
                                  'AI Prompt Finder',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Another Option',
                                child: Text(
                                  'Another Option',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'More Options',
                                child: Text(
                                  'More Options',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _showPromptMenu(context);
                          },
                          child: const Text('Select Prompts', style: TextStyle(fontSize: 11)),
                        ),
                        SizedBox(width: 8,),
                        Image.asset('assets/image/Edit.png', height: 25,width: 25,),
                      ],
                    ),
                  ],
                ),
                const Divider(),

                if (!_showChat) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/image/Logo.png', height: 60),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              const TextSpan(text: 'Hi, I am Fig '),
                              TextSpan(
                                text: 'AI',
                                style: GoogleFonts.poppins(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        Color(0xFFF2E9D8),
                                        Color(0xFFD0A197),
                                        Color(0xFFC2797A),
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 100, 40),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Ready to assist you with anything you need, from answering questions to providing recommendations.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FeatureCard(
                    imagePath: 'assets/image/Accurate Data.png',
                    title: 'Accurate Data',
                    subtitle: 'Ensures precision and reliability.',
                  ),
                  FeatureCard(
                    imagePath: 'assets/image/Fast Response.png',
                    title: 'Fast Response',
                    subtitle: 'Generates content instantly.',
                  ),
                  FeatureCard(
                    imagePath: 'assets/image/Trending Topic.png',
                    title: 'Trending Topic',
                    subtitle: 'Keeps content fresh and relevant.',
                  ),
                  const Spacer(),
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _messages[index];
                      },
                    ),
                  ),
                ],

                Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(
                      color: Colors.white, // Change to desired color
                      width: 0.2, // Change width as needed
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white, // Change to desired color
                        width: 0.2, // Change width as needed
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 15),
                              border: InputBorder.none,
                              hintText: 'Start typing, get magic...',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                        InkWell(
                          child: Image.asset('assets/image/Photo.png',
                            height: 30,width: 30,),
                          onTap: () {},
                        ),
                        SizedBox(width: 5,),
                        // IconButton(
                        //   icon: const Icon(Icons.image, color: Colors.white60),
                        //   onPressed: () {},
                        // ),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Center(
                  child: Text(
                    'Kukami AI may not always be accurate. Verify important info.',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage extends StatefulWidget {
  final String text;
  final bool isUser;
  final Function(String)? onEdit;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.isUser)
            CircleAvatar(
              backgroundColor: Colors.purple[300],
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isUser ? Colors.purple[300] : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing)
                    TextField(
                      controller: _editController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (newText) {
                        if (widget.onEdit != null) {
                          widget.onEdit!(newText);
                        }
                        setState(() => _isEditing = false);
                      },
                    )
                  else
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.isUser ? Colors.white : Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  if (widget.isUser && !_isEditing)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white60, size: 16),
                        onPressed: () {
                          setState(() => _isEditing = true);
                        },
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
}

class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const FeatureCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 28, height: 28, fit: BoxFit.cover),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Center(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
