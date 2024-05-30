// Sound Simulator's "Ryoji Ikeda Pure Data Tutorial" ported to SC
// source: https://www.youtube.com/watch?v=CLddxGIlVPU
// I only did the porting, kudos to Sound Simulator for the original idea
// and Pure Data implementation!

(
// SynthDefs & helper functions

~coeff = {|freq| exp(-2pi * (freq * SampleDur.ir))};

SynthDef(\click, { |out, amp=0.1|
	var snd;
	snd = Impulse.ar(0);
	snd = OnePole.ar(snd, ~coeff.(Rand(500, 10000)));
	DetectSilence.ar(snd, doneAction: Done.freeSelf);
	snd = snd * amp;
	snd = Pan2.ar(snd, pos: Rand(-1, 1));
	Out.ar(out, snd);
}).add;

SynthDef(\highshort, { |out, amp=0.1|
	var snd;
	snd = SinOsc.ar(10000);
	snd = snd * EnvGen.ar(Env([0,1,1,0], [0.001, 0.010, 0.010]), doneAction: Done.freeSelf);
	snd = snd * amp;
	Out.ar(0, snd!2);
}).add;

SynthDef(\bass, { |out, amp=0.1|
	//TODO: substitute HPF with OnePole+OneZero, but we must calculate the coeffs!
	var snd, noi;
	snd = SinOsc.ar([49, 98, 196]).sum * 2.0;
	snd = Clip.ar(snd, -0.9, 0.9);
	snd = OnePole.ar(snd, ~coeff.(50));
	snd = HPF.ar(snd, 20);
	noi = HPF.ar(OnePole.ar(WhiteNoise.ar, ~coeff.(100)), 500); // HPF = [hip~ 500]*2
	noi = noi * EnvGen.ar(Env.linen(0.010, 0.005, 0.005));
	snd = snd * EnvGen.ar(Env.linen(0.010, 1.090, 0.200), doneAction: Done.freeSelf);
	snd = snd + noi;
	snd = snd * amp;
	Out.ar(out, snd!2);
}).add;

SynthDef(\envsine, { |out, amp=0.1|
	var snd, noi;
	snd = SinOsc.ar(1174);
	snd = snd * EnvGen.ar(Env.linen(0.010, 0.200, 0.500));
	snd = snd;
	snd = FreeVerb2.ar(snd, snd, mix: 0.5, room: 0.7, damp: 0.2);
	snd = snd * amp;
	DetectSilence.ar(snd, doneAction: Done.freeSelf);
	Out.ar(out, snd);
}).add;

SynthDef(\highlong, { |out, amp=0.1|
	var snd;
	snd = SinOsc.ar(12544);
	snd = snd * EnvGen.ar(Env.linen(0.001, 0.400, 0.150), doneAction: Done.freeSelf);
	snd = snd * amp;
	Out.ar(out, snd!2);
}).add;

SynthDef(\midsine, { |out, amp=0.1|
	var snd, env;
	snd = SinOsc.ar(3136);
	snd = Clip.ar(snd, -0.9, 0.9);
	env=Env.linen(0.005, 0.050, 0.010);
	snd = snd * EnvGen.ar(env, doneAction: Done.freeSelf);
	snd = snd * amp;
	Out.ar(out, snd!2);
}).add;

SynthDef(\burst, { |out, amp=0.1|
	var snd;
	snd = WhiteNoise.ar(mul: -7.dbamp);
	snd = snd * EnvGen.ar(Env.linen(0.001, 0.400, 0.010), doneAction: Done.freeSelf);
	snd = snd * amp;
	Out.ar(out, snd!2);
}).add;

~xox = {|str| str.collectAs({|l| switch(l.toLower,$x, {1}, $o, {Rest(1)})}, Array)};
)

(
// sequencing

~p1 = "xxxxxxxxxxxxxxxx"; //click
~p2 = "xxxoxxooxxxooxxo"; //highshort
~p3 = "xooooooooooooooooooxoooooooooooo"; //bass
~p4 = "ooooooxooooooooooooooooooooooooo"; //envsine
~p5 = "oooooooooooooooooooooooooxoooooo"; //highlong
~p6 = "xooooooooooooooooooooooooooooooo"
   ++ "xxoooooooooooooooooooooooooooooo"; //midsine

~p7 = Array.newClear(31).fill(Rest(~tick16)).add(~tick16).scramble; //burst

~tick32 = 0.08823;
~tick16 = ~tick32 * 2;

Pdef(\ikeda, Ppar([
	Pbind(\instrument, \click,     \dur, Pseq(~tick32 * ~xox.(~p1), inf)),
	Pbind(\instrument, \highshort, \dur, Pseq(~tick32 * ~xox.(~p2), inf)),
	Pbind(\instrument, \bass,      \dur, Pseq(~tick16 * ~xox.(~p3), inf)),
	Pbind(\instrument, \envsine,   \dur, Pseq(~tick16 * ~xox.(~p4), inf)),
	Pbind(\instrument, \highlong,  \dur, Pseq(~tick16 * ~xox.(~p5), inf)),
	Pbind(\instrument, \midsine,   \dur, Pseq(~tick32 * ~xox.(~p6), inf)),
	Pbind(\instrument, \burst,     \dur, Pseq(~p7, inf)),
])).play;
)

Pdef(\ikeda).stop;


// test single synths
z = Synth(\click);
y = Synth(\highshort);
x = Synth(\bass);
w = Synth(\envsine);
v = Synth(\highlong);
u = Synth(\midsine);
t = Synth(\burst);
