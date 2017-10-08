# tclmpc

## What is This?

An API to facilitate communication with an MPD server in Tcl. At least, that's
the goal. Initially, the focus will be on implementing the bare minimum of
features to allow for basic remote control. I'm basing this off of the
documentation here: https://www.musicpd.org/doc/protocol/

This was initially based off of some old, really bad code I wrote a while ago.
As with many hobby projects, this is one I was working on sporadically,
whenever the mood struck me. I recently picked it up again and had several
"what was I thinking?" moments.

My goal is to keep this library relatively simple/thin. One with a familiarity
with the MPD protocol should be able to intuit what one of these library
functions done with a high degree of accuracy. At least, that's the idea.

Ultimately, I'd like to base a minimal Tk-based client off of this library, if
only as an overkill-level test suite of the API.

## Why

Because.

## Status

After writing the base bits for communicating with MPD, I started with the
low-hanging fruit. I intend to continue down this line, slowly implementing
features that require more effort. As I implement functions, they'll end up
under the "Complete/Working heading below".

# API Documentation

This script implements the mpd command namespace. Everything will be
implemented by sub-commands off of mpd.

## Complete/Working

### Playback Control

#### mpd pause {on}

Arguments:

* on - boolean: 0 to resume, 1 to pause

Plays/pauses playback, depending on the state of on.

#### mpd toggle {}

Toggle playback.

#### mpd next {}

Play the next track in the queue.

#### mpd prev {}

Play the previous track from the queue.

#### mpd play {songpos}

Start playing song at songpos in the playback queue.

#### mpd stop {}

Stops playback.

#### mpd seek {s}

Arguments:

* s - seconds, "fractions allowed"

Seek forward or backward the passed number of seconds in the current song. The
argument, s, must be a double and can be negative (to seek backwards).

### Options

Common variables:

* on - boolean: on=1, off=0

#### mpd config consume {on}

Enables/disables consume mode.

#### mpd config random {on}

Enable or disable random playback mode.

#### mpd config repeat {on}

Enable or disable repeat mode.

#### mpd config single {on}

When on, stop playback after the current track. If repeat is on, repeat the
current track.

#### mpd config setvol {vol}

Arguments:

* vol - Output volume, from 0-100

Set the output volume.

#### mpd config crossfade {s}

Arguments:

* s - seconds

Set the crossfade duration.

#### mpd config replaygain {state}

Arguments:

* state - Replaygain state, where state=off,track,album,auto

Change the state of Replaygain.

### Queue

#### mpd queue clear {}

Clear the playback queue.

#### mpd queue info {}

Returns a list lists containing info for the tracks in the play queue

#### mpd queue shuffle

Shuffle the entire playlist

### Utility

#### mpd connect {server port}

Arguments:

* server - IP/hostname of an server
* port - Port to connect

