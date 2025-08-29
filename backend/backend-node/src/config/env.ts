import dotenv from 'dotenv';
import Joi from 'joi';

dotenv.config();

const schema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'staging', 'production', 'test').default('development'),
  PORT: Joi.number().default(8000),

  MONGODB_URI: Joi.string().uri().required(),
  MONGODB_DB: Joi.string().required(),

  JWT_ACCESS_SECRET: Joi.string().min(32).required(),
  JWT_REFRESH_SECRET: Joi.string().min(32).required(),
  JWT_ACCESS_TTL: Joi.string().default('900s'),
  JWT_REFRESH_TTL: Joi.string().default('7d'),

  GITHUB_CLIENT_ID: Joi.string().required(),
  GITHUB_CLIENT_SECRET: Joi.string().required(),
  GITHUB_REDIRECT_URI: Joi.string().uri().required(),

  GOOGLE_CLIENT_ID: Joi.string().required(),
  GOOGLE_CLIENT_SECRET: Joi.string().required(),
  GOOGLE_REDIRECT_URI: Joi.string().uri().required(),

  CORS_ORIGINS: Joi.string().default('["http://localhost:3000"]'),

  LOG_LEVEL: Joi.string().default('info'),
  LOGTAIL_TOKEN: Joi.string().allow('').default(''),

  RATE_LIMIT_WINDOW_MS: Joi.number().default(60000),
  RATE_LIMIT_MAX: Joi.number().default(100),

  SWAGGER_ENABLED: Joi.boolean().default(true),
  BASE_URL: Joi.string().uri().default('http://localhost:8000'),
  WS_PATH: Joi.string().default('/ws'),
}).unknown();

const { value: env, error } = schema.validate(process.env);

if (error) {
  // Fail fast for invalid env
  throw new Error(`Invalid environment configuration: ${error.message}`);
}

export const config = {
  nodeEnv: env.NODE_ENV as string,
  port: Number(env.PORT),
  mongodbUri: env.MONGODB_URI as string,
  mongodbDb: env.MONGODB_DB as string,
  jwt: {
    accessSecret: env.JWT_ACCESS_SECRET as string,
    refreshSecret: env.JWT_REFRESH_SECRET as string,
    accessTtl: env.JWT_ACCESS_TTL as string,
    refreshTtl: env.JWT_REFRESH_TTL as string,
  },
  oauth: {
    github: {
      clientId: env.GITHUB_CLIENT_ID as string,
      clientSecret: env.GITHUB_CLIENT_SECRET as string,
      redirectUri: env.GITHUB_REDIRECT_URI as string,
    },
    google: {
      clientId: env.GOOGLE_CLIENT_ID as string,
      clientSecret: env.GOOGLE_CLIENT_SECRET as string,
      redirectUri: env.GOOGLE_REDIRECT_URI as string,
    },
  },
  corsOrigins: JSON.parse(env.CORS_ORIGINS as string) as string[],
  logLevel: env.LOG_LEVEL as string,
  logtailToken: env.LOGTAIL_TOKEN as string,
  rateLimit: { windowMs: Number(env.RATE_LIMIT_WINDOW_MS), max: Number(env.RATE_LIMIT_MAX) },
  swaggerEnabled: Boolean(env.SWAGGER_ENABLED),
  baseUrl: env.BASE_URL as string,
  wsPath: env.WS_PATH as string,
};
