import mongoose, { Schema, Document, Model, Types } from 'mongoose';

export interface IMessage extends Document {
  roomId: string; // could be user-user or project room
  sender: Types.ObjectId;
  recipient?: Types.ObjectId;
  content: string;
  type: 'text' | 'image' | 'file';
  readBy: Types.ObjectId[];
  createdAt: Date;
  updatedAt: Date;
}

const MessageSchema = new Schema<IMessage>(
  {
    roomId: { type: String, index: true, required: true },
    sender: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    recipient: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    content: { type: String, required: true },
    type: { type: String, enum: ['text', 'image', 'file'], default: 'text' },
    readBy: { type: [Schema.Types.ObjectId], ref: 'User', default: [] },
  },
  { timestamps: true }
);

MessageSchema.index({ roomId: 1, createdAt: -1 });

export const Message: Model<IMessage> = mongoose.model<IMessage>('Message', MessageSchema);
