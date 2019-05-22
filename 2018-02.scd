/*       ----------       */
/******* 2018-02-08 *******/
/*       ----------       */

// SpaceDrone remake

// parameters:
// pan, rnd, offset, fundamental, pitch, speed, amt, res,
// density, dynamic, attack, decay, damp, gain

(
{
    arg atk=1, rel = 1, density = 0.5, rnd = 10, pan = 10;
    var sig, env, geiger, panfreq;
    geiger = Dust.ar(density);
    env = EnvGen.ar(Env([0, 1, 0.5, 0], [atk, rel, rel]), geiger);
    sig = WhiteNoise.ar() * env;
    sig = BPF.ar(sig, 440, 1);
    panfreq = LFNoise0.kr(rnd.midicps, rnd.midicps) + pan.midicps;
    Pan2.ar(sig, LFTri.ar(panfreq));
}.play;
)

/*       ----------       */
/******* 2018-02-21 *******/
/*       ----------       */

// SpaceDrone remake

(
~geiger = {  |density, rndrange, dynamic|
    var freq, pulse, trig, rand;
    freq = (density + LocalIn.kr).midicps;
    pulse = Pulse.kr(freq);
    trig = Trig1.kr(pulse);
    LocalOut.kr(TRand.kr(lo: 1+(rndrange/2), hi: 1-(rndrange/2), trig: trig));

    TRand.kr(lo:(dynamic/2).neg, hi:dynamic/2, trig: trig);
}
)

(
{
    ~trig = ~geiger.value(-36, 30, 0.5);
    EnvGen.ar(Env.perc, ~trig) * SinOsc.ar(220);
}.play;
)


(
{
    arg atk=40, rel=40, density = 0.5, rnd = 10, pan = 10;
    var sig, env, geiger, panfreq;

    geiger = Dust.ar(density);
    env = EnvGen.ar(Env([0, 1, 0.5, 0], [atk, rel, rel]), geiger);

    sig = WhiteNoise.ar() * env;
    sig = BPF.ar(sig, 440, 1);
    panfreq = LFNoise0.kr(rnd.midicps, rnd.midicps) + pan.midicps;
    Pan2.ar(sig, LFTri.ar(panfreq));
}.play;
)

// space drone remake is not an exploration
// moved to its own project.
// prj/2018/sc_reaktor/spacedrone.sc



/*       ----------       */
/******* 2018-02-23 *******/
/*       ----------       */

// explorations on nick collins supercollider tutorial
// section 3.4

// interwoven sequences, second sequence speed depends on mouse position
(
{ Saw.ar(Select.kr(Stepper.kr(Impulse.kr(4,0.1),0,0,7,1),[72,63,67,72,55,62,63,60].midicps),0.1) }.play;
{ Saw.ar(Select.kr(Stepper.kr(Impulse.kr(MouseX.kr(1,10).floor,0.1),0,0,7,1),[75,63,67,72,55,62,63,60].midicps),0.1) }.play;
)

// noise patterns
{Latch.ar(SinOsc.ar(110), Impulse.ar(LFNoise0.kr(6,100,200))).dup*0.1}.play;

// drugged jazzist
{SinOsc.ar(300+(200*Latch.ar(Saw.ar(13.3), Impulse.kr(6))))*0.2}.play

// crazy beads
(
{
    var sound,env, trig, sig;
    trig= Impulse.ar(Stepper.kr(Impulse.kr(0.5), 0,1,6)); //trigger source
    sound= Mix(LFPulse.ar(110*[1,5/2],0.0,0.5,0.2));
    env= EnvGen.ar(Env.perc(0.02,0.2),trig); //with retriggering controlled by impulse
    sig = sound*env;
    sig = sig + CombL.ar(sig, 0.333, 1, 10);
    Pan2.ar(sig,0.0);
}.play
)


/*       ----------       */
/******* 2018-02-25 *******/
/*       ----------       */


// stochastic sample player
(
~dir = "/home/gg/downloads/patatap-samples-wav";
~bs = SoundFile.collectIntoBuffers(~dir +/+ "*", s);
s.options.memSize = 32 * 1024;
)

// 4 samples, random rate, random rhythm
({
    Mix.ar(Array.fill(4, {
        var b, rate, rhythm;
        b=~bs.choose.postln;
        rate =  [0.5, 1, 2].choose;
        rhythm = [1/2, 1, 2, 3, 4].choose;
        PlayBuf.ar(2, b, BufRateScale.kr(b) * rate, trigger: Impulse.kr(rhythm));
    }));
}.play;
)

// 4 samples, random rate, random rhythm
// rhythm changes every 'rchange' seconds
({
    var voices;
    voices = 4;
    Mix.ar(Array.fill(voices, {
        var b, rate, rhythms, rhythm, rchange;
        b=~bs.choose.postln;
        rchange = 10;
        rate = [0.5, 1, 2].choose;
        rhythms = [1/2, 1, 2, 3, 4];
        rhythm = Select.kr(LFNoise0.kr(1/10, rhythms.size).round, rhythms);
        PlayBuf.ar(2, b, BufRateScale.kr(b) * rate, trigger: Impulse.kr(rhythm)) / voices;
    }));
}.play;
)

// plays n samples, one after another
({
    var voices = 10;
    var dones = 0, mix;

    mix = Mix.fill(voices, {
        arg voice;
        var buf, sig, delay, trig;
        buf = ~bs.choose;
        delay = 0.1*voice;
        trig = EnvGen.kr(Env.step([0,1], [delay, 1]));
        sig = PlayBuf.ar(buf.numChannels, buf, rate: trig * (buf.sampleRate/s.sampleRate));
        dones = dones + Done.kr(sig[1]);
        sig/voices;
    });
    FreeSelf.kr(dones >= voices);
    mix;
}.play;
)


/*       ----------       */
/******* 2018-02-26 *******/
/*       ----------       */

