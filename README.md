# *E.L.V.I.S.*
*Enhanched Looper with Visual Interaction and Sonification*
<br />
<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#description">Description</a></li>
    <ul>
      <li><a href="#cal">Challenges, accomplishment and lessons learned</a></li>
    </ul>
    <li><a href="#technology">Technology</a></li>
      <li><a href="#loop-station">Loop Station Manager</a></li>
      <li><a href="#instruments">Instruments</a></li>
      <ul>
        <li><a href="#RP">Recorder and Player</a></li>
        <li><a href="#DM">Drum Machine</a></li>
        <li><a href="#MC">Melody Chat</a></li>
        <li><a href="#ship">Ship agent</a></li>
      </ul>
      <li><a href="#layer-interaction">Layer Interaction</a></li>
      <li><a href="#sounds">Sounds</a></li>
      <li><a href="#osc">Osc Structures</a></li>
    <li><a href="#contact">Contacts and contributions</a></li>
  </ol>
</details>

## 1. Description <a name="description"></a>
(A description of what the project is about, what you want to convey, how do you envision it (an artistic installation? a webapp?) and what it actually does, so what is the user experience)
This project aims to create a simple and user-friendly Loop Station. This application has been built with the idea to be used as an artistic installation, in which one or more users can interact with it in a few clicks.
It allows to create simple intstruments that require little-to-no musical knowledge or IT skills, so that anybody is able
to express themselves and enjoy the music they create.

### 1.1. Challenges, accomplishment and lessons learned <a name="cal"></a>
(What kind of challenges did you run into for this projects, what kind of accomplishment are you proud of and and what did you learn during the project? Few lines for each question.)
The main challenge was to create synchronism for the independent instruments. This lead us to establish a hierarchical structure
in which the **Loop Station Manager** dictates all the actions to perform.
We have worked autonomously on the various instrument and together on the foundation of the looper.
We learnt how to deal with threading problems, connections issues and local message dispatching, along with coding tricks here and there that will be useful in the future.

## 2. Technology <a name="technology"></a>
(just a plain list of the main technology you used, which include libraries, coding languages, concepts, etc.)
The project is a combination of *Python*, *Processing* and *Supercollider* languages. It has been optimized for Windows, Linux and MacOS operating system.
As for *Python* *tkinter* and *threading* are the main libraries used to create the independent windows; *osc* messages
are the main mean of communication among the parts.
As for Processing...
As For Supercollider...

## 3. Loop Station Manager <a name="loop-station"></a>

In the main page, we can choose many options and actions. We can set the number of beats of the loop and the bpm velocity. These parameters allow you to change the loop size for each instrument. On this main page you can choose the instruments, open them and create a track. Finally, all instruments can be played simultaneously.

## 4. Instruments <a name="instruments"></a>
### 4.1 Recorder and Player <a name="RP"></a>
Recorder and Player is a simple instrument. It allows the user to create a recording to use later in the loop as well as
to load an *mp3* or *wav* file to be played during the exhibition.
In the upper section of the instrument's interface, the user can use the buttons REC and OPEN to execute the above
mentioned actions, while in the lower section a real-time amplitude envelope is shown.

### 4.2 Drum Machine <a name="DM"></a>

### 4.3 Melody Chat <a name="MC"></a>

<img src="https://github.com/Rhapsodizer/CC_Project/assets/92687497/a85810c9-faeb-40e4-9280-8dd1debf53e2" width="250">

Melody Chat consists of a canvas created with *Processing* that represents the writing of sentences by two users (Melody maker and Melody modifier). Through *Firebase*, users can connect with their device, identify themselves with one of two roles, define their username and chat. The **Melody maker** "writes" a melody that will be stored and sent to *Super Collider* to be played during the loop. Furthermore, the melody will also be sent to the Interaction Layer (see corresponding paragraph). The **Melody modifier** instead has the possibility of modifying the previously written melody with effects and parameters such as vibrato, release or amplitude.

