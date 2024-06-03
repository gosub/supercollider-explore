// TODO: do not re-download the file if already present
(
~ytdl = {|vid, filename|
	["yt-dlp", "--extract-audio", "--audio-format", "wav",
		"--output", filename, vid].unixCmd;
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

