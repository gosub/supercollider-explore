(
SynthDef(\vocorruptor, {
	|out|
	var snd;
	snd = CombL.ar(WhiteNoise.ar);
	Out.ar(out, snd);
}).add;
)

Synth(\vocorruptor);