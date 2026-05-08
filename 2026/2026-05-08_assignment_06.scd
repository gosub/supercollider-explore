// Assignment 6 - 2026-05-08


/*
Assignment 6: Serve the Title
	
You have a title that is now a constraint. Every decision from here is
answerable to "open field gigantomachy" — does this serve that, or does it
distract from it?

Three questions to answer through listening, not thinking:
	
One: does droneA feel like an open field? Or does it feel like something already
enclosed, already underground? If it's too interior, find one change that opens
the space — wider stereo, longer reverb tail, higher frequency content in the
LPF ceiling.

Two: the transition from droneB back to droneA has a 1 second fade. A 1 second
cut back into darkness after the mountain plateau — is that the right violence,
or does it need more or less time? Re-examine it with the title in mind.

Three: the piece currently starts immediately. Should it? A
gigantomachy witnessed from an open field might begin with silence — with the
field itself, before anything arrives. Consider whether the piece needs 30 to 60
seconds of near-silence before droneA enters. Not fade-in: the drone appearing
out of stillness.

Report back with what you changed and what you left alone, and why.
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
1) I modified Drone A with the idea of ​​an open field. I reduced the reverb
   (there are no walls reflecting in an open field) and opened the filter, with
   an exponential envelope, giving the impression of something approaching. I
   also increased the drone's volume so that the peak reached distortion, giving
   the "noise too loud for your eardrums" effect. Some of these changes were
   also applied to Drone B and the final noise.

2) I shortened the transition between the drones to 0.7 seconds, which I
   consider to be the speed at which a frightened person turns their head from
   side to side to see what's coming from the other side.

3) I lengthened the fade time towards the opening, but didn't make it brutal. I
   wanted to add a fade-in instead of a linear one with discrete steps, like a
   giant taking huge, slow steps, but I couldn't find the right Env :(
*/