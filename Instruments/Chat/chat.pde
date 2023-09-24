//OSC
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
OscMessage pad;
//OSC

import java.util.ArrayList;
import java.util.HashMap;

ArrayList<ArrayList<Character>> words1 = new ArrayList<ArrayList<Character>>(); // Array di array per memorizzare le parole
ArrayList<ArrayList<Character>> words2 = new ArrayList<ArrayList<Character>>(); // Array di array per memorizzare le parole
ArrayList<Integer> sumArray1 = new ArrayList<Integer>(); // Array di array per memorizzare i numeri corrispondenti per messaggio OSC
ArrayList<Integer> sumArray2 = new ArrayList<Integer>(); // Array di array per memorizzare i numeri corrispondenti per messaggio OSC
ArrayList<Integer> sumArrayEl1 = new ArrayList<Integer>();
ArrayList<Integer> sumArrayEl2 = new ArrayList<Integer>();
ArrayList<Integer> sumKeyMelody = new ArrayList<Integer>(); 
ArrayList<Float> elementi_freq1 = new ArrayList<Float>(); //LISTA DI FREQ (+ pause >tot) da inviare a SC
ArrayList<Float> elementi_freq2 = new ArrayList<Float>(); //LISTA DI FREQ (+ pause >tot) da inviare a SC
ArrayList<String> sentences1 = new ArrayList<String>(); //chat 1
ArrayList<String> sentences2 = new ArrayList<String>(); //chat 2

String inputBuffer1 = ""; // Buffer per memorizzare le lettere digitate
String inputBuffer2 = ""; // Buffer per memorizzare le lettere digitate
float maxWords_length1; // Lunghezza massima sentence
float maxWords_length2; // Lunghezza massima sentence
int maxSentences = 9; // Numero massimo di sentence nell'array di stringhe

//int bpm = 60; //BPM
int nSteps; //Numero pulsazioni per battuta

boolean inputString1 = false;
boolean inputString2 = false;
boolean prima_frase = true;

int count = 0; //CONTATORE CHAT
String user1 = "";
String user2 = "";

HashMap<Character, Integer> letterToNumber = new HashMap<Character, Integer>(); // Mappa per associare le lettere ai numeri

void setup() {
  size(900, 500);
  textSize(20);
  
  //nSteps = int(args[0]);
  nSteps = 12;
  
  //OSC
  oscP5 = new OscP5(this, 12002);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  pad = new OscMessage("/pad");
  //OSC
  
  char[] lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".toCharArray();
  char[] uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();

  for (int i = 0; i < lowercaseLetters.length; i++) {
    letterToNumber.put(lowercaseLetters[i], i + 1);
    letterToNumber.put(uppercaseLetters[i], i + 1);
  }  
}

