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

NetAddr("127.0.0.1", 57120);

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

