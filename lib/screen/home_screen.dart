import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sample1app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample1app/screen/tweet_screen.dart';

final _firestone = Firestore.instance;

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
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
              Text('Home')
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
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _dummybottomnavitationBar,
    );
  }

  Widget get _dummybottomnavitationBar => Container(
        height: 80,
        color: Colors.black12,
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Column(
              children: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.comment,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, TweetScreen.id);
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
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
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
  MessageBubble({this.sender, this.text});

  final String sender;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage('images/icon.png'),
                ),
                Text(
                  sender,
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
            Container(
              width: 400.0,
              height: 150.0,
              color: Colors.lightBlueAccent,
              padding: const EdgeInsets.all(15.0),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
