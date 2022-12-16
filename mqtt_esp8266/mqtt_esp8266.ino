#include <ESP8266WiFi.h>
#include <PubSubClient.h>

String user = "grupo1-bancadaA4";
String passwd = "digi#@1A4";

const char* ssid = "LAB_DIGITAL";
const char* password = "C1-17*2018@labdig";
const char* mqtt_server = "labdigi.wiseful.com.br";

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE  (50)
char msg[MSG_BUFFER_SIZE];
int value = 0;

#include <Wire.h>
#include <SoftwareSerial.h>
SoftwareSerial mySerial(D6, D5); // RX, TX

uint8_t DXr[16];
uint8_t DXw[16] = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2};

uint32_t prev_millis;
uint32_t ms_cnt = 0;

const char* zero_cstr = "0";
const char* one_cstr = "1";

int V0 = 0;
int V1 = 0;
int seri = 0;
int FimJog = 0;
int Reset = 0;
int Init_FPGA = 0;
int S6 = 0;
int S7 = 0;


#define slider3
//#define slider2

#define sonar

#ifdef sonar
String dadosonar = "";
#endif

void setup_wifi() {

  delay(10);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  if (strcmp(topic,(user+"/led").c_str())==0) {
    if ((char)payload[0] == '1') {
      digitalWrite(D4, LOW);   
    } else {
      digitalWrite(D4, HIGH);  // Turn the LED off by making the voltage HIGH
    }
  }

  if (strcmp(topic,(user+"/Init").c_str())==0)  DXw[0]  = (int) ((char)payload[0] - '0');
  if (strcmp(topic,(user+"/Dif").c_str())==0)  DXw[1]  = (int) ((char)payload[0] - '0');
  if (strcmp(topic,(user+"/B0").c_str())==0)  DXw[2]  = (int) ((char)payload[0] - '0');
  if (strcmp(topic,(user+"/B1").c_str())==0)  DXw[3]  = (int) ((char)payload[0] - '0');
  if (strcmp(topic,(user+"/B2").c_str())==0)  DXw[4]  = (int) ((char)payload[0] - '0');
  if (strcmp(topic,(user+"/B3").c_str())==0)  DXw[5]  = (int) ((char)payload[0] - '0');
  if (strcmp(topic,(user+"/B4").c_str())==0)  DXw[6]  = (int) ((char)payload[0] - '0');
  if (strcmp(topic,(user+"/B5").c_str())==0)  DXw[7]  = (int) ((char)payload[0] - '0');

  if (strcmp(topic,(user+"/RX").c_str())==0){
    String dado = String((char)payload[0]);
    mySerial.print(dado);
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = user;
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str(), user.c_str(), passwd.c_str())) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish((user+"/hello").c_str(), "hello world");
      // ... and resubscribe
      client.subscribe((user+"/led").c_str());
      client.subscribe((user+"/Init").c_str());
      client.subscribe((user+"/Dif").c_str());
      client.subscribe((user+"/B0").c_str());
      client.subscribe((user+"/B1").c_str());
      client.subscribe((user+"/B2").c_str());
      client.subscribe((user+"/B3").c_str());
      client.subscribe((user+"/B4").c_str());
      client.subscribe((user+"/B5").c_str());
      client.subscribe((user+"/RX").c_str());
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup() {
  pinMode(BUILTIN_LED, OUTPUT);
  
  pinMode(D6, INPUT); //RX
  pinMode(D7, INPUT);
  pinMode(D8, INPUT);

  pinMode(D1, OUTPUT);
  pinMode(D2, OUTPUT);
  pinMode(D5, OUTPUT); //TX
  
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, 80);
  client.setCallback(callback);

  mySerial.begin(9600);

  Wire.begin(D2,D1); //SDA, SCL
}

