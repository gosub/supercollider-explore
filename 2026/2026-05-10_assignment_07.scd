// Assignment 7 - 2026-05-10


/*
Assignment 7: The Complete Piece

You are close to a finished first piece. The assignment is to render it — a
single take, recorded cleanly, beginning to end.

Before you hit record, write the final score as a comment in the code. Every
state, every transition time, every duration. Commit to it. Then run it
without intervening.

After: listen back on headphones, full volume, in the dark. No screens. Then
answer one question: is there anything that breaks the world of the title —
any moment where you leave "open field gigantomachy" and end up somewhere
else?

That answer becomes the brief for the next piece, not a fix for this
one. This piece is done when you record it.
*/

(
~droneA = {
    var sig, filt_open_env;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 80.0);
        Saw.ar(
            freq * LFNoise2.kr(rrand(0.01, 0.1)).range(0.98, 1.02)
        ) * 0.08
    }));
	sig = PitchShift.ar(sig, 0.1, LFNoise2.kr(0.5).range(0,4));
    sig = FreeVerb2.ar(sig, sig, mix: 0.4, room: 0.99, damp: 0.1);
	filt_open_env = XLine.ar(200, 4000, 60);
    sig = LPF.ar(sig, LFNoise2.kr(0.05).range(200, filt_open_env)*2);
    sig = sig * 18.dbamp;
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
    sig = sig * 18.dbamp;
    sig = sig.distort;
	sig;
};

~noise = {
	var sig, env;
    sig = LFNoise0.ar(100) + (GrayNoise.ar() * 0.3);
    sig = FreeVerb2.ar(sig, sig, mix: 0.3, room: 0.7, damp: 0.5);
	sig = LPF.ar(sig, [1300,1200]);
    sig = sig * 6.dbamp;
    sig = sig.distort;
	sig;
};
)


(
~tunit = 60;
~tatk = ~tunit;
~tturn = 0.7;

fork {
	"droneA".postln;
	Ndef(\drone).fadeTime = ~tatk;
	Ndef(\drone, ~droneA).play;
	(4*~tunit).wait;

	"droneB".postln;
	Ndef(\drone).fadeTime = ~tturn;
	Ndef(\drone, ~droneB).play;
	(2*~tunit).wait;

	"droneA".postln;
	Ndef(\drone).fadeTime = ~tturn;
	Ndef(\drone, ~droneA).play;
	(1*~tunit).wait;

	Ndef(\drone).fadeTime = ~tunit/2;
	"noise".postln;
	Ndef(\drone, ~noise).play;
	(1*~tunit).wait;

	"stop".postln;
	Ndef(\drone).clear(0.3);
};
)

/*
	The score:

	- drone A, fade-in 1 minute, duration 4 minutes
	- drone B, transition 0.7 seconds, duration 2 minutes
	- drone A, transition 0.7 seconds, duration 1 minute
	- noise, transition 30 seconds, duration 1 minute
	- abrupt ending, 0.3 seconds fade-out

	After listen analysis:

	- The first part, despite its movement, lacks any real events. In those four
	minutes, something has to happen: the giant must split a forest or destroy a
	mountain.

	- The transitions between drones are appropriate in length, but not in
	form. In the field there are two giants. When I focus on one, the other
	cannot disappear into thin air, unless something happens in between that
	explains why he's no longer there.
*/
