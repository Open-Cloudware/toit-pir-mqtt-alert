import net
import mqtt
import encoding.json
import device
import gpio

// GPIO pin the PIR sensor is connected to.
PIR_SENSOR::= 32
// Unique MQTT client ID to identify each client that connects to the MQTT broker.
CLIENT_ID ::= "$device.hardware_id"
// The publicly available EMQ X MQTT server/broker
HOST      ::= "broker.emqx.io"
// MQTT port 1883 is for unencrypted communication.
PORT      ::= 1883
// MQTT topic name
TOPIC     ::= "toit/sensor/pir"

main:
  pir ::= gpio.Pin PIR_SENSOR --input
  socket := net.open.tcp_connect HOST PORT
  // Connect the Toit MQTT client to the broker
  client := mqtt.Client
    CLIENT_ID
    mqtt.TcpTransport socket

  // The client is now connected.
  print "Connected to MQTT Broker @ $HOST:$PORT"

  while true:
    // Wait till movement is detected (high sensor output)
    pir.wait_for 1
    print "Motion detected! Time: $(Time.now) UTC"
    publish client true

    // Wait till no more movement is detected (low sensor output)
    pir.wait_for 0
    publish client false

publish client/mqtt.Client payload/bool:
  // Publish message to topic
  client.publish
    TOPIC 
    json.encode {
      "value": payload
    }
    --retain=true
  // print "Published message `$payload` on '$TOPIC'" 
