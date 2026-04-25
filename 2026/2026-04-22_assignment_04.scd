// Assignment 4 - 2026-04-22


/*
	Assignment 4: Inside the State

	DroneB doesn't hold attention. Your job is to fix that — not by replacing
	it, but by giving it internal movement. Something must change within the state
	over time, without you touching anything.  One tool: Env with EnvGen. A slow
	envelope that moves a parameter from one value to another over the duration of
	the state.  For example, a filter that opens slowly over 90 seconds:

	EnvGen.kr(Env([200, 3000], [90], \exp))

	Put that where a fixed LPF cutoff value would go. Now droneB has a direction
	— it goes somewhere.

	Your assignment: give droneB exactly one internal movement. One parameter,
	one slow envelope. It should take most or all of the 2 minutes to
	complete. The movement should feel inevitable in retrospect, not noticeable
	while it's happening.  Report: what did you move, and did it change whether
	you wanted to stay in that state longer?
*/

(
~droneA = {
    var sig;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 80.0);
        Saw.ar(
            freq * LFNoise2.kr(rrand(0.01, 0.1)).range(0.98, 1.02)
        ) * 0.08
    }));
	sig = PitchShift.ar(sig, 0.1, LFNoise2.kr(0.5).range(0,4));
    sig = FreeVerb2.ar(sig, sig, mix: 0.8, room: 0.99, damp: 0.1);
    sig = LPF.ar(sig, LFNoise2.kr(0.05).range(200, 2000));
    sig.distort
};

~droneB = {
	var sig, env;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 120.0);
        Pulse.ar(
            freq * LFNoise2.kr(rrand(0.005, 0.05)).range(0.98, 1.02),
			0.5 * LFNoise2.kr(rrand(0.005, 0.05)).range(0.98, 1.02)
        ) * 0.08
    }));
    sig = FreeVerb2.ar(sig, sig, mix: 0.6, room: 0.7, damp: 0.2);
	env = EnvGen.kr(Env([0.3, 3], [90], \exp));
	sig = PitchShift.ar(sig, 0.1, env, 0.01, 0.01);
	sig = LPF.ar(sig, LFNoise2.kr(0.3).exprange(200, 2000));
    sig = sig + FreeVerb2.ar(sig[0], sig[1], mix: 0.6, room: 0.7, damp: 0.2);
    sig = sig.distort;
	sig;
};
)

(
fork {
	Ndef(\drone).fadeTime = 16;
	
	"droneA".postln;
	Ndef(\drone, ~droneA).play;
	(4*60).wait;
	Ndef(\drone).fadeTime = 4;

	"droneB".postln;
	Ndef(\drone, ~droneB).play;
	(2*60).wait;
	Ndef(\drone).fadeTime = 1;

	"droneA".postln;
	Ndef(\drone, ~droneA).play;
	(1*60).wait;
	Ndef(\drone).fadeTime = 16;

	"fade".postln;
	Ndef(\drone).clear(16);
};
)

/*
	I've moved the pitchshift range with the envelope, ascending from 0.3x to 3x
	in 90secs. droneB now feels is like an ascension path, not linear thanks to
	the LPF modulation, but still with a direction. It feels good to reach the
	final value, and having some time to breath, before going back to the
	darkness of droneA. I was imagining a mountain path, not too difficult,
	reaching a plateau and seeing the sun shining between the dark clouds. The
	timing felt right.
*/