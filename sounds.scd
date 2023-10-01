NetAddr("127.0.0.1", 57120);


//---------------------------------------------------------------------
//
//                     MELODY CHAT
//
//---------------------------------------------------------------------

(
SynthDef(\melody, {
    arg freq = 440, amp = 1, tremoloFreq = 0, tremoloDepth = 0, release = 1;
    var triangle, env, mod, sig, tremolo, source, freqOctaveHigher, sigOctaveHigher;

    tremolo = SinOsc.kr(tremoloFreq).range(1 - tremoloDepth, 1 + tremoloDepth);
    triangle = LFTri.ar(freq);
    source = SinOsc.ar(freq);
    env = EnvGen.kr(Env.perc(0.01, release), doneAction: 2);
    mod = SinOsc.kr(0.2).range(0.1, 2);
    sig = amp * triangle * env * mod * tremolo * source;
    freqOctaveHigher = freq*2 ;
    sigOctaveHigher = amp * triangle * env * mod * tremolo * SinOsc.ar(freqOctaveHigher);
    sig = sig + sigOctaveHigher;
    Out.ar(0, sig ! 2);
}).add;
)

Synth(\melody, [freq: 220, amp: 1, tremoloFreq: 10, tremoloDepth: 0.5, release: 0.5]);

(
~reassignMod = {
	~counter = 0;

	~amp = 0.5;
	~release = 2;
	~tremoloFreq = 8;
	~tremoloDepth = 0.5;
    };
)
(
~playSound = { var release, amp, tremoloFreq, tremoloDepth;
	Synth(\melody, [\freq, ~arrayFreq[~counter], \release, ~release, \amp, ~amp, \tremoloFreq, ~tremoloFreq, \tremoloDepth, ~tremoloDepth]);
	//~counter.postln;
	~counter = ~counter + 1;
	if(~counter == ~arrayFreq.size, {~counter = 0;})
};
)

//---------------------------------------------------------------------
//
//                     DRUM MACHINE
//
//---------------------------------------------------------------------

(
SynthDef(\kick1, { arg pitch = 800;
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(pitch, 400, 0.01)) * Env.perc(0.0005, 0.01).ar);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), XLine.ar(800, 100, 0.01), 0.6) * Env.perc(0.001, 0.02).delay(0.001).ar);
    snd = snd + (SinOsc.ar(XLine.ar(172, 50, 0.01)) * Env.perc(0.0001, 0.3, 1, \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), 1));
}).add;
)

Synth(\kick1, [amp: 0.8, pitch: 4000]);

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

(
SynthDef(\hat, { arg amp = 1, startPan = -1, endPan = 1, pitch = 10000, release = 0.1;
  var whiteNoise = WhiteNoise.ar(mul: Env.perc(releaseTime: release, curve: -7).kr(doneAction: 2));
  Out.ar(0, Pan2.ar(BBandPass.ar(whiteNoise, freq: pitch, bw: 1), pos: Line.kr(startPan, endPan, 4)) * amp);
}).add;
)
Synth(\hat, [amp: 1, pitch: 1000]);

(
SynthDef(\snare, { arg pitch;

	var drumosc, filterenv, volenv, drumoutput, snaposc, snapenv, fulloutput;

	drumosc = {Pulse.ar(pitch)};
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
Synth(\snare, [amp: 1, pitch: 15]);

//---------------------------------------------------------------------
//
//                     OSC MANAGEMENT
//
//---------------------------------------------------------------------

(
OSCdef('playTrigger', {~playSound.value;}, "/playStep");
OSCdef('pixel',{arg msg; Synth(\melody, [\freq, msg[1], \release, ~release, \amp, ~amp, \tremoloFreq, ~tremoloFreq, \tremoloDepth, ~tremoloDepth]);}, "/notePixel");
OSCdef('kick',{arg msg; Synth(\kick1, [pitch: msg[1]]);}, "/kick");
OSCdef('hat', {arg msg; Synth(\hat,   [pitch: msg[1]]);}, "/hat");
OSCdef('snare', {arg msg; Synth(\snare,   [pitch: msg[1]]);}, "/snare");
OSCdef('collision',{Synth(\kick3)},"/collision");
OSCdef('melody',{arg msg; ~arrayFreq = Array.newClear(msg.size-1);
	// Reassign melody modifiers values
	~reassignMod.value;
	// Fill array
	(msg.size-1).do({arg i; ~arrayFreq.put(i, msg[i+1]); });
	// Print array
	~arrayFreq.postln;
},"/melody");
OSCdef('modifier', {arg msg;
	~release = msg[0];
	~tremoloFreq= msg[1];
	~tremoloDepth = msg[2];
	~amp = msg[3];
}, "/modifier");
)


//release: varia da 0.1 a 1
//tremoloFreq: varia da 2 a 20
//tremoloDepth: varia da 0.5 a 1
//amp: random tra 0.1 a 1
