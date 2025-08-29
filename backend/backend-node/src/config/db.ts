import mongoose from 'mongoose';
import { config } from './env';

export async function connectMongo(): Promise<void> {
  const uri = config.mongodbUri;
  await mongoose.connect(uri, {
    dbName: config.mongodbDb,
  } as any);
}

export async function disconnectMongo(): Promise<void> {
  await mongoose.disconnect();
}
