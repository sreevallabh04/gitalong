import { Router } from 'express';
import Joi from 'joi';
import { requireAuth } from '../middleware/auth';
import { Match } from '../models/Match';
import { Project } from '../models/Project';

export const matchesRouter = Router();

matchesRouter.get('/feed', requireAuth, async (_req, res) => {
  const items = await Project.find({ visibility: 'public' }).limit(50).sort({ createdAt: -1 });
  res.json({ items });
});

const swipeSchema = Joi.object({ status: Joi.string().valid('liked', 'superliked', 'rejected').required(), score: Joi.number().min(0).max(100) });

matchesRouter.post('/:projectId/swipe', requireAuth, async (req, res) => {
  const { error, value } = swipeSchema.validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });

  const { projectId } = req.params;
  const match = await Match.findOneAndUpdate(
    { user: req.user!.sub, project: projectId },
    { $set: { status: value.status, score: value.score } },
    { upsert: true, new: true }
  );
  // Simple match rule: if project owner also liked the user (out of scope), we set matched elsewhere.
  res.json({ match });
});
