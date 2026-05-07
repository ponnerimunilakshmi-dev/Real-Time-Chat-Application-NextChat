# 🚀 NexChat — Full-Stack Real-Time Chat Application

> MERN Stack · Socket.io · WebRTC · Fast2SMS OTP · Cloudinary

---

## ✨ Features

| Feature | Details |
|--------|---------|
| 📱 OTP Verification | Real SMS via **Fast2SMS** — no demo mode |
| 💬 Real-time Chat | Socket.io bidirectional messaging |
| 📸 Media Sharing | Images, Videos, Audio, Documents via Cloudinary |
| 🎭 Stickers & Emoji | Built-in sticker panel + full emoji picker |
| 🗑️ Message Delete | Delete for Me / Delete for Everyone |
| 🎨 Themes | 6 presets + custom photo background (per-user, not global) |
| 👥 Group Chat | Create groups, add members, group messaging |
| 📞 Audio Call | WebRTC peer-to-peer audio calling |
| 📹 Video Call | WebRTC peer-to-peer video calling |
| 🚫 Block/Unblock | Block users from contacting you |
| 🧹 Clear Chat | Clear conversation history (only for you) |
| ✅ Read Receipts | Single ✓ = sent, Double ✓✓ = read |
| 🟢 Online Status | Real-time online/offline indicators |
| ⌨️ Typing Indicator | Animated typing dots |
| 🎤 Voice Messages | Hold-to-record audio messages |

---

## 🏗️ Tech Stack

**Backend:** Node.js + Express + MongoDB + Socket.io  
**Frontend:** React 18 + React Router + Socket.io Client  
**OTP SMS:** Fast2SMS (Indian numbers — free tier available)  
**Media Storage:** Cloudinary (free tier: 25GB)  
**Video Calls:** WebRTC (browser-native, no third-party)

---

## ⚙️ Setup Instructions

### 1. Get API Keys

