import { Router } from 'express';
import Joi from 'joi';
import { requireAuth } from '../middleware/auth';
import { Project } from '../models/Project';

export const projectsRouter = Router();

const createSchema = Joi.object({
  title: Joi.string().min(2).max(140).required(),
  description: Joi.string().allow(''),
  tags: Joi.array().items(Joi.string()).default([]),
  visibility: Joi.string().valid('public', 'private').default('public'),
  repoUrl: Joi.string().uri().allow(''),
  languages: Joi.array().items(Joi.string()).default([]),
});

projectsRouter.post('/', requireAuth, async (req, res) => {
  const { error, value } = createSchema.validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });
  const project = await Project.create({ ...value, owner: req.user!.sub });
  res.status(201).json({ project });
});

projectsRouter.get('/', requireAuth, async (_req, res) => {
  const items = await Project.find().limit(50).sort({ createdAt: -1 });
  res.json({ items });
});

projectsRouter.get('/:id', requireAuth, async (req, res) => {
  const item = await Project.findById(req.params.id);
  if (!item) return res.status(404).json({ error: { message: 'Not found' } });
  res.json({ project: item });
});

projectsRouter.patch('/:id', requireAuth, async (req, res) => {
  const { error, value } = createSchema.min(1).validate(req.body);
  if (error) return res.status(400).json({ error: { message: error.message } });
  const updated = await Project.findOneAndUpdate({ _id: req.params.id, owner: req.user!.sub }, { $set: value }, { new: true });
  if (!updated) return res.status(404).json({ error: { message: 'Not found' } });
  res.json({ project: updated });
});

projectsRouter.delete('/:id', requireAuth, async (req, res) => {
  const deleted = await Project.findOneAndDelete({ _id: req.params.id, owner: req.user!.sub });
  if (!deleted) return res.status(404).json({ error: { message: 'Not found' } });
  res.json({ ok: true });
});
