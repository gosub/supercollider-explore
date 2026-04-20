// Assignment 2 - 2026-04-19


/*
Assignment 2: Contrast and Section

Start from the patch as you left it after your three changes. That's your
base. Reconstruct it from memory or notes, incorporating all three
modifications: Saw oscillators, distortion, PitchShift with the LFNoise2 ratio.

You used the word contrast for the PitchShift patch. That's the seed of
structure — not a timeline, not a song, but the idea that a piece can have more
than one state.  Your assignment: build two distinct states from the same base
patch. Call them A and B in your head. A is one texture, B is a different
one. They should feel like the same world but different weathers within it. Your
thunder/wind observation from change 3 is already almost there — that's your
model.  The constraint: no sequencer, no patterns, no scheduling yet. Switch
between them manually by evaluating different blocks. The transition doesn't
need to be smooth. A hard cut is fine — sometimes it's the right answer.

One technical hint that will help: use Ndef instead of raw .play. It lets you
redefine a running synth without stopping it, which makes switching states much
more fluid.

  Ndef(\drone, { ... your state A ... }).play;

later, evaluate this to crossfade into state B:

  Ndef(\drone, { ... your state B ... });

The crossfade happens automatically. Default is 4 seconds. You can set it with:

  Ndef(\drone).fadeTime = 8.

Report back with: what are your two states, in perceptual language. And whether
the transition between them tells you anything.
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

Ndef(\drone).play;
Ndef(\drone, ~droneB);
Ndef(\drone, ~droneA);
Ndef(\drone).fadeTime = 1;
Ndef(\drone).scope

/*

	The original drone is more menacing, it's closer, is incumbent like a dark
	cloud bringing a storm.

	The second drone is more distant, more windy, slower and not so scary. It's
	aerial and glassy, like its something ethereal not properly grounded to
	reality.

	I opted for a 1 second fadeTime, it feels like being in a meadow and turning
    one's head from north (drone1) to south (drone2). Neither are clear skyies,
    both bringing something uneasy.

*/