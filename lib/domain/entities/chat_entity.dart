import 'package:equatable/equatable.dart';

/// Chat entity representing a conversation
class ChatEntity extends Equatable {
  /// Unique identifier for the chat
  final String id;

  /// Display name of the chat
  final String name;

  /// Last message content in the chat
  final String? lastMessage;

  /// Timestamp of the last message
  final DateTime? lastMessageAt;

  /// ID of the user who sent the last message
  final String? lastMessageSenderId;

  /// List of participants in the chat
  final List<ChatParticipant> participants;

  /// Type of chat (direct, group, project)
  final ChatType type;

  /// When the chat was created
  final DateTime createdAt;

  /// When the chat was last updated
  final DateTime updatedAt;

  /// Whether the chat is currently active
  final bool isActive;

  /// Number of unread messages
  final int unreadCount;

  /// Associated project ID if this is a project chat
  final String? projectId;

  /// Creates a chat entity
  const ChatEntity({
    required this.id,
    required this.name,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.participants,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.unreadCount,
    this.projectId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    lastMessage,
    lastMessageAt,
    lastMessageSenderId,
    participants,
    type,
    createdAt,
    updatedAt,
    isActive,
    unreadCount,
    projectId,
  ];
}

/// Chat participant entity
class ChatParticipant extends Equatable {
  /// User ID of the participant
  final String userId;

  /// Username of the participant
  final String username;

  /// Avatar URL of the participant
  final String? avatarUrl;

  /// Role of the participant in the chat
  final ChatRole role;

  /// When the participant joined the chat
  final DateTime joinedAt;

  /// When the participant was last seen
  final DateTime? lastSeenAt;

  /// Creates a chat participant
  const ChatParticipant({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.lastSeenAt,
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    avatarUrl,
    role,
    joinedAt,
    lastSeenAt,
  ];
}

/// Message entity representing a chat message
class MessageEntity extends Equatable {
  /// Unique identifier for the message
  final String id;

  /// ID of the chat this message belongs to
  final String chatId;

  /// ID of the user who sent the message
  final String senderId;

  /// Username of the sender
  final String senderUsername;

  /// Avatar URL of the sender
  final String? senderAvatarUrl;

  /// Content of the message
  final String content;

  /// Type of message (text, image, file, etc.)
  final MessageType type;

  /// When the message was sent
  final DateTime sentAt;

  /// When the message was last edited
  final DateTime? editedAt;

  /// Whether the message has been edited
  final bool isEdited;

  /// List of user IDs who have read the message
  final List<String> readBy;

  /// ID of the message this is replying to
  final String? replyToMessageId;

  /// Attachments in the message
  final List<MessageAttachment> attachments;

  /// Creates a message entity
  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatarUrl,
    required this.content,
    required this.type,
    required this.sentAt,
    this.editedAt,
    required this.isEdited,
    required this.readBy,
    this.replyToMessageId,
    required this.attachments,
  });

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    senderUsername,
    senderAvatarUrl,
    content,
    type,
    sentAt,
    editedAt,
    isEdited,
    readBy,
    replyToMessageId,
    attachments,
  ];
}

/// Message attachment entity
class MessageAttachment extends Equatable {
  /// Unique identifier for the attachment
  final String id;

  /// URL of the attachment
  final String url;

  /// Original filename of the attachment
  final String fileName;

  /// MIME type of the attachment
  final String fileType;

  /// Size of the attachment in bytes
  final int fileSize;

  /// Type of attachment (image, file, etc.)
  final AttachmentType type;

  /// Creates a message attachment
  const MessageAttachment({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.type,
  });

  @override
  List<Object?> get props => [id, url, fileName, fileType, fileSize, type];
}

enum ChatType { direct, group, project }

enum ChatRole { owner, admin, member }

enum MessageType { text, image, file, code, system }

enum AttachmentType { image, document, code, other }
