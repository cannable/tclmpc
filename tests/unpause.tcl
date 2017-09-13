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

mpd pause 0

mpd disconnect