void draw() {
  background(220);
  
  
  textSize(20);
  
  //CHAT2 IN TEMPO REALE
  fill(128);
  String w2 = "My word: ";
  text(w2, 40, 30);
  fill(0);
  text(inputBuffer2, 40 + textWidth(w2), 30);
  
  //CHAT1 IN TEMPO REALE
  fill(128);
  String w1 = "My word: ";
  text(w1, width/2, 30);
  fill(0);
  text(inputBuffer1, width/2 + textWidth(w1), 30);

  //PAROLE MEMORIZZATE
  fill(128);
  String s2 = "My sentence: ";
  text(s2, 40 , 60);
  fill(0);
  float x2 = textWidth(s2);
  for (int i = 0; i < words2.size(); i++) {
    ArrayList<Character> word = words2.get(i);
    String wordString = "";
    for (char c : word) {
      wordString += c;
    }
    text(wordString, 40+x2, 60);
    x2 += textWidth(wordString) + 5;
    maxWords_length2 = x2;
  }
  //PAROLE MEMORIZZATE
  fill(128);
  String s1 = "My sentence: ";
  text(s1, width/2 , 60);
  fill(0);
  float x1 = textWidth(s1);
  for (int i = 0; i < words1.size(); i++) {
    ArrayList<Character> word = words1.get(i);
    String wordString = "";
    for (char c : word) {
      wordString += c;
    }
    text(wordString, width/2+x1, 60);
    x1 += textWidth(wordString) + 5;
    maxWords_length1 = x1;
  }

  for (int i = sentences1.size()-1; i >=0 ; i--) {
    String sentence = sentences1.get(i);
    int posizionex = width/2;
    int posizioney = height - 80 - (sentences1.size()-1-i) * 30;
    text(sentence, posizionex, posizioney);
  }
  for (int i = sentences2.size()-1; i >=0 ; i--) {
    String sentence = sentences2.get(i);
    int posizionex = 40;
    int posizioney = height - 80 - (sentences2.size()-1-i) * 30;
    text(sentence, posizionex, posizioney); 
  }

  //USERNAME
  fill(128);
  text(user1, width/2, 130);
  text(user2, 40, 130);
  
  //NOTE
  textSize(16);
  fill(128);
  String KeyString = "My key: ";
  String MelodyString = "My melody: ";

  for (int i = 0; i < sumKeyMelody.size(); i++) {
    if (i==0){
      KeyString += convertToNoteKey(sumKeyMelody.get(0));
    } else {
      MelodyString += convertToNoteMelody(sumKeyMelody.get(i), sumKeyMelody.get(0)) + " ";
    }
  }
  fill(128);
  text(KeyString, 40, height - 20);
  text(MelodyString, 160, height - 20);
}

String getWordNumbersString(ArrayList<Character> word) {
  String numbersString = "";
  for (char c : word) {
    if (letterToNumber.containsKey(c)) {
      numbersString += letterToNumber.get(c) + " ";
    }
  }
  return numbersString.trim();
}

int getWordNumbersSum(ArrayList<Character> word) {
  int sum = 0;
  for (char c : word) {
    if (letterToNumber.containsKey(c)) {
      sum += letterToNumber.get(c);
    }
  }
  return sum;
}

String convertToNoteKey(int number) {
  String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  if (number >= 0 && number <= 11) {
    return notes[number];
  } else {
    return "Invalid";
  }
}

String convertToNoteMelody(int number, int startingPoint) {
  
  if (number == 100) {
    return "Pause";
  }
  
    String[] notes = {"C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5"};  if (startingPoint >= 0 && startingPoint <= 11 && number >=0) {
    int adjustedNumber = (number + startingPoint) % 24;
    return notes[adjustedNumber];
  } else {
    return "Invalid";
  }
}

