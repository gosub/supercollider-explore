// patch name: TODOMA
// patch date: 2020-07-09
// patch desc: an experiment in decoupling MIDIdef and SynthDef


// TODO: explanation on how to use

(
MIDIClient.init;
MIDIIn.connectAll;
)

(
// TODO: test with a real controller

~make_controller = {|cc_dict, note_dict, midi_chan=nil|
    var controller = ();
    // install cc callbacks
    cc_dict.keysValuesDo {|symbol, cc_num|
        MIDIdef.cc(symbol, {|val, cc, chan, src|
            controller.put(symbol, val/127);
            controller[("on_" ++ symbol).asSymbol].value(controller, val/127);
        }, ccNum: cc_numm, chan: midi_chan);
    };
    // install note callbacks
    notes_dict.keysValuesDo {|symbol, note_num|
        // map NOTEON
        MIDIdef.noteOn(symbol, {|velocity, note, chan, src|
            controller.put(symbol, velocity/127);
            controller[("on_" ++ symbol).asSymbol].value(controller, velocity/127);
        },noteNum: note_num, chan: midi_chan);
        // map NOTEOFF
        MIDIdef.noteOff((symbol++"off").asSymbol, {|velocity, note, chan, src|
            controller.put(symbol, 0);
            controller[("on_" ++ symbol).asSymbol].value(controller, 0);
        },noteNum: note_num, chan: midi_chan);
    };
};
)

MIDIdef.freeAll;