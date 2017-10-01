#! /usr/bin/env tclsh

# Info proc tests

# Load the library & connect to MPD running on localhost
source ../tclmpc.tcl

# Output debug logs to stdout
proc debug {text} {
    puts "DEBUG:$text"
}

# Connect to MPD and run some tests

mpd connect localhost 6600

set queueTracks [mpd queue info]

set counter -1
foreach track $queueTracks {
    debug "queueTracks([incr counter])>'$track'"
}

foreach track $queueTracks {
    set title [msg::getValue $track Title]
    msg::printReply $title $track
}

mpd disconnect
