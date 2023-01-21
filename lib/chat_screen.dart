import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/threedots.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  ChatGPT? chatGPT;

  StreamSubscription? _subscription;
  bool _isTyping = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatGPT = ChatGPT.instance;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    ChatMessage message = ChatMessage(text: _controller.text, sender: "User");

    setState(() {
      _messages.insert(0, message);
      _isTyping=true;
    });
    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);
    _subscription = chatGPT!
        .builder("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",
            orgId: "")
        .onCompleteStream(request: request)
        .listen((response) {
          Vx.log(response!.choices[0].text);
          ChatMessage botMessage = ChatMessage(text: response!.choices[0].text, sender: "Bot");
          setState(() {
            _isTyping=false;
            _messages.insert(0, botMessage);

          });
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: InputDecoration.collapsed(hintText: "Tulis Pesan"),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.send),
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ChatGPT Coba"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) ThreeDots(),const Divider(height: 1.0,),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}
