#include <SoftwareSerial.h>
#include <Adafruit_NeoPixel.h>
#include <PulseSensorPlayground.h>
#include <Adafruit_DotStar.h>
#include <SPI.h> // Use SPI library


PulseSensorPlayground pulseSensor;
const int PULSE_INPUT = A0; // Your analog pin goes here
const int THRESHOLD = 550;  // Adjust this value based on your sensor signal


SoftwareSerial HM10(2, 3); // RX = 2, TX = 3
#define PIN 11
#define NUMPIXELS 64 // Number of LEDs in the NeoPixel stick
#define MAX_COMMANDS 10 // Adjust based on expected maximum number of commands

#define DATAPIN    11
#define CLOCKPIN  13
const int redPin = 10;
const int greenPin = 9;
const int bluePin = 8;
// Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
Adafruit_DotStar strip = Adafruit_DotStar(NUMPIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

String inData = "";  

String rgbCommandsArray[MAX_COMMANDS];
int numCommands = 0; // Number of RGB commands parsed
unsigned long lastChangeTime = 0; // For managing timing
int currentCommandIndex = 0; // Index to keep track of the current command
int globalRate = 1000; // Default rate of change, in milliseconds

bool isNewCommandReceived = false;
bool isHeartRateMonitoringActive = false; 



void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  HM10.begin(9600); // set HM10 serial at 9600 baud rate
  Serial.println("HM10 serial started at 9600");
  // pixels.begin(); // Initialize the NeoPixel stick
    pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
strip.begin(); // Initialize pins for output
  strip.show();  // Turn all LEDs off ASAP
    pulseSensor.analogInput(PULSE_INPUT);
    pulseSensor.setThreshold(THRESHOLD);

    if (!pulseSensor.begin()) {
        Serial.println("Could not find a valid PulseSensor.");
        while (1); // Freeze! Failed to initialize PulseSensor
    }
  while (HM10.available() > 0) {
    HM10.read(); // Discard this data
  }

}

void loop() {
  // put your main code here, to run repeatedly:
    handleIncomingBluetoothData();
    loopThroughCustomColors();
    checkHeartRateMonitoring();
    // dotStarGrid();
}

void dotStarGrid(){
  Serial.println("in here");
  for(int i = 0; i < NUMPIXELS; i++) {
    strip.setPixelColor(i, strip.Color(255, 0, 0)); // Set pixel 'i' to red
  }
  strip.show();  // Update the strip with new color values
  delay(500);

  // Example: Create a simple animation
  for(int i = 0; i < NUMPIXELS; i++) {
    strip.setPixelColor(i, strip.Color(0, 255, 0)); // Set pixel 'i' to green
    strip.show();
    delay(50);
  }

  // Clear the matrix
  for(int i = 0; i < NUMPIXELS; i++) {
    strip.setPixelColor(i, strip.Color(0, 0, 0)); // Turn off pixel 'i'
  }
  strip.show();
  delay(500);
}

void checkHeartRateMonitoring() {
    int myBPM; 
  if (isHeartRateMonitoringActive && pulseSensor.sawStartOfBeat()) {
    isNewCommandReceived = false ; 
     myBPM = pulseSensor.getBeatsPerMinute();
    Serial.print("Heart Rate: ");
    Serial.println(myBPM);
    String heartRateStr = "Heartrate:" + String(myBPM);
    
    // Send the formatted string over HM10
    HM10.println(heartRateStr);
    turnOnHeartColors(myBPM);
  }else if (pulseSensor.sawStartOfBeat()) {
       myBPM = pulseSensor.getBeatsPerMinute();
    String heartRateStr = "Heartrate:" + String(myBPM);
     HM10.println(heartRateStr);
  }
}
void handleIncomingBluetoothData() {
  while (HM10.available() > 0) {
    char receivedChar = HM10.read();
    if (receivedChar == '\n') {
      parseRGBCommand(inData);
      inData = ""; // Reset for next command
    } else {
      // Accumulate the incoming characters into a command string
      inData += receivedChar;
    }
  }
}

void turnOnHeartColors(int bpm) {
    static unsigned long lastBlinkTime = 0; // Time since the last blink
    static bool ledState = false; // LED state: false means off, true means on

    unsigned long currentMillis = millis();
    int beatInterval = 60000 / bpm; // Calculate the interval between beats in milliseconds

    // Determine if it's time to toggle the LED state
    if (currentMillis - lastBlinkTime > beatInterval / 2) { // Divided by 2 for quicker blink
        lastBlinkTime = currentMillis; // Update the last blink time
        ledState = !ledState; // Toggle the LED state
        if (ledState) {
            // Turn LEDs on to the calculated brightness
            int brightness = map(bpm, 60, 180, 0, 255);
            brightness = constrain(brightness, 50, 255);
            // for (int i = 0; i < NUMPIXELS; i++) {
            //     pixels.setPixelColor(i, pixels.Color(brightness, 0, 0));
            // }
                       analogWrite(redPin, brightness);
         analogWrite(greenPin, 0);
         analogWrite(bluePin, 0);
        } else {
                     analogWrite(redPin, 50);
        analogWrite(greenPin, 0);
        analogWrite(bluePin, 0);
            // Turn LEDs off
            // for (int i = 0; i < NUMPIXELS; i++) {
            //     pixels.setPixelColor(i, pixels.Color(10, 0, 0));
            // }
        }
        // pixels.show(); // Apply the changes
    }
}

