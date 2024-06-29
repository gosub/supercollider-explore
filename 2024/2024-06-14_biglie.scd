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

// create a new list of pbinds
q = List.new;

// add a pbind to the list and play it
(
p = Pbind(
	\instrument, \piano,
	\scale, Scale.minor,
	\degree, (-12..12).choose,
	\dur, ((1..10)*0.25).choose,
).play;
q.add(p);
)

// remove and stop a bind from the list
q=q.scramble; q.pop.stop; q;

// stop all the pbinds
q do: _.stop; q.clear;

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
