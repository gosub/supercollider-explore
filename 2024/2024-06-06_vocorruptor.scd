(
b = Buffer.read(s, "/home/gg//dl/audio/samples/il_popolo_celebra.wav");
)

{PlayBuf.ar(1, b, BufRateScale.kr(b))!2}.play;

(
SynthDef(\vocorruptor, {
	|out|
	var snd;
	snd = CombL.ar(WhiteNoise.ar);
	Out.ar(out, snd);
}).add;
)

Synth(\vocorruptor);