// patch name: DANACA
// patch date: 2020-01-06
// patch desc: st-st-stutter effect, inspired by tkog feral glitch
// patch prev: DOPACOS

(
// string simulator copied from http://sccode.org/1-5aC
~string = { |freq|
    var delay, trig, sig, exc;
    delay = freq.reciprocal;
    trig = Impulse.kr(LFPulse.ar(1).range(0, 5));
    exc = SinOsc.ar(Env.perc(0.001, 0.01).range(50, 1000).ar(gate:trig));
    sig = Pluck.ar(exc, trig, 0.2, delay, 5, 0.5);
    sig * 0.1;
    };
)

(
// when mouse cursor goes to the right half of the screen
// the effect is engaged, vertical cursor position set the
// stutter time
{
    var switch, mode_sel, dry_mix, fx_time, volume; // external input
    var sig, freq, delayed_switch, input, out, feedback, glitch, chosen_time;

    switch = MouseX.kr > 0.5;
    mode_sel = 1;
    dry_mix = 0;
    fx_time = MouseY.kr.exprange(0.05, 1.237);
    volume = 1;

    freq = LFPulse.kr(10.reciprocal).range(100, 100*2/3);
    sig = ~string.(freq) + ~string.(freq*1.5) + ~string.(freq*2);

    feedback = LocalIn.ar;
    chosen_time = Select.kr(mode_sel, [fx_time, WhiteNoise.kr.range(0.05, fx_time)]);
    // the switch that selects the input is delayed to prevent
    // glitches when the delay time is changed.
    // first the delay time is changed, then feedback input is switched in
    delayed_switch = DelayN.ar(switch, delaytime:0.002);
    input = SelectX.ar(delayed_switch, [sig, feedback]);
    glitch = DelayC.ar(input, 1, Latch.ar(chosen_time, switch));
    LocalOut.ar([glitch]);
    out = (glitch*switch) * volume;
    out = out + Select.ar(dry_mix, [sig*(switch.not), sig]);
    out!2;
}.play;
)
