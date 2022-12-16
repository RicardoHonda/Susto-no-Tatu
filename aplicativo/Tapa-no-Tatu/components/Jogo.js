import * as React from 'react';
import { Text, View, StyleSheet, Image, TouchableOpacity, Dimensions } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import styled from 'styled-components/native';
import { COLORS } from './Colors.js'
import { WhiteEmptyButton, ButtonsContainer } from './Buttons.js'
import { NormalText, SmallPontuation, EndNormalText, EndMainText, EndPontuation } from './Typography.js'
import { setMsg, publishMsg } from './PahoMqtt';
import Paho from 'paho-mqtt';

const windowWidth = Dimensions.get('window').width;
const windowHeight = Dimensions.get('window').height;

export default function Dificuldade({navigation, route}) {

  const TatuAberto = require('../assets/TatuAberto_ajustado.png');
  const TatuFechado = require('../assets/TatuFechado_ajustado.png');

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

  const tatusImageDefalut = [
    T0 == '1' ? TatuAberto: TatuFechado,
    T1 == '1' ? TatuAberto: TatuFechado,
    T2 == '1' ? TatuAberto: TatuFechado,
    T3 == '1' ? TatuAberto: TatuFechado,
    T4 == '1' ? TatuAberto: TatuFechado,
    T5 == '1' ? TatuAberto: TatuFechado,
    ];

  const [ hearts, setHearts ] = React.useState(3);
  const [ pontuation, setPontuation ] = React.useState(0);
  const [ tatus, setTatus ] = React.useState(["0","0","0","0","0","0"]);
  const [ tatusImage, setTatuImage ] = React.useState(tatusImageDefalut);
  const [ fimJogo, setFimJogo ] = React.useState(false);

  const [topicos, setTopicos] = React.useState(tpcs);

  client.onMessageArrived = JGonMessageArrived;

  React.useEffect(() => {
    async function setValues() {
      setHearts(getVida());
      setPontuation(getPontuation());
      setFimJogo(topicos.fimJog);
    }
    setValues();
  }, []);

  function JGonMessageArrived(message) {
    setTopicos(setMsg(message.destinationName, topicos, message.payloadString));
    console.log("JG - onMessageArrived from "+message.destinationName+": "+message.payloadString);
    setHearts(getVida());
    setPontuation(getPontuation());
    setFimJogo(topicos.fimJog);
    let topic = message.destinationName;
    if(topic == "grupo1-bancadaA4/Serial"){
      setTatuStatus();
    }
  }

  function getVida(){
    return parseInt(topicos.V1)*2+parseInt(topicos.V0);
  }

  function getPontuation(){
    return (parseInt(topicos.P6)*64+parseInt(topicos.P5)*32+parseInt(topicos.P4)*16+parseInt(topicos.P3)*8+
            parseInt(topicos.P2)*4+parseInt(topicos.P1)*2+parseInt(topicos.P0));
  }

  function changePage(nextPage){
    const newTopics = topicos;
    newTopics.client = client;
    navigation.navigate(nextPage, newTopics);
  }

  const Background = styled.View`
    position: absolute;
    alignItems: center;
    justify-content: center;
    padding: 24px;
    backgroundColor: ${COLORS.white};
    height: ${windowHeight}px;
    width: ${windowWidth}px;
  `;

  const Heart = styled.Image`
    width: 40px;
    height: 40px;
  `;

  const HeartContainer = styled.View`
    padding: 10px;
  `;

  const Row = styled.View`
    flex-direction: row;
    justify-content: space-around;
    margin: 8px;
  `;

  const Tatu = styled.Image`
    width: 133px;
    height: 90px;
    padding: 10px;
  `;

  const getImage = (status) => {
    if(status == '1'){
      return TatuAberto;
    }else{
      return TatuFechado;
    }
  }

  const setTatuStatus = () => {
    // const newTatus = tatus;
    let newTatusImage = tatusImage;
    newTatusImage = [tatusImage[0], tatusImage[1], tatusImage[2], tatusImage[3], tatusImage[4], tatusImage[5]];
    
    newTatusImage[0] = getImage(topicos.T0);
    newTatusImage[1] = getImage(topicos.T1);
    newTatusImage[2] = getImage(topicos.T2);
    newTatusImage[3] = getImage(topicos.T3);
    newTatusImage[4] = getImage(topicos.T4);
    newTatusImage[5] = getImage(topicos.T5);

    // setTatus(newTatus);
    setTatuImage(newTatusImage);
    console.log(tatus[0]);
  }

  const selectTatu = (num) => {
    const topic = "grupo1-bancadaA4/B" + num;
    publishMsg(client, topic, "1");
    setTimeout(() => publishMsg(client, topic, "0"),100)
  }

  // Layer de fim de jogo

  const Layer = styled.View`
    position: absolute;
    alignItems: center;
    justify-content: center;
    padding: 24px;
    backgroundColor: ${COLORS.orange};
    height: 100%;
    height: ${windowHeight}px;
    width: ${windowWidth}px;
    opacity: 0.9;
  `;

  const TransparentLayer = styled.View`
    position: absolute;
    alignItems: center;
    justify-content: space-around;
    padding: 24px;
    height: ${windowHeight}px;
    width: ${windowWidth}px;
  `;

  const RemoveOpacity = styled.View`
    opacity: 1;
  `;

  return (
    <View>
      <Background>
        <NormalText>Pontuação</NormalText>
        <SmallPontuation>{pontuation}</SmallPontuation>

        <Row>
          {[...Array(hearts)].map((_, i) => <HeartContainer><Heart source={require('../assets/Heart.png')} /></HeartContainer>)}
        </Row>

        <Row>
          <HeartContainer>
            <TouchableOpacity onPress={() => selectTatu(0)} onClick={() => console.log("oi")}>
              <Tatu source={tatusImage[0]} />
            </TouchableOpacity>
          </HeartContainer>
          <HeartContainer>
            <TouchableOpacity onPress={() => selectTatu(1)}>
              <Tatu source={tatusImage[1]} />
            </TouchableOpacity>
          </HeartContainer>
        </Row>
        <Row>
          <HeartContainer>
            <TouchableOpacity onPress={() => selectTatu(2)}>
              <Tatu source={tatusImage[2]} />
            </TouchableOpacity>
          </HeartContainer>
          <HeartContainer>
            <TouchableOpacity onPress={() => selectTatu(3)}>
              <Tatu source={tatusImage[3]} />
            </TouchableOpacity>
          </HeartContainer>
        </Row>
        <Row>
          <HeartContainer>
            <TouchableOpacity onPress={() => selectTatu(4)}>
              <Tatu source={tatusImage[4]} />
            </TouchableOpacity>
          </HeartContainer>
          <HeartContainer>
            <TouchableOpacity onPress={() => selectTatu(5)}>
              <Tatu source={tatusImage[5]} />
            </TouchableOpacity>
          </HeartContainer>
        </Row>
      </Background>
      {fimJogo == '1'  && 
        <View>
          <Layer>
          </Layer>
          <TransparentLayer>
            <View style={{padding: 15}}>
              <EndMainText>FIM DE JOGO</EndMainText>
            </View>
            <EndNormalText>Sua pontuação</EndNormalText>
            <EndPontuation>{pontuation}</EndPontuation>
            <ButtonsContainer>
              <WhiteEmptyButton text={'Jogar novamente'} onPress={() => changePage("Dificuldade")}/>
              <WhiteEmptyButton text={'Sair'} onPress={() => changePage("Inicial")}/>
            </ButtonsContainer>
          </TransparentLayer>
        </View>
      }
      </View>
  );
}

// <Tatu image={getTatuStatus(0)} source={(props) => require(props.image)} />