import { Router } from 'express';
import Joi from 'joi';
import { config } from '../config/env';
import { User } from '../models/User';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/jwt';

export const authRouter = Router();

// OAuth callbacks expect frontend to exchange code for tokens server-side. Here we accept provider profile payloads.
const oauthSchema = Joi.object({
  provider: Joi.string().valid('github', 'google').required(),
  id: Joi.string().required(),
  email: Joi.string().email().required(),
  username: Joi.string().required(),
  name: Joi.string().allow(''),
  avatarUrl: Joi.string().uri().allow(''),
  accessToken: Joi.string().allow(''), // stored only for GitHub actions
});

authRouter.post('/oauth', async (req, res) => {
  const { error, value } = oauthSchema.validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });

  const { provider, id, email, username, name, avatarUrl, accessToken } = value;

  let user = await User.findOne({ email });
  if (!user) {
    user = await User.create({
      email,
      username,
      name,
      avatarUrl,
      roles: ['developer'],
      providers: provider === 'github' ? { github: { id, username, accessToken } } : { google: { id } },
    });
  } else {
    if (provider === 'github') user.providers.github = { id, username, accessToken };
    if (provider === 'google') user.providers.google = { id };
    if (name) user.name = name;
    if (avatarUrl) user.avatarUrl = avatarUrl;
    await user.save();
  }

  const access = signAccessToken(user.id, user.roles);
  const refresh = signRefreshToken(user.id, user.roles);

  return res.json({
    user: {
      id: user.id,
      email: user.email,
      username: user.username,
      name: user.name,
      avatarUrl: user.avatarUrl,
      roles: user.roles,
    },
    tokens: { access, refresh },
  });
});

const refreshSchema = Joi.object({ refresh: Joi.string().required() });

authRouter.post('/refresh', (req, res) => {
  const { error, value } = refreshSchema.validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });
  const payload = verifyRefreshToken(value.refresh);
  const access = signAccessToken(payload.sub, payload.roles);
  return res.json({ access });
});

authRouter.get('/me', async (req, res) => {
  // This endpoint can be protected by middleware in routes where needed
  return res.json({ status: 'ok' });
});

authRouter.post('/logout', (_req, res) => {
  return res.json({ ok: true });
});
