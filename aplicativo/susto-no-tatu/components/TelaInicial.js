import * as React from 'react';
import { Text, View, StyleSheet, Image } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import styled from 'styled-components/native';
import { COLORS } from './Colors.js';
import { FullButton, EmptyButton, ButtonsContainer } from './Buttons.js';
import { Title } from './Typography.js';
import Paho from 'paho-mqtt';
import { setMsg, publishMsg } from './PahoMqtt';

export default function Inicial({navigation, route}) {

  const {
    V0,V1, Dif0, Dif1,
    P0, P1, P2, P3, P4, P5, P6,
    T0, T1, T2, T3, T4, T5,
    fimJog, reset, gameRunning, client
  }  = route.params;

  let tpcs = {
    V0,V1, Dif0, Dif1,
    P0, P1, P2, P3, P4, P5, P6,
    T0, T1, T2, T3, T4, T5,
   fimJog, reset, gameRunning, client,
  };

  const [topicos, setTopicos] = React.useState(tpcs);
  const [myVida, setMyVida] = React.useState(tpcs.vida);

  client.onMessageArrived = TIonMessageArrived;

  function TIonMessageArrived(message) {
    setTopicos(setMsg(message.destinationName, topicos, message.payloadString));
    console.log("TI - onMessageArrived from "+message.destinationName+": "+message.payloadString);
  }

  function getVida(){
    return parseInt(topicos.V1)*2+parseInt(topicos.V0);
  }

  const Background = styled.View`
    alignItems: center;
    justifyContent: space-around;
    padding: 24px;
    backgroundColor: ${COLORS.white};
    height: 100%;
  `;

  const ImageSize = styled.Image`
    width: 220px;
    height: 200px;
    top: 40px;
  `;

  const LogoView = styled.View`
    background: #000000;
  `;

  const IniciaJogo = () => {
    const topic = "grupo1-bancadaA4/Init";
    publishMsg(client, topic, "1");
    setTimeout(() => publishMsg(client, topic, "0"),100);
    changePage("Dificuldade");
  }

  function changePage(nextPage){
    const newTopics = topicos;
    // newTopics.client = client;
    navigation.navigate(nextPage, newTopics);
  }

  return (
    <Background>
      <ImageSize source={require('../assets/TatuAberto_ajustado.png')} />
      <Title>{"Susto no Tatu"}</Title>
      <ButtonsContainer>
        <FullButton text={"Iniciar"} onPress={() => changePage("Dificuldade")}/>
        <FullButton text={"Ranking"} onPress={() => changePage("Ranking")}/>
        <FullButton text={"Regras"} onPress={() => changePage("Regras")}/>
      </ButtonsContainer>
    </Background>
  );
}