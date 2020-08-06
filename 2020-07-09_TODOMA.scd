// patch name: TODOMA
// patch date: 2020-07-09
// patch desc: an experiment in decoupling MIDIdef and SynthDef


// TODO: explanation on how to use

(
~map_normalized_cc_to_callback = {|symbol, cc_num, midi_chan=nil|
    MIDIdef.cc(symbol,
        func: {|val, cc, chan, src|
            symbol.envirPut(val/127);
            ("on_" ++ symbol).asSymbol.envirGet.(val/127);
        },
        ccNum: cc_num,
        chan: midi_chan);
};

~map_normalized_note_to_callback = {|symbol, note_num, midi_chan=nil|
    MIDIdef.noteOn(symbol,
        func: {|velocity, note, chan, src|
            symbol.envirPut(velocity/127);
            ("on_" ++ symbol).asSymbol.envirGet.(velocity/127);
        },
        noteNum: note_num,
        chan: midi_chan);
    MIDIdef.noteOff((symbol++"off").asSymbol,
        func: {|velocity, note, chan, src|
            symbol.envirPut(0);
            ("on_" ++ symbol).asSymbol.envirGet.(0);
        },
        noteNum: note_num,
        chan: midi_chan);
};
)

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