// Receive OSC triggers
void oscEvent(OscMessage trigger)
{
  // Manage username  /username 1 Riccardo
  if(trigger.checkAddrPattern("/username")) {
    int userType = trigger.get(0).intValue();
    String username = trigger.get(1).stringValue();
    if (userType == 1){
      user1 = username;
    } else if (userType == 2){
      user2 = username;
    }
  }
  
  
  // Manage characters  /char 2 f
  if(trigger.checkAddrPattern("/char")) {
    
    int streamType = trigger.get(0).intValue();
    if (streamType == 1){
      
      prima_frase = true;
      char stream1 = trigger.get(1).stringValue().toCharArray()[0];
      inputBuffer1 += stream1;
      
      if(inputString1){
        sumArray1.clear();
        sumArrayEl1.clear();
        elementi_freq1.clear();
        inputString1 = false;
      }
      
      if ((stream1 == ' '  || stream1 == '%') && !inputBuffer1.equals("")) {
    
      if (maxWords_length1>width-80) {
        words1.remove(0); // Rimuovi la prima parola
      }
    
      ArrayList<Character> word = new ArrayList<Character>();
      for (char c : inputBuffer1.toCharArray()) {
        if (letterToNumber.containsKey(c)) {
          word.add(c);
        }
      }

     int sum = 0;
      if (word.size() >= 2 || words1.size()==0) { //parole con più di 3 lettere eccetto la prima parola
        sum = getWordNumbersSum(word);
        while (sum > 7 && sumArray1.size() != 0) { // somma numeri da 1 a 7 (NOTE)
          sum = sum - 7;
        }
        
        //GRAMMATICA SCALA MAGGIORE
        if (sum == 1) {
          sum = 0; //I grado
        } else if (sum == 2) {
          sum = 2; //II grado
        } else if (sum == 3) {
          sum = 4; //III grado
        } else if (sum == 4) {
          sum = 5; //IV grado
        } else if (sum == 5) {
          sum = 7; //V grado
        } else if (sum == 6) {
          sum = 9; //VI grado
        } else if (sum == 7) {
          sum = 11; //VII grado
        } else if (sum == 8) {
          sum = 12; //I grado (ottava alta)
        } else if (sum == 9) {
          sum = 14; //II grado (ottava alta)
        } else if (sum == 10) {
          sum = 16; //III grado (ottava alta)
        } else if (sum == 11) {
          sum = 17; //IV grado (ottava alta)
        } else if (sum == 12) {
          sum = 19; //V grado (ottava alta)
        } else if (sum == 13) {
          sum = 21; //VI grado (ottava alta)
        } else if (sum == 14) {
          sum = 23; //VII grado (ottava alta)
        }
      } else {
        sum = 100; //VALORE DELLAA PAUSA
      }
      
      sumArray1.add(sum);
      words1.add(word);
      
      //SETTING TONALITA'
      if(sumArray1.size() == 1) {
        int tonalità = sumArray1.get(0);
        
        tonalità = tonalità - 1;
        
        if (tonalità < 0) { //controllo se faccio solo spazio all'inizio
          tonalità = 0;
        }
        
        while (tonalità>=12) { //finchè il numero non è tra 0 e 11, tolgo 12
          tonalità = tonalità - 12;
        }
        
        sumArray1.set(0, tonalità);
        sumArray1.add(1, 0); //imposto primo elemento della melodia a 0: tonica
      }
      sumKeyMelody = sumArray1;
  
      //FINE FRASE
      if(stream1 == '%'){
        count++;
        sentences2.add("");
        
        if (sentences1.size() >= maxSentences) {
          sentences1.remove(0); // Rimuovi la prima frase della prima chat
          sentences2.remove(0); // Rimuovi la prima frase della prima chat
        }
     
        String wordsString = "";
        for (ArrayList<Character> parola : words1) {
          StringBuilder wordString = new StringBuilder();
          for (char c : parola) {
            wordString.append(c);
          }
          wordsString += wordString.toString() + " ";
        }
        if (!words1.isEmpty()) {
          wordsString = wordsString.substring(0, wordsString.length() - 1);
        }
        
        //COPIARE SEQUENZA PER NUMERO DI STEPS
        for (int i = 1; i < sumArray1.size(); i++) {
          sumArrayEl1.add(sumArray1.get(i));
        }
        int elementsAdded = 0;
        while (sumArray1.size()-1 < nSteps) {
          if (elementsAdded < sumArrayEl1.size()) {
            sumArray1.add(sumArrayEl1.get(elementsAdded)); 
            elementsAdded++;
          } else {
            elementsAdded = 0;
          }
        }
  
        if (sumArray1.size() > 1) {
          sumArray1.add(sumArray1.size() - 1); //INSERIRE ELEMENTO DELL'ARRAY con il numero di parole/note della frase
          //sumArray1.add(bpm); //INSERIRE PENULTIMO ELEMENTO con bpm
          sumArray1.add(nSteps); //INSERIRE PENULTIMO ELEMENTO con pulsazioni in loop
        }
        
        //if(prima_frase == true){
        sumArray1.add(1); //INSERIRE ULTIMISSIMO ELEMENTO (FRASE 1)
        sentences1.add(wordsString);
        //} else {
        //  sumArray1.add(2); //INSERIRE ULTIMISSIMO ELEMENTO (FRASE 2)
        //  sentences2.add(wordsString);
        //  //int vol = 0;
        //  //for (int i = 1; i < sumArray.size() - 4; i++) {
        //    //vol += sumArray.get(i);
        //  //}
        //  //float volume = (float)vol / sumArray.get(sumArray.size() - 4);
        //  //sumArray.add((int)volume);
        //}
        
        words1.clear();
        
        //TRASFORMO IN FREQ
        float baseFreq = 261.63;
        float freqMultiplier = pow(2,1.0/12.0);
        for(int i=1; i < sumArray1.size()-4; i++){
          float freq = baseFreq*(pow(freqMultiplier,float(sumArray1.get(0))))*(pow(freqMultiplier,float(sumArray1.get(i))));
          freq = round(freq * 100) / 100.0;
          elementi_freq1.add(freq);
        }
              
        println("OSC (1st el -> key, last-2 el -> n°notes, last-1 el -> bpm: , last el -> nSteps:, ultimiss -> frase 1 o 2? " + sumArray1);
        println("OSC (freq corrispondenti)" + elementi_freq1);
        OscMessage newPadMessage = new OscMessage("/melody");
        for (float i : elementi_freq1) {
          newPadMessage.add(i);
        }
        oscP5.send(newPadMessage, myRemoteLocation);
        
        inputString1 = true;
        
        if (sumKeyMelody.size() >= 2) {
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi l'ultimo elemento
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il penultimo elemento
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il terzultimo elemento
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il quartultimo elemento
        }
      }
      
      inputBuffer1 = ""; // Reset del buffer
    }
      
      
      
      
      
      
      
      
      
      
      
      
      
    } else if (streamType == 2){
      
      prima_frase = false;
      char stream2 = trigger.get(1).stringValue().toCharArray()[0];
      inputBuffer2 += stream2;
      
      if(inputString2){
        sumArray2.clear();
        sumArrayEl2.clear();
        elementi_freq2.clear();
        inputString2 = false;
      }
      
      if ((stream2 == ' '  || stream2 == '%') && !inputBuffer2.equals("")) {
    
      if (maxWords_length2>(width/2)-80) {
        words2.remove(0); // Rimuovi la prima parola
      }
    
      ArrayList<Character> word = new ArrayList<Character>();
      for (char c : inputBuffer2.toCharArray()) {
        if (letterToNumber.containsKey(c)) {
          word.add(c);
        }
      }

     int sum = 0;
      if (word.size() >= 2 || words2.size()==0) { //parole con più di 3 lettere eccetto la prima parola
        sum = getWordNumbersSum(word);
        while (sum > 7 && sumArray2.size() != 0) { // somma numeri da 1 a 7 (NOTE)
          sum = sum - 7;
        }
        
        //GRAMMATICA SCALA MAGGIORE
        if (sum == 1) {
          sum = 0; //I grado
        } else if (sum == 2) {
          sum = 2; //II grado
        } else if (sum == 3) {
          sum = 4; //III grado
        } else if (sum == 4) {
          sum = 5; //IV grado
        } else if (sum == 5) {
          sum = 7; //V grado
        } else if (sum == 6) {
          sum = 9; //VI grado
        } else if (sum == 7) {
          sum = 11; //VII grado
        } else if (sum == 8) {
          sum = 12; //I grado (ottava alta)
        } else if (sum == 9) {
          sum = 14; //II grado (ottava alta)
        } else if (sum == 10) {
          sum = 16; //III grado (ottava alta)
        } else if (sum == 11) {
          sum = 17; //IV grado (ottava alta)
        } else if (sum == 12) {
          sum = 19; //V grado (ottava alta)
        } else if (sum == 13) {
          sum = 21; //VI grado (ottava alta)
        } else if (sum == 14) {
          sum = 23; //VII grado (ottava alta)
        }
      } else {
        sum = 100; //VALORE DELLAA PAUSA
      }
      
      sumArray2.add(sum);
      words2.add(word);
      
      //SETTING TONALITA'
      if(sumArray2.size() == 1) {
        int tonalità = sumArray2.get(0);
        
        tonalità = tonalità - 1;
        
        if (tonalità < 0) { //controllo se faccio solo spazio all'inizio
          tonalità = 0;
        }
        
        while (tonalità>=12) { //finchè il numero non è tra 0 e 11, tolgo 12
          tonalità = tonalità - 12;
        }
        
        sumArray2.set(0, tonalità);
        sumArray2.add(1, 0); //imposto primo elemento della melodia a 0: tonica
      }
      sumKeyMelody = sumArray2;
  
      //FINE FRASE
      if(stream2 == '%'){
        count++;
        sentences1.add("");
        
        if (sentences2.size() >= maxSentences) {
          sentences2.remove(0); // Rimuovi la prima frase della prima chat
          sentences1.remove(0); // Rimuovi la prima frase della prima chat
        }
     
        String wordsString = "";
        for (ArrayList<Character> parola : words2) {
          StringBuilder wordString = new StringBuilder();
          for (char c : parola) {
            wordString.append(c);
          }
          wordsString += wordString.toString() + " ";
        }
        if (!words2.isEmpty()) {
          wordsString = wordsString.substring(0, wordsString.length() - 1);
        }
        
        //COPIARE SEQUENZA PER NUMERO DI STEPS
        for (int i = 1; i < sumArray2.size(); i++) {
          sumArrayEl2.add(sumArray2.get(i));
        }
        int elementsAdded = 0;
        while (sumArray2.size()-1 < nSteps) {
          if (elementsAdded < sumArrayEl2.size()) {
            sumArray2.add(sumArrayEl2.get(elementsAdded)); 
            elementsAdded++;
          } else {
            elementsAdded = 0;
          }
        }
  
        if (sumArray2.size() > 1) {
          sumArray2.add(sumArray2.size() - 1); //INSERIRE ELEMENTO DELL'ARRAY con il numero di parole/note della frase
          //sumArray2.add(bpm); //INSERIRE PENULTIMO ELEMENTO con bpm
          sumArray2.add(nSteps); //INSERIRE PENULTIMO ELEMENTO con pulsazioni in loop
        }
        
        //if(prima_frase == true){
          sumArray2.add(1); //INSERIRE ULTIMISSIMO ELEMENTO (FRASE 1)
          sentences2.add(wordsString);
        //} else {
        //  sumArray2.add(2); //INSERIRE ULTIMISSIMO ELEMENTO (FRASE 2)
        //  sentences2.add(wordsString);
        //  //int vol = 0;
        //  //for (int i = 1; i < sumArray.size() - 4; i++) {
        //    //vol += sumArray.get(i);
        //  //}
        //  //float volume = (float)vol / sumArray.get(sumArray.size() - 4);
        //  //sumArray.add((int)volume);
        //}
        
        words2.clear();
        
        //TRASFORMO IN FREQ
        float baseFreq = 261.63;
        float freqMultiplier = pow(2,1.0/12.0);
        for(int i=1; i < sumArray1.size()-4; i++){
          float freq = baseFreq*(pow(freqMultiplier,float(sumArray1.get(0))))*(pow(freqMultiplier,float(sumArray2.get(i))));
          freq = round(freq * 100) / 100.0;
          elementi_freq2.add(freq);
        }
              
        println("OSC (1st el -> key, last-2 el -> n°notes, last-1 el -> bpm: , last el -> nSteps:, ultimiss -> frase 1 o 2? " + sumArray2);
        println("OSC (freq corrispondenti)" + elementi_freq2);
        OscMessage newPadMessage = new OscMessage("/melody");
        for (float i : elementi_freq2) {
          newPadMessage.add(i);
        }
        oscP5.send(newPadMessage, myRemoteLocation);
        
        inputString2 = true;
        
        if (sumKeyMelody.size() >= 2) {
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi l'ultimo elemento
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il penultimo elemento
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il terzultimo elemento
          sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il quartultimo elemento
        }
      }
      
      inputBuffer2 = ""; // Reset del buffer
    }
    }
    
    
    
  
    
  }
}
