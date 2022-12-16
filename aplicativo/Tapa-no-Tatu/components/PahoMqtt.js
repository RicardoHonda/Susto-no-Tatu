import React from 'react';
import { Text, View, StyleSheet, Image, TouchableOpacity } from 'react-native';
import Paho from 'paho-mqtt';
import { NavigationContainer } from '@react-navigation/native';

const user = "grupo1-bancadaA4";

export function publishMsg(client, topic, msg) {
  if(client.isConnected()){
    let message = new Paho.Message(msg);
    message.destinationName = topic;
    client.send(message);
  }else {
    console.log("ERROR: nao conectado!");
  }
}

export function setMsg(topic, topics, msg) {
  switch(topic){
    case user+"/V0":
      topics.V0 = msg;
      break;
    case user+"/V1":
      topics.V1 = msg;
      break;
    case user+"/Serial":
      if(msg.charAt(0) == "1") { // flag de tatus
        topics.T0 = msg.charAt(7);
        topics.T1 = msg.charAt(6);
        topics.T2 = msg.charAt(5);
        topics.T3 = msg.charAt(4);
        topics.T4 = msg.charAt(3);
        topics.T5 = msg.charAt(2);
      } else { // flag de pontos
        topics.P0 = msg.charAt(7);
        topics.P1 = msg.charAt(6);
        topics.P2 = msg.charAt(5);
        topics.P3 = msg.charAt(4);
        topics.P4 = msg.charAt(3);
        topics.P5 = msg.charAt(2);
        topics.P6 = msg.charAt(1);
      }
      break;
    // Outros sinais
    case user+"/Init":
      topics.init = msg;
      break;
    case user+"/FimJog":
      topics.fimJog = msg;
      break;
    default:
      console.log("mensagem nao imcompativel!");
      break;
  }
  return topics;
}

function App({navigation}) {

  const clientId = "myClientId" + new Date().getTime();
  const keepAlive = 60;
  const uName = "grupo1-bancadaA4";
  const uPassword = "L@Bdygy1A4";
  
  const port = "8080";
  const broker = "test.mosquitto.org";

  let baseTpcs = {
    V0: "0",V1: "0",
    P0: "0", P1: "0", P2: "0", P3: "0", P4: "0", P5: "0", P6: "0",
    T0: "0", T1: "0", T2: "0", T3: "0", T4: "0", T5: "0",
    fimJog: "0", client: null
  };

  const [connectionStatus, setConnectionStatus] = React.useState(false);
  const [topicos, setTopicos] = React.useState(baseTpcs);

  // Create a client instance
  topicos.client = new Paho.Client(broker, Number(port), clientId);

  // set callback handlers
  topicos.client.onConnectionLost = onConnectionLost;
  topicos.client.onMessageArrived = onMessageArrived;
  
  // connect the client
  tryConnect();

  function tryConnect(){
    console.log("Tentando conexao...");
    topicos.client.connect({onSuccess:onConnect, userName: uName, password: uPassword, onFailure:(props) => {
      console.log(props.errorMessage);
      console.log(clientId);
      },
      });
    console.log("Finaliza tentativa");
  }
  
  // called when the client connects
  function onConnect() {
    // Once a connection has been made, make a subscription and send a message.
    console.log("onConnect");
    topicos.client.subscribe(user+"/V0");
    topicos.client.subscribe(user+"/V1");

    topicos.client.subscribe(user+"/FimJog");

    topicos.client.subscribe(user+"/Serial");
    setConnectionStatus(true);
  }
  
  // called when the client loses its connection
  function onConnectionLost(responseObject) {
    if (responseObject.errorCode !== 0) {
      console.log("onConnectionLost:"+responseObject.errorMessage);
    }
  }

  // called when a message arrives
  function onMessageArrived(message) {
    setTopicos(setMsg(message.destinationName, topicos, message.payloadString));
    console.log("onMessageArrived from "+message.destinationName+": "+message.payloadString);
  }

  navigation.navigate("Inicial", topicos);

  return null;
}

export default App;