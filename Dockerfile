# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Build arguments
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG GOOGLE_MAPS_API_KEY

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build web app
RUN flutter build web --release \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
    --dart-define=GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy built web app to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx config template
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Install envsubst (already included in nginx:alpine)
# The nginx image will automatically process templates and substitute $PORT

EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
