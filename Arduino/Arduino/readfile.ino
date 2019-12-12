/*
  SD card read/write

 This example shows how to read and write data to and from an SD card file
 The circuit:
 * SD card attached to SPI bus as follows:
 ** MOSI - pin 11
 ** MISO - pin 12
 ** CLK - pin 13
 ** CS - pin 4 (for MKRZero SD: SDCARD_SS_PIN)
 * 
  */

#include <SPI.h>
#include <SD.h>

File myFile;
File myFileEnc;
File root;
char tempmessagein[16];
char tempmessageout[16];
char temp;
String filename;
int i = 0;
int count = 0;
bool check;


void setup() {
  // Open serial communications and wait for port to open:
  Serial.begin(115200);
    
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  if(!SD.begin(4)){
    while(1);
  }

  //myFileEnc = SD.open("encrypt.txt", FILE_WRITE);
  myFile = SD.open("test.txt");
  check = true;
}

void loop() {
      delay(10000);
      if (myFile) {
        // read from the file until there's nothing else in it:
        while (myFile.available()) {
          //Serial.write(myFile.read());
          while(count < 16) {
          if(myFile.peek() == -1) {
            tempmessagein[count] = 'b';
            char temp = myFile.read();
          }
          else {
            tempmessagein[count] = myFile.read();
          }
            count++;
          }
          count = 0;
          if(check == true) {
            while(count < 16) {
              Serial.write(tempmessagein[count]);
              count++;
              delay(10);
            }
            check = false;
          }
          
          delay(1000);
          count = 0;
          while(count < 17) {
            //tempmessageout[count] = Serial.read();
            if(Serial.available() > 0){
              if(count == 16) {
                temp = Serial.read();
                count++;
              }
              else {
                tempmessageout[count] = Serial.read();
                count++;
              }
            } 
          }
          count = 0;
          //Serial.println("test");
          Serial.print(tempmessageout);
          //Serial.println("test");
         // myFileEnc.print(tempmessageout);
        }
        // close the file:
      }
      myFile.close();
      //myFileEnc.close();
}
