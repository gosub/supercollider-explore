// Assignment 1 - 2026-04-18

(
{
    var sig, env;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 80.0);
        SinOsc.ar(
            freq * LFNoise2.kr(rrand(0.01, 0.1)).range(0.98, 1.02)
        ) * 0.08
    }));
    sig = FreeVerb2.ar(sig, sig, mix: 0.8, room: 0.99, damp: 0.1);
    sig = LPF.ar(sig, LFNoise2.kr(0.05).range(200, 2000));
    sig ! 2
}.play
)

/*
Assignment 1
Run the drone I gave you. Listen to it for at least 5 minutes without touching anything.
Then make exactly 3 changes — no more. Each change should be one parameter, one UGen swap, or one addition.
Write down what each change did to the sound, in plain language.
Not technical language: perceptual language. "It got darker." "It started breathing." "It felt further away."
Then come back and tell me what happened.
That's it. No other goal. The output is not a track, not a patch you're proud of — it's three observations.
When you report back I'll give you Assignment 2, which will be based on what you found.
*/

(
{
    var sig, env;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 80.0);
        SinOsc.ar(
            freq * LFNoise2.kr(rrand(0.01, 0.1)).range(0.98, 1.02)
        ) * 0.08
    }));
    sig = FreeVerb2.ar(sig, sig, mix: 0.8, room: 0.99, damp: 0.1);
    sig = LPF.ar(sig, LFNoise2.kr(0.05).range(200, 2000));
    sig.distort ! 2
}.play
)

/*
First change: I've added distort at the end of the signal chain
  - The sound is somewhat brighter, but got more raw, and somehow more menacing
  - Before it was scary, now it is anxious
  - The rhythm perception is different, before it seemed slower, now it seems faster
  - Also, the high pitched clicks are now gone, making it more immersive
*/

(
{
    var sig, env;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 80.0);
        Saw.ar(
            freq * LFNoise2.kr(rrand(0.01, 0.1)).range(0.98, 1.02)
        ) * 0.08
    }));
    sig = FreeVerb2.ar(sig, sig, mix: 0.8, room: 0.99, damp: 0.1);
    sig = LPF.ar(sig, LFNoise2.kr(0.05).range(200, 2000));
    sig ! 2
}.play
)

/*
Second change: I've substituted SinOsc with Saw
  - The sound is much more bright and metallic
  - There is still a dark core, but it seems to be surrounded by high pitch voices
  - It still feel distant, but before it was thumping from below, now it's looming from above
  - It feels more vocal, but not in a recognizable way, and that transmits danger
*/

(
{
    var sig, env;
    sig = Mix(Array.fill(8, {
        var freq = rrand(40.0, 80.0);
        SinOsc.ar(
            freq * LFNoise2.kr(rrand(0.01, 0.1)).range(0.98, 1.02)
        ) * 0.08
    }));
	sig = PitchShift.ar(sig, 0.1, LFNoise2.kr(0.5).range(0,4));
    sig = FreeVerb2.ar(sig, sig, mix: 0.8, room: 0.99, damp: 0.1);
    sig = LPF.ar(sig, LFNoise2.kr(0.05).range(200, 2000));
    sig ! 2
}.play
)

/*
Third change: I've added a PitchShift effect between the Mix and the Freeverb, with a pitchRatio moved
by an LFNoise2.kr(0.5).range(0,4)
  - There is more movement, the sound oscillates randomly between a rumble and something more musical
  - There is more contrast
  - When it's rumbling it remembers me of a thunder
  - When it's higher pitched, it's windy in nature, like something blowing past me
  - There is an inherent instability, it makes me curious of where it's going to go next
*/