# Use the official AWS Lambda Node.js base image
FROM public.ecr.aws/lambda/nodejs:20

# Set the working directory
WORKDIR /var/task

# Copy package.json and yarn.lock (or package-lock.json)
COPY package.json yarn.lock ./

# Install dependencies
RUN npm install -g yarn
RUN yarn install --production

# Copy the rest of the application code
COPY . .

# Command to run the Lambda handler
CMD ["lambda.handler"]