import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

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

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.text);
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
        crossAxisAlignment:
            widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                      else if (_isEditing)
                        TextField(
                          controller: _editController,
                          autofocus: true,
                          maxLines: null,
                          minLines: 3,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Edit your message...',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.white10,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                          onSubmitted: (newText) {
                            widget.onEdit?.call(newText);
                            // _sendMessage();
                            setState(() => _isEditing = false);
                          },
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
          if (widget.isUser && widget.imagePath == null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditing) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        widget.onEdit?.call(_editController.text);
                        setState(() => _isEditing = false);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _editController.text = widget.text;
                          _isEditing = false;
                        });
                      },
                    ),
                  ] else
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _isEditing = true);
                      },
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
