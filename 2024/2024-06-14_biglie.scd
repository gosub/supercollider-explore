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
