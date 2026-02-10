# TrueLedger Docker Setup - Quick Reference

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended)
```bash
cd docker
docker-compose up --build
```
Access at: http://localhost:8080

### Option 2: Docker CLI
```bash
# Build
docker build -f docker/Dockerfile -t trueledger-web .

# Run
docker run -d -p 8080:80 --name trueledger trueledger-web
```
Access at: http://localhost:8080

## 📁 Docker Files

All Docker-related files are in the `docker/` folder:

```
docker/
├── Dockerfile           # Multi-stage build (Flutter + Nginx)
├── docker-compose.yml   # Compose configuration
├── nginx.conf          # Nginx server config
└── README.md           # Detailed documentation
```

## 🔧 Configuration

- **Flutter Image**: `instrumentisto/flutter:3`
- **Build Mode**: Debug (for seed data demo)
- **Web Server**: Nginx Alpine
- **Port**: 8080 → 80

## 📝 Common Commands

```bash
# Build
docker build -f docker/Dockerfile -t trueledger-web .

# Run
docker run -d -p 8080:80 --name trueledger trueledger-web

# Stop
docker stop trueledger

# Remove
docker rm trueledger

# Logs
docker logs -f trueledger

# Rebuild without cache
docker build --no-cache -f docker/Dockerfile -t trueledger-web .
```

## 🌐 Vercel Deployment

The Docker setup is ready for Vercel deployment. Simply:

1. Push to GitHub
2. Connect to Vercel
3. Vercel will auto-detect the Dockerfile

Or use Vercel CLI:
```bash
vercel --prod
```

## 📚 Full Documentation

See `docker/README.md` for complete documentation including:
- Detailed deployment instructions
- Troubleshooting guide
- Performance optimization
- Production checklist

## ✅ Verified Working

- ✅ Docker build successful
- ✅ Container runs without errors
- ✅ Nginx serving Flutter web app
- ✅ Debug mode enabled for seed data
- ✅ All dependencies included
