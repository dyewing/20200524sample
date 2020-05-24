import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample1app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sample1app/screen/home_screen.dart';

final _firestone = Firestore.instance;
FirebaseUser loggedInUser;

class TweetScreen extends StatefulWidget {
  static const String id = 'tweet_screen';

  @override
  _TweetScreenState createState() => _TweetScreenState();
}

class _TweetScreenState extends State<TweetScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestone.collection('messages').snapshots()) {
      for (var messages in snapshot.documents) {
        print(messages.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage('images/icon.png'),
              ),
              Text('Tweet'),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              messagesStream();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestone.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _dummybottomnavitationBar,
    );
  }

  Widget get _dummybottomnavitationBar => Container(
        height: 80.0,
        color: Colors.black12,
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Column(
              children: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.home,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, HomeScreen.id);
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestone.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];

          final currentUser = loggedInUser.email;

          if (currentUser == messageSender) {
            //The message from the logged in user.
          }

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: isMe ? AssetImage('images/icon.png') : null,
                  backgroundColor: Colors.white,
                ),
                Text(
                  sender,
                  style: isMe
                      ? TextStyle(fontSize: 15.0, color: Colors.black54)
                      : TextStyle(color: Colors.white),
                ),
              ],
            ),
            Material(
              borderRadius: BorderRadius.circular(10.0),
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
