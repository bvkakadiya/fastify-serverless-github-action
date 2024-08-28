#!/bin/bash

# Step 1: Initialize a Fastify project
npx fastify-cli generate e . --integrate   --esm --standardlint 

# Step 3: Create .github/workflows directory
mkdir -p .github/workflows

# Step 4: Create a GitHub Actions workflow file for SonarQube scan
cat <<EOL > .github/workflows/sonar.yml
name: SonarCloud analysis
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

permissions:
  pull-requests: read # allows SonarCloud to decorate PRs with analysis results

jobs:
  Analysis:
    runs-on: ubuntu-latest

    steps:
      - name: Analyze with SonarCloud
        uses: SonarSource/sonarcloud-github-action@v3
        env:
          SONAR_TOKEN: \${{ secrets.SONAR_TOKEN }}   # Generate a token on Sonarcloud.io, add it to the secrets of this repo with the name SONAR_TOKEN (Settings > Secrets > Actions > add new repository secret)
        with:
          # Additional arguments for the SonarScanner CLI
          args:
            # Unique keys of your project and organization. You can find them in SonarCloud > Information (bottom-left menu)
            # mandatory
            -Dsonar.projectKey=bvkakadiya_fastify-serverless-github-action
            -Dsonar.organization=bvkakadiya
            # Comma-separated paths to directories containing main source files.
            #-Dsonar.sources= # optional, default is project base directory
            # Comma-separated paths to directories containing test source files.
            #-Dsonar.tests= # optional. For more info about Code Coverage, please refer to https://docs.sonarcloud.io/enriching/test-coverage/overview/
            # Adds more detail to both client and server-side analysis logs, activating DEBUG mode for the scanner, and adding client-side environment variables and system properties to the server-side log of analysis report processing.
            #-Dsonar.verbose= # optional, default is false
          # When you need the analysis to take place in a directory other than the one from which it was launched, default is .
          projectBaseDir: .
EOL


# Step 4: Create a GitHub Actions workflow file for testing and linting
cat <<'EOL' > .github/workflows/ci-pipeline.yml
name: CI Pipeline

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

permissions:
  pull-requests: read # allows SonarCloud to decorate PRs with analysis results

jobs:
  test-and-lint:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [20, 22]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}

      - name: Install dependencies
        run: yarn install

      - name: Run lint
        run: yarn lint

      - name: Run tests
        run: yarn test
      - name: Analyze with SonarCloud
        uses: SonarSource/sonarcloud-github-action@v2.2.0
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}   # Generate a token on Sonarcloud.io, add it to the secrets of this repo with the name SONAR_TOKEN (Settings > Secrets > Actions > add new repository secret)
        with:
          # Additional arguments for the SonarScanner CLI
          args:
            # Unique keys of your project and organization. You can find them in SonarCloud > Information (bottom-left menu)
            # mandatory
            -Dsonar.projectKey=bvkakadiya_fastify-serverless-github-action
            -Dsonar.organization=bvkakadiya
            # Comma-separated paths to directories containing main source files.
            #-Dsonar.sources= # optional, default is project base directory
            # Comma-separated paths to directories containing test source files.
            #-Dsonar.tests= # optional. For more info about Code Coverage, please refer to https://docs.sonarcloud.io/enriching/test-coverage/overview/
            # Adds more detail to both client and server-side analysis logs, activating DEBUG mode for the scanner, and adding client-side environment variables and system properties to the server-side log of analysis report processing.
            #-Dsonar.verbose= # optional, default is false
          # When you need the analysis to take place in a directory other than the one from which it was launched, default is .
          projectBaseDir: .
EOL

echo "Fastify project setup complete with GitHub Actions for SonarQube scan, testing, and linting."