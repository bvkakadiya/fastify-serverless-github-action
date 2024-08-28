import awsLambdaFastify from '@fastify/aws-lambda';
import server from './server.js';

const proxy = awsLambdaFastify(server);

export const handler = async (event, context) => {
  return proxy(event, context);
};