#! /usr/bin/env tclsh

# Load the library & connect to MPD running on localhost
lappend auto_path [file normalize ..]
package require tclmpc

## Output debug logs to stdout
proc debug {text} {
    puts "DEBUG:[lindex [uplevel 1 {info level 0} ] 0]> $text"
}

if {[llength $argv] != 1} {
    puts stderr {Please give me an artist.}
    puts stderr {This script takes exactly 1 argument.}
    exit 1
}

set artist $argv

# Connect to MPD and run some tests

mpd connect localhost 6600

set albums [mpd db list Album Artist $artist]

puts [string repeat - 20]
puts ">>> $artist Albums <<<"

set counter -1
foreach album $albums {
    puts "\t[incr counter]. $album"

    # Get the list of tracks for this album
    set tracks [mpd db find Artist $artist Album $album]

    foreach track $tracks {
        array set tinfo $track
        puts "\t\t$tinfo(Track). $tinfo(Title)"
    }
}

mpd disconnect
