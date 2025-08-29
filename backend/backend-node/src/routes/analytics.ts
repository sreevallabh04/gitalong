import { Router } from 'express';
import Joi from 'joi';
import { requireAuth } from '../middleware/auth';
import { Analytics } from '../models/Analytics';

export const analyticsRouter = Router();

const trackSchema = Joi.object({ event: Joi.string().required(), properties: Joi.object().default({}) });

analyticsRouter.post('/track', requireAuth, async (req, res) => {
  const { error, value } = trackSchema.validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });
  const a = await Analytics.create({ userId: req.user!.sub, event: value.event, properties: value.properties });
  res.status(201).json({ ok: true, id: a.id });
});

analyticsRouter.get('/events', requireAuth, async (_req, res) => {
  const items = await Analytics.find().limit(100).sort({ createdAt: -1 });
  res.json({ items });
});
