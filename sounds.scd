NetAddr("127.0.0.1", 57120);



//---------------------------------------------------------------------
//
//                     MELODY CHAT
//
//---------------------------------------------------------------------

//PRIMO PAD
(
SynthDef(\pad, {
    arg freq = 440, sustain = 1, amp = 0.3;
    var env, osc, padSound;

    // Envelope
    env = EnvGen.kr(Env.perc(0.01, sustain), doneAction: 2);

    // Oscillatori
    osc = Mix.ar([
        Saw.ar(freq * [1, 1.005], 0.2),
        LFSaw.ar(freq * [0.5, 0.501], 0.15)
    ]);

    // Applicazione dell'envelope
    padSound = osc * env * amp;

    // Aggiungi un po' di riverbero
    padSound = padSound * FreeVerb.ar(padSound, 0.2);

    Out.ar(0, padSound);
}).add;
)

//SECONDO PAD
(
SynthDef(\pad_smooth, {
    arg freq = 440, sustain = 1, amp = 0.2; // Amp ridotto per renderlo più morbido
    var env, osc, padSound;

    // Envelope con attacco più lento
    env = EnvGen.kr(Env.perc(0.1, sustain), doneAction: 2); // Attacco più lento

    // Oscillatori con una sinusoide e una forma d'onda quadrata
    osc = Mix.ar([
        SinOsc.ar(freq * [1, 1.005], 0.2),
        Pulse.ar(freq * [0.5, 0.501], 0.15, 0.5) // Larghezza di banda regolabile (0.5)
    ]);

    // Applicazione dell'envelope
    padSound = osc * env * amp;

    // Applicazione di un riverbero con una frequenza di riverbero più bassa
    padSound = padSound * FreeVerb.ar(padSound, 0.1); // Frequenza del riverbero ridotta

    Out.ar(0, padSound);
}).add;
)

//TERZO PAD
(
SynthDef(\smooth_pad, {
    arg freq = 440, sustain = 1, amp = 0.4;
    var env, osc, filteredSound;

    // Envelope con attacco e rilascio personalizzati
    env = EnvGen.kr(Env.perc(0.1, sustain, curve: \lin, releaseNode: [0.9, 2]), doneAction: 2);

    // Oscillatore sinusoidale
    osc = SinOsc.ar(freq, 0, amp);

    // Filtro passa-basso per arrotondare il suono
    filteredSound = LPF.ar(osc, freq * 2);

    // Applicazione dell'envelope
    filteredSound = filteredSound * env;

    Out.ar(0, filteredSound);
}).add;
)

(
~playSound = { arg freq;
    Synth(\pad_smooth, [\freq, freq, \amp, 0.2, \sustain, 1]);
};

OSCdef('OSCreceiver', { arg msg;
	var array = msg.copyRange(2, msg.size-3).asArray; //prendo array delle note della melodia
	var tonalità = msg[1]; //prendo primo elemnto che setta la tonalità
	var baseFreq = 261.63; //frequenza di base (C4)
	var freqMultiplier = 2 ** (1 / 12); //moltiplicatore di frequenza per semitono

	var playRoutine = Routine({
		var dur = msg[msg.size-1] / msg[msg.size-2]; //calcola durata delle note
		array.do { arg noteIndex;
			var freq = baseFreq * (freqMultiplier ** tonalità) * (freqMultiplier ** noteIndex); //frequenza della nota calcolata
			~playSound.value(freq, dur); //riproduci il suono con la frequenza calcolata
			dur.wait; //attendere la durata delle note
		}
	});

	playRoutine.play;
}, "/pad");
)

//SE NON FUNZIONA IL SAMPLE RATE USARE:
s.options.sampleRate = 48000;

//---------------------------------------------------------------------
//
//                     DRUM MACHINE
//
//---------------------------------------------------------------------

(
SynthDef(\kick1, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(800, 400, 0.01)) * Env.perc(0.0005, 0.01).ar);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), XLine.ar(800, 100, 0.01), 0.6) * Env.perc(0.001, 0.02).delay(0.001).ar);
    snd = snd + (SinOsc.ar(XLine.ar(172, 50, 0.01)) * Env.perc(0.0001, 0.3, 1, \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick1, [amp: 0.8]);

(
SynthDef(\kick2, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1320) * Env.perc(0.003, 0.03).ar * 0.5);
    snd = snd + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(167, 52, 0.04)) * Env.perc(0.0005, 0.3).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick2, [amp: 0.8]);

(
SynthDef(\kick3, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
    snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(472, 60, 0.045)) * Env.perc(0.0001, 0.3, curve: \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick3, [amp: 0.8]);

/*
contributors so far: nathan ho

i use Hasher.ar(Sweep.ar) as a quick way to generate deterministic white noise, so i can get exactly the same kick each time for a precise digital sampler effect. you are free to replace it with WhiteNoise.ar.

the DC.ar(0) does nothing, it's just so i can reorder all the "snd = snd +" lines and/or comment out parts of the synth.

some of the attacks are so fast that Env:kr doesn't correctly handle them. that's why i always use Env:ar, so i don't have to think about ar/kr when i'm messing with sharp envelope attacks. i'm sure many of them could be refactored to kr for CPU, but idc
*/

(
SynthDef(\hat, { arg amp = 0.4, startPan = -1, endPan = 1, pitchVariation = 5000, release = 0.1;
  var whiteNoise = WhiteNoise.ar(mul: Env.perc(releaseTime: release, curve: -7).kr(doneAction: 2));
  Out.ar(0, Pan2.ar(BBandPass.ar(whiteNoise, freq: pitchVariation, bw: 1), pos: Line.kr(startPan, endPan, 4)) * amp);
}).add;
)
Synth(\hat);

(
SynthDef(\snare, {

	var drumosc, filterenv, volenv, drumoutput, snaposc, snapenv, fulloutput;

	drumosc = {Pulse.ar(100)};
	filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
	volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};
	drumoutput = {LPF.ar(drumosc,(filterenv *1000) + 30)};

	snaposc = {BPF.ar(HPF.ar(WhiteNoise.ar(1),500),1500)};
	snapenv = {Line.ar(1, 0, 0.2, doneAction: 0)};

	fulloutput = (drumoutput * volenv) + (snaposc * snapenv);
	//fulloutput = (drumoutput * volenv);
	Out.ar(0,
		Pan2.ar(fulloutput, 0)
	)
}).add;
)
Synth(\snare);


(
OSCdef('kick',{Synth(\kick1, [amp: 0.7])},"/kick");
OSCdef('hat',{Synth(\hat)},"/hat");
OSCdef('snare',{Synth(\snare)},"/snare");
OSCdef('collision',{Synth(\kick3)},"/collision");
)