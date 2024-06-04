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

// example download
(
~rr = "dQw4w9WgXcQ";
~file = "/tmp/rr.wav";

~ytdl.(~rr, ~file);
)

// wait for file to download
// then run the following
(
b = Buffer.read(s, ~file);
{
	PlayBuf.ar(2,b);
}.play;
)

