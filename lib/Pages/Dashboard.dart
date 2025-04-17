import 'dart:convert';
import 'dart:io';
import 'package:fig_ai/API/API.dart';
import 'package:fig_ai/Compoents/ChatMessage.dart';
import 'package:fig_ai/Compoents/ChatScreen.dart';
import 'package:fig_ai/Compoents/Dailogbox.dart';
import 'package:fig_ai/Compoents/FeatureCard.dart';
import 'package:fig_ai/Models/PromptCategory.dart';
import 'package:fig_ai/Pages/Log%20In.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? chatId;
  String _selectedOption = 'AI Prompt Finder';
  bool _showChat = false;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  int? selectedCategoryId;
  List<PromptCategory> categories = [];
  final authservice = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  String _selectedPromptId = "1";

  String? userName;
  String? userProfile;
  String? token;
  String? userId;

  String? slug;

  String? title;
  bool? isLoading;
  DateTime? _lastPressedAt;

  bool _isPromptMenuOpen = false;
  bool _isCreatingChat = false;
  bool _isOwnChat = false;

  bool isLoadingHistory = false;
  bool isLoadingOwnChats = false;
  bool isLoadingnewchat = false;
  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    initializeDashboard();
  }

  Future<void> initializeDashboard() async {
    await loadUserToken();
    await loadUserName();
    await loadUserProfile();
    await loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> launchExternalUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('❌ Could not launch $url');
    }
  }

  Future<void> loadUserName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = pref.getString("user_name");
    });
  }

  Future<void> loadUserProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userProfile = pref.getString("user_photo");
    });
  }

  Future<void> loadUserToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      token = pref.getString("access_token");
      userId = pref.getString("userId");
    });
    print("TOKEN: $token");
  }

  Future<void> loadCategories() async {
    if (token == null || token!.isEmpty) {
      print("Token is null, skipping loadCategories");
      return;
    }

    try {
      final response = await authservice.getPromptCategory(token!);
      print('Status CATEGORY: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonCategories = json.decode(response.body);
        setState(() {
          categories =
              jsonCategories
                  .map((json) => PromptCategory.fromJson(json))
                  .toList();
          print('Categories Loaded: $categories');

          if (categories.isNotEmpty) {
            setState(() {
              print("SELECTED CATAGORY: ${categories.first.id}");
              selectedCategoryId = int.parse(categories.first.id);
            });
          }
        });
      } else {
        print('Error loading categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in loadCategories: $e');
    }
  }

  Future<Map<String, dynamic>?> _createNewChatSession() async {
    if (token == null || userId == null) return null;

    try {
      AuthService auth = AuthService();
      final response = await auth.createNewChat(token!, userId!);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        debugPrint("Chat creation response: ${response.body}");

        if (body['status'] == true && body['data'] != null) {
          final data = body['data'];
          title = data['title'];

          return {
            'id': data['id'],
            'slug': data['slug'],
            'title': data['title'],
          };
        }
      }
    } catch (e) {
      debugPrint("Error creating chat: $e");
    }

    return null;
  }

  Future<void> _getOwnChat() async {
    if (isLoadingOwnChats) return;

    setState(() => isLoadingOwnChats = true);
    try {
      AuthService auth = AuthService();
      final response = await auth.getAllChats(token!);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> chats = data['chats'];
        print("Cahtes data get: $chats");
        print("CHATES DATASSS: $data");
        _showChatsPopup(chats);
      } else {
        print("Failed to fetch chats: ${response.body}");
      }
    } catch (e) {
      print("Error fetching chats: $e");
    } finally {
      setState(() => isLoadingOwnChats = false);
    }
  }

  Future<void> _showHistory(BuildContext context, List<dynamic> chats) async {
    final validChats =
    chats.where((chat) {
      final prompts = chat['prompts'] as List<dynamic>? ?? [];
      final firstPrompt = prompts.isNotEmpty ? prompts.first : null;
      final requestText =
      (firstPrompt?['request_text'] ?? '').toString().trim();
      return requestText.isNotEmpty;
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "📜 Chat History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Chat history content
                SizedBox(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child:
                  validChats.isEmpty
                      ? const Center(
                    child: Text(
                      "No chat history available.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                      : StatefulBuilder(
                    builder: (context, setState) {
                      return Scrollbar(
                        child: ListView.separated(
                          separatorBuilder:
                              (_, __) => const Divider(
                            color: Colors.white10,
                            thickness: 0.5,
                          ),
                          itemCount: validChats.length,
                          itemBuilder: (context, index) {
                            final chat = validChats[index];
                            final int chatId = chat['id'];
                            final List<dynamic> prompts =
                            chat['prompts'];
                            // if (prompts.isEmpty ||
                            //     (prompts.first['request_text'] ?? '')
                            //         .toString()
                            //         .trim()
                            //         .isEmpty) {
                            //   return const SizedBox.shrink();
                            // }

                            final String request =
                            prompts.first['request_text'];

                            // final String request = prompts.isNotEmpty
                            //     ? (prompts.first['request_text'] ?? '')
                            //     : "No prompt";

                            return Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // Bubble style
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A2A40),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      request,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<
                                        bool
                                    >(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                        backgroundColor:
                                        const Color(0xFF2E2E3E),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        title: const Text(
                                          "Delete Chat",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        content: const Text(
                                          "Are you sure you want to delete this chat?",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                              ctx,
                                            ).pop(false),
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                              ctx,
                                            ).pop(true),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color:
                                                Colors
                                                    .redAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      final success = await _deleteChat(
                                        chatId,
                                      );
                                      if (success) {
                                        setState(() {
                                          validChats.removeAt(index);
                                        });
                                        // Navigator.of(context)
                                        //     .pop(); // Close history dialog
                                        //_getOwnChat(); // Refresh chat list
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chatBubble(String message, {required bool isSender}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.indigo[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<bool> _deleteChat(int chatId) async {
    try {
      AuthService auth = AuthService();
      final response = await auth.deletChat(token!, chatId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Delete Chat Successfully");
        // Navigator.pop(context);
        // _getOwnChat();
        return true;
      } else {
        print("Not Delete Chat");
        return false;
      }
    } catch (e) {
      print("Error while delete chat, $e");
      return false;
    }
  }

  Future<void> _showPromptMenu(BuildContext context) async {
    try {
      AuthService auth = AuthService();

      print("CHECK THE SUB CATEGORY ID: ${selectedCategoryId!}");
      final response = await auth.getSubCategories(token!, selectedCategoryId!);
      print("CAT RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          data = responseData['data'];
        } else {
          print("Unexpected response structure");
          return;
        }

        await _showSelectPrompt(data);
      } else {
        print("Failed to fetch chats: ${response.body}");
      }
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  Future<void> _showSelectPrompt(List<dynamic> prompts) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.zero,
              titlePadding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),

              title: const Text(
                "✨ Select a Prompt",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),

              content: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 300,
                  child: prompts.isEmpty
                      ? const Center(
                    child: Text(
                      "No prompts available.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                      : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      itemCount: prompts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final prompt = prompts[index];
                        final String name = prompt['name'] ?? 'Untitled';
                        final String id = prompt['id'].toString();

                        return GestureDetector(
                          onTap: () {
                            debugPrint("🔁 Previous Prompt ID: $_selectedPromptId");

                            setState(() {
                              _messageController.text = name;
                              _selectedPromptId = id;
                            });

                            debugPrint("✅ Selected Prompt ID: $_selectedPromptId");
                            Navigator.of(dialogContext).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A40),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openChatPopup() async {
    print("Fetching chats...");
    final response = await AuthService().getAllChats(token!);

    if (response.statusCode == 200) {
      final List<dynamic> chats = jsonDecode(response.body);
      _showChatsPopup(chats);
    } else {
      print("Failed to fetch chats: ${response.statusCode}");
      _showChatsPopup([]);
    }
  }

  void _showChatsPopup(List<dynamic> chats) {
    final List<dynamic> validChats =
    chats
        .where(
          (chat) =>
      chat['title'] != null &&
          chat['title'].toString().trim().isNotEmpty,
    )
        .toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "🗨️ My Chats",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chat list or empty text
                    SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child:
                      validChats.isEmpty
                          ? const Center(
                        child: Text(
                          "No chats available.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                          : StatefulBuilder(
                        builder: (context, setState) {
                          return Scrollbar(
                            child: ListView.separated(
                              separatorBuilder:
                                  (_, __) => const Divider(
                                color: Colors.white10,
                                thickness: 0.5,
                              ),
                              itemCount: validChats.length,
                              itemBuilder: (context, index) {
                                final chat = validChats[index];
                                slug = chat['slug'];
                                return ListTile(
                                  tileColor: const Color(0xFF2A2A40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  title:
                                  (chat['title']
                                      ?.toString()
                                      .trim()
                                      .isEmpty ??
                                      true)
                                      ? const SizedBox.shrink()
                                      : Text(
                                    chat['title'],
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),

                                  trailing:
                                  (chat['title']
                                      ?.toString()
                                      .trim()
                                      .isEmpty ??
                                      true)
                                      ? null
                                      : IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      bool deleted =
                                      await _deleteChat(
                                        chat['id'],
                                      );
                                      if (deleted) {
                                        setState(() {
                                          validChats.removeAt(
                                            index,
                                          );
                                        });
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ChatScreen(
                                          chatId: chat['id'],
                                          chatSlug: chat['slug'],
                                          prompts: chat["prompts"],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.deepPurpleAccent.withOpacity(
                            0.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Close",
                          style: TextStyle(color: Colors.white70),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteMessage(int index, int promptId) async {
    try {
      final response = await AuthService().deletePropmt(token!, promptId);

      if (response.statusCode == 204 || response.statusCode == 200) {
        setState(() {
          _messages.removeAt(index);
          if (index < _messages.length && !_messages[index].isUser) {
            _messages.removeAt(index);
          }
        });
      } else {
        print("Failed to delete prompt: ${response.body}");
      }
    } catch (e) {
      print("Error deleting prompt: $e");
    }
  }

  void _selectPrompt(String prompt) async {
    Navigator.pop(context);
    int subCategoryId = 1;

    final response = await AuthService().createPrompt(
      token!,
      chatId!,
      prompt,
      selectedCategoryId!,
      subCategoryId: int.parse(_selectedPromptId),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String aiReply = data['ai_response'] ?? "No response from AI.";
      int promptId = data['prompt_id'];

      setState(() {
        int userMsgIndex = _messages.length;

        _messages.add(
          ChatMessage(
            text: prompt,
            isUser: true,
            onEdit: (text) => _editMessage(userMsgIndex, text),
            onDelete: () => _deleteMessage(userMsgIndex, promptId),
          ),
        );

        _messages.add(ChatMessage(text: aiReply, isUser: false));
      });
    } else {
      print("❌ Failed to create prompt: ${response.body}");
    }
  }

  void _editMessage(int index, String newText) async {
    setState(() {
      _messages[index] = ChatMessage(
        text: newText,
        isUser: true,
        onEdit: (text) => _editMessage(index, text),
      );

      if (index + 1 < _messages.length && !_messages[index + 1].isUser) {
        _messages.removeAt(index + 1);
      }
    });

    try {
      final response = await AuthService().createPrompt(
        token!,
        chatId!,
        newText,
        selectedCategoryId!,
        subCategoryId: int.parse(_selectedPromptId!),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String aiReply = data['ai_response'] ?? "No response from AI.";

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _messages.insert(
                index + 1,
                ChatMessage(
                  text: aiReply,
                  isUser: false, // AI message
                  onEdit: null,  // AI response shouldn't be editable
                ),
              );
            });
          }
        });
      } else {
        print("❌ Failed to regenerate prompt: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error while regenerating prompt: $e");
    }
  }

  void _sendMessage() async {
    try {
      print("Send tapped");
      if (_messageController.text.trim().isEmpty) return;

      String messageText = _messageController.text.trim();

      if (_messages.isEmpty) {
        final chatSession = await _createNewChatSession();
        if (chatSession == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to create chat session")),
            );
          }
          return;
        }
        chatId = chatSession['id'] as int;
      }

      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: messageText,
            isUser: true,
            onEdit: (text) => _editMessage(_messages.length - 1, text),
          ),
        );
        _messageController.clear();
        _showChat = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      setState(() {
        _messages.add(ChatMessage(
          text: "🤖 Wait AI Generate the response...",
          isUser: false,
        ));
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      print("TOKEN DATA: $token");
      print("chatId DATA: $chatId");
      print("MessageText DATA: $messageText");
      print("selectedCategoryId DATA: $selectedCategoryId");
      print("selectedCategoryId DATA: $_selectedPromptId");

      try {
        final response = await AuthService().createPrompt(
          token!,
          chatId!,
          messageText,
          selectedCategoryId!,
          subCategoryId: _selectedPromptId != null
              ? int.tryParse(_selectedPromptId!) ?? 1
              : 1,
        );

        if (response.statusCode == 201 && mounted) {
          Map<String, dynamic> data = jsonDecode(response.body);
          String aiReply = data['ai_response'] ?? "No response from AI.";

          setState(() {
            // Remove the loading message and add the AI response
            _messages.removeLast();
            _messages.add(ChatMessage(text: aiReply, isUser: false));
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Failed to get response")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        }
      }
    } catch (e) {
      print("Exception in _sendMessage: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String? filePath = file.path;

        setState(() {
          if (filePath != null) {
            _selectedImageFile = File(filePath); // use file path
          }

          _selectedImageBytes = file.bytes; // this might be null
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image selected!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  Future<bool> _handleWillPop() async {
    if (token != null && token!.isNotEmpty) {
      final now = DateTime.now();
      const maxDuration = Duration(seconds: 2);
      if (_lastPressedAt == null ||
          now.difference(_lastPressedAt!) > maxDuration) {
        _lastPressedAt = now;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return false;
      }

      SystemNavigator.pop();
      return true;
    }

    return true;
  }


  // Future<bool> _handleWillPop() async {
  //   if (token != null && token!.isNotEmpty) {
  //     final now = DateTime.now();
  //     const maxDuration = Duration(seconds: 2);
  //
  //     if (_lastPressedAt == null ||
  //         now.difference(_lastPressedAt!) > maxDuration) {
  //       _lastPressedAt = now;
  //
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Press back again to logout'),
  //             duration: Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //       return false;
  //     }
  //
  //     return await _showExitConfirmationDialog();
  //   }
  //   return true;
  // }
  //
  // Future<bool> _showExitConfirmationDialog() async {
  //   final shouldLogout = await showDialog<bool>(
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return AlertDialog(
  //         title: const Text(
  //           'Confirm Logout',
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         content: const Text('Are you sure you want to log out?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(dialogContext).pop(false),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               foregroundColor: Colors.white,
  //               backgroundColor: Colors.red,
  //             ),
  //             onPressed: () => Navigator.of(dialogContext).pop(true),
  //             child: const Text('Logout'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   if (shouldLogout == true) {
  //     await _performLogout();
  //     return true;
  //   }
  //
  //   return false;
  // }

  Future<void> _performLogout() async {
    try {
      await _googleSignIn.signOut();
      final pref = await SharedPreferences.getInstance();
      await pref.remove("access_token");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Log_In()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xff1B0B25),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
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
                        foreground:
                            Paint()
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
            ],
          ),
          actions: [
            Builder(
              builder:
                  (context) => GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Image.asset(
                        'assets/image/Drawer.png',
                        height: 28,
                        width: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
          ],
        ),
        endDrawer: Padding(
          padding: const EdgeInsets.only(top: 75, bottom: 300),
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
                          Color(0xFFF2E9D8),
                          Color(0xFFD0A197),
                          Color(0xFFC2797A),
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
                            backgroundImage:
                                userProfile != null
                                    ? NetworkImage(userProfile!)
                                    : AssetImage('assets/image/person.png')
                                        as ImageProvider,
                          ),

                          const SizedBox(width: 6),
                          Text(
                            userName ?? "No Name",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                ListTile(
                  title: const Text(
                    'New Chats',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    if (isLoadingnewchat) return;

                    setState(() => isLoadingnewchat = true);
                    try {
                      final result = await _createNewChatSession();
                      if (result != null) {
                        final chatId = result['id'];
                        final slug = result['slug'];

                        if (chatId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chatId,
                                chatSlug: slug,
                                prompts: [],
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Failed to create new chat")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Failed to create new chat")),
                        );
                      }
                    } catch (e) {
                      print("Error creating new chat: $e");
                    } finally {
                      setState(() => isLoadingnewchat = false);
                    }
                    ;
                  },
                ),
                ListTile(
                  title: const Text(
                    'Own Chats',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _getOwnChat();
                  },
                ),
                ListTile(
                  title: const Text(
                    'History',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    if (isLoadingHistory) return;

                    setState(() => isLoadingHistory = true);

                    try {
                      AuthService auth = AuthService();
                      final response = await auth.getAllChats(token!);
                      if (response.statusCode == 200) {
                        final Map<String, dynamic> data =
                        jsonDecode(response.body);
                        final List<dynamic> chats = data['chats'];
                        await _showHistory(context, chats);
                      } else {
                        print("Failed to fetch chats: ${response.body}");
                      }
                    } catch (e) {
                      print("Error fetching chats: $e");
                    } finally {
                      setState(() => isLoadingHistory = false);
                    }
                    // try {
                    //   AuthService auth = AuthService();
                    //   final response = await auth.getAllChats(token!);
                    //   if (response.statusCode == 200) {
                    //     final Map<String, dynamic> data =
                    //         jsonDecode(response.body);
                    //     final List<dynamic> chats = data['chats'];
                    //     await _showHistory(context, chats);
                    //   } else {
                    //     print("Failed to fetch chats: ${response.body}");
                    //   }
                    // } catch (e) {
                    //   print("Error fetching chats: $e");
                    // }
                  },
                ),

                ListTile(
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    launchExternalUrl('https://figpromptfinder.com/privacy');
                    // final Uri url =
                    //     Uri.parse('https://figpromptfinder.com/privacy');
                    // if (await canLaunchUrl(url)) {
                    //   await launchUrl(url,
                    //       mode: LaunchMode.externalApplication);
                    // } else {
                    //   throw 'Could not launch $url';
                    // }
                  },
                ),
                ListTile(
                  title: const Text(
                    'Terms & Conditions',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    launchExternalUrl('https://figpromptfinder.com/terms');
                  },
                ),
                ListTile(
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    launchExternalUrl('https://figpromptfinder.com/privacy');
                  },
                ),

                const Divider(color: Colors.white38, endIndent: 15, indent: 15),
                ListTile(
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    try {
                      await _googleSignIn.signOut();

                      final pref = await SharedPreferences.getInstance();
                      await pref.remove("access_token");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Logout Successfully!")),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Log_In()),
                      );
                    } catch (error) {
                      print('Logout failed: $error');
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategoryId?.toString(),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        dropdownColor: Colors.black,
                        onChanged: (String? newValue) {
                          if (newValue == 'create_prompt') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dailogbox();
                              },
                            );
                          } else {
                            setState(() {
                              selectedCategoryId = int.parse(newValue!);
                              print(
                                "SELECTED CATEGORY UPDATED: $selectedCategoryId",
                              );
                            });
                          }
                        },
                        items: [
                          // const DropdownMenuItem<String>(
                          //   value: 'create_prompt',
                          //   child: Text('Create Prompt'),
                          // ),
                          ...categories.map<DropdownMenuItem<String>>((
                            PromptCategory category,
                          ) {
                            return DropdownMenuItem<String>(
                              value: category.id.toString(),
                              child: Text(category.name),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    // child: DropdownButtonHideUnderline(
                    //   child: DropdownButton<String>(
                    //     value: selectedCategoryId,
                    //     icon: const Icon(
                    //       Icons.arrow_drop_down,
                    //       color: Colors.white,
                    //     ),
                    //     style: GoogleFonts.poppins(
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w500,
                    //       color: Colors.white,
                    //     ),
                    //     dropdownColor: Colors.black,
                    //     onChanged: (String? newValue) {
                    //       setState(() {
                    //         selectedCategoryId = newValue!;
                    //       });
                    //     },
                    //     items:
                    //     categories.map<DropdownMenuItem<String>>((
                    //         PromptCategory category,
                    //         ) {
                    //       return DropdownMenuItem<String>(
                    //         value: category.id,
                    //         child: Text(category.name),
                    //       );
                    //     }).toList(),
                    //   ),
                    // ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          if (_isPromptMenuOpen) return;

                          _isPromptMenuOpen = true;
                          await _showPromptMenu(context);
                          _isPromptMenuOpen = false;
                        },

                        child: const Text(
                          'Select Prompts',
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (_isCreatingChat) return;

                          _isCreatingChat = true;

                          try {
                            final result = await _createNewChatSession();
                            if (result != null) {
                              final chatId = result['id'];
                              final slug = result['slug'];

                              if (chatId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                        ChatScreen(
                                          chatId: chatId,
                                          chatSlug: slug,
                                          prompts: [],
                                        ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to create new chat"),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to create new chat"),
                                ),
                              );
                            }
                          } finally {
                            _isCreatingChat = false;
                          }
                        },
                        child: Image.asset(
                          'assets/image/Edit.png',
                          height: 25,
                          width: 25,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.black45,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.025),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // If chat is off
                          if (!_showChat) ...[
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.00625),
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/image/Logo.png',
                                    height: 60,
                                  ),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.00625),
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
                                                const Rect.fromLTWH(
                                                  0,
                                                  0,
                                                  100,
                                                  40,
                                                ),
                                              ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.00625),
                                  Text(
                                    'Ready to assist you with anything you need, from answering questions to providing recommendations.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Welcome, Dashboard',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.00625),
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
                          ] else ...[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _messages.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return _messages[index];
                                },
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.00625),

              // Chat Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(color: Colors.white, width: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 0.2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedImageBytes != null ||
                                _selectedImageFile != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            _selectedImageBytes != null
                                                ? Image.memory(
                                                  _selectedImageBytes!,
                                                  fit: BoxFit.cover,
                                                )
                                                : Image.file(
                                                  _selectedImageFile!,
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImageBytes = null;
                                            _selectedImageFile = null;
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // TextField inside fixed-height container with scroll
                            Container(
                              height: 100, // fixed height
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: TextField(
                                  controller: _messageController,
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  style: const TextStyle(color: Colors.white),
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(12),
                                    border: InputBorder.none,
                                    hintText: 'Start typing, get magic...',
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // InkWell(
                      //   child: Image.asset(
                      //     'assets/image/Photo.png',
                      //     height: 30,
                      //     width: 30,
                      //   ),
                      //   onTap: () {
                      //     _pickImage(context);
                      //   },
                      // ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          _sendMessage();
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, chatSlug: "")));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
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
    );
  }
}
