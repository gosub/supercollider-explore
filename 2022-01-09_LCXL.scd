MIDIIn.connectAll;

(
// midi channels of factory templates
~factoryCh = (8..15);

// cc numbers for knobs and sliders
~knbA_cc = (13..20); ~knbB_cc = (29..36); ~knbC_cc = (49..56); ~sldr_cc = (77..84);
~btnA_note = (41..44) ++ (57..60); ~btnB_note = (73..76) ++ (89..92);

// create a Control Bus for each knob, slider and button
~knbA = ~knbA_cc collect: {Bus.control(s)}; ~knbB = ~knbB_cc collect: {Bus.control(s)};
~knbC = ~knbC_cc collect: {Bus.control(s)}; ~sldr = ~sldr_cc collect: {Bus.control(s)};
~btnA = ~btnA_note collect: {Bus.control(s)}; ~btnB = ~btnB_note collect: {Bus.control(s)};
)


(
// mapping cc midi input to control busses
~knbA_midif = MIDIFunc.cc({|val, cc, chan, src| ~knbA[~knbA_cc.indexOf(cc)].set(val.linlin(0,127,0.0,1.0));}, ~knbA_cc, ~factoryCh.first);
~knbB_midif = MIDIFunc.cc({|val, cc, chan, src| ~knbB[~knbB_cc.indexOf(cc)].set(val.linlin(0,127,0.0,1.0));}, ~knbB_cc, ~factoryCh.first);
~knbC_midif = MIDIFunc.cc({|val, cc, chan, src| ~knbC[~knbC_cc.indexOf(cc)].set(val.linlin(0,127,0.0,1.0));}, ~knbC_cc, ~factoryCh.first);
~sldr_midif = MIDIFunc.cc({|val, cc, chan, src| ~sldr[~sldr_cc.indexOf(cc)].set(val.linlin(0,127,0.0,1.0));}, ~sldr_cc, ~factoryCh.first);

// mapping note midi input to control busses
~btnA_midiOn = MIDIFunc.noteOn({|val, nt, chan, src| ~btnA[~btnA_note.indexOf(nt)].set(val.linlin(0,127,0.0,1.0));}, ~btnA_note, ~factoryCh.first);
~btnA_midiOff = MIDIFunc.noteOff({|val, nt, chan, src| ~btnA[~btnA_note.indexOf(nt)].set(0);}, ~btnA_note, ~factoryCh.first);
~btnB_midiOn = MIDIFunc.noteOn({|val, nt, chan, src| ~btnB[~btnB_note.indexOf(nt)].set(val.linlin(0,127,0.0,1.0));}, ~btnB_note, ~factoryCh.first);
~btnB_midiOff = MIDIFunc.noteOff({|val, nt, chan, src| ~btnB[~btnB_note.indexOf(nt)].set(0);}, ~btnB_note, ~factoryCh.first);
)


(
~def = SynthDef(\lcxl, { |out|
    var car1 = In.kr(~knbA[0]).linexp(0,1,44,440);
    var mod1 = In.kr(~knbA[1]).linexp(0,1,44,440);
    var id1 = In.kr(~sldr[0]).linlin(0,1,0,2pi);
    var ph1 = In.kr(~sldr[1]).linlin(0,1,0,2pi);

    var car2 = In.kr(~knbA[2]).linexp(0,1,44,440);
    var mod2 = In.kr(~knbA[3]).linexp(0,1,44,440);
    var id2 = In.kr(~sldr[2]).linlin(0,1,0,2pi);
    var ph2 = In.kr(~sldr[3]).linlin(0,1,0,2pi);

    var car3 = In.kr(~knbA[4]).linexp(0,1,44,440);
    var mod3 = In.kr(~knbA[5]).linexp(0,1,44,440);
    var id3 = In.kr(~sldr[4]).linlin(0,1,0,2pi);
    var ph3 = In.kr(~sldr[5]).linlin(0,1,0,2pi);

    var car4 = In.kr(~knbA[6]).linexp(0,1,44,440);
    var mod4 = In.kr(~knbA[7]).linexp(0,1,44,440);
    var id4 = In.kr(~sldr[6]).linlin(0,1,0,2pi);
    var ph4 = In.kr(~sldr[7]).linlin(0,1,0,2pi);

    var sig1 = PMOsc.ar(car1, mod1, id1, ph1);
    var sig2 = PMOsc.ar(car2, mod2, id2, ph2);
    var sig3 = PMOsc.ar(car3, mod3, id3, ph3);
    var sig4 = PMOsc.ar(car4, mod4, id4, ph4);

    var sig = Mix.ar([sig1,sig2,sig3,sig4])/4;

    Out.ar(out, sig.tanh!2);
}).add;
)


(
~synth = Synth(\lcxl);
)
