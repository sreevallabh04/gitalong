import { Router } from 'express';
import Joi from 'joi';
import { requireAuth } from '../middleware/auth';
import { Notification } from '../models/Notification';

export const notificationsRouter = Router();

notificationsRouter.get('/', requireAuth, async (req, res) => {
  const items = await Notification.find({ user: req.user!.sub }).sort({ createdAt: -1 }).limit(100);
  res.json({ items });
});

const markSchema = Joi.object({ read: Joi.boolean().required() });

notificationsRouter.patch('/:id', requireAuth, async (req, res) => {
  const { error, value } = markSchema.validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });
  const updated = await Notification.findOneAndUpdate({ _id: req.params.id, user: req.user!.sub }, { $set: { read: value.read } }, { new: true });
  if (!updated) return res.status(404).json({ error: { message: 'Not found' } });
  res.json({ notification: updated });
});
