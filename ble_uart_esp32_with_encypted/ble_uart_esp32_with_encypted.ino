#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLEServer *pServer = NULL;
BLECharacteristic * pTxCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint8_t txValue = 0;
uint8_t currentPasswordHash[17];
const int ledPin = 0; // Pin number for the built-in LED



#define SERVICE_UUID           "25eb434a-260c-4df1-a39c-3b87e9c0ccfa" // UART service UUID
#define CHARACTERISTIC_UUID_RX "25eb434b-260c-4df1-a39c-3b87e9c0ccfa" // Characteristic RX
#define CHARACTERISTIC_UUID_TX "25eb434c-260c-4df1-a39c-3b87e9c0ccfa" // Characteristic TX

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
   void onWrite(BLECharacteristic *pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();

    if (rxValue.length() > 0) {
      Serial.println("*********");
      Serial.print("Received Value: [");
      for (int i = 0; i < rxValue.length(); i++) {
        Serial.print((int)rxValue[i]);
        if (i < rxValue.length() - 1) {
          Serial.print(", ");
        }
      }
      Serial.println("]");

      // Check for SET command
      if (rxValue.length() > 3 && rxValue.substr(0, 3) == "SET") {
        // Update current password hash
        if (rxValue.length() == 3 + sizeof(currentPasswordHash)) {
          memcpy(currentPasswordHash, rxValue.data() + 3, sizeof(currentPasswordHash));
          Serial.println("Password updated!");
        } else {
          Serial.println("Invalid password hash!");
        }
      } else if (rxValue.length() > 3 && rxValue.substr(0, 3) == "LOG") {
        // Handle login attempt
        if (rxValue.length() == 3 + sizeof(currentPasswordHash) && memcmp(rxValue.data() + 3, currentPasswordHash, sizeof(currentPasswordHash)) == 0) {

            digitalWrite(ledPin, 0); // Turn the LED on
            delay(1000); // Wait for 1 second            
            Serial.println("Password is correct!");

        } else {
          digitalWrite(ledPin, 1); // Turn the LED off
          delay(1000); // Wait for 1 second          
          Serial.println("Password is incorrect!");
          
        }
      }
      else if (rxValue.length() > 3 && rxValue.substr(0, 3) == "LCK") {
        // Handle login attempt
        if (rxValue.length() == 3 + sizeof(currentPasswordHash) && memcmp(rxValue.data() + 3, currentPasswordHash, sizeof(currentPasswordHash)) == 0) {

          digitalWrite(ledPin, 1); // Turn the LED off
          delay(1000); // Wait for 1 second          
          Serial.println("Locked !");
          
        }
      }

      Serial.println("*********");
    }
  }
};

void setup() {
  Serial.begin(115200);

  // Create the BLE Device
  BLEDevice::init("BLE Locker");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  pinMode(ledPin, OUTPUT); // Set the LED pin as an output
  digitalWrite(ledPin, 1);

  // Create a BLE Characteristic
  pTxCharacteristic = pService->createCharacteristic(
										CHARACTERISTIC_UUID_TX,
										BLECharacteristic::PROPERTY_NOTIFY
									);
                      
  pTxCharacteristic->addDescriptor(new BLE2902());

  BLECharacteristic * pRxCharacteristic = pService->createCharacteristic(
											 CHARACTERISTIC_UUID_RX,
											BLECharacteristic::PROPERTY_WRITE
										);

  pRxCharacteristic->setCallbacks(new MyCallbacks());

  // Start the service
  pService->start();

  // Start advertising
  pServer->getAdvertising()->start();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
		// do stuff here on connecting
        oldDeviceConnected = deviceConnected;
    }
}
