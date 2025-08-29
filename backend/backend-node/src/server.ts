import http from 'http';
import { Server as SocketIOServer } from 'socket.io';
import { app } from './app';
import { config } from './config/env';
import { logger } from './config/logger';
import { connectMongo, disconnectMongo } from './config/db';

const server = http.createServer(app);
const io = new SocketIOServer(server, {
  path: config.wsPath,
  cors: { origin: config.corsOrigins, credentials: true },
});

io.on('connection', (socket) => {
  logger.info(`WebSocket connected: ${socket.id}`);
  socket.on('disconnect', () => {
    logger.info(`WebSocket disconnected: ${socket.id}`);
  });
});

async function bootstrap() {
  try {
    await connectMongo();
    server.listen(config.port, () => {
      logger.info(`HTTP server listening on port ${config.port}`);
      logger.info(`Docs: ${config.baseUrl}/docs`);
    });
  } catch (e: any) {
    logger.error(`Failed to start: ${e?.message}`);
    process.exit(1);
  }
}

async function shutdown() {
  logger.info('Shutting down...');
  await disconnectMongo();
  server.close(() => process.exit(0));
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

bootstrap();
