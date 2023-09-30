//OSC
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress addressIL;
OscMessage melody;
//OSC

import java.util.ArrayList;
import java.util.HashMap;

ArrayList<ArrayList<Character>> words1 = new ArrayList<ArrayList<Character>>(); // Array di array per memorizzare le parole
ArrayList<ArrayList<Character>> words2 = new ArrayList<ArrayList<Character>>(); // Array di array per memorizzare le parole
ArrayList<Integer> sumArray1 = new ArrayList<Integer>(); // Array di array per memorizzare i numeri corrispondenti per messaggio OSC
ArrayList<Integer> sumArray2 = new ArrayList<Integer>(); // Array di array per memorizzare i numeri corrispondenti per messaggio OSC
ArrayList<Integer> sumArrayEl1 = new ArrayList<Integer>();
ArrayList<Integer> sumArrayEl2 = new ArrayList<Integer>();
ArrayList<Integer> sumKeyMelody1 = new ArrayList<Integer>();
ArrayList<Float> elementi_freq1 = new ArrayList<Float>(); //LISTA DI FREQ (+ pause =0) da inviare a SC
ArrayList<Float> modifierArray2 = new ArrayList<Float>(); //LISTA DI VALORI MODIFIER da inviare a SC
ArrayList<String> sentences1 = new ArrayList<String>(); //chat 1
ArrayList<String> sentences2 = new ArrayList<String>(); //chat 2

String inputBuffer1 = ""; // Buffer per memorizzare le lettere digitate
String inputBuffer2 = ""; // Buffer per memorizzare le lettere digitate
float maxWords_length1; // Lunghezza massima sentence
float maxWords_length2; // Lunghezza massima sentence
int maxSentences = 9; // Numero massimo di sentence nell'array di stringhe

int nSteps; //Numero pulsazioni per battuta

boolean inputString1 = false;
boolean inputString2 = false;
boolean prima_frase = true;

int count = 0; //CONTATORE CHAT
String user1 = "";
String user2 = "";

HashMap<Character, Integer> letterToNumber = new HashMap<Character, Integer>(); // Mappa per associare le lettere ai numeri

PImage img1, img2;

void setup() {
  size(900, 500);
  textSize(20);
  
  //nSteps = int(args[0]);
  nSteps = 16;
  
  //OSC
  oscP5 = new OscP5(this, 12002);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  addressIL = new NetAddress("127.0.0.1", 12000);
  melody = new OscMessage("/melody");
  //OSC
  
  char[] lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".toCharArray();
  char[] uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();

  for (int i = 0; i < lowercaseLetters.length; i++) {
    letterToNumber.put(lowercaseLetters[i], i + 1);
    letterToNumber.put(uppercaseLetters[i], i + 1);
  }  
  
  // Load image
  img1 = loadImage("elvis.png");
  img2 = loadImage("elvis-face.png");
  imageMode(CENTER);
}

void draw() {
  
  background(220);
  textSize(20);
  image(img1,(width/2)-125,(height/2)+50,122,213);
  image(img2,(width)-125,(height/2)+50,150,150);
  
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

  //PAROLE MEMORIZZATE CHAT 2
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
  
  //PAROLE MEMORIZZATE CHAT 1
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
  text("Melody maker: " + user1, width/2, 130);
  text("Melody modifier: " + user2, 40, 130);
  
  //NOTE
  textSize(16);
  fill(128);
  String KeyString = "My key: ";
  String MelodyString = "My melody: ";
  for (int i = 0; i < sumKeyMelody1.size(); i++) {
    if (i==0){
      KeyString += convertToNoteKey(sumKeyMelody1.get(0));
    } else {
      MelodyString += convertToNoteMelody(sumKeyMelody1.get(i), sumKeyMelody1.get(0)) + " ";
    }
  }
  fill(128);
  text(KeyString, 40, height - 20);
  text(MelodyString, 160, height - 20);
}

