#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting SonarQube Production-Grade Setup...${NC}"

# 1. Check for Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose V2 is not available.${NC}"
    exit 1
fi

# 2. Check vm.max_map_count (Crucial for Elasticsearch)
# This is usually only an issue on Linux. Docker Desktop on Mac/Windows handles this.
OS_TYPE=$(uname)
if [ "$OS_TYPE" == "Linux" ]; then
    CURRENT_MAX_MAP_COUNT=$(sysctl -n vm.max_map_count)
    if [ "$CURRENT_MAX_MAP_COUNT" -lt 262144 ]; then
        echo -e "${YELLOW}Warning: vm.max_map_count is set to $CURRENT_MAX_MAP_COUNT. SonarQube requires at least 262144.${NC}"
        echo -e "${YELLOW}Attempting to set it now (requires sudo)...${NC}"
        sudo sysctl -w vm.max_map_count=262144
        echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
    else
        echo -e "${GREEN}Check: vm.max_map_count is sufficient ($CURRENT_MAX_MAP_COUNT).${NC}"
    fi
else
    echo -e "${GREEN}Check: Running on $OS_TYPE. vm.max_map_count is typically managed by Docker Desktop.${NC}"
fi

# 3. Start the containers
echo -e "${YELLOW}Pulling and starting containers...${NC}"
docker compose up -d

# 4. Wait for SonarQube to be ready
echo -e "${YELLOW}Waiting for SonarQube to start (this may take a minute)...${NC}"
until $(curl --output /dev/null --silent --head --fail http://localhost:9000); do
    printf '.'
    sleep 5
done

echo -e "\n${GREEN}SonarQube is UP and running!${NC}"
echo -e "${GREEN}Access it at: http://localhost:9000${NC}"
echo -e "${YELLOW}Default credentials: admin / admin${NC}"
echo -e "${YELLOW}Check GUIDE.md for GitHub integration steps.${NC}"
