#include <SPI.h>
#include <SD.h>

char tempMessageIn[16];
char tempMessageOut[32] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
File myFile;
File myFileEnc;
File root;
int i = 0;
int j = 0;
int parity = 0;
String fileName;

void setup() {
  Serial.begin(115200, SERIAL_8E1);

  while (!Serial);

  if(!SD.begin(4)){
    while(1);
  }

  myFile = SD.open("test.txt");

  
}

void loop() {
  while(i < 16){
    if(myFile.available() > 0){
      tempMessageIn[i] = myFile.read();
      for(j = 0; j < 8; j++){
        if(bitRead(tempMessageIn[i], j) == 1){
          parity++;
        }
      }
      tempMessageOut[i*2] = tempMessageIn[i];
      if(parity % 2 == 1){
        tempMessageOut[i*2 + 1] = 0x01;
      }
      else{
        tempMessageOut[i*2 + 1] = 0x02;
      }
      parity = 0;
      i++;
    }
  }
  Serial.print(tempMessageOut);
  i = 0;
  delay(10000);
}