void loopThroughCustomColors() {
    static unsigned long lastChangeTime = millis(); // Remember the last update time
    unsigned long currentMillis = millis(); // Current time

    // Check if new commands were received
    if (isNewCommandReceived && numCommands > 0) {
        applyRGBToLEDs(rgbCommandsArray[currentCommandIndex], globalRate);
        currentCommandIndex++;
        if (currentCommandIndex >= numCommands) {
            currentCommandIndex = 0; // Loop back to the first command
        }
        lastChangeTime = currentMillis; // Reset the timer
        isNewCommandReceived = false; // Reset the flag
    }
    else if (currentMillis - lastChangeTime >= globalRate && numCommands > 0) {
        // Time to update for subsequent commands
        applyRGBToLEDs(rgbCommandsArray[currentCommandIndex], globalRate);
        currentCommandIndex++; // Move to the next command
        if (currentCommandIndex >= numCommands) {
            currentCommandIndex = 0; // Loop back to the first command
        }
        lastChangeTime = currentMillis; // Reset the timer
    }
}




void parseRGBCommand(String command) {
  if ( !checksumCheck(command) ){
      Serial.println("Check sum failed");
      requestResend();
      inData = "";
      return; 
  }
  Serial.println("Check sum good");
  Serial.println(command);
  Serial.println(command[0]);
  Serial.println(command[1]);
  if (command == "OFF"){
    turnColorsOff();
  }
  else if (command[1] == 'H') {
      Serial.println("HEART COMMAND ACTIVE");

    isHeartRateMonitoringActive = true; 
  }
  else{
  // convertColorArray(command);
  extractAndApplyRgbCommands(command);

    isNewCommandReceived = true; // Indicate that new commands have been received
 
    }
      inData = "";

  }



bool checksumCheck(const String& command) {
    Serial.println("Verifying checksum...");

    int checksumIndex = command.lastIndexOf(",C:");
    if (checksumIndex == -1) {
        Serial.println("Checksum missing, requesting resend...");
        requestResend();
        return false;
    }

    String payload = command.substring(0, checksumIndex); // Extract payload without checksum
    Serial.println("Payload");

    Serial.println(payload);
    String receivedChecksumStr = command.substring(checksumIndex + 3, command.indexOf("[END]")); // Extract checksum value
    unsigned int receivedChecksum = receivedChecksumStr.toInt();
            Serial.println("Checksumstring");

    Serial.println(receivedChecksumStr);


    // Calculate checksum of the payload
    unsigned char calculatedChecksum = 0;
    for (unsigned int i = 0; i < payload.length(); i++) {
        calculatedChecksum += (unsigned char)payload[i];
    }

    if (calculatedChecksum != receivedChecksum) {
        Serial.print("Checksum mismatch: calculated ");
        Serial.print(calculatedChecksum);
        Serial.print(", received ");
        Serial.println(receivedChecksum);
        Serial.println("Requesting resend...");
        requestResend();
        return false;
    }

    Serial.println("Checksum verified successfully.");
    return true;
}
void convertColorArray(String command) {
    // Locate the start of actual RGB commands by skipping the prefix
    int startOfRgbCommands = command.indexOf(']') + 1;
    if (startOfRgbCommands <= 0) {
        Serial.println("Invalid command format: Prefix missing or incorrect");
        return;
    }

    // Locate the end of actual RGB commands by finding the start of the checksum section
    int endOfRgbCommands = command.lastIndexOf(",C:");
    if (endOfRgbCommands == -1) {
        Serial.println("Invalid command format: Checksum section missing");
        return;
    }

    // Extract only the RGB commands part
    String rgbCommandsString = command.substring(startOfRgbCommands, endOfRgbCommands);

    // Debug print the cleaned RGB commands
    Serial.println("Cleaned RGB Commands:");
    Serial.println(rgbCommandsString);

    // Reset the commands array and counter
    int startIndex = 0;
    int separatorIndex = rgbCommandsString.indexOf(';');
    while (separatorIndex != -1) {
        String rgbCommand = rgbCommandsString.substring(startIndex, separatorIndex);
        rgbCommand.trim(); // Correctly use trim() without assignment
        if (rgbCommand.length() > 0) {
            applyRGBToLEDs(rgbCommand, globalRate); // Assuming globalRate has been defined
        }

        startIndex = separatorIndex + 1;
        separatorIndex = rgbCommandsString.indexOf(';', startIndex);
    }

    // Handle the last RGB command if it doesn't end with a semicolon
    if (startIndex < rgbCommandsString.length()) {
        String rgbCommand = rgbCommandsString.substring(startIndex);
        rgbCommand.trim(); // Correctly use trim() without assignment
        if (rgbCommand.length() > 0) {
            applyRGBToLEDs(rgbCommand, globalRate);
        }
    }
}



