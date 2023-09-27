# *Title CC_Project (CREATIVE LOOPER????)*
(1-line description Creative Computing Project)

## 1. Description
(A description of what the project is about, what you want to convey, how do you envision it (an artistic installation? a webapp?) and what it actually does, so what is the user experience)

## 2. Challenges, accomplishment and lessons learned
(What kind of challenges did you run into for this projects, what kind of accomplishment are you proud of and and what did you learn during the project? Few lines for each question.)

## 3. Technology
(just a plain list of the main technology you used, which include libraries, coding languages, concepts, etc.)

### 3.1 Loop Station
### 3.2 Instruments
#### Recorder and Player
#### Minimalistic Drum Machine
#### Melody Chat (grammar)
Melody Chat consists of a canvas created with *Processing* that represents the writing of sentences by two users (Melody maker and Melody modifier). Through *Firebase*, users can connect with their device, identify themselves with one of two roles, define their username and chat. The **Melody maker** "writes" a melody that will be stored and sent to *Super Collider* to be played during the loop. Furthermore, the melody will also be sent to the Interaction Layer (see corresponding paragraph). The **Melody modifier** instead has the possibility of modifying the previously written melody with effects and parameters such as vibrato, release, ...???

The chat will simply be displayed on each user's device. On the canvas, however, the writing of each character, the memorization of each word (separated by SPACE) and the sentence (after sending ENTER) will be displayed in real time. Each phrase of the **Melody maker** corresponds to a melody created in this way:
- Each character corresponds to a numerical value (a/A = 1, b/B = 2, ...).
- Each word corresponds to the sum of the numerical values of the characters, appropriately normalized.
- The first word sets the major key on which the melody is created. The sum of the numerical values of the characters is normalized between 0 and 11. Therefore each number corresponds to the tonic of the key (0 = C, 1 = C#, ...).
- All words are normalized in a range of values between 1 and 14, which correspond to the degree values of the corresponding major scale in two octaves 3 and 4 (1 = I degree, 2 = II degree, ... , 8 = I degree (high octave), 9 = II degree (high octave), ...). These values will be transformed into frequency and will correspond to the created melody.
- The first note of the melody always corresponds to the first degree of the corresponding scale.
- Each word corresponds to a note that plays at each beat of the loop, made up of n beats (nSteps). If the number of words is less than nSteps, the melody will continue from the beginning until the loop is completed. If the number of words is greater than nStep, the melody will be truncated.
- If the number of characters in a word has a value less than or equal to 2, there will be a pause and the corresponding frequency value will be 0.0 (inaudible). This cannot happen for the first note of the melody.

The **Melody modifier** modifies the melody created in this way. The phrase written by the second user modifies the melody (effects) through parameters created in this way:
- The first parameter uses the key value (from 0 to 11), mapped in a range between 0.0 and 100.0.
- The second is an arithmetic mean between the numerical values of the melody (without counting any pauses), mapped in a range between 0.0 and 50.0
- The third parameter concerns the length of the melody (nSteps), mapped in a range between 0.0 and 100.0.
- The fourth is instead a random number between 0.0 and 100.0.

AGGIUNGERE CORRISPONDENZA DI PARAMETRI A EFFETTO




### 3.3 Layer Interaction

### 3.4 Sounds
### 3.5 OSC structure
SCHEMA MESSAGGI OSC TRA PROCESSING-PHYTON-SUPERCOLLIDER-FIREBASE

## 4. Students
(the members of the group with a sentence that explains for each person what was their main contribution to the project)

**Attolini Silvio**: LoopStation

**Gorni Alessandro**: DM, MelodyChat, sounds.scd, LayerInteraction

**Martinelli Riccardo**: MelodyChat, sounds.scd

## 5. links
(available links such as github repo (mandatory), youtube videos, presentation, link for the web app.)
https://github.com/Rhapsodizer/CC_Project.git

## 6. 1 thumbnail image related to the projects: format 1024x768

## 7. Pictures
(3 pictures of the project (format 1024x768): use screenshots or pictures of you using the demo, rather than block diagrams)

## Video: provide a video showing the demo (edited)

PER PRESENTAZIONE:
- PRESENTATION: slides containing: context, motivation, concept, technical solutions and technical details. You will have 15' for the presentation at your disposal, including the demo session.
- real-time running demo of the project:  In the case this is not feasible due to the virtual call, you are asked produce a video to share us
- Github repo for the code: We will, potentially, ask you to take a look at the code. The Github should be self-explanatory on the project and on how to use the code.





