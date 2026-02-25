const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);

// Enable CORS for potential web clients
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

app.get('/', (req, res) => {
  res.send('LoopinJ WebRTC Signaling Server is running.');
});

// Map to keep track of connected users: userId -> socketId
const users = new Map();

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // 1. User registers their userId with this socket
  socket.on('register', (userId) => {
    users.set(userId, socket.id);
    console.log(`Registered user ${userId} with socket ${socket.id}`);
  });

  // 2. Forward WebRTC offer to specific user
  socket.on('offer', (data) => {
    const { targetUserId, callerId, sdp } = data;
    const targetSocketId = users.get(targetUserId);

    if (targetSocketId) {
      console.log(`Forwarding offer from ${callerId} to ${targetUserId}`);
      io.to(targetSocketId).emit('offer', { callerId, sdp });
    } else {
      console.log(`Target user ${targetUserId} not found for offer.`);
      // Optionally notify caller that user is offline
      socket.emit('error_message', 'User is offline');
    }
  });

  // 3. Forward WebRTC answer to caller
  socket.on('answer', (data) => {
    const { callerId, targetUserId, sdp } = data;
    const callerSocketId = users.get(callerId);

    if (callerSocketId) {
      console.log(`Forwarding answer from ${targetUserId} to ${callerId}`);
      io.to(callerSocketId).emit('answer', { targetUserId, sdp });
    }
  });

  // 4. Forward ICE candidates
  socket.on('ice_candidate', (data) => {
    const { targetUserId, senderId, candidate } = data;
    const targetSocketId = users.get(targetUserId);

    if (targetSocketId) {
      console.log(`Forwarding ICE candidate from ${senderId} to ${targetUserId}`);
      io.to(targetSocketId).emit('ice_candidate', { senderId, candidate });
    }
  });
  
  // 5. End Call signaling
  socket.on('end_call', (data) => {
    const { targetUserId, senderId } = data;
    const targetSocketId = users.get(targetUserId);
    
    if (targetSocketId) {
      console.log(`Forwarding call end from ${senderId} to ${targetUserId}`);
      io.to(targetSocketId).emit('end_call', { senderId });
    }
  })

  // 6. Handle disconnection and clean up map
  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    for (let [userId, socketId] of users.entries()) {
      if (socketId === socket.id) {
        users.delete(userId);
        console.log(`Removed user ${userId} from connected map.`);
        break;
      }
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Signaling server listening on port ${PORT}`);
});
