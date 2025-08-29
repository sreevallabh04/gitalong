import winston from 'winston';
import { Logtail } from '@logtail/node';
import { LogtailTransport } from '@logtail/winston';
import { config } from './env';

const transports: winston.transport[] = [
  new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.timestamp(),
      winston.format.printf((info) => `${info.timestamp} [${info.level}]: ${info.message}`)
    ),
  }),
];

if (config.logtailToken) {
  const logtail = new Logtail(config.logtailToken);
  transports.push(new LogtailTransport(logtail));
}

export const logger = winston.createLogger({
  level: config.logLevel,
  format: winston.format.json(),
  transports,
});
