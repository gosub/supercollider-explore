(
SynthDef(\click, {
	var snd;
	snd = Impulse.ar(0);
	snd = LPF.ar(snd, freq: Rand(500, 10000));
	DetectSilence.ar(snd, doneAction: Done.freeSelf);
	snd = Pan2.ar(snd, pos: Rand(-1, 1));
	Out.ar(0, snd);
}).add;

SynthDef(\hightone, {
	var snd;
	snd = SinOsc.ar(10000);
	snd = snd * EnvGen.ar(Env([0,1,1,0], [0.001, 0.010, 0.010]), doneAction: Done.freeSelf);
	Out.ar(0, snd!2);
}).add;

)

a = Pbind(\instrument, \click, \dur, 0.1).play;
a.stop;

(
b = Pbind(
	\instrument, \hightone,
	\dur, Pseq(0.1 * [1,1,1,Rest(1),1,1,Rest(1),Rest(1),1,1,1,Rest(1),Rest(1),1,1,Rest(1)], inf)
).play;
)
b.stop;

z = Synth(\hightone);