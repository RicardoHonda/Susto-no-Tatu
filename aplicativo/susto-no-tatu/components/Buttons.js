import * as React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import styled from 'styled-components/native';
import { COLORS } from './Colors.js';
import { SimpleText } from './Typography.js'

export const ButtonsContainer = styled.View`
  justify-content: space-around;
  width: 100%;
  heigth: 100%;
  padding: 10px;
`;

const Container = styled.View`
  padding: 10px;
  width: 100%;
  align-self: center;
`;

const FullButtonLayout = styled.TouchableOpacity`
  border-radius: 10px;
  background: ${COLORS.orange};
  padding: 10px;
`;

const FullButtonText = styled.Text`
  color: ${COLORS.white};
  font-weight: normal;
  font-size: 27px;
  align-self: center;
`;

export const FullButton = (props) => {
  return(
    <Container>
        <FullButtonLayout onPress={props.onPress}>
          <FullButtonText>{props.text}</FullButtonText>
        </FullButtonLayout>
    </Container>
  );
}

const EmptyButtonLayout = styled.TouchableOpacity`
  border-radius: 10px;
  background: ${COLORS.white};
  padding: 10px;
  border: 3px;
  border-color: ${COLORS.orange};
`;

const EmptyButtonText = styled.Text`
  color: ${COLORS.orange};
  font-weight: normal;
  font-size: 32px;
  align-self: center;
`;

export const EmptyButton = (props) => {
  return(
    <Container>
        <EmptyButtonLayout onPress={props.onPress}>
          <EmptyButtonText>{props.text}</EmptyButtonText>
        </EmptyButtonLayout>
    </Container>
  );
}

export const SimpleButton = (props) => {
  return(
    <Container>
        <TouchableOpacity onPress={props.onPress}>
          <SimpleText>{props.text}</SimpleText>
        </TouchableOpacity>
    </Container>
  );
}

const WhiteEmptyButtonLayout = styled.TouchableOpacity`
  border-radius: 10px;
  padding: 10px;
  border: 3px;
  border-color: ${COLORS.white};
  width: 100%;
`;

const WhiteEmptyButtonText = styled.Text`
  color: ${COLORS.white};
  font-weight: normal;
  font-size: 25px;
  align-self: center;
`;

export const WhiteEmptyButton = (props) => {
  return(
    <Container>
        <WhiteEmptyButtonLayout onPress={props.onPress}>
          <WhiteEmptyButtonText>{props.text}</WhiteEmptyButtonText>
        </WhiteEmptyButtonLayout>
    </Container>
  );
}