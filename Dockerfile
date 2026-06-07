# Build stage
FROM node:22-slim AS builder

# Install pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

# Copy configuration files for pnpm build policies
COPY package.json pnpm-lock.yaml .pnpmconfig.json ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Build the SvelteKit app
RUN pnpm run build

# Runner stage
FROM node:22-slim AS runner

WORKDIR /app

# Install pnpm for any runtime needs (though adapter-node usually produces a self-contained build)
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Copy built files from builder
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/.pnpmconfig.json ./.pnpmconfig.json

# Install only production dependencies
RUN pnpm install --prod --frozen-lockfile

# Expose the port SvelteKit Node adapter uses (default 3000)
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Start the application
CMD ["node", "build"]
