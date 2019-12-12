#include <iostream>
#include "include/SerialPort.h"
#include <stdio.h>
#include <string.h>
#include <fstream>
#include <chrono>

using namespace std;

char* portName = "\\\\.\\COM3";
char charFromFile;
char charFromFPGA;
string inFileName;
string outFileName;
int charNumber;
bool doneWithFile = false;

ifstream inFile;
ofstream outFile;

SerialPort* FPGA;

void readFromFile(){
  charNumber = 0;

  while(charNumber <= 15){
    if(!inFile.eof()){
      inFile.get(charFromFile);
      FPGA->writeSerialPort(&charFromFile, 1);
      Sleep(1);
      charNumber++;
    }
    else{
      charFromFile = ' ';
      doneWithFile = true;

      while(charNumber <= 15){
          FPGA->writeSerialPort(&charFromFile, 1);
          Sleep(1);
          charNumber++;
      }
    }
  }

  Sleep(1);
  charNumber = 0;

  while(charNumber <= 16) {
    FPGA->readSerialPort(&charFromFPGA, 1);

    if(charNumber >= 1){
        outFile << charFromFPGA;
    }

    Sleep(1);
    charNumber++;
  }
}

void autoConnect(){
  while(!FPGA->isConnected()){
  	Sleep(1);
  	FPGA = new SerialPort(portName);
  }

  if(!doneWithFile){
    readFromFile();
    autoConnect();
  }
  else{
    return;
  }
}

int main(){
  FPGA = new SerialPort(portName);

  cout << "------------------------------------------------" << endl;
  cout << "Portable Hardware for AES Encryption/Decryption" << endl;
  cout << "------------------------------------------------" << endl;

  while(1){
      cout << "Please enter a file name to read from" << endl;
      cin >> inFileName;
      cout << endl;
      cout << "Please enter a file name to write to" << endl;
      cin >> outFileName;
      cout << endl;

      auto start = chrono::steady_clock::now();

      inFile.open(inFileName.c_str());
      outFile.open(outFileName.c_str());

      if(!inFile){
        auto end = chrono::steady_clock::now();
        cout << "Unable to open input file: " << inFileName << endl;
      }
      else if(!outFile){
        auto end = chrono::steady_clock::now();
        cout << "Unable to open output file: " << outFileName << endl;
      }
      else{
          autoConnect();
          auto end = chrono::steady_clock::now();
          doneWithFile = false;

          cout << "...finished!" << endl;

          cout << "Elapsed time in milliseconds... ";
          cout << chrono::duration_cast<chrono::milliseconds>(end - start).count();
          cout << " ms" << endl << endl;

          inFile.close();
          outFile.close();
      }

      cout << "------------------------------------------------" << endl << endl;
  }
}