The chat will simply be displayed on each user's device. On the canvas, however, the writing of each character, the memorization of each word (separated by SPACE) and the sentence (after sending ENTER) will be displayed in real time. Each sentence of the **Melody maker** corresponds to a melody created in this way:
- Each character corresponds to a numerical value (a/A = 1, b/B = 2, ...). Only letters are included in the count (no symbols or other characters).
- Each word corresponds to the sum of the numerical values of the characters, appropriately normalized.
- The first word sets the major key on which the melody is created. The sum of the numerical values of the characters is normalized between 0 and 11. Therefore each number corresponds to the tonic of the key (0 = C, 1 = C#, ...).
- All words are normalized in a range of values between 1 and 14, which correspond to the degree values of the corresponding major scale in two octaves 3 and 4 (1 = I degree, 2 = II degree, ... , 8 = I degree (high octave), 9 = II degree (high octave), ...). These values will be transformed into frequency and will correspond to the created melody.
- The first note of the melody always corresponds to the first degree of the corresponding scale.
- Each word corresponds to a note that plays at each beat of the loop, made up of n beats (nSteps). If the number of words is less than nSteps, the melody will continue from the beginning until the loop is completed. If the number of words is greater than nStep, the melody will be truncated.
- If the number of characters (including other symbols or punctuation marks) in a word has a value less than or equal to 2, there will be a rest/pause (P) and the corresponding frequency value will be 0.0 (inaudible). This cannot happen for the first note of the melody.
- The key and melody are displayed on the canvas below each time a new sentence is created.

The **Melody modifier** modifies the melody created in this way. The sentence written by the second user modifies the melody (effects) through parameters created in this way:
- The first parameter uses the key value (from 0 to 11) and maps the *\release* of the oscillator in a range between 0.1 and 1.0.
- The second is an arithmetic mean between the numerical values of the melody (without counting any pauses). It maps the *\tremoloFreq* in a range between 2.0 and 20.0.
- The third parameter concerns the length of the melody (nSteps) and maps the *\tremoloDepth* in a range between 0.5 and 1.0.
- The fourth is instead a random number between 0.1 and 1.0 and modifies the *\amp* of the sound.

### 4.4 Ship agent <a name="ship"></a>



## 5. Layer Interaction <a name="layer-interaction"></a>

The creative visualization of the Interaction Layer is created in *Processing* and it has the purpose of randomly modifying the state of the sounds created by the Drum Machine and Melody Chat. Each element of the Drum Machine and each note (or rest) of the Melody Chat appears on the canvas as a ball that moves and collides with the others. The balls have a minimalist display and differ from each other thanks to the text and size (or color????).

COSA SUCCEDE SE LE PALLINE COLLIDONO??

## 6. Sounds <a name="sounds"></a>

The sounds are created using *Super Collider*. As for the drum machine and melody chat, each percussive sound (\kick, \snare, \hat) or each note (\melody) corresponds to a single *Synthdef*. At each collision of the balls, the state of some parameters defined within each tool changes.

## 7. OSC structure <a name="osc"></a>
SCHEMA MESSAGGI OSC TRA PROCESSING-PHYTON-SUPERCOLLIDER-FIREBASE

## 8. Contacts and contributions <a name="contact"></a>

- **Attolini Silvio** - silvio.attolini@mail.polimi.it: UI, Master, LoopStationManager, Tracks, Utils, RecorderAndPlayer
- **Gorni Alessandro** - alessandro.gorni@mail.polimi.it: DM, MelodyChat, sounds.scd, LayerInteraction
- **Martinelli Riccardo** - riccardo.martineli@mail.polimi.it: MelodyChat, sounds.scd

Project link: https://github.com/Rhapsodizer/CC_Project
OTHER LINKSSSSS???????????????????? (youtube videos, presentation, link for the web app.)


## 6. 1 thumbnail image related to the projects: format 1024x768

## 7. Pictures
(3 pictures of the project (format 1024x768): use screenshots or pictures of you using the demo, rather than block diagrams)

## Video: provide a video showing the demo (edited)

PER PRESENTAZIONE:
- PRESENTATION: slides containing: context, motivation, concept, technical solutions and technical details. You will have 15' for the presentation at your disposal, including the demo session.
- real-time running demo of the project:  In the case this is not feasible due to the virtual call, you are asked produce a video to share us
- Github repo for the code: We will, potentially, ask you to take a look at the code. The Github should be self-explanatory on the project and on how to use the code.

<p align="right">(<a href="#top">back to top</a>)</p>







