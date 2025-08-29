import mongoose, { Schema, Document, Model } from 'mongoose';

export type UserRole = 'maintainer' | 'developer';

export interface IUser extends Document {
  email: string;
  username: string;
  name?: string;
  avatarUrl?: string;
  roles: UserRole[];
  providers: {
    github?: { id: string; username?: string; accessToken?: string };
    google?: { id: string };
  };
  skills: string[];
  createdAt: Date;
  updatedAt: Date;
}

const ProviderSchema = new Schema(
  {
    id: { type: String, index: true },
    username: { type: String },
    accessToken: { type: String, select: false },
  },
  { _id: false }
);

const UserSchema = new Schema<IUser>(
  {
    email: { type: String, required: true, unique: true, index: true, lowercase: true, trim: true },
    username: { type: String, required: true, unique: true, index: true },
    name: { type: String },
    avatarUrl: { type: String },
    roles: { type: [String], enum: ['maintainer', 'developer'], default: ['developer'], index: true },
    providers: {
      github: { type: ProviderSchema, default: undefined },
      google: { type: ProviderSchema, default: undefined },
    },
    skills: { type: [String], default: [] },
  },
  { timestamps: true }
);

UserSchema.index({ 'providers.github.id': 1 });
UserSchema.index({ 'providers.google.id': 1 });

export const User: Model<IUser> = mongoose.model<IUser>('User', UserSchema);
