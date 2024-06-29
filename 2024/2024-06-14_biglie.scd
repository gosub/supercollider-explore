// create a group to add effect to the end of
// the signal chain
~chain = Group.tail(s);

(
SynthDef(\dist_del_verb, {
	|outbuf, inbuf|
	var sig;
	sig = In.ar(inbuf, 2);
	sig = (sig * 10).tanh;
	sig = CombL.ar(sig);
	sig = FreeVerb.ar(sig.tanh, 0.8);
	Out.ar(outbuf, sig);
}).add;
)

// instantiate the effect to the end of the chain
Synth.tail(~chain, \dist_del_verb);

(
SynthDef("piano", {
	var sig;
	sig = MdaPiano.ar(\freq.kr(440),
		stereo: 0.5,
		gate: \gate.kr(1),
		vel: \vel.kr(100),
		mul: \amp.kr(0.5));
	DetectSilence.ar(sig, doneAction: Done.freeSelf);
	Out.ar(\out.kr(0), sig);
}).add;
)

Synth(\piano);

// start a pbind that stops after a random number of notes
// tip: launch a cluster of them together
(
p = Pbind(
	\instrument, [\piano, \default].choose,
	\scale, Scale.minor,
	\degree, (-12..12).choose,
	\vel, (80..111).choose,
	\dur, [1/4, 1/3, 1/2, 1, 3/2, 2].choose.postln,
	\dummy, Pseq([1], [1,2,4,8,16,32,64].choose.postln),
).play(quant: 1/2);
)
(
x = {
    s = MdaPiano.ar(
        (30,32..60).scramble.keep(5).midicps,
        stereo: 0.5,
        gate: LFPulse.kr((1..5).reciprocal.scramble),
        vel: LFNoise0.kr(0.1!5).range(80, 100), // varying velocity
        mul: 0.8
    ).sum;
	FreeVerb.ar(s.tanh, 0.8);
}.play
)

x.free;
