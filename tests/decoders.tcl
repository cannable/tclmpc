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

set decoders [mpd info decoders]

set counter -1
foreach decoder $decoders {
    debug "decoders([incr counter])>'$decoder'"
}

foreach decoder $decoders {
    set plugin [msg::getValue $decoder plugin]
    msg::printReply $plugin $decoder
}

mpd disconnect
