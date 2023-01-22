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

// signal graph

/* TODO */

// interesting modifications

/* TODO */
