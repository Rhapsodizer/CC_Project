# *E.L.V.I.S.* <a name="top"></a>
*Enhanched Looper with Visual Interaction and Sonification*

![elvis gif](https://github.com/Rhapsodizer/CC_Project/assets/93535281/bee54d25-f18e-47fe-9d20-7bf7123ff275)

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#description">Description</a></li>
    <ul>
      <li><a href="#cal">Challenges, accomplishment and lessons learned</a></li>
    </ul>
    <li><a href="#technology">Technology</a></li>
    <ul>
        <li><a href="#PR">Launch procedure</a></li>
    </ul>
      <li><a href="#loop-station">Loop Station Manager</a></li>
      <li><a href="#instruments">Instruments</a></li>
      <ul>
        <li><a href="#RP">Recorder and Player</a></li>
        <li><a href="#DM">Drum Machine</a></li>
        <li><a href="#MC">Melody Chat</a></li>
        <li><a href="#image-sonificator">Image Sonificator</a></li>
      </ul>
      <li><a href="#layer-interaction">Layer Interaction</a></li>
    <ul>
        <li><a href="#control-agent">Control Agent</a></li>
      </ul>
      <li><a href="#sounds">Sounds</a></li>
      <li><a href="#osc">Osc Structures</a></li>
    <li><a href="#future">Future improvements</a></li>
    <li><a href="#contact">Contacts and contributions</a></li>
  </ol>
</details>

## 1. Description <a name="description"></a>

This project aims to create a simple and user-friendly Loop Station. This application has been built with the idea to be used as an artistic installation, in which one or more users can interact with it in a few clicks.
It allows to create simple intstruments that require little-to-no musical knowledge or IT skills, so that anybody is able to express themselves and enjoy the music they create, with a certain degree of chaotic behavior.

### 1.1. Challenges, accomplishment and lessons learned <a name="cal"></a>

The main challenge was to create synchronism for the independent instruments. This lead us to establish a hierarchical structure
in which the **Loop Station Manager** dictates all the actions to perform.
We have worked autonomously on the various instrument and together on the foundation of the looper.
We learnt how to deal with threading problems, connections issues and local message dispatching, along with coding tricks here and there that will be useful in the future. Humanly speaking, we remark how important it is to keep an open mind at all times.

## 2. Technology <a name="technology"></a>

The project is a combination of *Python*, *Processing*, *Supercollider* and *html* languages. It relays on a real time database (*Firebase*) to exchange some data. It has been optimized for Windows, Linux and MacOS operating system.
- As for *Python* *tkinter* and *threading* are the main libraries used to create the independent windows; *osc* messages are the main mean of communication among the parts.
- As for *Processing*, it has been chosen for its versatility. Different libraries has been used, such *Osc* for communications between modules, *Minim* for audio analysis and *OpenCV* for video processing.
- As for *Supercollider*, it has been chosen for its real-time sound generation power. Sounds can be created and modified during play.

<img width="543" alt="Screenshot 2023-10-02 alle 11 58 28" src="https://github.com/Rhapsodizer/CC_Project/assets/93535281/8388aa6a-00f9-4ec1-8ff6-9d46638407d7">


### 2.1 Launch procedure <a name="PR"></a>
- Open the file "Utils/users.py" and add your profile with your local paths.
- Start Supercollider, boot the server, open the file "sounds.osc" and evaluate all the Synthdef and functions.
- Launch the python script "master.py" from the terminal or python ide after changed the user.

## 3. Loop Station Manager <a name="loop-station"></a>

In the main page, you can choose among many options and perform different actions. You can set the number of beats of the loop and the bpms. These parameters allow you to change the loop size for each instrument. On this main page you can also create a track, choose the instruments and setting them up. Finally, all instruments can be played simultaneously or individually.

![ELVIS](https://github.com/Rhapsodizer/CC_Project/assets/93535281/6eb364d7-2f44-4922-a256-1ed712767c69)

## 4. Instruments <a name="instruments"></a>
### 4.1 Recorder and Player <a name="RP"></a>

Recorder and Player is a simple instrument. It allows the user to create a recording to use later in the loop as well as
to load an *mp3* or *wav* file to be played during the exhibition.
In the upper section of the instrument's interface, the user can use the buttons REC and OPEN to execute the above mentioned actions, while in the lower section a real-time amplitude envelope is shown.

![RandP](https://github.com/Rhapsodizer/CC_Project/assets/93535281/62a887da-4478-44b3-b525-813aa34f587e)

### 4.2 Drum Machine <a name="DM"></a>

The **Minimalistic Drum Machine** is made up of three rows of instruments: kick, hat and snare. Each pulse is characterized by a circle which, when selected, is colored and a ball is generated in the Layer Interaction, with the relative label of the instrument, together with the reproduction of the single sound. The columns are equal to the number of beats in a loop, which can be changed directly from the Loop Station Manager. If any space is deselected, the ball disappears from the Layer Interaction.

![MDM](https://github.com/Rhapsodizer/CC_Project/assets/93535281/c3a16442-ea9e-4b30-b089-c2afc31c23a8)

### 4.3 Melody Chat <a name="MC"></a>

<img src="https://github.com/Rhapsodizer/CC_Project/assets/92687497/a85810c9-faeb-40e4-9280-8dd1debf53e2" width="200">

Melody Chat represents the exchange of messages by two users (Melody maker and Melody modifier). Through *Firebase*, users can connect with their device, identify themselves with one of two roles, define their username and chat themselfs. The **Melody maker** "writes" a melody that will be stored and sent to *Super Collider* to be played during the loop. After that, the melody will also be sent to the Interaction Layer (see corresponding paragraph). The **Melody modifier** instead has the possibility of modifying the previously written melody with effects and parameters such as vibrato, release or amplitude.

<img width="747" alt="MC" src="https://github.com/Rhapsodizer/CC_Project/assets/93535281/a1162326-e727-4083-b3ef-5c980c833f86">

### 4.4 Image Sonificator <a name="image-sonificator"></a>

It allows the user to load an image, from which the pixels will be randomly extracted when the loop plays. Pixels will be transformed into numerical values and will reproduce notes in the choosen key. When loop is played the pixels are visualized also in the Interaction Layer in the same position as a black hole, that erases balls that collide with it.

![IS](https://github.com/Rhapsodizer/CC_Project/assets/93535281/e66fc864-63d1-4516-b7d5-149f41ec37a8)


## 5. Layer Interaction <a name="layer-interaction"></a>

The creative visualization of the Interaction Layer is created in *Processing* and it has the purpose of randomly modifying the state of the sounds created by the Drum Machine and Melody Chat. Each element of the Drum Machine and each note (or rest) of the Melody Chat appears on the canvas as a ball that moves and collides with the others. The balls have a minimalist display and differ from each other thanks to the text, size and color. If two balls representing the same instrument of the drum machine collide, their pitch is modified randomly in a certain predefined range of values.

<img width="440" alt="LI" src="https://github.com/Rhapsodizer/CC_Project/assets/93535281/dbb8df8d-dc0d-4336-b381-bcb19c42acd4">

Each ball can be selected clicking at it. A popup appears showing some informations, like the type of instrument, id, position and speed.

### 5.1 Control agent <a name="control-agent"></a>

Balls inside Layer Interaction sketch reduce their speed because of the friction and finally stop. In order to make them collide again a new agent (class *Agent*) can be called inside the sketch. It's an image with a radius of interaction that can be moved by the user. The controls are coded in the sketch named *controlAgent*. The controls are simple:
+ **Up** and **Down** are controlled via microphone by the pitch computed
+ **Left** and **Right** are controlled by the averaged optical flow amount computed from the left and region of the webcam stream
The collision with the agent give momentum to the ball, causing cascading collisions.

## 6. Sounds <a name="sounds"></a>

The Drum Machine, Melody Chat and Image Sonification sounds are created using *Super Collider*. Each percussive sound (\kick, \snare, \hat) and each note (\melody) corresponds to a particular *SynthDef*. The parameters that change the states of each sound are sent via OSC messages. At each collision of the spheres the state of some parameters defined within each user changes.

## 7. OSC structure <a name="osc"></a>
![immagine](https://github.com/Rhapsodizer/CC_Project/assets/92687497/d2911156-d38a-47f6-970b-1ecb26c28d9c)

## 8. Future improvements <a name="future"></a>

The richness of a loop station is given by the user's artistic-musical freedom. For this reason, the addition of different methods of interaction with the machine is the first step, as well as the interaction itself between the various graphic-sound layers. Even a modification of the real-time tracks can be a direction for improvement.

## 9. Contacts and contributions <a name="contact"></a>

- **Attolini Silvio** - silvio.attolini@mail.polimi.it: UI, Master, LoopStationManager, Tracks, Utils, RecorderAndPlayer, Image Sonification
- **Gorni Alessandro** - alessandro.gorni@mail.polimi.it: DM, MelodyChat, sounds.scd, LayerInteraction
- **Martinelli Riccardo** - riccardo.martineli@mail.polimi.it: MelodyChat, sounds.scd

Project link: https: //github.com/Rhapsodizer/CC_Project

Youtube video demo: https://youtu.be/iicaeMra-OA

<p align="right">(<a href="#top">back to top</a>)</p>











