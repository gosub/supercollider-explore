// patch name: REBEVALLA
// patch date: 2019-12-31
// patch desc: st-st-stutter effect, with fixed time

(
// string simulator copied from http://sccode.org/1-5aC
~string = { |freq|
    var delay, trig, sig, exc;
    delay = freq.reciprocal;
    trig = Impulse.kr(LFPulse.ar(1).range(0, 5));
    exc = SinOsc.ar(Env.perc(0.001, 0.01).range(50, 1000).ar(gate:trig));
    sig = Pluck.ar(exc, trig, delay, delay, 5, 0.5);
    sig * 0.1;
    };
)

(
// when mouse cursor goes to the right half of the screen
// the effect is engaged
{
    var sig, switch, input, out, feedback, glitch, time;
    time = 0.1;
    sig = ~string.(100) + ~string.(150) + ~string.(200);
    switch = MouseX.kr > 0.5;
    feedback = LocalIn.ar;
    input = SelectX.ar(switch.lag(0.001), [sig, feedback]);
    glitch = DelayC.ar(input, 1, time);
    LocalOut.ar([glitch]);
    out = sig*(switch.not) + (glitch*switch);
    out!2;
}.play;
)