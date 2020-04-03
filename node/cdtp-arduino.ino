#include <ArduinoJson.h>

#include <math.h>

void setup() {

	Serial.begin(115200);
	WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

	while (WiFi.status() != WL_CONNECTED) {

		delay(500);
		Serial.println("Waiting for connection");

	}
	randomSeed(analogRead(0));
}

void loop() {

	if (WiFi.status() == WL_CONNECTED) {

		StaticJsonDocument < 256 > doc;
		JsonObject root = doc.to <JsonObject>();
		String sourceList[2] = {
			"sebeke",
			"yenilenebilir"
		};
		String timeList[3] = {
			"gunduz",
			"puant",
			"gece"
		};
		root["kaynak"] = sourceList[random(0, 2)];
		root["zaman"] = timeList[random(0, 3)];

		JsonArray liste = root.createNestedArray("liste");

		JsonObject daire1 = liste.createNestedObject();
		JsonObject daire2 = liste.createNestedObject();
		JsonObject daire3 = liste.createNestedObject();
		JsonObject daire4 = liste.createNestedObject();
		JsonObject daire5 = liste.createNestedObject();

		daire1["id"] = 1;
		daire1["watt"] = random(100, 200);

		daire2["id"] = 2;
		daire2["watt"] = random(100, 200);

		daire3["id"] = 3;
		daire3["watt"] = random(100, 200);

		daire4["id"] = 4;
		daire4["watt"] = random(100, 200);

		daire5["id"] = 5;
		daire5["watt"] = random(100, 200);

		String JSONmessageBuffer;
		serializeJson(doc, JSONmessageBuffer);
		Serial.println(JSONmessageBuffer);

		HTTPClient http;

		http.begin(HTTP_ENDPOINT);
		http.addHeader("Content-Type", "application/json");

		int httpCode = http.POST(JSONmessageBuffer);
		String payload = http.getString();

		Serial.println(httpCode);
		Serial.println(payload);

		http.end();

	} else {

		Serial.println("Error in WiFi connection");

	}

	delay(500);
}
