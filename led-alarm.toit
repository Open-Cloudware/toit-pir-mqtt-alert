import net
import mqtt
import encoding.json
import device
import gpio

// GPIO pin the LED is connected to.
LED       ::= 19
// Unique MQTT client ID to identify each client that connects to the MQTT broker.
CLIENT_ID ::= "$device.hardware_id"
// The publicly available EMQ X MQTT server/broker
HOST      ::= "broker.emqx.io"
// MQTT port 1883 is for unencrypted communication.
PORT      ::= 1883
// MQTT topic name
TOPIC     ::= "toit/sensor/pir"

main:
  led := gpio.Pin LED --output
  socket := net.open.tcp_connect HOST PORT
  // Connect the Toit MQTT client to the broker
  client := mqtt.Client
    CLIENT_ID
    mqtt.TcpTransport socket

  // The client is now connected.
  print "Connected to MQTT Broker @ $HOST:$PORT"

  // Start subscribing to the topic.
  client.subscribe TOPIC --qos=1
  print "Subscribed to topic '$TOPIC'"

  // Process subscribed messages.
  client.handle: | topic/string payload/ByteArray |
    decoded := json.decode payload
    // print "Received message '$(decoded["value"])' on '$topic'"

    if decoded["value"]:
      led.set 1
      print "LED turned ON! Time: $(Time.now) UTC"
    else:
      led.set 0
      print "LED turned OFF! Time: $(Time.now) UTC"

