import * as React from 'react';
import { Text, View, StyleSheet, Image } from 'react-native';
import styled from 'styled-components/native';
import { COLORS } from './Colors.js';

export const Title = styled.Text`
  color: ${COLORS.orange};
  font-weight: bold;
  font-size: 45px;
  align-self: center;
  text-align: center;
`;

export const MainText = styled.Text`
  color: ${COLORS.orange};
  font-weight: normal;
  font-size: 32px;
  align-self: center;
  font-family: Montserrat;
`;

export const NormalText = styled.Text`
  color: ${COLORS.black};
  font-weight: normal;
  font-size: 25px;
  align-self: center;
  font-family: Montserrat;
  text-align: center;
`;

export const SimpleText = styled.Text`
  color: ${COLORS.black};
  font-weight: normal;
  font-size: 20px;
  font-family: Montserrat;
`;

export const SimpleParagraph = styled.Text`
  color: ${COLORS.black};
  font-weight: normal;
  font-size: 15px;
  font-family: Montserrat;
  align-self: center;
  text-align: center;
`;

export const SmallPontuation = styled.Text`
  color: ${COLORS.orange};
  font-family: Montserrat;
  font-weight: normal;
  font-size: 60px;
  align-self: center;
`;

export const EndNormalText = styled.Text`
  color: ${COLORS.white};
  font-weight: normal;
  font-size: 25px;
  align-self: center;
`;

export const EndMainText = styled.Text`
  color: ${COLORS.white};
  font-weight: normal;
  font-size: 32px;
  align-self: center;
  font-family: Montserrat;
`;

export const EndPontuation = styled.Text`
  color: ${COLORS.white};
  font-family: Montserrat;
  font-weight: normal;
  font-size: 100px;
  align-self: center;
`;