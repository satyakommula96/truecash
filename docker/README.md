# Docker Deployment Guide for TrueLedger

This guide explains how to build and deploy the TrueLedger Flutter web application using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, for local testing)

## Quick Start

### Build and Run with Docker Compose

```bash
# From the project root directory
cd docker
docker-compose up --build

# Access the application at http://localhost:8080
```

### Build and Run with Docker CLI

```bash
# From the project root directory
docker build -f docker/Dockerfile -t trueledger-web .

# Run the container
docker run -d -p 8080:80 --name trueledger trueledger-web

# Access the application at http://localhost:8080
```

## Docker Files Structure

```
trueledger/
├── docker/
│   ├── Dockerfile           # Multi-stage build configuration
│   ├── docker-compose.yml   # Docker Compose configuration
│   ├── nginx.conf          # Nginx server configuration
│   └── README.md           # This file
└── .dockerignore           # Files to exclude from build context
```

## Useful Docker Commands

```bash
# Stop the container
docker stop trueledger

# Start the container
docker start trueledger

# View logs
docker logs trueledger

# Follow logs in real-time
docker logs -f trueledger

# Remove the container
docker rm trueledger

# Remove the image
docker rmi trueledger-web

# Rebuild without cache
docker build --no-cache -f docker/Dockerfile -t trueledger-web .
```

## Vercel Deployment

Vercel supports Docker deployments. Here's how to deploy:

### Option 1: Using Vercel CLI

1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy from project root:
```bash
vercel --prod
```

### Option 2: GitHub Integration

1. Push your code to GitHub
2. Connect your repository to Vercel
3. Vercel will automatically detect the Dockerfile and build your application
4. Make sure to set the root directory to your project root in Vercel settings

### Vercel Configuration

Create or update `vercel.json` in the project root:

```json
{
  "builds": [
    {
      "src": "docker/Dockerfile",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "build/web"
      }
    }
  ]
}
```

## Docker Image Details

### Multi-Stage Build

The Dockerfile uses a multi-stage build process:

1. **Build Stage** (Flutter 3.38.9):
   - Uses pre-built Flutter image from Cirrus Labs
   - Enables web support
   - Builds the Flutter web application in debug mode (for seed data demo)
   - Optimized layer caching (pubspec files copied first)

2. **Production Stage** (Nginx Alpine):
   - Lightweight Nginx server (~50MB total)
   - Serves the built static files
   - Includes optimized configuration for Flutter web apps

### Build Configuration

- **Flutter Version**: 3.38.9 (from ghcr.io/cirruslabs/flutter)
- **Build Mode**: Debug (to support seed data for demo)
- **Web Renderer**: Auto-selected by Flutter (configured in index.html)

### Image Size Optimization

- Uses `.dockerignore` to exclude unnecessary files
- Multi-stage build keeps final image small
- Only production artifacts are included in the final image
- Platform-specific folders (android, ios, etc.) are excluded

## Nginx Configuration

The included `nginx.conf` provides:

- **Gzip compression** for faster loading
- **Security headers** (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)
- **Static asset caching** (1 year for immutable assets)
- **Flutter routing support** (SPA fallback to index.html)
- **Optimized logging** (disabled for favicon and robots.txt)

## Seed Data for Demo

The application is built in **debug mode** to support seed data functionality. This allows you to:

- Demonstrate the application with pre-populated data
- Test all features without manual data entry
- Showcase the UI/UX to stakeholders

If you need to switch to production mode, edit `docker/Dockerfile` and change:

```dockerfile
RUN flutter build web --debug
```

to:

```dockerfile
RUN flutter build web --release
```

## Troubleshooting

### Build Fails

If the build fails, try:

```bash
# Clear Docker cache and rebuild
docker build --no-cache -f docker/Dockerfile -t trueledger-web .

# Check Docker logs
docker logs trueledger
```

### Container Won't Start

Check the logs:

```bash
docker logs trueledger

# Or for real-time logs
docker logs -f trueledger
```

### Port Already in Use

Change the port mapping:

```bash
# Use port 3000 instead of 8080
docker run -d -p 3000:80 --name trueledger trueledger-web

# Or update docker-compose.yml
```

### Flutter Build Issues

If you encounter Flutter-specific issues:

1. Verify Flutter version compatibility
2. Check that web support is enabled
3. Ensure all dependencies are properly specified in `pubspec.yaml`

## Performance Optimization

### Web Renderer

Flutter automatically selects the best web renderer. The renderer is configured in `web/index.html`:

- **CanvasKit**: Better performance, larger initial download
- **HTML**: Smaller initial download, may have performance limitations
- **Auto**: Flutter decides based on browser capabilities (recommended)

### Caching Strategy

The Nginx configuration implements aggressive caching for static assets:

- JavaScript, CSS, images: 1 year cache
- HTML files: No cache (to ensure latest version)

## Production Checklist

Before deploying to production:

- [ ] Test the Docker build locally
- [ ] Verify all routes work correctly
- [ ] Check mobile responsiveness
- [ ] Test performance with Lighthouse
- [ ] Verify security headers are present
- [ ] Test with different browsers (Chrome, Firefox, Safari, Edge)
- [ ] Monitor container resource usage
- [ ] Set up proper logging and monitoring
- [ ] Configure SSL/TLS certificates (if not using Vercel)
- [ ] Review and update environment variables

## Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Vercel Documentation](https://vercel.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Cirrus Labs Flutter Image](https://github.com/cirruslabs/docker-images-flutter)

## Support

For issues specific to:
- **Docker setup**: Check this README and Docker logs
- **Flutter build**: Refer to Flutter documentation
- **Vercel deployment**: Check Vercel deployment logs
- **Nginx configuration**: Review nginx error logs in the container