void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  if (mySerial.available()){
    char value = mySerial.read();
    //Serial.println(value, BIN);

    char valueb = value;

    bitWrite(valueb, 8, 0);
    bitWrite(valueb, 7, 0);
    for (int i=0; i<7; i++) {
      bitWrite(valueb, 6 - i, bitRead(value, i));
    }
    Serial.println(valueb, BIN);
      
    //String sa = String(value, HEX);
      
    String sa2;
    sa2 = value;
      
    //Serial.println(sa2);
      
    client.publish((user+"/TX").c_str(), sa2.c_str());

    //===dadosonar===
    #ifdef sonar
      dadosonar = dadosonar + value;
    
      if (dadosonar.length() > 100) 
        dadosonar = "";
    
      Serial.println(dadosonar);
      
      if (value == '.') {
        Serial.println("dadosonar= " + dadosonar);
        client.publish((user+"/dadosonar").c_str(), dadosonar.c_str());
        dadosonar = "";
      }
    #endif
  }

  if(prev_millis!=millis()){
    prev_millis=millis();
    if(ms_cnt%100==0){
      dxRead();

      int change = -1;

      if ((V0 != DXr[8])and(DXr[8] == 0)){
        client.publish((user+"/V0").c_str(), zero_cstr);
        change = 1;
      }
      if ((V0 != DXr[8])and(DXr[8] == 1)){
        client.publish((user+"/V0").c_str(), one_cstr);
        change = 1;
      }

      if ((V1 != DXr[9])and(DXr[9] == 0)){
        client.publish((user+"/V1").c_str(), zero_cstr);
        change = 1;
      }
      if ((V1 != DXr[9])and(DXr[9] == 1)){
        client.publish((user+"/V1").c_str(), one_cstr);
        change = 1;
      }

      if ((seri != DXr[10])and(DXr[10] == 0)){
        client.publish((user+"/Seri").c_str(), zero_cstr);
        change = 1;
      }
      if ((seri != DXr[10])and(DXr[10] == 1)){
        client.publish((user+"/Seri").c_str(), one_cstr);
        change = 1;
      }

      if ((FimJog != DXr[11])and(DXr[11] == 0)){
        client.publish((user+"/FimJog").c_str(), zero_cstr);
        change = 1;
      }
      if ((FimJog != DXr[11])and(DXr[11] == 1)){
        client.publish((user+"/FimJog").c_str(), one_cstr);
        change = 1;
      }

      if ((Reset != DXr[12])and(DXr[12] == 0)){
        client.publish((user+"/Reset").c_str(), zero_cstr);
        change = 1;
      }
      if ((Reset != DXr[12])and(DXr[12] == 1)){
        client.publish((user+"/Reset").c_str(), one_cstr);
        change = 1;
      }

      if ((Init_FPGA != DXr[13])and(DXr[13] == 0)){
        client.publish((user+"/Init_FPGA").c_str(), zero_cstr);
        change = 1;
      }
      if ((Init_FPGA != DXr[13])and(DXr[13] == 1)){
        client.publish((user+"/Init_FPGA").c_str(), one_cstr);
        change = 1;
      }

      if ((S6 != DXr[14])and(DXr[14] == 0)){
        client.publish((user+"/S6").c_str(), zero_cstr);
        change = 1;
      }
      if ((S6 != DXr[14])and(DXr[14] == 1)){
        client.publish((user+"/S6").c_str(), one_cstr);
        change = 1;
      }

      if ((S7 != DXr[15])and(DXr[15] == 0)){
        client.publish((user+"/S7").c_str(), zero_cstr);
        change = 1;
      }
      if ((S7 != DXr[15])and(DXr[15] == 1)){
        client.publish((user+"/S7").c_str(), one_cstr);
        change = 1;
      }
      
      V0 = DXr[8];
      V1 = DXr[9];
      seri = DXr[10];
      FimJog = DXr[11];
      Reset = DXr[12];
      Init_FPGA = DXr[13];
      S6 = DXr[14];
      S7 = DXr[15];

      if (change >= 0){

        #ifdef slider3
        client.publish((user+"/slider").c_str(), (String(seri*4 + V1*2 + V0)).c_str());
        #endif

        #ifdef slider2
        client.publish((user+"/slider").c_str(), (String(V1*2 + V0)).c_str());
        #endif
      }

      dxWrite();
    }
    ms_cnt++;
  }

  unsigned long now = millis();
  if (now - lastMsg > 2000) {
    lastMsg = now;
    ++value;
    snprintf (msg, MSG_BUFFER_SIZE, "#%ld", value);
    Serial.print("Publish message: ");
    Serial.println(msg);
    client.publish((user+"/hello").c_str(), msg);
  }
}
