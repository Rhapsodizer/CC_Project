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
ArrayList<String> sentences = new ArrayList<String>(); // Array di frasi da visualizzare

String inputBuffer = ""; // Buffer per memorizzare le lettere digitate
int maxWords = 10; // Numero massimo di parole nell'array
int maxSentences = 5; // Numero massimo di sentence nell'array di stringhe

int loop_length = 1; //VALORE DA PASSARE DI LUNGHEZZA LOOP (in secondi)

HashMap<Character, Integer> letterToNumber = new HashMap<Character, Integer>(); // Mappa per associare le lettere ai numeri


void setup() {
  size(750, 325);
  textSize(20);
  
  //OSC
  oscP5 = new OscP5(this, 57120);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120); // Indirizzo e porta del destinatario (es. SuperCollider)
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
  
  fill(0);
  textSize(20);
  
  //CHAT IN TEMPO REALE
  String w = "My word: ";
  text(w, 40, 30);
  text(inputBuffer, 40 + textWidth(w), 30);

  //PAROLE MEMORIZZATE
  String s = "My sentence: ";
  text(s, 40 , 60);
  float x = textWidth(s);
  for (int i = 0; i < words.size(); i++) {
    ArrayList<Character> word = words.get(i);
    String wordString = "";
    for (char c : word) {
      wordString += c;
    }
    text(wordString, 40+x, 60);
    x += textWidth(wordString) + 5;
  }

  //CHAT
  String c = "My CHAT (press ENTER to send)";
  text(c, 40 , 90);
  
  fill(255,255,255);
  stroke(128);
  rect(20,100,710,175,20);
  fill(0);
  int startY = 250;
  for (int i = sentences.size()-1; i >=0 ; i--) {
    String sentence = sentences.get(i);
    text(sentence, 40, startY - (sentences.size()-1-i) * 30);
  }
 
  //NOTE
  textSize(16);
  String sumArrayString = "";
  for (int i = 0; i < sumArray.size(); i++) {
    if (i==0){
      sumArrayString += "My key: " + convertToNote(sumArray.get(i)) + " " + "My melody: ";
    } else {
      sumArrayString += convertToNote(sumArray.get(i)) + " ";
    }
  }
  text(sumArrayString, 40, height - 20);
}

void keyPressed() {

    inputBuffer += key;
}

void keyReleased() {

  if ((key == ' '  || key == ENTER) && !inputBuffer.equals("")) {

    if (words.size() >= maxWords) {
      words.remove(0); // Rimuovi la prima parola
    }
    
    ArrayList<Character> word = new ArrayList<Character>();
    for (char c : inputBuffer.toCharArray()) {
      if (letterToNumber.containsKey(c)) {
        word.add(c);
      }
    }
    println("WORD:" + word);
    
    int sum = getWordNumbersSum(word); // Calcola la somma dei numeri
    while (sum > 7 && sumArray.size() != 0) { //somma numeri da 1 a 7 (NOTE)
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
    println("Somma: " + sum);
    sumArray.add(sum);
    words.add(word);
    
    println("WORDs:" + words);
    
    //SETTING TONALITA'
    if(sumArray.size() == 1) {
      int tonalità = sumArray.get(0);
      int primo_elemento_melodia = tonalità;
      
      tonalità = tonalità - 1;
      
      if (tonalità < 0) { //controllo se faccio solo spazio all'inizio
        tonalità = 0;
      }
      
      while (tonalità>=12) { //finchè il numero non è tra 0 e 11, tolgo 12
        tonalità = tonalità - 12;
      }
      
      println("Tonalità: " + tonalità);
      sumArray.set(0, tonalità);
      
      while (primo_elemento_melodia > 7) { //somma numeri da 1 a 7 del primo elemento (NOTE)
      primo_elemento_melodia = primo_elemento_melodia - 7;
      }
    
      //GRAMMATICA SCALA MAGGIORE
      if (primo_elemento_melodia == 1) {
        primo_elemento_melodia = 0; //I grado
      } else if (primo_elemento_melodia == 2) {
        primo_elemento_melodia = 2; //II grado
      } else if (primo_elemento_melodia == 3) {
        primo_elemento_melodia = 4; //III grado
      } else if (primo_elemento_melodia == 4) {
        primo_elemento_melodia = 5; //IV grado
      } else if (primo_elemento_melodia == 5) {
        primo_elemento_melodia = 7; //V grado
      } else if (primo_elemento_melodia == 6) {
        primo_elemento_melodia = 9; //VI grado
      } else if (primo_elemento_melodia == 7) {
        primo_elemento_melodia = 11; //VII grado
      }
      
      sumArray.add(1, primo_elemento_melodia);
    }
    
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
      println("Parole in una stringa: " + wordsString);
  
      sentences.add(wordsString);

      words.clear();

      println("RISULTATO" + sentences);
      if (sumArray.size() > 1) { 
        sumArray.add(sumArray.size() - 1); // INSERIRE PENULTIMO ELEMENTO DELL'ARRAY con il numero di parole della frase
        sumArray.add(loop_length); //INSERIRE ULTIMO ELEMENTO con lunghezza del loop
      }
      
      println("OSC (1st el -> key, last-1 el -> n°notes, last el -> loop_length: " + sumArray);
      OscMessage newPadMessage = new OscMessage("/pad");
      for (float i : sumArray) {
        newPadMessage.add(i);
      }
      oscP5.send(newPadMessage, myRemoteLocation);
      
      sumArray.clear();

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

String convertToNote(int number) {
  String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  if (number >= 0 && number <= 11) {
    return notes[number];
  } else {
    return "Invalid";
  }
}
