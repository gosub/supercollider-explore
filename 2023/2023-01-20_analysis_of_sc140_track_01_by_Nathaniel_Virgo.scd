// sc-140 track #01 - Nathaniel Virgo
// original code

{LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play

// rewritten for readability

(
{
    var signal, feedback, source, filter_freq;
    source = Saw.ar([32, 33], 0.2);
    feedback = LocalIn.ar(2) * 7.5;
    signal = source + feedback;
    filter_freq = 2 ** LFNoise0.kr(4/3, mul: 4) * 300;
    signal = BPF.ar(signal, filter_freq, rq: 0.1).distort;
    signal = CombN.ar(signal, maxdelaytime: 2, delaytime: 2, decaytime: 40);
    LocalOut.ar(signal);
    signal;
}.play
)

// analysis

/*

There are two sources:
  - a low frequency Saw oscillator, with frequencies of 32 Hz on left channel and 33 Hz on the right
  - the return of the feedback signal

these two signal are summed and fed to a BandPass filter the output of the
BandPass filter is distorted and then fed to a Comb filter the output of the
comb filter is both the send of the feedback signal and the final output

the frequency of the BandPass filter is modulated by a LFNoise0 ugen. This is a
staircase signal that changes with a frequency of 4/3 (i.e. every 3/4 of a
second). The LFNoise0 signal has an amplitude between -4 and +4 (given by the
mult parameter) and is the manipulated to obtain a range of audible
frequencies. The manipulation is the following:

- noise = random staircase source, range: -4, +4
- pow = 2^noise, range: 16, 1/16
- freq = pow*300, range: 4800, 18.75

Note that when using the noise as an exponent, the initial linear distribution
of values is transformed to an exponential one, mirroring the exponential
perception of pitch.

There is a subtle balance in place here, some elements reinforce the sound,
while others dump and soften it. For example, the feedback return (LocalIn) is
multiplied by 7.5 to amplify it. The Rq parameter of the BandPass filter is
small, so that only a narrow band of frequencies are allowed to pass, but then
the signal is immediately distorted, to add harmonics. The Comb filter has a
long tail (40 seconds) to add a pad under the sound, enhanced by feeding it the
feedback loop. A non-smooth noise is used to change the BandPass filter
frequency, creating abrupt changes that introduce clicks and pops. These clicks
and pops act like percussive elements, but the harsher frequencies are filtered
by the sequent Comb filter. The choice of delay time for the Comb filter and
frequencies of the LFNoise0 are related but not exact multiples, creating some
reinforcement by resonance.

*/

// signal path graph

/*

https://dreampuf.github.io/GraphvizOnline/#digraph%20sc140track01%20%7B%0A%0A%20%20node%20%5Bshape%3Drect%2C%20fontname%3D%22Sans%22%2C%20fontsize%3D10%5D%3B%0A%20%20edge%20%5Bfontsize%3D9%5D%3B%0A%0A%20%20%22Saw.ar%22%3As%20-%3E%20%22%2B%22%3Anw%3B%0A%20%20BPF%20%5Bshape%3Drecord%2Clabel%3D%22%7BBPF.ar%7C%3Cfreq%3E%20freq%7D%22%5D%0A%20%20%22%2B%22%3As%20-%3E%20BPF%3An%3B%0A%20%20%22LFNoise0.kr%22%3As%20-%3E%20BPF%3Afreq%3Aw%20%5Barrowhead%3Ddot%5D%3B%0A%20%20BPF%3As%20-%3E%20%22CombN.ar%22%3An%3B%0A%20%20%22CombN.ar%22%3As%20-%3E%20%22%2B%22%3Ane%20%5Blabel%3D%22feedback%22%5D%3B%0A%20%20%22CombN.ar%22%3As%20-%3E%20out%3An%3B%0A%0A%20%20out%20%5Bshape%3DMsquare%5D%3B%0A%20%20%22%2B%22%20%5Bshape%3Dinvtriangle%5D%3B%0A%7D

digraph sc140track01 {

  node [shape=rect, fontname="Sans", fontsize=10];
  edge [fontsize=9];

  "Saw.ar":s -> "+":nw;
  BPF [shape=record,label="{BPF.ar|<freq> freq}"]
  "+":s -> BPF:n;
  "LFNoise0.kr":s -> BPF:freq:w [arrowhead=dot];
  BPF:s -> "CombN.ar":n;
  "CombN.ar":s -> "+":ne [label="feedback"];
  "CombN.ar":s -> out:n;

  out [shape=Msquare];
  "+" [shape=invtriangle];
}

*/

// interesting modifications

/*

- substite the Saw ugen with another harmonically rich oscillator, e.g. Pulse
- change the source starting frequencies, e.g. [320, 67]
- change the LFNoise0 frequency modulator with a smooth one, e.g. LFNoise1
- change the frequency of LFNoise0 modulator, e.g. 4/3 -> 5
- increase or decrease the rq parameter of the BPF, e.g. 0.5 or 0.001
- change the BP filter to a different filter type, e.g. LPF or HPF
- reduce the delay and decay times in CombB, e.g. delaytime:0.2, decaytime: 0.4

*/

// variation

(
{
    var signal, feedback, source, filter_freq;
    source = Pulse.ar([32, 33], 0.2);
    feedback = LocalIn.ar(2) * 7.5;
    signal = source + feedback;
    filter_freq = 2 ** LFNoise0.kr(5, mul: 4) * 300;
    signal = BPF.ar(signal, filter_freq, rq: 0.5).distort;
    signal = CombN.ar(signal, maxdelaytime: 0.2, delaytime: 0.2, decaytime: 0.4);
    LocalOut.ar(signal);
    signal;
}.play
)