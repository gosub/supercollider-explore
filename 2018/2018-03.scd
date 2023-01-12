/*       ----------       */
/******* 2018-03-01 *******/
/*       ----------       */

// explorations on nick collins supercollider tutorial
// section 3.4

// mario money machine
(
{
    var sound,env, trig;
    trig= LFNoise0.ar(LFNoise0.kr(1/3).range(20,80))>0;
    sound= Mix(LFPulse.ar(110*TIRand.ar(1,2,trig)*[1,5/2,TRand.ar(3.9,4.1,trig)],0.0,0.5,0.2));
    env= EnvGen.ar(Env.perc(0.01,0.2),trig);
    Pan2.ar(sound*env,0.0);
}.play;
)

// romanaccio digitale
(
{
    t = Dust.kr(3);
    f = TRand.kr(50, 400, t);
    f = Lag.kr(f, 1);
    BPF.ar(SyncSaw.ar(f, f+400, 0.1), f).dup;
}.play;
)

// Sequencing and event reactive functionality can be constructed with other UGens like Index, IEnvGen, PulseCount, PulseDivider, ToggleFF, SetResetFF, Timer, Schmidt and more
// da testare


/*       ----------       */
/******* 2018-03-06 *******/
/*       ----------       */

// explorations on nick collins supercollider tutorial
// section 4.1

(
// strumming guitar
~open = [ 52, 57, 62, 67, 71, 76 ];
~e_chord = [ 0, 2, 2, 1, 0, 0 ];
~buf = Buffer.loadCollection(s, ~open + ~e_chord);
{
	var out, pennata;
    pennata = Dust.kr(6);
	out = Mix.fill(~open.size, { arg i;
		var pluck, period, string, trigger;
        trigger = PulseDivider.kr(pennata, ~open.size, i.neg);
		pluck = PinkNoise.ar(Decay.kr(trigger, 0.05));
		period = Index.kr(~buf, i).midicps.reciprocal;
		string = CombL.ar(pluck, period, period, 3);
		Pan2.ar(string, i * 0.2 - 0.5);
	});
	LPF.ar(out, 12000);
	LeakDC.ar(out);
}.play;
)

~buf.setn(0, ~open + ~e_chord + 3);


/*       ----------       */
/******* 2018-03-08 *******/
/*       ----------       */

// explorations on nick collins supercollider tutorial
// section 4.1


// pulse train player, with qwerty & asdfgh
(
{
    var timings = [1, 2, 3, 4];
    ~qwerty = (24..29);
    ~asdfgh = (38..43);
    Mix.ar(~qwerty.collect {
        |key, i|
        var toggle = ToggleFF.kr(KeyState.kr(key, lag:0));
        var freq = Select.kr(Stepper.kr(KeyState.kr(key+14),max:timings.size-1), timings);
        var env = LFPulse.ar(freq).lag(0.1);
        toggle * env * SinOsc.ar(110*(i+1),mul: 0.1).dup;
    });
}.play;
)
