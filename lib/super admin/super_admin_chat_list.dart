import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'super_admin_chat.dart';

class SuperAdminChatList extends StatefulWidget {
  const SuperAdminChatList({super.key});

  @override
  State<SuperAdminChatList> createState() =>
      _SuperAdminChatListState();
}

class _SuperAdminChatListState
    extends State<SuperAdminChatList> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GET ALL ADMIN CHAT DOCUMENTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get adminChatsStream {
    return _firestore
        .collection('adminChats')
        .snapshots();
  }

  // ============================================================
  // GET ADMIN INFORMATION
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getAdmin(
    String adminDocumentId,
  ) {
    return _firestore
        .collection('Admin')
        .doc(adminDocumentId)
        .get();
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

    final String minute =
        date.minute.toString().padLeft(2, '0');

    final String period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // GET LAST MESSAGE
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      messagesStream(
    String adminDocumentId,
  ) {
    return _firestore
        .collection('adminChats')
        .doc(adminDocumentId)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(1)
        .snapshots();
  }

  // ============================================================
  // COUNT UNREAD ADMIN MESSAGES
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      unreadMessagesStream(
    String adminDocumentId,
  ) {
    return _firestore
        .collection('adminChats')
        .doc(adminDocumentId)
        .collection('messages')
        .where(
          'senderRole',
          isEqualTo: 'admin',
        )
        .where(
          'read',
          isEqualTo: false,
        )
        .snapshots();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7F7),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFFFECB04),

        title: Text(
          'Admin Chats',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      // ========================================================
      // CHAT LIST
      // ========================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: adminChatsStream,

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Unable to load admin chats.\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final chatDocuments =
              snapshot.data?.docs ?? [];

          if (chatDocuments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 70,
                    color:
                        Colors.grey.shade400,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'No Admin Chats',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Admin conversations will appear here.',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: chatDocuments.length,
            itemBuilder: (
              context,
              index,
            ) {
              final chatDocument =
                  chatDocuments[index];

              final String
                  adminDocumentId =
                  chatDocument.id;

              return FutureBuilder<
                  DocumentSnapshot<
                      Map<String, dynamic>>>(
                future:
                    getAdmin(adminDocumentId),

                builder: (
                  context,
                  adminSnapshot,
                ) {
                  if (adminSnapshot
                          .connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 80,
                      child: Center(
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  final adminData =
                      adminSnapshot.data?.data();

                  final String adminName =
                      adminData?['name']
                              ?.toString() ??
                          'Admin';

                  final String adminId =
                      adminData?['id']
                              ?.toString() ??
                          '';

                  final bool active =
                      adminData?['active'] ??
                          true;

                  return StreamBuilder<
                      QuerySnapshot<
                          Map<String, dynamic>>>(
                    stream:
                        messagesStream(
                      adminDocumentId,
                    ),

                    builder: (
                      context,
                      messageSnapshot,
                    ) {
                      String lastMessage =
                          'No messages yet';

                      Timestamp? lastMessageTime;

                      if (messageSnapshot
                              .hasData &&
                          messageSnapshot
                              .data!
                              .docs
                              .isNotEmpty) {
                        final data =
                            messageSnapshot
                                .data!
                                .docs
                                .first
                                .data();

                        lastMessage =
                            data['message']
                                    ?.toString() ??
                                'No messages yet';

                        if (data['createdAt']
                            is Timestamp) {
                          lastMessageTime =
                              data['createdAt']
                                  as Timestamp;
                        }
                      }

                      return StreamBuilder<
                          QuerySnapshot<
                              Map<String,
                                  dynamic>>>(
                        stream:
                            unreadMessagesStream(
                          adminDocumentId,
                        ),

                        builder: (
                          context,
                          unreadSnapshot,
                        ) {
                          final int
                              unreadCount =
                              unreadSnapshot
                                      .data
                                      ?.docs
                                      .length ??
                                  0;

                          return _buildChatCard(
                            context: context,
                            adminDocumentId:
                                adminDocumentId,
                            adminName:
                                adminName,
                            adminId: adminId,
                            active: active,
                            lastMessage:
                                lastMessage,
                            lastMessageTime:
                                lastMessageTime,
                            unreadCount:
                                unreadCount,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // CHAT CARD
  // ============================================================

  Widget _buildChatCard({
    required BuildContext context,
    required String adminDocumentId,
    required String adminName,
    required String adminId,
    required bool active,
    required String lastMessage,
    required Timestamp? lastMessageTime,
    required int unreadCount,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SuperAdminChat(
                adminDocumentId:
                    adminDocumentId,
                adminName:
                    adminName,
                adminId: adminId,
              ),
            ),
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(14),
          child: Row(
            children: [
              // ==================================================
              // ADMIN ICON
              // ==================================================

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: active
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),

              const SizedBox(width: 13),

              // ==================================================
              // ADMIN INFORMATION
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            adminName,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  Colors.black,
                            ),
                          ),
                        ),

                        if (unreadCount > 0)
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          20),
                            ),
                            child: Text(
                              unreadCount >
                                      99
                                  ? '99+'
                                  : unreadCount
                                      .toString(),
                              style:
                                  GoogleFonts
                                      .poppins(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (adminId.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 2,
                        ),
                        child: Text(
                          'ID: $adminId',
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 10,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                GoogleFonts
                                    .poppins(
                              fontSize: 12,
                              color: Colors
                                  .grey
                                  .shade600,
                              fontWeight:
                                  unreadCount >
                                          0
                                      ? FontWeight
                                          .w600
                                      : FontWeight
                                          .normal,
                            ),
                          ),
                        ),

                        if (lastMessageTime !=
                            null) ...[
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            formatTime(
                              lastMessageTime,
                            ),
                            style:
                                GoogleFonts
                                    .poppins(
                              fontSize: 9,
                              color: Colors
                                  .grey
                                  .shade500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,
                            color: active
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Text(
                          active
                              ? 'Active'
                              : 'Inactive',
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 10,
                            color: active
                                ? Colors
                                    .green
                                    .shade700
                                : Colors
                                    .orange
                                    .shade700,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons
                    .arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}