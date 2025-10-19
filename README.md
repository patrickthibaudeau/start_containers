# Docker Compose Multi-Project Starter

🐳 **start_containers** is a bash utility script that automates the startup of multiple Docker Compose projects from a configurable list of directories.

## 🚀 Features

- **Smart Docker Compose Detection**: Automatically finds and uses the available Docker Compose command (`docker compose` v2 plugin preferred, falls back to `docker-compose` v1)
- **Multi-Project Support**: Start multiple Docker Compose projects with a single command
- **Flexible Compose File Detection**: Supports various compose file naming conventions
- **Docker Daemon Health Check**: Waits for Docker daemon availability before proceeding
- **Detailed Logging**: Clear progress reporting and error messages

## 📋 Prerequisites

- **Docker**: Docker Engine must be installed and running
- **Docker Compose**: Either Docker Compose v2 plugin (`docker compose`) or standalone v1 (`docker-compose`)
- **Bash**: The script requires bash shell environment

## ⚙️ Configuration

### 1. Edit the FOLDERS Array

Open `start_containers.sh` and modify the `FOLDERS` array to include absolute paths to your Docker Compose project directories:

```bash
FOLDERS=(
  "/home/user/projects/web-app"
  "/home/user/projects/api-service"
  "/home/user/projects/database"
  "/opt/docker-projects/monitoring"
)
```

### 2. Optional: Force Specific Docker Compose Command

If you need to use a specific Docker Compose command, set the `DOCKER_COMPOSE_CMD` variable:

```bash
DOCKER_COMPOSE_CMD="docker-compose"  # Force v1 standalone
# or
DOCKER_COMPOSE_CMD="docker compose"  # Force v2 plugin
```

### 3. Optional: Adjust Docker Wait Timeout

Modify the timeout for waiting for Docker daemon (default: 15 seconds):

```bash
DOCKER_WAIT_TIMEOUT=30  # Wait up to 30 seconds
```

## 🔧 Installation & Usage

### 1. Make the Script Executable

**Important:** You must make the script executable before first use:

```bash
chmod +x start_containers.sh
```

### 2. Run the Script

Execute from any directory (uses absolute paths):

```bash
./start_containers.sh
```

Or run from anywhere by providing the full path:

```bash
/path/to/start_containers.sh
```

## 📊 What the Script Does

### Execution Flow

1. **🔍 Detection Phase**
   - Locates available Docker Compose command
   - Validates Docker daemon accessibility
   
2. **🗂️ Processing Phase**
   - Iterates through each directory in the `FOLDERS` array
   - Validates directory existence
   - Searches for compose files in this order:
     - `docker-compose.yml`
     - `docker-compose.yaml` 
     - `compose.yaml`
     - `docker-compose.override.yml`

3. **🚀 Execution Phase**
   - Runs `docker compose up -d --quiet-pull` in each directory
   - Starts containers in detached mode with quiet image pulling
   - Continues to next directory even if current one fails

4. **📈 Reporting Phase**
   - Reports success/failure for each directory
   - Provides final summary with failure count

### Sample Output

```
Using compose command: docker compose

=== Processing: /home/user/projects/web-app ===
Found compose file: docker-compose.yml
Started containers in /home/user/projects/web-app

=== Processing: /home/user/projects/api-service ===
Found compose file: compose.yaml
Started containers in /home/user/projects/api-service

All compose projects processed successfully.
```

## 🚦 Exit Codes

| Code | Meaning |
|------|---------|
| `0` | ✅ All compose projects processed successfully |
| `2` | ❌ No docker compose command found |
| `3` | ❌ Docker daemon not reachable within timeout |
| `4` | ❌ One or more folders failed to start containers |

## 💡 Best Practices & Tips

### Path Management
- **Always use absolute paths** in the `FOLDERS` array to avoid ambiguity when running from different directories
- Verify all paths exist and contain valid Docker Compose files before running

### Docker Environment
- Ensure Docker daemon is running before executing the script
- For development environments, consider using `docker system prune` periodically to clean up unused resources

### Customization Options
- **Dry Run**: For testing, modify the script to print commands instead of executing them
- **Selective Startup**: Comment out specific folders in the array to skip them temporarily
- **Custom Compose Files**: The script can be modified to support custom compose file names

### Development Workflow
```bash
# Example development startup routine
./start_containers.sh           # Start all projects
docker ps                       # Verify containers are running
docker-compose logs -f app      # Follow logs for specific service
```

## 🔧 Troubleshooting

### Common Issues

**"No docker compose command found"**
- Install Docker and Docker Compose
- Verify installation: `docker --version && docker compose version`

**"Docker daemon not reachable"**
- Start Docker service: `sudo systemctl start docker`
- Check Docker status: `docker info`

**"Directory not found"**
- Verify all paths in `FOLDERS` array are absolute and exist
- Check directory permissions

**Containers fail to start**
- Check individual project logs: `docker-compose logs` in the failing directory
- Verify compose file syntax: `docker-compose config` in the project directory
- Ensure required images are available or can be built

## 📄 License

See the `LICENSE` file in this repository.
