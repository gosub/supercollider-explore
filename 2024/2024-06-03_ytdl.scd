(
~ytdl = {|vid, filename, debug=false|
	var output;
	if (File.exists(filename)) {
		if (debug) {(filename + "already present").postln};
		filename;
	} {
		if (debug) {("downloading" + vid + "into" + filename).postln};
		output = ["yt-dlp", "--extract-audio", "--audio-format", "wav",
			"--output", filename, vid].unixCmdGetStdOut;
		if (debug) {output.postln};
		filename;
	};
};
)

// example usage
(
~rr = "dQw4w9WgXcQ";
~file = "/tmp/rr.wav";

~ytdl.(~rr, ~file);
("download complete:" + ~file).postln;

Buffer.read(s, ~file, action:
	{ |bufnum|
		{
			var rate = 2;
			var frames = bufnum.numFrames/bufnum.numChannels;
			var lf = LFNoise0.ar(rate).linlin(-1, 1, 0, frames);
			PlayBuf.ar(2, b, BufRateScale.ir(b), Impulse.kr(rate), startPos: lf );
		}.play;
	});
)

File.delete(~file);