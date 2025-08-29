import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, JwtPayload } from '../utils/jwt';

declare global {
  namespace Express {
    interface Request { user?: JwtPayload }
  }
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) return res.status(401).json({ error: { message: 'Unauthorized' } });
  try {
    const token = header.slice(7);
    const payload = verifyAccessToken(token);
    req.user = payload;
    next();
  } catch {
    return res.status(401).json({ error: { message: 'Unauthorized' } });
  }
}

export function requireRoles(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) return res.status(401).json({ error: { message: 'Unauthorized' } });
    const has = req.user.roles.some((r) => roles.includes(r));
    if (!has) return res.status(403).json({ error: { message: 'Forbidden' } });
    next();
  };
}
