//OSC
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
OscMessage pad;
//OSC

import java.util.ArrayList;
import java.util.HashMap;

ArrayList<ArrayList<Character>> words = new ArrayList<ArrayList<Character>>(); // Array di array per memorizzare le parole
ArrayList<Integer> sumArray = new ArrayList<Integer>(); // Array di array per memorizzare i numeri corrispondenti per messaggio OSC
ArrayList<Integer> sumKeyMelody = new ArrayList<Integer>(); 
ArrayList<String> sentences = new ArrayList<String>(); // Array di frasi da visualizzare

String inputBuffer = ""; // Buffer per memorizzare le lettere digitate
float maxWords_length; // Lunghezza massima sentence
int maxSentences = 5; // Numero massimo di sentence nell'array di stringhe

int bpm = 60; //BPM
int nSteps = 4; //Numero pulsazioni per battuta

boolean inputString = false;
boolean prima_frase = true;

HashMap<Character, Integer> letterToNumber = new HashMap<Character, Integer>(); // Mappa per associare le lettere ai numeri

void setup() {
  size(750, 325);
  textSize(20);
  
  //OSC
  oscP5 = new OscP5(this, 57120);
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
  
  //CHAT IN TEMPO REALE
  fill(128);
  String w = "My word: ";
  text(w, 40, 30);
  fill(0);
  text(inputBuffer, 40 + textWidth(w), 30);

  //PAROLE MEMORIZZATE
  fill(128);
  String s = "My sentence: ";
  text(s, 40 , 60);
  fill(0);
  float x = textWidth(s);
  for (int i = 0; i < words.size(); i++) {
    ArrayList<Character> word = words.get(i);
    String wordString = "";
    for (char c : word) {
      wordString += c;
    }
    text(wordString, 40+x, 60);
    x += textWidth(wordString) + 5;
    maxWords_length = x;
  }

  //CHAT
  int startY = 250;
  for (int i = sentences.size()-1; i >=0 ; i--) {
    String sentence = sentences.get(i);
    text(sentence, 40, startY - (sentences.size()-1-i) * 30);  
  }
  
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

void keyPressed() {
  
  if(inputString){
    sumArray.clear();
    inputString = false;
  }
    inputBuffer += key;
}

void keyReleased() {

  if ((key == ' '  || key == ENTER) && !inputBuffer.equals("")) {
    
    if (maxWords_length>width-80) {
      words.remove(0); // Rimuovi la prima parola
    }
    
    ArrayList<Character> word = new ArrayList<Character>();
    for (char c : inputBuffer.toCharArray()) {
      if (letterToNumber.containsKey(c)) {
        word.add(c);
      }
    }

   int sum = 0;
    if (word.size() >= 3 || words.size()==0) { //parole con più di 3 lettere eccetto la prima parola
      sum = getWordNumbersSum(word);
      while (sum > 7 && sumArray.size() != 0) { // somma numeri da 1 a 7 (NOTE)
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
      }
    } else {
      sum = 100; //VALORE DELLAA PAUSA
    }
    
    sumArray.add(sum);
    words.add(word);
    
    //SETTING TONALITA'
    if(sumArray.size() == 1) {
      int tonalità = sumArray.get(0);
      
      tonalità = tonalità - 1;
      
      if (tonalità < 0) { //controllo se faccio solo spazio all'inizio
        tonalità = 0;
      }
      
      while (tonalità>=12) { //finchè il numero non è tra 0 e 11, tolgo 12
        tonalità = tonalità - 12;
      }
      
      sumArray.set(0, tonalità);
      sumArray.add(1, 0); //imposto primo elemento della melodia a 0: tonica
    }
    sumKeyMelody = sumArray;

    //FINE FRASE
    if(key == ENTER){
      
      if (sentences.size() >= maxSentences) {
      sentences.remove(0); // Rimuovi la prima frase
      }
   
      String wordsString = "";
      for (ArrayList<Character> parola : words) {
        StringBuilder wordString = new StringBuilder();
        for (char c : parola) {
          wordString.append(c);
        }
        wordsString += wordString.toString() + " ";
      }
      if (!words.isEmpty()) {
        wordsString = wordsString.substring(0, wordsString.length() - 1);
      }
  
      sentences.add(wordsString);
      words.clear();

      if (sumArray.size() > 1) {
        sumArray.add(sumArray.size() - 1); //INSERIRE ELEMENTO DELL'ARRAY con il numero di parole/note della frase
        sumArray.add(bpm); //INSERIRE PENULTIMO ELEMENTO con bpm
        sumArray.add(nSteps); //INSERIRE PENULTIMO ELEMENTO con pulsazioni in loop
      }
      
      if(prima_frase == true){
        sumArray.add(1); //INSERIRE ULTIMISSIMO ELEMENTO (FRASE 1)
        prima_frase = false;
      } else {
        sumArray.add(2); //INSERIRE ULTIMISSIMO ELEMENTO (FRASE 2)
        //int vol = 0;
        //for (int i = 1; i < sumArray.size() - 4; i++) {
          //vol += sumArray.get(i);
        //}
        //float volume = (float)vol / sumArray.get(sumArray.size() - 4);
        //sumArray.add((int)volume);
        //prima_frase = true;
      }
     
      println("OSC (1st el -> key, last-2 el -> n°notes, last-1 el -> bpm: , last el -> nSteps:, ultimiss -> frase 1 o 2? " + sumArray);
      OscMessage newPadMessage = new OscMessage("/pad");
      for (float i : sumArray) {
        newPadMessage.add(i);
      }
      oscP5.send(newPadMessage, myRemoteLocation);
      
      inputString = true;
      
      if (sumKeyMelody.size() >= 2) {
        sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi l'ultimo elemento
        sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il penultimo elemento
        sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il terzultimo elemento
        sumKeyMelody.remove(sumKeyMelody.size() - 1); // Rimuovi il quartultimo elemento
      }
    }
    
    inputBuffer = ""; // Reset del buffer
  }
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
  
  String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  if (startingPoint >= 0 && startingPoint <= 11 && number >=0) {
    int adjustedNumber = (number + startingPoint) % 12;
    return notes[adjustedNumber];
  } else {
    return "Invalid";
  }
}
