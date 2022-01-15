MIDIIn.connectAll;

(
// midi channels of factory templates
~fctry = (8..15);

// cc numbers for knobs and sliders
~knbA = (13..20);
~knbB = (29..36);
~knbC = (49..56);
~sldr = (77..84);
// note numbers for buttons
~btnA = (41..44) ++ (57..60);
~btnB = (73..76) ++ (89..92);
)


(
~def = SynthDef(\lcxl, {
    arg out, car1=55, mod1=55, id1, ph1,
             car2=55, mod2=55, id2, ph2,
             car3=55, mod3=55, id3, ph3,
             car4=55, mod4=55, id4, ph4;

    var sig1 = PMOsc.ar(car1, mod1, id1, LFNoise1.ar(22, mul:2pi) * ph1);
    var sig2 = PMOsc.ar(car2, mod2, id2, LFNoise1.ar(22, mul:2pi) * ph2);
    var sig3 = PMOsc.ar(car3, mod3, id3, LFNoise1.ar(22, mul:2pi) * ph3);
    var sig4 = PMOsc.ar(car4, mod4, id4, LFNoise1.ar(22, mul:2pi) * ph4);
    var sig;

    sig1 = sig1 * EnvGen.ar(Env.circle([0,1], [0.4, 0.01]));
    //var sig = Mix.ar([sig1,sig2,sig3,sig4])/4;
    sig = Mix.ar([sig1])/1;
    Out.ar(out, sig.tanh!2);
}).add;
)

(
~synth = Synth(\lcxl);

MIDIFunc.cc({|val| ~synth.set(\car1, val.linexp(0,127,55,440))}, ~knbA[0], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\mod1, val.linexp(0,127,55,440))}, ~knbA[1], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\id1, val.linlin(0,127,0,2pi))}, ~sldr[0], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\ph1, val.linlin(0,127,0,1))}, ~sldr[1], ~fctry.first);

MIDIFunc.cc({|val| ~synth.set(\car2, val.linexp(0,127,55,440))}, ~knbA[2], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\mod2, val.linexp(0,127,55,440))}, ~knbA[3], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\id2, val.linlin(0,127,0,2pi))}, ~sldr[2], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\ph2, val.linlin(0,127,0,1))}, ~sldr[3], ~fctry.first);

MIDIFunc.cc({|val| ~synth.set(\car3, val.linexp(0,127,55,440))}, ~knbA[4], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\mod3, val.linexp(0,127,55,440))}, ~knbA[5], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\id3, val.linlin(0,127,0,2pi))}, ~sldr[4], ~fctry.first);
MIDIFunc.cc({|val| ~synth.set(\ph3, val.linlin(0,127,0,1))}, ~sldr[5], ~fctry.first);
)