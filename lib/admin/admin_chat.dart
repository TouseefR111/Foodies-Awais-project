import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminChat extends StatefulWidget {
  final String adminDocumentId;
  final String adminName;
  final String adminId;

  const AdminChat({
    super.key,
    required this.adminDocumentId,
    required this.adminName,
    required this.adminId,
  });

  @override
  State<AdminChat> createState() => _AdminChatState();
}

class _AdminChatState extends State<AdminChat> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  bool isSending = false;

  CollectionReference<Map<String, dynamic>> get messagesCollection {
    return _firestore
        .collection('adminChats')
        .doc(widget.adminDocumentId)
        .collection('messages');
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    final String message = messageController.text.trim();

    if (message.isEmpty || isSending) {
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      // ==========================================================
      // CREATE / UPDATE PARENT CHAT DOCUMENT
      // ==========================================================

      await _firestore
          .collection('adminChats')
          .doc(widget.adminDocumentId)
          .set({
            'adminDocumentId': widget.adminDocumentId,
            'adminId': widget.adminId,
            'adminName': widget.adminName,
            'lastMessage': message,
            'lastMessageAt': FieldValue.serverTimestamp(),
            'lastMessageSender': 'admin',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // ==========================================================
      // SAVE MESSAGE
      // ==========================================================

      await messagesCollection.add({
        'message': message,
        'senderId': widget.adminDocumentId,
        'senderName': widget.adminName,
        'senderRole': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // ==========================================================
      // CLEAR TEXT FIELD
      // ==========================================================

      messageController.clear();

      // ==========================================================
      // CLOSE KEYBOARD
      // ==========================================================

      if (mounted) {
        FocusScope.of(context).unfocus();
      }

      // ==========================================================
      // WAIT FOR FIRESTORE/UI UPDATE
      // ==========================================================

      await Future.delayed(const Duration(milliseconds: 300));

      // ==========================================================
      // SCROLL ONLY AFTER SENDING A MESSAGE
      // ==========================================================

      if (mounted) {
        scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send message: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void scrollToBottom() {
    if (!scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) {
        return;
      }

      final double maxScroll = scrollController.position.maxScrollExtent;

      scrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final DateTime date = timestamp.toDate();

    final int hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');

    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget messageBubble(Map<String, dynamic> data) {
    final String senderRole = data['senderRole']?.toString() ?? '';

    final bool isAdmin = senderRole == 'admin';

    final String message = data['message']?.toString() ?? '';

    final Timestamp? timestamp = data['createdAt'] is Timestamp
        ? data['createdAt'] as Timestamp
        : null;

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: EdgeInsets.only(
          left: isAdmin ? 50 : 10,
          right: isAdmin ? 10 : 50,
          top: 5,
          bottom: 5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          gradient: isAdmin
              ? const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isAdmin ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 16 : 4),
            bottomRight: Radius.circular(isAdmin ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

            if (timestamp != null) ...[
              const SizedBox(height: 5),

              Text(
                formatTime(timestamp),
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // Keep the normal Flutter keyboard resize behavior.
      // The important fix is that we no longer scroll the list
      // every time the keyboard causes a rebuild.
      resizeToAvoidBottomInset: true,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFECB04),
        centerTitle: true,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Super Admin',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            Text(
              'Contact Super Admin',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
            ),
          ],
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        children: [
          // ======================================================
          // INFORMATION BANNER
          // ======================================================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade800,
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Your account is currently inactive. '
                    'You can contact the Super Admin here regarding your account.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // CHAT
          // ======================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messagesCollection
                  .orderBy('createdAt', descending: false)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load messages.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'No messages yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Send a message to the Super Admin.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // IMPORTANT:
                // No scrollToBottom() here.
                //
                // The old code was scrolling every time this
                // StreamBuilder rebuilt. Keyboard opening/closing
                // can cause rebuilds, which created the shaking.

                return ListView.builder(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  padding: const EdgeInsets.only(top: 8, bottom: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();

                    return messageBubble(data);
                  },
                );
              },
            ),
          ),

          // ======================================================
          // MESSAGE INPUT
          // ======================================================
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ==================================================
                  // TEXT FIELD
                  // ==================================================
                  Expanded(
                    child: TextField(
                      controller: messageController,

                      minLines: 1,
                      maxLines: 5,

                      textCapitalization: TextCapitalization.sentences,

                      keyboardType: TextInputType.multiline,

                      textInputAction: TextInputAction.newline,

                      onSubmitted: (_) {
                        // Do not automatically send when the
                        // keyboard's action button is pressed.
                        //
                        // This prevents the keyboard from opening/
                        // closing unexpectedly while typing.
                      },

                      decoration: InputDecoration(
                        hintText: 'Type your message...',

                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),

                        filled: true,

                        fillColor: Colors.grey.shade100,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.orange.shade400,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ==================================================
                  // SEND BUTTON
                  // ==================================================
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: IconButton(
                      onPressed: isSending ? null : sendMessage,

                      icon: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.black,
                              size: 22,
                            ),
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