//FUNZIONE getWordNumbersString
String getWordNumbersString(ArrayList<Character> word) {
  String numString = "";
  for (char c : word) {
    if (letterToNumber.containsKey(c)) {
      numString += letterToNumber.get(c) + " ";
    }
  }
  return numString.trim();
}
//FUNZIONE SOMMA LETTERE DELLA PAROLA
int sumFunction(ArrayList<Character> word) {
  int sum = 0;
  for (char c : word) {
    if (letterToNumber.containsKey(c)) {
      sum += letterToNumber.get(c);
    }
  }
  return sum;
}
//FUNZIONE TONALILTA'
String convertToNoteKey(int number) {
  String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  if (number >= 0 && number <= 11) {
    return notes[number];
  } else {
    return "Invalid";
  }
}
//FUNZIONE MELLODIA
String convertToNoteMelody(int number, int startingPoint) {  
  if (number == 100) {
    return "P";
  }  
    String[] notes = {"C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5"};  if (startingPoint >= 0 && startingPoint <= 11 && number >=0) {
    int adjustedNumber = (number + startingPoint) % 24;
    return notes[adjustedNumber];
  } else {
    return "Invalid";
  }
}

// Receive OSC triggers
void oscEvent(OscMessage trigger) {
  
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
  
  // Exit applet
  if(trigger.checkAddrPattern("/terminate")) {
    exit();
  }
  
  // Manage characters  /char 2 f
  if(trigger.checkAddrPattern("/char")) {
    
    int streamType = trigger.get(0).intValue();
    if (streamType == 1) {
      
      prima_frase = true;
      char stream1 = trigger.get(1).stringValue().toCharArray()[0];
      if(stream1 == '*' && inputBuffer1.length() > 0) {
        inputBuffer1 = inputBuffer1.substring(0, inputBuffer1.length() - 1);
        } else if (stream1 != '%') {
          inputBuffer1 += stream1;
      }
      
      if(inputString1) {
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
          if (c != ' '){
            word.add(c);
          }
        }

        int sum = 0;
        if (word.size() >= 3 || words1.size()==0) { //parole con più di 3 lettere eccetto la prima parola
          sum = sumFunction(word);
          
          //SETTING TONALITA'
          if(sumArray1.size() == 0) {
            int ton = sum-1;    
            if (ton < 0) {
              ton = 0;
            }    
            while (ton>=12) {
              ton = ton - 12;
            }       
            sumArray1.add(ton);  
          }
          
          //SETTING PRIMO ELEMENTO DELLA MELODIA
          if (sumArray1.size()==1){
            int tonica = 0;
            sumArray1.add(tonica); //imposto primo elemento della melodia a 0: tonica
          } else {
            
            //GRAMMATICA SCALA MAGGIORE - SETTING ALTRE NOTE MELODIA
            while (sum > 14 && sumArray1.size() != 0) { // somma numeri da 1 a 14 (NOTE)
              sum = sum - 14;
            }  
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
            sumArray1.add(sum);
          }
        } else {
          sum = 100; //VALORE DELLA PAUSA
          sumArray1.add(sum);
        }
  
        words1.add(word);
        sumKeyMelody1 = sumArray1;
  
        //FINE FRASE
        if(stream1 == '%'){
          count++;
          sentences2.add("");
          
          if (sentences1.size() >= maxSentences) {
            sentences1.remove(0);
            sentences2.remove(0);
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
          }
          sentences1.add(wordsString);
  
          
          words1.clear();
          
          //TRASFORMO IN FREQ
          float baseFreq = 261.63;
          float freqMultiplier = pow(2,1.0/12.0);
          for (int i = 1; i < sumArray1.size() - 1; i++) {
            if (sumArray1.get(i) != 100) {
              float freq = baseFreq * (pow(freqMultiplier, float(sumArray1.get(0)))) * (pow(freqMultiplier, float(sumArray1.get(i))));
              freq = round(freq * 100) / 100.0;
              elementi_freq1.add(freq);
            } else {
              float freq = 0.0; //setto a 0 la frequenza per le pause
              elementi_freq1.add(freq);
            }
          }
                
          println("OSC (1st el -> key, last el -> n°notes)" + sumArray1);
          println("OSC (freq corrispondenti)" + elementi_freq1);
          OscMessage newPadMessage = new OscMessage("/melody");
          for (float i : elementi_freq1) {
            newPadMessage.add(i);
          }
          oscP5.send(newPadMessage, myRemoteLocation);
          // Send note to interaction layer
          OscMessage sendIL = new OscMessage("/noteChars");
          for (int i=1; i<sumKeyMelody1.size()-1; i++) {
            sendIL.add(convertToNoteMelody(sumKeyMelody1.get(i), sumKeyMelody1.get(0)));
          }
          oscP5.send(sendIL, addressIL);
          
          inputString1 = true;
          
          if (sumKeyMelody1.size() >= 2) {
            sumKeyMelody1.remove(sumKeyMelody1.size() - 1); // Rimuovi l'ultimo elemento
          }
        }
        
        inputBuffer1 = ""; // Reset del buffer
      }
 
    } else if (streamType == 2){
      
      prima_frase = false;
      char stream2 = trigger.get(1).stringValue().toCharArray()[0];
      if(stream2 == '*' && inputBuffer2.length() > 0) {
        inputBuffer2 = inputBuffer2.substring(0, inputBuffer2.length() - 1);
        } else if (stream2 != '%') {
          inputBuffer2 += stream2;
      }
      
      if(inputString2){
        sumArray2.clear();
        sumArrayEl2.clear();
        modifierArray2.clear();
        inputString2 = false;
      }
      
      if ((stream2 == ' '  || stream2 == '%') && !inputBuffer2.equals("")) {
    
        if (maxWords_length2>(width/2)-80) {
          words2.remove(0); // Rimuovi la prima parola
        }
      
        ArrayList<Character> word = new ArrayList<Character>();
        for (char c : inputBuffer2.toCharArray()) {
          if (c != ' '){
            word.add(c);
          }
        }

        int sum = 0;
        if (word.size() >= 3 || words2.size()==0) { //parole con più di 3 lettere eccetto la prima parola
          sum = sumFunction(word);
          
          //SETTING TONALITA'
          if(sumArray2.size() == 0) {
            int ton = sum-1;    
            if (ton < 0) { //controllo se faccio solo spazio all'inizio
              ton = 0;
            }    
            while (ton>=12) { //finchè il numero non è tra 0 e 11, tolgo 12
              ton = ton - 12;
            }       
            sumArray2.add(ton);  
          }
          
          //SETTING PRIMO ELEMENTO DELLA MELODIA
          if (sumArray2.size()==1){
            int tonica = 0;
            sumArray2.add(tonica); //imposto primo elemento della melodia a 0: tonica
          } else {
            //GRAMMATICA SCALA MAGGIORE - SETTING ALTRE NOTE MELODIA
            while (sum > 14 && sumArray2.size() != 0) { // somma numeri da 1 a 14 (NOTE)
              sum = sum - 14;
            }  
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
            sumArray2.add(sum);
          }
        } else {
          sum = 100; //VALORE DELLAA PAUSA
          sumArray2.add(sum);
        }
  
        words2.add(word);
    
        //FINE FRASE
        if(stream2 == '%'){
          count++;
          sentences1.add("");
          
          if (sentences2.size() >= maxSentences) {
            sentences2.remove(0);
            sentences1.remove(0);
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
          }
  
          sentences2.add(wordsString);
          words2.clear();
          
          ////MODIFIER
          
          if(sumArray2.size()>0){
            
            //PRIMO ELEMENTO (elemento tonalità) da 0.1 a 1.5
            //release
            int firstInteger = sumArray2.get(0);
            float mappedFloat_1 = map(firstInteger, 0, 11, 0.1, 1.5); 
            modifierArray2.add(mappedFloat_1);
            
            //SECONDO ELEMENTO (media melodia) da 2.0 a 20.0 (non arriva mai a 20 perchè primo elemento sempre 0)
            //tremoloFreq
            int somma = 0;
            int melody_length = sumArray2.size() - 2;
            for(int i=1; i< sumArray2.size()-1;i++){
              if(sumArray2.get(i) == 100){
                melody_length--;
              } else{
                somma += sumArray2.get(i);
              }
            }
            float average = (float) somma / (melody_length);
            float mappedFloat_2 = map(average, 0, 23, 2.0, 20.0); 
            modifierArray2.add(mappedFloat_2);
            
            //TERZO ELEMENTO (lunghezza melodia = nSteps) da 0.5 a 1.0
            //tremoloDepth
            int lastInteger = sumArray2.get(sumArray2.size() - 1);
            float mappedFloat_3 = map(lastInteger, 1, 16, 0.5, 1.0);
            modifierArray2.add(mappedFloat_3);
            
            //QUARTO ELEMENTO (random)
            //amp
            modifierArray2.add(random(0.1, 1.0));
          }
             
          println("OSC (1st el -> key, last el -> n°notes)" + sumArray2);
          println("MODIFIER" + modifierArray2);
          OscMessage newPadMessage = new OscMessage("/melody");
          for (float i : modifierArray2) {
            newPadMessage.add(i);
          }
          oscP5.send(newPadMessage, myRemoteLocation);
          
          inputString2 = true;
        }
        
        inputBuffer2 = ""; // Reset del buffer
      }
    }  
  }
}
