import 'package:chat_app_flutter_course/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authanticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          const Center(
            child: Text('No message found.'),
          );
        }

        if (!chatSnapshots.hasError) {
          const Center(
            child: Text('Something went wrond...'),
          );
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessages = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessages['userId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nexUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nexUserIsSame) {
              return MessageBubble.next(
                message: chatMessages['text'],
                isMe: authanticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                  userImage: chatMessages['userImage'],
                  username: chatMessages['username'],
                  message: chatMessages['text'],
                  isMe: authanticatedUser.uid == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
