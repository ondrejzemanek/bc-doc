= Clown.Talk & Clown.Model

The BigClown system is based on the exchange of messages using MQTT technology (see corresponding article link:mqtt.html[here]).
However, there are places in the system where MQTT cannot be used directly - for example, web browsers do not yet use it.
For such places and situations we have devised the Clown.Talk protocol, which can very easily be introduced as a “serialized MQTT”.

Clown.Talk is a de facto an MQTT message, written in simple text format - specifically in JSON notation.
It is a JSON field with two elements: the first is the name of the MQTT topic, the second the actual content of the message (payload).
The message ends with “\n” (new line, 0x0a).

Format:

 [topic (string), payload (object)]\n

The topic is the same as for MQTT, for example `barometer/i2c0-60`, the payload corresponds to the body of the message as defined by Clown.Model.

For example:

[source,javascript]
----
{"pressure": [101.9, "kPa"]}
----

A third, optional element of the field is the object that defines additional parameters of the message, such as its source and destination, possibly the level of QoS (determines how the message should be delivered, whether the sender requires confirmation, etc.).
This part is not used in the current version of Clown.Hub.

Clown.Talk requires that the client initialize transmission.
After establishing a connection, it is necessary to send an introductory message with the topic `clown.talk/-/config/set` and an empty body, i.e.:

 ["clown.talk/-/config/set", {}]\n


== Clown.Model

Clown.Model handles the creation and structuring of MQTT topics and the content of messages.
If defines four basic scenarios, and based on these, governs the creation of topic names.
The first scenario involves notifications (from the node to the system).
Their subtopic is single level, for example `boot`:

[source,javascript]
----
["boot", {"reason-for-reset": "power-on"}]
----

The second scenario, probably more frequent, concerns data from sensors.
This type of message uses a two-level subtopic name, where the first part describes the type of sensor and the second its address, i.e. the specific I^2^C bus and I^2^C address, separated by a hyphen.

Examples: `thermometer/i2c0-48`, `thermometer/i2c1-49`, `barometer/i2c0-60` etc.
If the device does not use I2C, then the hyphen will appear in the address position - e.g. `pir/-`.

[source,javascript]
----
["thermometer/i2c0-48", {"temperature": [20.01, "℃"]}]

["thermometer/i2c1-48", {"temperature": [25.15, "℃"]}]

["lux-meter/i2c0-44", {"illuminance": [600.1, "lux"]}

["humidity-sensor/i2c0-5f", {"relative-humidity": [30.2, "%"]}]

["barometer/i2c0-60", {"pressure": [101.9, "kPa"], "altitude": [583.0, "m"]}]

["co2-sensor/i2c0-38", {"concentration": [300, "ppm"]}]

["pir/-", {"event-count": 1467}]
----

The third scenario involves messages that require a device to perform an action, typically switching relays or changing LED status.
The system sends these messages to nodes.
The subtopic has three levels: type of device, I^2^C address, and event.
Type of device and address are the same as in the previous scenario, the event is either “set”, or “get” - set the actuator, or request some information (status, measurement results etc.).

[source,javascript]
----
["led/-/set", {"state": "on"}]

["relay/i2c0-3b/set", {"state": true}]

["thermometer/i2c0-48/get", {}]
----

The fourth scenario is “demand and response”, typically when setting and reading the configuration of a node or device.
The subtopic is four-level; the previous two levels, "type/adress", and now request and event.
The subtopic of the response will have confirmation instead of an event (ok/error):

Setting the intervals for message transmission:

From hub to device:

[source,javascript]
----
["thermometer/i2c0-48/config/set", {"publish-interval": 30}]
----

Response from device to hub:

[source,javascript]
----
["thermometer/i2c0-48/config/ok", {"publish-interval": 30}]
----

Checking device capabilities:

[source,javascript]
----
["clown.talk/-/config/set", {}]

["clown.talk/-/config/ok", {"ack": false, "device": "bridge", "capabilities": 1, "firmware-datetime": "2016-07-01T21:46:07.057Z"]
----

Getting a list of devices:

[source,javascript]
----
["-/-/config/list", {}]

["-/-/config/ok", {
  "sensors": [
    "thermometer/i2c0-48",
    "thermometer/i2c1-48",
    "lux-meter/i2c0-44",
    "co2-sensor/i2c0-38"
  ], "actuators": [
    "led/-",
    "relay/i2c0-3b",
    "relay/i2c0-3f"],
    "notifications": ["boot"]
  }
]
----

The actual message content is formatted as a JSON object, i.e. a `key: value` pair.
In sensors, the key is always the name of the measured quantity, and the value is the measured value.
For limitless quantities, (number of pulses, etc.) it is only the given value (123, on, true, etc.).
For quantities with a unit, a field with two elements is used: the first containing the value, the second the chain with the unit name.
If the sensor measures multiple quantities (for example pressure and altitude), it will send multiple values.

[source,javascript]
----
["lux-meter/i2c0-44", {"illuminance": [600, "lux"]}

["barometer/i2c0-60", {"pressure": [101.9, "kPa"], "altitude": [583.0, "m"]}]

["relay/i2c0-3b", {"state": true}]
----

A more detailed description can be found in the technical specifications for Clown.Model:
*TODO: Insert link to Clown.Talk reference documentation*


== Practical example: Clown.Model for Bridge project

Here is a summary of all subtopics and messages that you can send or receive with Bridge project.

|===
|Sensor/Actuator |MQTT Subtopic |Message Payload

|LED
|led/-
|state

|Thermometer
|thermometer/i2c0-48
|temperature

|
|thermometer/i2c1-48
|

|
|thermometer/i2c0-49
|

|
|thermometer/i2c1-49
|

|Lux meter
|luxmeter/i2c0-44
|illuminance

|
|lux-meter/i2c1-44
|

|
|lux-meter/i2c0-45
|

|
|lux-meter/i2c1-45
|

|Barometer
|barometer/i2c0-60
|pressure, altitude

|
|barometer/i2c1-60
|

|Humidity sensor
|humidity-sensor/i2c0-40
|relative-humidity

|
|humidity-sensor/i2c0-41
|

|
|humidity-sensor/i2c1-40
|

|
|humidity-sensor/i2c1-41
|

|CO2 sensor
|co2-sensor/i2c0-38
|concentration

|Relay
|relay/i2c0-3b
|state

|
|relay/i2c0-3f
|
|===
