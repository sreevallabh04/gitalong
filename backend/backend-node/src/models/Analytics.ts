import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IAnalytics extends Document {
  userId?: string;
  event: string; // e.g., view_project, swipe_right, send_message
  properties: Record<string, any>;
  createdAt: Date;
}

const AnalyticsSchema = new Schema<IAnalytics>(
  {
    userId: { type: String, index: true },
    event: { type: String, required: true, index: true },
    properties: { type: Schema.Types.Mixed, default: {} },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

AnalyticsSchema.index({ event: 1, createdAt: -1 });

export const Analytics: Model<IAnalytics> = mongoose.model<IAnalytics>('Analytics', AnalyticsSchema);
