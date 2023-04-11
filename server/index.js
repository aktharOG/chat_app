const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const { notificationRouter, admin } = require('./notification');
const io = new Server(server);
const pgadmin = require('pg')
const uniqueId = require('uuid')
const messages = []
app.use(express.json())
app.use(notificationRouter)
var request = require('request');
const { log } = require('console');
var tokens = "ctqmSwi2QN-l6ThmJ2oKQ3:APA91bEzmrBSj81LdBJRgffv8eil_r9tHFSbqzVyaJo30u8T999KPRUIPgGGf4J7ysc4fqXysVU0yuFfE2R5NGWrJwSloXUPtUBbWPRQZkF6uaK31TzHqWH0lcDlYEBz7jgCFzyjyEE6"

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

    function (response) {
      console.log("conneted to pstgressql")

    }

  ).catch(
    function (error) {
      console.log(error)
    }
  )
}
connecttion()
//!------------------------------------------

//! socket connection 
io.on('connection', (socket) => {
  const username = socket.handshake.query.username
  const token = socket.handshake.query.token

  console.log(username)
  console.log(token)

  const message = {
    notification: {
      title: 'Welcome! ' + username,
      body: 'You are now connected to the server.'
    },
    token: token
  };

  //! check user
  checkuser()
  async function checkuser() {
    try {
      sql = `SELECT user_name FROM public.message WHERE user_name=$1`
      client.query(sql, [username], function (error, result) {
        if (error) {
          console.log({ message: "something went wrong", error: error })
        } else {
          //  console.log({message:"saved user",success:result.rows})
          // console.log(result)
          if (result.rows.length != 0) {
            console.log("Username already exists")
            updateToken(token,username)
            
          } else {
            console.log("ready to go")

            saveuser()
            admin.messaging().send(message)
            .then((response) => {
              console.log('Successfully sent message:', response);
            })
            .catch((error) => {
              console.log('Error sending message:', error);
            });
          }
        }
      })
    } catch (e) {
      console.log(e)
    }
  }

  //!-----------------------------------------

  //! save user to db 

  async function saveuser() {
    try {
      sql = `INSERT INTO public.message(
      user_name, token, messages,  id)
      VALUES ($1, $2, $3, $4)`

      client.query(sql, [username, token, [''], "uniqueId.v3"], function (error, result) {
        if (error) {
          console.log({ message: "something went wrong", error: error })
        } else {
          // console.log({message:"saved user",success:result})
          console.log('user saved')
        }
      })
    } catch (e) {
      console.log(e)
    }
  }


  //!---------------------------------------------

 

  socket.on('message', (data) => {
    const message = {
      message: data.message,
      sender: username,
      sentAt: Date.now(),
      image:data.image
    }



    try {
      console.log(data)
      messages.push(message)
      io.emit('message', message)
      //! save message to db
      saveMessages(data.message,username)
      //! send notificaion on message
      send_notification()
      async function send_notification() {
        try {
          sql = `SELECT token FROM public.message WHERE user_name!=$1`
          client.query(sql, [username], function (error, result) {
            if (error) {
              console.log(error)
            } else {

              items = result.rows
              var names = items.map(function (item) {
                
                 
                  return item['token'].trim()
                  
                

              });

              console.log(names)
              const notification = {
                notification: {
                  title: 'message from ' + username,
                  body: data.message
                },
                tokens: names
              };


              admin.messaging().sendMulticast(notification)
                .then((response) => {
                  console.log('Successfully sent message:', response);
                })
                .catch((error) => {
                  console.log('Error sending message:', error);
                });

            }
          })
        } catch (e) {
          console.log(e)
        }
      }
      //!---------------------------------------------------------------


    } catch (e) {
      console.log(e)
    }

  })
});


// var requestLoop = setInterval(function(){
//   request({
//       url: "https://my-chat-app-1slx.onrender.com",
//       method: "GET",
//       timeout: 10000,
//       followRedirect: true,
//       maxRedirects: 10
//   },function(error, response, body){
//       if(!error && response.statusCode == 200){
//           console.log('sucess!');
//       }else{
//           console.log('error' + response.statusCode);
//       }
//   });
// }, 120000);

/// sample routes

app.get('/check', (req, res) => {
  const { username } = req.body

  // sql = `SELECT array_agg(val)
  // FROM (
  //   SELECT unnest(messages) AS val
  //   FROM public.message
  // ) t
  // `
  sql = 'select messages from public.message'
  client.query(sql, function (error, result) {
    if (error) {
      res.send({ msg: error })
    } else {

     
      //  items = result.rows
      // var names = items.map(function (item) {
      //   return item['messages'].trim()
      // });
    const  arrayMessage = []
      result.rows.forEach(row=>{
        const array = row.messages
        //arrayMessage.push(array)
        
      })
      // const rows = result.rows.map(row => {
      //   if (Array.isArray(row.messages)) {
      //     row.messages = row.messages.join('').trim();
      //   }
      //   return row;
      // });
  
      // console.log(rows); 

      const allMessages = arrayMessage.reduce((acc,val)=>acc.concat(val),[])
     //const fetch = allMessages.trim().split(' ')
    //  cleanData = result.rows
    //  const jsonArray = JSON.parse(`[${cleanData}]`);
    const rows = result.rows;

    // Loop through each row and trim each element of the messages array
    rows.forEach((row) => {
      const messages = row.messages.map((msg) => msg.trim());
      row.messages = messages.reduce((acc,val)=>acc.concat(val),[]);
    });
            arrayMessage.push(rows)

    // const messages = result.rows.map(row => JSON.parse(row.messages.trim()));
      const messageList = arrayMessage.reduce((acc,val)=>acc.concat(val),[])
      res.send(messageList)
      try {
        const data = JSON.parse(allMessages);
        // use the parsed data here
      } catch (error) {
        console.error(`Error parsing JSON: ${error.message}`);
        // handle the error here
      }
      // console.log(allMessages)
    }
  })
})


  
async function saveMessages(message,username){
   sql =`UPDATE public.message SET messages=array_append(messages, $1) WHERE user_name = $2
   `
    try{
   client.query(sql,[message,username],function(error,result){
    if (error) {
      console.log(error)
    } else {
       console.log({message: 'Saved'})
    }
         
   })
    }catch(e){
      console.log(e)
    }
 }
 async function updateToken(token,username){
  sql =`UPDATE public.message SET token=$1 WHERE user_name = $2
  `
   try{
  client.query(sql,[token,username],function(error,result){
   if (error) {
     console.log(error)
   } else {
      console.log({message: 'token updated'})
   }
        
  })
   }catch(e){
     console.log(e)
   }
}




server.listen(3000, () => {
  console.log('listening on *:3000');
});

