const express = require('express')
const notificationRouter = express.Router()

var admin = require("firebase-admin");

var serviceAccount = require("./chat-f429d-firebase-adminsdk-kdkql-9cafd0b016.json");
const client = require('.');
const defualtapp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});






 notificationRouter.post('/artista/send',async(req,res)=>{
   // console.log(defualtapp)
    const {token} = req.body
    var payload ={
        notification:{
            title:'Helllo  guyzz',
            body:'Welocome back',
           
        },
        token:token
       }
       const message = {
        notification: {
          title: 'New Notification',
          body: 'This is a notification from Firebase!'
        },
        token:token
       
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







