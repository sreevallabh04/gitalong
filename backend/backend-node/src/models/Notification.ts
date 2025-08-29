import mongoose, { Schema, Document, Model, Types } from 'mongoose';

export interface INotification extends Document {
  user: Types.ObjectId;
  kind: 'match' | 'message' | 'system';
  title: string;
  body: string;
  data?: Record<string, any>;
  read: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const NotificationSchema = new Schema<INotification>(
  {
    user: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    kind: { type: String, enum: ['match', 'message', 'system'], required: true },
    title: { type: String, required: true },
    body: { type: String, required: true },
    data: { type: Schema.Types.Mixed },
    read: { type: Boolean, default: false, index: true },
  },
  { timestamps: true }
);

NotificationSchema.index({ user: 1, createdAt: -1 });

export const Notification: Model<INotification> = mongoose.model<INotification>('Notification', NotificationSchema);
