import * as React from 'react';
import { Text, View, StyleSheet, Image } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import styled from 'styled-components/native';
import { COLORS } from './Colors.js';
import { FullButton, EmptyButton, ButtonsContainer } from './Buttons.js';
import { Title, NormalText, SimpleText, SimpleParagraph } from './Typography.js';
import Paho from 'paho-mqtt';
import { setMsg, publishMsg } from './PahoMqtt';

export default function Regras({navigation, route}) {

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
  const [myVida, setMyVida] = React.useState(tpcs.vida);

  topicos.client.onMessageArrived = TIonMessageArrived;

  function TIonMessageArrived(message) {
    setTopicos(setMsg(message.destinationName, topicos, message.payloadString));
    console.log("TI - onMessageArrived from "+message.destinationName+": "+message.payloadString);
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

  const Row = styled.View`
    flex-direction: row;
    justify-content: space-around;
    margin: 8px;
  `;

  const Container = styled.View`
    align-items: center;
  `;

  const Tatu = styled.Image`
    width: 133px;
    height: 90px;
    padding: 10px;
  `;

  const Heart = styled.Image`
    width: 40px;
    height: 40px;
  `;

  const HeartContainer = styled.View`
    padding: 10px;
  `;

  const IniciaJogo = () => {
    const topic = "grupo1-bancadaA4/Init";
    publishMsg(client, topic, "1");
    setTimeout(() => publishMsg(client, topic, "0"),100);
    changePage("Dificuldade");
  }

  function changePage(nextPage){
    const newTopics = topicos;
    newTopics.client = client;
    navigation.navigate(nextPage, newTopics);
  }

  return (
    <Background>
    
      <Title>{"Tapa no Tatu"}</Title>
      <NormalText>{"Como jogar"}</NormalText>
      <SimpleParagraph>{"A cada rodada, você deve selecionar todos os tatus que estiverem acordados."}</SimpleParagraph>

      <Row>
        <Container>
          <SimpleText>{"Dormindo"}</SimpleText>
          <Tatu source={require('../assets/TatuFechado_ajustado.png')}/>
        </Container>
        <Container>
          <SimpleText>{"Acordado"}</SimpleText>
          <Tatu source={require('../assets/TatuAberto_ajustado.png')}/>
        </Container>
      </Row>
      <SimpleParagraph>{"Cada tatu correto selecionado lhe dará um ponto."}</SimpleParagraph>

      <Row>
        {[...Array(3)].map((_, i) => <HeartContainer><Heart source={require('../assets/Heart.png')} /></HeartContainer>)}
      </Row>

      <SimpleParagraph>{"A cada jogo você possui 3 vidas, selecionar um tatu dormindo, ou estourar o tempo da rodada faz você perder vidas."}</SimpleParagraph>
      <SimpleParagraph>{"O jogo conta com um seletor de dificuldade que definirá o tempo inicial de cada rodada. Com o passar das jogadas, esse tempo é diminuido."}</SimpleParagraph>
      <SimpleParagraph>{"O jogo acaba quando todas a vidas terminarem."}</SimpleParagraph>

      <ButtonsContainer>
        <FullButton text={"Voltar"} onPress={() => changePage("Inicial")}/>
      </ButtonsContainer>
    </Background>
  );
}