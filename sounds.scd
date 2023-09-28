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

Synth(\kick1, [amp: 0.8, pitch: 800]);

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
SynthDef(\hat, { arg amp = 1, startPan = -1, endPan = 1, pitch = 10000, release = 0.1;
  var whiteNoise = WhiteNoise.ar(mul: Env.perc(releaseTime: release, curve: -7).kr(doneAction: 2));
  Out.ar(0, Pan2.ar(BBandPass.ar(whiteNoise, freq: pitch, bw: 1), pos: Line.kr(startPan, endPan, 4)) * amp);
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

//---------------------------------------------------------------------
//
//                     OSC MANAGEMENT
//
//---------------------------------------------------------------------
(
OSCdef('kick',{arg msg; Synth(\kick1, [pitch: msg[1]]);}, "/kick");
OSCdef('hat', {arg msg; Synth(\hat,   [pitch: msg[1]]);}, "/hat");
OSCdef('snare',{Synth(\snare)},"/snare");
OSCdef('collision',{Synth(\kick3)},"/collision");
OSCdef('melody',{arg msg; var freq = msg[0]; var count = msg[1]; Synth(\melody, [freq: freq[count]])},"/melody");
OSCdef('modifier', {arg msg; Synth(\melody, [release: msg[0]], [tremoloFreq: msg[1]], [tremoloDepth: msg[2]], [amp: msg[3]])}, "/modifier");
)

//release: varia da 0.1 a 1
//tremoloFreq: varia da 2 a 20
//tremoloDepth: varia da 0.5 a 1
//amp: random tra 0.1 a 1