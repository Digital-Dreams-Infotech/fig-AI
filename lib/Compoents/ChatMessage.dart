import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage extends StatefulWidget {
  final String text;
  final bool isUser;
  final String? imagePath;
  final Function(String)? onEdit;
  final VoidCallback? onDelete;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.imagePath,
    this.onEdit,
    this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool _isEditing = false;
  late TextEditingController _editController;
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.text);
    _loadLikeDislikeState();
  }

  Future<void> _loadLikeDislikeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLiked = prefs.getBool('like_${widget.text}') ?? false;
      _isDisliked = prefs.getBool('dislike_${widget.text}') ?? false;
    });
  }

  Future<void> _saveLikeDislikeState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('like_${widget.text}', _isLiked);
    prefs.setBool('dislike_${widget.text}', _isDisliked);
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _isDisliked = false;
    });
    _saveLikeDislikeState();
  }

  void _toggleDislike() {
    setState(() {
      _isDisliked = !_isDisliked;
      _isLiked = false;
    });
    _saveLikeDislikeState();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response copied!'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  void _shareText() {
    Share.share(widget.text);
  }

  Widget _buildMessageContent(BuildContext context, String text) {
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(color: Colors.white70, fontSize: 14),
        strong: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white60),
        code: const TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Colors.transparent,
          color: Colors.white,
        ),
        blockquote: const TextStyle(color: Colors.grey),
        listBullet: const TextStyle(color: Colors.white),
        codeblockDecoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      builders: {'code': CodeBlockBuilder(context)},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      child: Column(
        crossAxisAlignment: widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isUser)
                CircleAvatar(
                  backgroundColor: Colors.purple[300],
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              if (!widget.isUser) const SizedBox(width: 10),
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
                      if (widget.imagePath != null)
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(widget.imagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Builder(
                          builder: (context) {
                            try {
                              return _buildMessageContent(context, widget.text);
                            } catch (e) {
                              debugPrint("Markdown rendering failed: $e");
                              return Text(
                                widget.text,
                                style: const TextStyle(color: Colors.white70),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Add copy/share buttons only for received messages
          if (!widget.isUser)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: Colors.white60,
                    ),
                    tooltip: 'Copy response',
                    onPressed: _copyToClipboard,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share,
                      size: 20,
                      color: Colors.white60,
                    ),
                    tooltip: 'Share response',
                    onPressed: _shareText,
                  ),
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      size: 20,
                      color: Colors.blue,
                    ),
                    tooltip: 'Like this message',
                    onPressed: _toggleLike,
                  ),
                  IconButton(
                    icon: Icon(
                      _isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                      size: 20,
                      color: Colors.red,
                    ),
                    tooltip: 'Dislike this message',
                    onPressed: _toggleDislike,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeBlockBuilder(this.context);

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final codeText = element.textContent.trim();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 30),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                codeText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.copy, size: 16, color: Colors.white54),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: codeText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Code copied!'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}