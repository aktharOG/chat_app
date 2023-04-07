const express = require('express')
const notificationRouter = express.Router()

var admin = require("firebase-admin");

var serviceAccount = require("./chat-f429d-firebase-adminsdk-kdkql-9cafd0b016.json");
const defualtapp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});






 notificationRouter.get('/artista/send',async(req,res)=>{
   // console.log(defualtapp)
    var tokens ="e5nmSRJqQAKDGRr11Mr15s:APA91bE0Dw5XzSmMcW7zSACVl77ppjR9YwPTt6zGXRDiwPDgze2sevyZ6bBR6ji9EDbET_fc0noidNBADp09vTYuVCrBZbvR-rWkbOzUDuTX2400IrUoDC_aji91q93d7Sr6obR6ZJZr"
    var payload ={
        notification:{
            title:'Helllo  guyzz',
            body:'Welocome back',
           
        }
       }
       const message = {
        notification: {
          title: 'New Notification',
          body: 'This is a notification from Firebase!'
        },
        token: tokens
      };
    try{
       
       await admin.messaging().send(
         message
    
       ).then(function(response){
        res.send({message:"notification send"})
       }).catch(function(error) {
    
        res.send({"Message": "Error sending notification "+error});
        console.log(error)
    });
    }catch(error){
        res.send({
            msg:error
        })
    }
})


   


module.exports = {notificationRouter,admin}