void applyRGBToLEDs(String rgbCommand, int rateOfChange) {
    Serial.println("RGB Command: " + rgbCommand);
    if (rgbCommand.startsWith(",")) {
        rgbCommand = rgbCommand.substring(1);
    }

    int firstCommaIndex = rgbCommand.indexOf(',');
    int lastCommaIndex = rgbCommand.lastIndexOf(',');
    if (firstCommaIndex != -1 && lastCommaIndex != -1 && firstCommaIndex != lastCommaIndex) {
        int red = rgbCommand.substring(0, firstCommaIndex).toInt();
        int green = rgbCommand.substring(firstCommaIndex + 1, lastCommaIndex).toInt();
        int blue = rgbCommand.substring(lastCommaIndex + 1).toInt();
        
        Serial.print("Red: "); Serial.println(red);
        Serial.print("Green: "); Serial.println(green);
        Serial.print("Blue: "); Serial.println(blue);
        
        // for (int i = 0; i < NUMPIXELS; i++) {
        //     pixels.setPixelColor(i, pixels.Color(red, green, blue));
        // }
        // pixels.show();
             analogWrite(redPin, red);
        analogWrite(greenPin, green);
        analogWrite(bluePin, blue);
        
    } else {
        Serial.println("Invalid RGB command format.");
    }
    // Consider removing the delay here, or adjust based on your requirement
}



void processRgbCommands(String rgbCommands, int rateOfChange) {
  int index = 0;
  while (index < rgbCommands.length()) {
    int nextSeparator = rgbCommands.indexOf(';', index);
    if (nextSeparator == -1) nextSeparator = rgbCommands.length();

    String rgbCommand = rgbCommands.substring(index, nextSeparator);
    applyRGBToLEDs(rgbCommand, rateOfChange);

    index = nextSeparator + 1; // Move past the semicolon
  }
}

void extractAndApplyRgbCommands(String command) {
  // Strip the metadata and checksum
      isHeartRateMonitoringActive = false; 

  int startIdx = command.indexOf(']') + 1;
  int endIdx = command.lastIndexOf(",C:");
  if (startIdx == -1 || endIdx == -1 || startIdx >= endIdx) {
    Serial.println("Command format error.");
    return;
  }

  // Extract the RGB commands part
  String rgbCommands = command.substring(startIdx, endIdx);
  Serial.println("Extracted RGB Commands: " + rgbCommands);
     numCommands = 0;
    currentCommandIndex = 0;

  // Extract the rate of change
      int separatorIndex = rgbCommands.indexOf(';');
    int startIndex = 0;
    while (separatorIndex != -1 && numCommands < MAX_COMMANDS) {
        rgbCommandsArray[numCommands++] = rgbCommands.substring(startIndex, separatorIndex);
        startIndex = separatorIndex + 1;
        separatorIndex = rgbCommands.indexOf(';', startIndex);
    }

    // Catch the last command if it doesn't end with a semicolon
    if (startIndex < rgbCommands.length() && numCommands < MAX_COMMANDS) {
        rgbCommandsArray[numCommands++] = rgbCommands.substring(startIndex);
    }

    // Extract and update the global rate of change
    extractAndApplyRateOfChange(command);
  // Apply RGB commands
  // processRgbCommands(rgbCommands, rateOfChange);
}


void extractAndApplyRateOfChange(String command) {
    int rateIdx = command.indexOf(",R:") + 3; // Finding the start of rate of change
    String rateOfChangeStr = command.substring(rateIdx, command.indexOf(',', rateIdx));
 

    globalRate = rateOfChangeStr.toInt() * 1000; // Assuming rate is given in seconds, convert to milliseconds
           Serial.print("Global rate: ");
        Serial.println(globalRate);
}

void turnColorsOff(){
        analogWrite(redPin, 0);
        analogWrite(greenPin, 0);
        analogWrite(bluePin, 0);
         isNewCommandReceived = false;
     isHeartRateMonitoringActive = false; 
}


void requestResend() {
    // Example: send a specific command or message back to request a resend of the last command
    String message = "RESEND_LAST_COMMAND";
    sendDataBackToSender(message);
    // inData = "";
}

void sendDataBackToSender(const String& message) {
    // Implement this function based on your project's specific requirements
    // This might involve sending a message over Bluetooth back to the sender
    Serial.print("Requesting resend: ");
    Serial.println(message);
    // Example: HM10.println(message); // Assuming HM10 is your SoftwareSerial connection
    HM10.println(message); // Send message back to the connected device

}
