(
~xox = {|str| str.collectAs({|l| switch(l.toLower,$x, {1}, $o, {Rest(1)})}, Array)};
)


(
SynthDef(\acid, { arg out, freq = 1000, gate = 1, pan = 1, cut = 4000, rez = 0.8, amp = 1, sustain = 1, release = 0.5;
    var sig, env;
	env = EnvGen.kr(Env.linen(0.01, sustain, sustain * release), gate, amp, doneAction: Done.freeSelf);
	sig = Pulse.ar([freq,freq*1.001], 0.5);
	sig = sig + Pulse.ar(freq*0.501, 0.01, [0,0.5]);
	sig = sig + Pulse.ar(freq*1.99, 0.11, [0.5,0]);
	sig = RLPF.ar(sig, cut, rez);
	sig = Pan2.ar(sig);
	sig = sig * env;

	Out.ar(out, sig);
}).add;
)

(
Pbind(
	\instrument, \acid,
	\dur, Pseq(~xox.("xxooxoxo") * 8/120, inf),
	\scale, Scale.minor,
	\degree, Pseq([0,4,5,3,3], inf),
	\cut, Pwhite(100, 1500),
	\rez, Pwhite(0.1, 0.8),
	\amp, -10.dbamp,
).play;
)

// published at: http://sccode.org/1-5hZ