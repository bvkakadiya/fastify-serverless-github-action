import awsLambdaFastify from '@fastify/aws-lambda';
import init from './app2.js';

const proxy = awsLambdaFastify(init());
// or
// const proxy = awsLambdaFastify(init(), { binaryMimeTypes: ['application/octet-stream'] });

export const handler = proxy;
// or
// export const handler = (event, context, callback) => proxy(event, context, callback);
// or
// export const handler = (event, context) => proxy(event, context);
// or
// export const handler = async (event, context) => proxy(event, context);