#### Fast2SMS (Free OTP SMS for Indian numbers)
1. Go to [fast2sms.com](https://fast2sms.com) → Sign up free
2. Dashboard → **Dev API** → Copy your API key
3. This sends **real OTPs** to Indian mobile numbers

#### Cloudinary (Free media storage)
1. Go to [cloudinary.com](https://cloudinary.com) → Sign up free
2. Dashboard → copy **Cloud Name**, **API Key**, **API Secret**

#### MongoDB
- **Local:** Install MongoDB Community → use `mongodb://localhost:27017/nexchat`
- **Atlas (free cloud):** [mongodb.com/atlas](https://www.mongodb.com/atlas) → create free cluster → get connection string

---

### 2. Backend Setup

```bash
cd backend
npm install

# Create .env file
cp .env.example .env
```

Edit `.env`:
```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/nexchat
JWT_SECRET=your_random_secret_key_at_least_32_chars
FAST2SMS_API_KEY=your_fast2sms_api_key_here
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
CLIENT_URL=http://localhost:3000
```

```bash
# Start backend
npm run dev     # development (with nodemon)
npm start       # production
```

Server runs on **http://localhost:5000**

---

### 3. Frontend Setup

```bash
cd frontend
npm install

# Create .env file
echo "REACT_APP_API_URL=http://localhost:5000/api" > .env
echo "REACT_APP_SOCKET_URL=http://localhost:5000" >> .env

# Start frontend
npm start
```

App runs on **http://localhost:3000**

---

## 📱 How OTP Works (Fast2SMS)

```
User enters phone → POST /api/auth/send-otp
→ Backend generates 6-digit OTP
→ Calls Fast2SMS API → Real SMS to mobile
→ User enters OTP → POST /api/auth/verify-otp
→ OTP verified → Registration continues
```

**Fast2SMS Free Tier:** ~₹50 free credits on signup (enough for testing)  
**Works with:** Indian mobile numbers (10 digits)  
**OTP Expiry:** 10 minutes

---

## 🌐 API Endpoints

### Auth
```
POST /api/auth/send-otp       { phone }
POST /api/auth/verify-otp     { phone, otp }
POST /api/auth/register       { name, phone, password }
POST /api/auth/login          { phone, password }
POST /api/auth/login-otp      { phone, otp }
```

### Users
```
GET  /api/users/me
PUT  /api/users/profile       { name, about }
POST /api/users/avatar        (multipart: avatar)
PUT  /api/users/theme         { theme }
POST /api/users/theme/custom  (multipart: themeImage)
POST /api/users/contacts      { phone }
GET  /api/users/contacts
POST /api/users/block/:userId
POST /api/users/unblock/:userId
GET  /api/users/search?phone=
```

### Messages
```
GET    /api/messages/:userId
POST   /api/messages/send     { receiver/group, type, content }
POST   /api/messages/upload   (multipart: media)
DELETE /api/messages/:id      { deleteType: 'me'|'everyone' }
DELETE /api/messages/clear/:userId
```

### Groups
```
POST /api/groups/create
GET  /api/groups
GET  /api/groups/:id/messages
POST /api/groups/:id/members  { userId }
DELETE /api/groups/:id/leave
```

---

## 🔌 Socket.io Events

### Client → Server
```
message:send       → Send message
message:delete     → Delete message
typing:start       → Start typing indicator
typing:stop        → Stop typing indicator
group:join         → Join group room
call:initiate      → Start WebRTC call
call:answer        → Answer incoming call
call:ice-candidate → WebRTC ICE candidate
call:end           → End call
call:reject        → Reject incoming call
```

### Server → Client
```
message:receive    → Incoming message
message:sent       → Message sent confirmation
message:deleted    → Message was deleted
message:read       → Message read receipt
typing:start/stop  → Typing status
user:online/offline→ Presence update
call:incoming      → Incoming call
call:answered      → Call answered
call:ended         → Call ended
call:rejected      → Call rejected
```

---

## 🗂️ Project Structure

```
nexchat/
├── backend/
│   ├── models/
│   │   ├── User.js          # User schema with theme, OTP, contacts
│   │   ├── Message.js       # Message schema with delete options
│   │   └── Group.js         # Group schema
│   ├── routes/
│   │   ├── auth.js          # OTP + login/register
│   │   ├── users.js         # Profile, contacts, theme, block
│   │   ├── messages.js      # CRUD + media upload
│   │   └── groups.js        # Group management
│   ├── middleware/
│   │   └── auth.js          # JWT verification
│   ├── socket/
│   │   └── socketHandler.js # All real-time events + WebRTC
│   ├── .env.example
│   └── server.js
│
└── frontend/
    └── src/
        ├── pages/
        │   ├── Login.jsx     # Password + OTP login
        │   ├── Register.jsx  # 3-step registration with OTP
        │   └── Chat.jsx      # Main chat application
        ├── components/
        │   ├── CallOverlay.jsx     # Audio/Video call UI
        │   ├── ThemeModal.jsx      # Theme selector + custom photo
        │   ├── ProfilePanel.jsx    # Profile editor
        │   ├── AddContactModal.jsx # Find + add contacts
        │   └── CreateGroupModal.jsx# Group creation
        ├── context/
        │   ├── AuthContext.jsx     # Auth state
        │   ├── SocketContext.jsx   # Socket.io connection
        │   └── ThemeContext.jsx    # Theme management
        └── styles/
            └── global.css          # Complete styling
```

---

## 🚀 Production Deployment

### Backend (Railway / Render / VPS)
```bash
npm start
# Set all .env variables in dashboard
```

### Frontend (Vercel / Netlify)
```bash
npm run build
# Set:
# REACT_APP_API_URL=https://your-backend.railway.app/api
# REACT_APP_SOCKET_URL=https://your-backend.railway.app
```

---

## ❓ Troubleshooting

**OTP not received?**
- Check Fast2SMS API key in `.env`
- Ensure phone number is 10 digits (Indian)
- Check Fast2SMS dashboard for credit balance
- Check backend console for error details

**MongoDB connection failed?**
- Ensure MongoDB is running: `sudo systemctl start mongod`
- Or use MongoDB Atlas free cluster

**Media upload fails?**
- Verify Cloudinary credentials in `.env`
- Check file size (limit: 50MB images, 100MB videos)

**Calls not connecting?**
- Both users need camera/mic permissions
- WebRTC works best on same network or with a TURN server
- For production, add a TURN server to the ICE config in `socketHandler.js`
