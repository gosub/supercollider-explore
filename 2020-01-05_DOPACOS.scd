// patch name: DOPACOS
// patch date: 2020-01-05
// patch desc: st-st-stutter effect, with variable time
// patch prev: REBEVALLA

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
// the effect is engaged, vertical cursor position set the
// stutter time
{
    var switch, dry_mix; // external input
    var sig, delayed_switch, input, out, feedback, glitch, time;
    dry_mix = 0;
    time = MouseY.kr.exprange(0.1, 1.237);
    sig = ~string.(100) + ~string.(150) + ~string.(200);
    switch = MouseX.kr > 0.5;
    feedback = LocalIn.ar;
    // the switch that selects the input is delayed to prevent
    // glitches when the delay time is changed.
    // first the delay time is changed, then feedback input is switched in
    delayed_switch = DelayN.ar(switch, delaytime:0.002);
    input = SelectX.ar(delayed_switch, [sig, feedback]);
    glitch = DelayC.ar(input, 1, Latch.ar(time, switch));
    LocalOut.ar([glitch]);
    out = (glitch*switch);
    out = out + Select.ar(dry_mix, [sig*(switch.not), sig]);
    out!2;
}.play;
)
