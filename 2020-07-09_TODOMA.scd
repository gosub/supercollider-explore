// patch name: TODOMA
// patch date: 2020-07-09
// patch desc: an experiment in decoupling MIDIdef and SynthDef


/*

KORG NANOPAD2 MIDI DATA
dumped with: amidi -p hw:1 --dump

// XY TOUCH
B0 10 7F // touch on
B0 01 49 // touch x
B0 02 50 // touch y
B0 10 00 // touch off

// BUTTON PRESS
90 24 57  // button 1 on
80 24 40  // button 1 off

90 25 60  // button 2 on
80 25 40  // button 2 off

*/

(
// factory defaults
~nanopad_chan = 0;
~nanopad_cc = Dictionary[
    \xy_gate -> 16,
    \x_axis -> 1,
    \y_axis -> 2];

~nanopad_first_button = 36;
~nanopad_scenes = 4;
~nanopad_buttons_per_scene = 16;

MIDIClient.init;
MIDIIn.connectAll;
)

// TODO: separate nanopad specifics into a new file

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
~nanopad_scenes.do {|scene|
    ~nanopad_buttons_per_scene.do {|button|
        var symbol, note;
        if(scene==0,
            {symbol = format("butt%",button + 1).asSymbol},
            {symbol = format("butt%sc%",button + 1,scene).asSymbol});
        note = (scene * ~nanopad_buttons_per_scene) + button + ~nanopad_first_button;
        ~map_normalized_note_to_callback.(symbol, note, ~nanopad_chan);
    };
};

~on_butt1 = {|val|
    f = {var a = Synth(\default,[\amp, val, \freq, 500]);
            0.1.sleep;
            a.release
    };
    val.asBoolean.if({f.fork});
};
)

(
~nanopad_cc.keysValuesDo { |symbol, cc_num|
    ~map_normalized_cc_to_callback.(symbol, cc_num, ~nanopad_chan);
};
)

(
~synth = Synth(\default, [\amp, 0]);
~on_xy_gate = {|val| ~synth.set(\amp, val)};
)

(
~synth.release;
~on_xy_gate = nil;
)

(
~pattern = Pbind(
    \note, Pseq([0,7,4,11],inf),
    \dur, Pfunc({~xy_gate}) * 0.3 + 0.3
).play;
)

~pattern.stop;

MIDIdef.freeAll;