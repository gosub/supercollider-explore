// patch name: PEPUQEF
// patch date: 2020-07-22
// patch desc: korg nanopad midi test
// patch prev: TODOMA


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
