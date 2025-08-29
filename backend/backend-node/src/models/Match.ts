import mongoose, { Schema, Document, Model, Types } from 'mongoose';

export interface IMatch extends Document {
  user: Types.ObjectId;
  project: Types.ObjectId;
  status: 'pending' | 'liked' | 'superliked' | 'matched' | 'rejected';
  score?: number;
  createdAt: Date;
  updatedAt: Date;
}

const MatchSchema = new Schema<IMatch>(
  {
    user: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    project: { type: Schema.Types.ObjectId, ref: 'Project', required: true, index: true },
    status: { type: String, enum: ['pending', 'liked', 'superliked', 'matched', 'rejected'], default: 'pending', index: true },
    score: { type: Number },
  },
  { timestamps: true }
);

MatchSchema.index({ user: 1, project: 1 }, { unique: true });

export const Match: Model<IMatch> = mongoose.model<IMatch>('Match', MatchSchema);
