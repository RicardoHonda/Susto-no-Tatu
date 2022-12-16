import * as React from 'react';
import Inicial from './components/TelaInicial';
import Dificuldade from './components/Dificuldade';
import Jogo from './components/Jogo';
import Regras from './components/Regras';
import PahoMqtt from './components/PahoMqtt';
import Ranking from './components/Ranking';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

const Stack = createStackNavigator();

export default function App() {

  const [globalClient, setGlobalClient] = React.useState([]);

  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="PahoMqtt" screenOptions={{headerShown: false}}>
        <Stack.Screen name="Inicial" component={Inicial} />
        <Stack.Screen name="Dificuldade" component={Dificuldade} />
        <Stack.Screen name="Jogo" component={Jogo} />
        <Stack.Screen name="PahoMqtt" component={PahoMqtt} />
        <Stack.Screen name="Regras" component={Regras} />
        <Stack.Screen name="Ranking" component={Ranking} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
