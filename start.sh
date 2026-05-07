#!/bin/bash
# ═══════════════════════════════════════════════════
#  NexChat — Full Setup & Run Script
# ═══════════════════════════════════════════════════

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}ℹ  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠  $1${NC}"; }
error()   { echo -e "${RED}❌ $1${NC}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

# ── Checks ─────────────────────────────────────────
command -v node &>/dev/null || error "Node.js not installed. Install from https://nodejs.org"
command -v npm  &>/dev/null || error "npm not installed"
NODE_VER=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
[ "$NODE_VER" -lt 16 ] && error "Node.js 16+ required (you have $(node -v))"

info "NexChat Setup"
echo ""

# ── MongoDB check ───────────────────────────────────
if command -v mongod &>/dev/null; then
  if ! pgrep -x mongod &>/dev/null; then
    warn "MongoDB is installed but not running. Starting..."
    if command -v systemctl &>/dev/null; then
      sudo systemctl start mongod 2>/dev/null && success "MongoDB started" || warn "Could not start MongoDB automatically. Please start it manually: sudo systemctl start mongod"
    else
      mongod --fork --logpath /tmp/mongod.log --dbpath /tmp/mongodb 2>/dev/null && success "MongoDB started" || warn "Could not start MongoDB. Please start it manually."
    fi
  else
    success "MongoDB is running"
  fi
else
  warn "MongoDB not found locally."
  echo -e "  ${YELLOW}→ Either install MongoDB: https://www.mongodb.com/try/download/community${NC}"
  echo -e "  ${YELLOW}→ Or use MongoDB Atlas (free cloud): https://www.mongodb.com/atlas${NC}"
  echo -e "  ${YELLOW}  Then set MONGO_URI in backend/.env${NC}"
  echo ""
fi

# ── Backend .env ────────────────────────────────────
ENV_FILE="$BACKEND_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  info "Creating backend/.env ..."
  cat > "$ENV_FILE" << 'ENVEOF'
MONGO_URI=mongodb://localhost:27017/nexchat
JWT_SECRET=nexchat_super_secret_change_in_production
PORT=5000
CLIENT_URL=http://localhost:3000
FAST2SMS_API_KEY=your_fast2sms_api_key_here
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
ENVEOF
  success "Created backend/.env"
fi

# ── Install backend deps ────────────────────────────
info "Installing backend dependencies..."
cd "$BACKEND_DIR"
npm install --silent
success "Backend dependencies installed"

# ── Install frontend deps ───────────────────────────
info "Installing frontend dependencies..."
cd "$FRONTEND_DIR"
npm install --silent
success "Frontend dependencies installed"

# ── Start ───────────────────────────────────────────
echo ""
success "Setup complete!"
echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${CYAN}  Starting NexChat...${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo ""
echo -e "  Backend  → ${GREEN}http://localhost:5000${NC}"
echo -e "  Frontend → ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "  ${YELLOW}Press Ctrl+C to stop both servers${NC}"
echo ""

# Start backend in background
cd "$BACKEND_DIR"
node server.js &
BACKEND_PID=$!
info "Backend started (PID: $BACKEND_PID)"

sleep 2

# Start frontend
cd "$FRONTEND_DIR"
BROWSER=none npm start &
FRONTEND_PID=$!
info "Frontend starting..."

# Cleanup on exit
cleanup() {
  echo ""
  info "Shutting down..."
  kill $BACKEND_PID 2>/dev/null
  kill $FRONTEND_PID 2>/dev/null
  success "NexChat stopped"
}
trap cleanup EXIT INT TERM

wait
