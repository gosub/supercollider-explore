// Assignment 3 - 2026-04-20


/*
Assignment 3: Time and Attention

You have a world with two weathers. Now give it a duration.  The assignment:
make a performance decision. Write down, before you sit down to play it, a
simple score. Something like:

	A — 4 minutes
	transition
	B — 3 minutes
	transition
	A — 2 minutes

Then execute it. Use a clock or your phone. Sit with each state for the full
duration before switching. Don't touch parameters while it's running — just
listen.  Record the whole thing with s.record. Don't listen back
immediately. Wait at least an hour.

Then report: did the durations feel right, or did you want more or less time in
each state? What happened in the silences inside each state — the moments where
nothing changed?
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
	var sig;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 120.0);
        Pulse.ar(
            freq * LFNoise2.kr(rrand(0.005, 0.05)).range(0.98, 1.02),
			0.5 * LFNoise2.kr(rrand(0.005, 0.05)).range(0.98, 1.02)
        ) * 0.08
    }));
    sig = FreeVerb2.ar(sig, sig, mix: 0.6, room: 0.7, damp: 0.2);
	sig = PitchShift.ar(sig, 0.1, LFNoise2.kr(0.07).range(0.5,2), 0.01, 0.01);
    sig = LPF.ar(sig, LFNoise2.kr(0.02).range(200, 2000));
    sig = sig.distort;
    sig = FreeVerb2.ar(sig[0], sig[1], mix: 0.6, room: 0.7, damp: 0.2);
	sig;
};
)

/*
I've decided for an increasing amount of minutes, but decreasing transition
times.

	1 min of A
	transition 4sec
	2 min of B
	transition 1sec
	4 min of A
	transition 16sec
	fade
*/

(
fork {
	Ndef(\drone).fadeTime = 16;
	
	"droneA".postln;
	Ndef(\drone, ~droneA).play;
	(1*60).wait;
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
did the durations feel right?
	- it is not easy to say, it seems to miss a narrative, a structure
	
did you want more or less time in each state?
	- droneB was not keeping my interest, so I wanted less time for that,
	  while droneA seemed right

What happened in the silences inside each state, the moments where nothing changed?
    - It gave a sense of suspension, made me wait for next "event"
*/