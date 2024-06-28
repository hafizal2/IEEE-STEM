#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// const char* ssid = "OneplusHotspot";
// const char* password = "asdf1234";
const char* ssid = "dlinkap1360";
const char* password = "abcd1234";

const char* mqtt_server = "174.138.28.115";
const int mqtt_port = 1883;
const char* mqtt_user = ""; // Add user if authentication is required
const char* mqtt_password = ""; // Add password if authentication is required

//MQTT Topics
const char* distance_topic = "sensor/distance";
const char* light_topic = "sensor/light";
const char* onoff_topic = "led/power";

// Ultrasonic Sensor Pins
const int trigPin = D0;
const int echoPin = D1;
float preDistance = 0;

// LDR Sensor Pin
const int ldrPin = A0;

// LED
const int ledBluePin = D2;
const int ledGreenPin = D3; 
const int ledYellowPin = D4; 
const int ledRedPin = D5; 


// Node-RED
const char* led_override_topic = "sensor/led_override";

bool overrideLed = false; // Global variable to track override state

WiFiClient espClient;
PubSubClient client(espClient);

void setupWifi() {
  delay(10);
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP8266Client", mqtt_user, mqtt_password)) {
      Serial.println("connected");
      client.subscribe(onoff_topic);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void ensureConnections() {
  if (WiFi.status() != WL_CONNECTED) {
    setupWifi();
  }
  if (!client.connected()) {
    reconnect();
  }
}

//void callback(char* topic, byte* payload, unsigned int length) {
//  payload[length] = '\0'; // Ensure payload is null-terminated
//  String message = String((char*)payload);
//
//  Serial.print("Message arrived [");
//  Serial.print(topic);
//  Serial.print("] ");
//  String message;
//
//  if (String(topic) == led_override_topic) {
//    if (message == "ON") {
//      digitalWrite(ledBluePin, HIGH);
//    } else {
//      digitalWrite(ledBluePin, LOW);
//    }
//  }
//}

// Function to handle incoming MQTT messages
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  String message;
  
  // Construct the message from the payload
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.println(message);

  // Turn LED (ON or OFF) based on the message
  if (message == "ON") {
    digitalWrite(ledBluePin, HIGH);
    Serial.println("LED turned ON");
  } else if (message == "OFF") {
    digitalWrite(ledBluePin, LOW);
    Serial.println("LED turned OFF");
  }
}


void setup() {
  Serial.begin(9600);
  setupWifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(ldrPin, INPUT);
  pinMode(ledBluePin, OUTPUT);
  pinMode(ledGreenPin, OUTPUT);
  pinMode(ledYellowPin, OUTPUT);
  pinMode(ledRedPin, OUTPUT);

  digitalWrite(ledGreenPin, LOW);
  digitalWrite(ledYellowPin, LOW);
  digitalWrite(ledRedPin, LOW);
  digitalWrite(ledBluePin, HIGH);
}



void loop() {
  ensureConnections();
  client.loop();

  // Read distance from ultrasonic sensor
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  unsigned long duration = pulseIn(echoPin, HIGH);
  float distance = duration * 0.034 / 2;

  if (distance < 20) {
    digitalWrite(ledGreenPin, HIGH);
    digitalWrite(ledYellowPin, LOW);
    digitalWrite(ledRedPin, LOW);
    digitalWrite(ledBluePin, HIGH);
//    Serial.println("Green (distance < 20cm)");
    preDistance = distance;
  } else if (distance >= 20 && distance <= 40 ) {
    digitalWrite(ledGreenPin, LOW);
    digitalWrite(ledYellowPin, HIGH);
    digitalWrite(ledRedPin, LOW);
//    Serial.println("Yellow (20cm < distance < 40cm)");
    preDistance = distance;
  } else if (distance > 40 && distance < 60 ) {
    digitalWrite(ledGreenPin, LOW);
    digitalWrite(ledYellowPin, LOW);
    digitalWrite(ledRedPin, HIGH);
    digitalWrite(ledBluePin, LOW);
//    Serial.println("Red (distance > 40cm)");
    preDistance = distance;
  } else {
//    Serial.println("Off (distance > 60cm)");
    distance = preDistance;
  }
  delay(10);


  int ldrStatusNumber = analogRead(ldrPin); // Read the LDR value
  String ldrStatus; 

//  if(ldrStatusNumber >400) { // Check if it is dark
//    digitalWrite(ledBluePin, HIGH); // Turn on LED
//    ldrStatus = "Dark";
//  } else {
//    digitalWrite(ledBluePin, LOW); // Turn off LED
//    ldrStatus = "Bright";
//  }

//  Serial.print("LDR Value: ");
//  Serial.println(ldrStatus); // Print the LDR value to the serial monitor
  delay(10);

  // Check if any reads failed and exit early (to try again).
  if (isnan(ldrStatusNumber) || isnan(distance)) {
    Serial.println("Failed to read from sensors!");
    return;
  }

  // Publish Sensor Data
  client.publish(distance_topic, String(distance).c_str(), true);
  client.publish(light_topic, String(ldrStatus).c_str(), true);

  delay(100); // Delay between measurements
}