Creates an active connection to an MPD server and stashes the socket somewhere
for future use. Currently, this only supports connecting over an IP socket.
Port is specified as a separate argument to make it easier to handle the
address (ex. don't have to split on a colon).

#### mpd disconnect {}

Disconnects from MPD. This will also destroy the socket.

#### mpd ping {}

A basic test to confirm we have a working connection established with an MPD
server. Returns 1 if everything is OK; otherwise, returns 0.

This could be expanded to be more robust, but, currently, it only checks the
socket, then sends a ping command to the server and waits for a response.

### Info
#### mpd info currentsong {}

Returns a key-value list of information for the current song. This info is
useful for showing a "Now Playing" kind of display. Note: while this returns
things like the rough length of the file (to the nearest second) and location
in the queue, it will not give you anything about playback. For things like bit
rate, song position, or playback state, use info status.

Returned keys include:

* Album
* AlbumArtist
* Artist
* Date
* Genre
* Id
* Last-Modified
* Pos
* Time
* Title
* Track
* duration
* file

#### mpd info status {}

Returns a key-value list of information about the current state of MPD. This
includes things like playback state (paused, playing, etc.), repeat, random,
bit rate, etc.

Returned keys include:

* audio
* bitrate
* consume
* duration
* elapsed
* mixrampdb
* nextsong
* nextsongid
* playlist
* playlistlength
* random
* repeat
* single
* song
* songid
* state
* time
* volume

#### mpd info stats {}

Retuns a key-value list of pertinent server stats.

Returned keys include:

* albums
* artists
* db_playtime
* db_update
* playtime
* songs
* uptime

#### mpd info decoders {}

Returns a key-value list of decoders supported by the MPD server, their
filename suffixes, and associated mime types.

### 'Is'

These are helper functions to make writing if statements easier.

#### mpd is playing {}

Returns 1 when MPD is playing; 0 otherwise.

#### mpd is stopped {}

Returns 1 when MPD is stopped; 0 otherwise.

### Database

#### mpd db find {args}

Perform a case-sensitive search of the MPD DB. The contents of args are passed,
verbatim. to the message sent to MPD.

#### mpd db search {args} 

Perform a case-insensitive search of the MPD DB. The contents of args are
passed, verbatim. to the message sent to MPD.

#### mpd db list {args} 

Lists objects by passed tag criteria. The contents of args are passed,
verbatim. to the message sent to MPD.

## Work In Progress/To-Do List

### Playlists

Common variables:

* name - Playlist name

#### mpd playlist list {}

Lists all playlists.

#### mpd playlist info {name}

Returns a key-value list of playlist info, a la "listplaylistinfo".

#### mpd playlist load {name}

Load the passed playlist into the playback queue.

#### mpd playlist addtrack {name uri}

Add the track specified by uri to the playlist.

#### mpd playlist clear {name}

Blank the contents of the passed playlist.

#### mpd playlist delete {name songpos}

Delete the track at songpos from the passed playlist.

#### mpd playlist rename {name newName}

Rename the playlist.

#### mpd playlist rm {name}

Nuke the passed playlist.

#### mpd playlist save {name}

Save the playlist.

### Queue

#### mpd queue add {uri}

Arguments:

* uri - File name, URL, or directory

Add the song(s) at uri to the playback queue. If the passed uri is a directory,
adds tracks recursively.

#### mpd queue delete {songpos}

Arguments:

* songpos - location of song in queue

Remove the song at songpos from the queue.

#### mpd queue prio {priority}

Sets track priority

#### mpd queue swap {a b}

Swap a and b in the queue

### Info

#### mpd info rights {}          commands and notcommands

Returns a key-value list of commands that are allowed to be run by the client
and commands that are not allowed (as returned by the MPD directives "commands"
and "notcommands", respectively).

#### mpd info replaygain {}

Returns the current state of Replaygain.

### Outputs

Common variables:

* id - Output ID

#### mpd output disable {id}

Disable the passed output.

#### mpd output enable {id}

Enable the passed output.

#### mpd output list {}

Return a list of all available outputs.

### Database

#### mpd db update {args}

Scan for modified files and update the DB. Scope of the scan is controlled by
args: if nothing is passed, everything is scanned. Pass a file or directory to
scan a fragment of the library.

#### mpd db rescan {args}

Scan all files and update the DB. Scope of the scan is controlled by args: if
nothing is passed, everything is scanned. Pass a file or directory to scan a
fragment of the library.

#### mpd db albumart {URI}

Returns the album art binary blog from the MPD DB.

## Requires Further Planning
### Database
#### mpd db count {TAG NEEDLE}
#### mpd db get albumsByArtist {artist}

Convenience procedure to perform a search of the MPD DB.

#### mpd db get tracksByAlbum {album}

Convenience procedure to perform a search of the MPD DB.

## Not Implementing

These are some things that I im intentionally ignoring until I get round one
complete.

* Mounts/neighbour stuff
* Partitions
* Stickers
* Most search functionality (At least, until the base is fleshed-out)
* Client-to-client communication
