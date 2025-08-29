import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import rateLimit from 'express-rate-limit';
import morgan from 'morgan';
import xss from 'xss-clean';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

import { config } from './config/env';
import { logger } from './config/logger';

import { authRouter } from './routes/auth';
import { projectsRouter } from './routes/projects';
import { matchesRouter } from './routes/matches';
import { messagesRouter } from './routes/messages';
import { notificationsRouter } from './routes/notifications';
import { analyticsRouter } from './routes/analytics';

export const app = express();

app.set('trust proxy', true);
app.use(helmet());
app.use(cors({ origin: config.corsOrigins, credentials: true }));
app.use(rateLimit({ windowMs: config.rateLimit.windowMs, max: config.rateLimit.max }));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(xss());
app.use(morgan('combined'));

// Swagger
if (config.swaggerEnabled) {
  const swaggerSpec = swaggerJsdoc({
    definition: {
      openapi: '3.0.3',
      info: { title: 'GitAlong API', version: '1.0.0' },
      servers: [{ url: config.baseUrl }],
      components: {
        securitySchemes: {
          bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
        },
      },
      security: [{ bearerAuth: [] }],
    },
    apis: ['src/routes/**/*.ts', 'src/controllers/**/*.ts', 'src/models/**/*.ts'],
  });
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}

// Routes
app.use('/auth', authRouter);
app.use('/projects', projectsRouter);
app.use('/matches', matchesRouter);
app.use('/messages', messagesRouter);
app.use('/notifications', notificationsRouter);
app.use('/analytics', analyticsRouter);

app.get('/health', (_req, res) => {
  res.json({ status: 'healthy', env: config.nodeEnv, timestamp: Date.now() });
});

// Error handler
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  logger.error(err?.stack || String(err));
  res.status(err.status || 500).json({ error: { message: err.message || 'Internal Server Error' } });
});
