import * as React from 'react';
import { Text, View, StyleSheet, Image } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import styled from 'styled-components/native';
import { COLORS } from './Colors.js'
import { FullButton, EmptyButton, SimpleButton } from './Buttons.js'
import { NormalText } from './Typography.js';
import { setMsg, publishMsg } from './PahoMqtt';
import Paho from 'paho-mqtt';

export default function Dificuldade({navigation, route}) {

  const {
    V0,V1, Dif0, Dif1,
    P0, P1, P2, P3, P4, P5, P6,
    T0, T1, T2, T3, T4, T5,
    fimJog, client
  }  = route.params;

  let tpcs = {
    V0,V1, Dif0, Dif1,
    P0, P1, P2, P3, P4, P5, P6,
    T0, T1, T2, T3, T4, T5,
   fimJog, client,
  };

  const [topicos, setTopicos] = React.useState(tpcs);

  client.onMessageArrived = TIonMessageArrived;

  function TIonMessageArrived(message) {
    setTopicos(setMsg(message.destinationName, topicos, message.payloadString));
    console.log("DIF - onMessageArrived from "+message.destinationName+": "+message.payloadString);
  }

  const Background = styled.View`
    alignItems: center;
    justify-content: space-around;
    padding: 24px;
    backgroundColor: ${COLORS.white};
    height: 100%;
  `;

  const Title = styled.Text`
    color: ${COLORS.orange};
    font-weight: bold;
    font-size: 45px;
    align-self: center;
  `;

  const ButtonsContainer = styled.View`
    justify-content: space-around;
    width: 100%;
    heigth: 100%;
    padding: 10px;
  `;

  const IniciaJogo = () => {
    const topic = "grupo1-bancadaA4/Init";
    publishMsg(client, topic, "1");
    setTimeout(() => publishMsg(client, topic, "0"),100);
    changePage("Dificuldade");
  }

  const selectDificulty = (dif) => {
    // Publish da dificuldade
    publishMsg(client,"grupo1-bancadaA4/Dif", dif);
    console.log('Dificuldade escolhida',dif);
    publishMsg(client,"grupo1-bancadaA4/Init", '1');
    setTimeout(() => {publishMsg(client,"grupo1-bancadaA4/Dif", '0'); publishMsg(client,"grupo1-bancadaA4/Init", '0');changePage("Jogo");} , 1000);
  }

  function changePage(nextPage){
    const newTopics = topicos;
    newTopics.client = client;
    navigation.navigate(nextPage, newTopics);
  }

  const BottomContainer = styled.View`
    justify-content: flex-end;
    height: 20%;
  `;

  return (
    <View>
      <Background>
        <NormalText>Escolha a dificuldade</NormalText>
        <ButtonsContainer>
          <EmptyButton text={"Fácil"} onPress={() => selectDificulty('0')}/>
          <EmptyButton text={"Difícil"} onPress={() => selectDificulty('1')}/>
          <BottomContainer/>
          <BottomContainer>
            <SimpleButton text={"Voltar"} onPress={() => changePage("Inicial")}/>
          </BottomContainer>
        </ButtonsContainer>
      </Background>
    </View>
  );
}