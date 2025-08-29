import jwt from 'jsonwebtoken';
import { config } from '../config/env';

export interface JwtPayload {
  sub: string;
  roles: string[];
  type: 'access' | 'refresh';
}

export function signAccessToken(userId: string, roles: string[]): string {
  return jwt.sign({ sub: userId, roles, type: 'access' } as JwtPayload, config.jwt.accessSecret, {
    expiresIn: config.jwt.accessTtl,
  });
}

export function signRefreshToken(userId: string, roles: string[]): string {
  return jwt.sign({ sub: userId, roles, type: 'refresh' } as JwtPayload, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshTtl,
  });
}

export function verifyAccessToken(token: string): JwtPayload {
  return jwt.verify(token, config.jwt.accessSecret) as JwtPayload;
}

export function verifyRefreshToken(token: string): JwtPayload {
  return jwt.verify(token, config.jwt.refreshSecret) as JwtPayload;
}
