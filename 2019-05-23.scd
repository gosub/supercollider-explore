(
a = {
    |f1=40,f2=40,f3=40,f4=40,f5=40,f6=40,f7=40,f8=40,fb1=0,fb2=0,fb3=0,fb4=0,fb5=0,fb6=0,fb7=0,fb8=0,fbfreq=1, delay=0.001|
    ~fb = LocalIn.ar(1,0);
    ~saw = LFPulse.ar(f1+(1000*~fb*fb1), 0, 0.05);
    ~saw = ~saw + LFPulse.ar(f2+(1000*~fb*fb2), 0, 0.05);
    ~saw = ~saw + LFPulse.ar(f3+(1000*~fb*fb3), 0, 0.05);
    ~saw = ~saw + LFPulse.ar(f4+(1000*~fb*fb4), 0, 0.05);
    ~saw = ~saw + LFPulse.ar(f5+(1000*~fb*fb5), 0, 0.05);
    ~saw = ~saw + LFPulse.ar(f6+(1000*~fb*fb6), 0, 0.05);
    ~saw = ~saw + LFPulse.ar(f7+(1000*~fb*fb7), 0, 0.05);
    ~saw = ~saw + LFPulse.ar(f8+(1000*~fb*fb8), 0, 0.05);
    ~saw = ~saw.tanh;
    LocalOut.ar([DelayC.ar(LPF.ar(~saw,fbfreq),1,delay)]);
    ~saw.dup;
}.play();

w = Window.new("pulse").layout_(
    VLayout(
      HLayout(
        Slider().action_({|x| a.set(\f1, [0.1,800,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f2, [0.1,800,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f3, [0.1,800,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f4, [0.1,800,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f5, [0.1,800,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f6, [0.1,800,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f7, [0.1,800,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f8, [0.1,800,\exp].asSpec.map(x.value))}),
      ),
      HLayout(
        Slider().action_({|x| a.set(\fb1, (x.value))}),
        Slider().action_({|x| a.set(\fb2, (x.value))}),
        Slider().action_({|x| a.set(\fb3, (x.value))}),
        Slider().action_({|x| a.set(\fb4, (x.value))}),
        Slider().action_({|x| a.set(\fb5, (x.value))}),
        Slider().action_({|x| a.set(\fb6, (x.value))}),
        Slider().action_({|x| a.set(\fb7, (x.value))}),
        Slider().action_({|x| a.set(\fb8, (x.value))}),
      ),
      HLayout(
        Slider().action_({|x| a.set(\fbfreq, [1,100,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\delay, [0.001,1].asSpec.map(x.value))}),
      )
   )
).front;
)