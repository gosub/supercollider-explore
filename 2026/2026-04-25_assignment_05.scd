// Assignment 5 - 2026-04-25


/*
	Assignment 5: The Fade and the Title
	
	Two tasks, both short.

	First: the fade out over 16 seconds feels abrupt for a piece with this much
	space. Redesign the ending. It can be longer, it can be a third state, it
	can be silence entering the room gradually. Your call — but make it a
	decision, not a default.

	Second: give the piece a title. Not a good title, not a final title — just a
	working title that comes from the images you've been using. Mountain path,
	dark clouds, meadow, north and south, thunder, wind. Something in there is
	the title. Write it down before Assignment 6, because Assignment 6 will ask
	you to make compositional decisions in service of that title. The title
	becomes a constraint.
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

~noise = {
	var sig, env;
    sig = LFNoise0.ar(100);
    sig = FreeVerb2.ar(sig, sig, mix: 0.6, room: 0.7, damp: 0.2);
	sig = LPF.ar(sig, 1300);
    sig = sig.distort;
	sig;
};
)

(
fork {
	"droneA".postln;
	Ndef(\drone).fadeTime = 16;
	Ndef(\drone, ~droneA).play;
	(4*60).wait;

	"droneB".postln;
	Ndef(\drone).fadeTime = 4;
	Ndef(\drone, ~droneB).play;
	(2*60).wait;


	"droneA".postln;
	Ndef(\drone).fadeTime = 1;
	Ndef(\drone, ~droneA).play;
	(1*60).wait;

	Ndef(\drone).fadeTime = 30;
	"noise".postln;
	Ndef(\drone, ~noise).play;
	(2*60).wait;

	"stop".postln;
	Ndef(\drone).clear(0.3);
};
)

/*
I've opted for ending the piece with a long fade to pure low-rumbling noise, to
add to the general theme of uneasyness in the composition. Then an abrupt
ending, like something catastrophical has happened.

With the title I want convey two things:

- an open setting, with no cover and no familiar structures. A meadow, for
  example.

- witnessing something grandiose happening, at scale much above
  humans. Something Lovecraftian.

My title is: open field gigantomachy
*/