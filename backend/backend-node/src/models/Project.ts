import mongoose, { Schema, Document, Model, Types } from 'mongoose';

export interface IProject extends Document {
  owner: Types.ObjectId;
  title: string;
  description?: string;
  tags: string[];
  visibility: 'public' | 'private';
  repoUrl?: string;
  languages: string[];
  stars: number;
  forks: number;
  createdAt: Date;
  updatedAt: Date;
}

const ProjectSchema = new Schema<IProject>(
  {
    owner: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true },
    description: { type: String },
    tags: { type: [String], default: [] },
    visibility: { type: String, enum: ['public', 'private'], default: 'public', index: true },
    repoUrl: { type: String },
    languages: { type: [String], default: [] },
    stars: { type: Number, default: 0 },
    forks: { type: Number, default: 0 },
  },
  { timestamps: true }
);

ProjectSchema.index({ title: 'text', description: 'text', tags: 1 });

export const Project: Model<IProject> = mongoose.model<IProject>('Project', ProjectSchema);
