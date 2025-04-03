import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmessages/components/chat_bubble.dart';
import 'package:dmessages/components/my_textfield.dart';
import 'package:dmessages/services/auth/auth_service.dart';
import 'package:dmessages/services/chat/chat_services.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  // user requirements
  // Needed in order to identify
  // who the user is chatting with
  final String receiverEmail;
  final String receiverID;
  final String receiverName;

   const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // create text box for chatting
  final TextEditingController _messageController = TextEditingController();

  // chat + auth services for messaging 
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // focus node necessary to automatically scroll messages down
  // i.e. for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //add the listener to the focus node -> 
    myFocusNode.addListener((){
      if (myFocusNode.hasFocus) {
        // create a delay in order for the keyboard to appear
        // calculate remaining space on the screen, then scroll down
        // automatically
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    // apply artificial loading to wait for the list to be constructed/built
    Future.delayed(const Duration(milliseconds: 500),
    () => scrollDown(),
    );

  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // create a scroll controller -> 
  final ScrollController _scrollController = ScrollController();
  void scrollDown(){
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
      );
  }

  // sending the message 
  void sendMessage() async {
    // case where there is input inside of the text field:
    if(_messageController.text.isNotEmpty) {
      // send the message
      await _chatService.sendMessage(widget.receiverID, _messageController.text);


      // after sending the message, clear the controller ->
      _messageController.clear();

    }
    // scroll down to the bottom after sending a message
    // so we can see the latest message ->
    scrollDown();
  }

  // messaging UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        // Start: Cleaner, minimalist look
        // can also implement to all other app bars
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        // End
        ),
      body: Column(
        children: [
          // display all of the messages
          // to fill out most of the screen:
          Expanded(
            child: _buildMessageList()
            ),

          // display the user input ->
          _buildUserInput(),
        ],
      ),
    );
  }

  // build the message list to output:
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID), 
      builder: (context, snapshot){
        // check for any errors:
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading...

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // finally, return the list view for messages
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          // return a message item given a document 
        ); 
      },
    );
  }

 // now build the message item: 
 Widget _buildMessageItem(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  // UI for chat room

  // is current user
  bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

  // align the message to the right for the sender, receivers on the left
  var alignment =
      isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

  // return the message
  return Container(
    alignment: alignment,
    child: Column(
      crossAxisAlignment: 
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [ 
    ChatBubble(
      message: data["message"], 
      isCurrentUser: isCurrentUser,
    )
    ]
  )
  ); 
 }

 // finally, build the user input
 Widget _buildUserInput() {
  return Padding(
    padding: const EdgeInsets.only(bottom:50.0),
    child: Row(
      children: [
        // textfield has to take up majority of the space
        // so use 'Expanded' widget
        Expanded(
          child: MyTextField(
            controller: _messageController,
            hintText: "Type a message here:",
            obscureText: false,
            focusNode: myFocusNode,
            ),
          ),
          // implement the send button
          Container(
            decoration: BoxDecoration(color: Colors.amber,
            shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage, 
              icon: const Icon(Icons.arrow_upward,
              color: Colors.white,
              ),
            ),
          ),
      ],
    ),
  );
 }
}