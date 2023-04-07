const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const {notificationRouter, admin} = require('./notification');
const io = new Server(server);
const pgadmin = require('pg')
const messages = []
  app.use(notificationRouter)
  var tokens ="e5nmSRJqQAKDGRr11Mr15s:APA91bE0Dw5XzSmMcW7zSACVl77ppjR9YwPTt6zGXRDiwPDgze2sevyZ6bBR6ji9EDbET_fc0noidNBADp09vTYuVCrBZbvR-rWkbOzUDuTX2400IrUoDC_aji91q93d7Sr6obR6ZJZr"

  //! database connection 
  var client
async function connecttion() {
    client = new pgadmin.Pool({
        user: "dilshad",
        host: "dpg-cga0o84eoogtbdsumc60-a.oregon-postgres.render.com",
        database: "mydb_jbh3",
        password: "tm45QohI1pPFgk8y0zCaSpkW95YJ0lqY",
        port: 5432,
        ssl: true
    })
    await client.connect()
    const res = await client.query('select * from login').then(

       function(response){
        console.log("conneted to pstgressql")

       }

    ).catch(
       function(error){
        console.log(error)
       }
    )
}
connecttion()
  //!------------------------------------------

  //! socket connection 
io.on('connection', (socket) => {
  const username = socket.handshake.query.username
  console.log(username)
  const message = {
    notification: {
      title: 'Welcome! '+username,
      body: 'You are now connected to the server.'
    },
    token: tokens
  };

  admin.messaging().send(message)
    .then((response) => {
      console.log('Successfully sent message:', response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
  
  socket.on('message',(data)=>{
    const message = {
        message:data.message,
        sender:username,
        sentAt:Date.now()
      }
      const notification = {
        notification: {
          title: 'message from '+username,
          body: data.message
        },
        token: tokens
      };


      try{
        console.log(data)
     messages.push(message)
     io.emit('message',message)
     admin.messaging().send(notification)
    .then((response) => {
      console.log('Successfully sent message:', response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });

      }catch(e){
        console.log(e)
      }
    
  })
});

server.listen(3000, () => {
  console.log('listening on *:3000');
});