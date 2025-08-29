import { Router } from 'express';
import Joi from 'joi';
import { requireAuth } from '../middleware/auth';
import { Message } from '../models/Message';

export const messagesRouter = Router();

messagesRouter.get('/:roomId', requireAuth, async (req, res) => {
  const { roomId } = req.params;
  const items = await Message.find({ roomId }).sort({ createdAt: -1 }).limit(100);
  res.json({ items });
});

const sendSchema = Joi.object({ content: Joi.string().min(1).max(4000).required(), type: Joi.string().valid('text', 'image', 'file').default('text'), recipient: Joi.string().allow('') });

messagesRouter.post('/:roomId', requireAuth, async (req, res) => {
  const { error, value } = sendSchema.validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });
  const { roomId } = req.params;
  const msg = await Message.create({ roomId, sender: req.user!.sub, recipient: value.recipient, content: value.content, type: value.type });
  res.status(201).json({ message: msg });
});
