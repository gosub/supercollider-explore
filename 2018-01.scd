/*       ----------       */
/******* 2018-01-19 *******/
/*       ----------       */


// from SC140 compilation
// http://ia800202.us.archive.org/29/items/sc140/sc140_sourcecode.txt

// track 01 - Nathaniel Virgo

{LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play

// riformattato

({
	n = LFNoise0.kr(4/3, 4);
	w = Saw.ar([32, 33], 0.2);
    i = LocalIn.ar(2);
    b = BPF.ar(i * 7.5 + w, (2**n) * 300, 0.1).distort;
	a = CombN.ar(b, 2, 2, 40);
	LocalOut.ar(a);
	a;
}.play;)

// analisi della catena del segnale:
// il segnale e' una saw wave (w) missata con il ritorno del feedback (i)
// che passano per un filtro passa banda (b) distorto, la cui frequenza e'
// modulata da un segnale noise (n). Il segnale, dopo essere passato per
// un filtro comb (b), viene inviato al feedback e all'output


/*       ----------       */
/******* 2018-01-20 *******/
/*       ----------       */

// continua da ieri

// ricostruendo il segnale dalla base
// si parte con l'oscillatore a dente di sega
// il segnale sinistro e destro hanno frequenze
// leggermente diverse 32 hertz e 33 hertz, per
// ottenere un effetto di detuning

(
{
    Saw.ar([32,33], 0.2);
}.play;
)

// si aggiunge il fitro passa-banda
// con una frequenza fissa a 2**2 * 300 = 1200Hz
// si possono sperimentare valore di n da tra 0 e 4

(
{
    w = Saw.ar([32,33], 0.2);
    n = 2;
    BPF.ar(w, (2**n) * 300, 0.1);
}.play;
)

// aggiungendo una sorgente rumore a bassa frequenza (4/3Hz)
// che modula la frequenza del filtro passa-basso, si ottiene
// che la dente di sega venga filtrata in una sequenza di frequenze
// random poco piu' di una volta al secondo, in un range che va
// da 300 * 2^0 = 300Hz fino a 300 * 2^4 = 4800Hz
// i pop che si sentono sono dovuti al cambio repentino di frequenza
// dati da LFNoise0, sostituendolo con LFNoise1 si puo' provare
// un cambio piu' graduale

(
{
    w = Saw.ar([32,33], 0.2);
    n = LFNoise0.kr(4/3, 4);
    BPF.ar(w, (2**n) * 300, 0.1);
}.play;
)

// si aggiunge il filtro comb con 2 secondi di delay
// e decay a 40 secondi. filtro comb non fa altro che
// missare il segnale originale con una versione di esso
// ritardata di x secondi, e attenuata con il valore decay
// per evitare che il feedback saturi.

// Questo fa si che i pop di cambio frequenza vengano
// reinseriti nel segnale dopo 2 secondi, creando un ritmo.
// Con il tempo il ritmo di un singolo pop si perde nell'
// attenuazione, ma i pop successivi lo sostituiscono.
// In questo caso, sostituendo LFNoise0 con LFNoise1
// l'effetto ritmico sparisce.

// Modificando il tempo di delay del comb filter
// si ottengono ritmi di velocita' diverse
// ad esempio sostituendo 2 con 1 il ritmo raddoppia
// di velocita'.
// Se si fa questa prova e' bene tenere a mente che
// se il comb filter reinserisce piu velocemente,
// piu' ritmi si sovrappangono prima che il decay
// riesca a farli scemare, rendendo il suono piu'
// caotico. Si puo' ovviare riducendo il decay
// di quanto si velocizza il ritmo es. da 40 a 20

(
{
    w = Saw.ar([32,33], 0.2);
    n = LFNoise0.kr(7/3, 4);
    b = BPF.ar(w, (2**n) * 300, 0.1);
    CombN.ar(b, 2, 2, 40);
}.play;
)


/*       ----------       */
/******* 2018-01-23 *******/
/*       ----------       */

// continua da 2018-01-20

// infine reinseriamo gli UGen LocalIn e LocalOut
// che equivalgono ad aggiungere un cavo audio al
// l'interno del synth che va da LocalOut a LocalIn.
// In questo caso LocalOut si trova alla fine della
// catena di segnale, mentre LocalIn e' missato
// con la dente di sega prima di entrare nel filtro
// passa-banda, generando un feedback che provoca
// un effetto di riverbero

({
	w = Saw.ar([32, 33], 0.2);
    i = LocalIn.ar(2);
    n = LFNoise0.kr(4/3, 4);
    b = BPF.ar(i * 7.5 + w, (2**n) * 300, 0.1).distort;
	a = CombN.ar(b, 2, 2, 40);
	LocalOut.ar(a);
	a;
}.play;)


/*       ----------       */
/******* 2018-01-24 *******/
/*       ----------       */


// Eli Fieldsteel's - Infinite Hold Reverb https://www.youtube.com/watch?v=_2N7lG5uzJI
// copied from https://www.youtube.com/watch?v=_2N7lG5uzJI

(
~infiniteHoldReverb = {
    arg feedback=1;
    var sig, local;

    //establish input signal
    sig = SoundIn.ar(0,);
    local = LocalIn.ar(2)+sig.dup;

    //apply reverb - x.do is no. of taps, other args are input, maxdly, dly, decay
    7.do{local = AllpassN.ar(local, 1, Rand(0.001,1), 3)};

    //complete feedback loop -- send audio back to LocalIn
    // multiply by 0 to 1, 0 in no feedback, 1 = 100% feedback
    LocalOut.ar(local*feedback);

    Out.ar(0, local);
}.play
)

~infiniteHoldReverb.set(\feedback, 0.90)


// from SC140 compilation
// http://ia800202.us.archive.org/29/items/sc140/sc140_sourcecode.txt

// track 02 - LFSaw

{Splay.ar(Ringz.ar(Impulse.ar([2, 1, 4], [0.1, 0.11, 0.12]), [0.1, 0.1, 0.5])) * EnvGen.kr(Env([1, 1, 0], [120, 10]), doneAction: 2)}.play

// riformattando

(
{

    i = Impulse.ar([2, 1, 4], [0.1, 0.11, 0.12]);
    r = Ringz.ar(i, [0.1, 0.1, 0.5]) ;
    e = EnvGen.kr(Env([1, 1, 0], [120, 10]), doneAction: 2);
    Splay.ar(r) * e;
}.play;
)

// e' completamente diverso dal suono originale
// forse per cambiamenti dalla versione di SC o per dipendenza
// dal samplerate originale



// from SC140 compilation
// http://ia800202.us.archive.org/29/items/sc140/sc140_sourcecode.txt

// track 03 - Tim Walters

play{({|k|({|i|y=SinOsc;y.ar(i*k*k,y.ar(i*k**i/[4,5])*Decay.kr(Dust.kr(1/4**i),y.ar(0.1)+1*k+i,k*999))}!8).product}!16).sum}//#supercollider

// riformattato

(
{
    ~gen = {
        |k, i|
        ~freq = i * k * k;
        ~phase_env_trig = Dust.kr(1/4 ** i);
        ~phase_env_decayTime = SinOsc.ar(0.1) + 1 * k+i;
        ~phase_env = Decay.kr(~phase_env_trig, ~phase_env_decayTime, k*999);
        ~phase_sig = SinOsc.ar(i*k**i/[4,5]);
        ~phase = ~phase_sig * ~phase_env;
        SinOsc.ar(freq: i*k*k, phase: ~phase);
    };

    sum({ |k| product({|i| ~gen.(k, i)}!8) }!16);

}.play;
)
