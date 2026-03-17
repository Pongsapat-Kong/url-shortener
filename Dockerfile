# Use official Node.js LTS image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy application source
COPY src/ ./src/
COPY www/ ./www/

COPY student_id.txt ./

# Read student ID from file
RUN STUDENT_ID=$(cat student_id.txt) && \
    echo "export STUDENT_ID='$STUDENT_ID'" >> /etc/profile

# Set build timestamp as environment variable
ARG BUILD_TIME

RUN if [ -z "$BUILD_TIME" ]; then \
      BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ"); \
    fi && \
    echo "$BUILD_TIME" > /app/build_time.txt && \
    echo "Build Time: $BUILD_TIME"

RUN BUILD_TIME=$(cat /app/build_time.txt) && \
    echo "export BUILD_TIME='$BUILD_TIME'" >> /etc/profile

ENV STUDENT_ID_FILE=/app/student_id.txt
ENV BUILD_TIME_FILE=/app/build_time.txt

RUN if [ -f student_id.txt ]; then echo "Student ID: $(cat student_id.txt)"; fi && \
    if [ -f build_time.txt ]; then echo "Build Time: $(cat build_time.txt)"; fi

EXPOSE 3000

ENV NODE_ENV=production

# Start the application
CMD ["node", "src/index.js"]