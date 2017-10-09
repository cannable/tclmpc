#! /usr/bin/env tclsh

# Load the library & connect to MPD running on localhost
lappend auto_path [file normalize ..]
package require tclmpc

# Output debug logs to stdout
proc debug {text} {
    #puts "DEBUG:[lindex [uplevel 1 {info level 0} ] 0]> $text"
}

# Connect to MPD and run some tests

mpd connect localhost 6600

set outputs [mpd output list]

set counter -1
foreach output $outputs {
    puts "outputs([incr counter])>'$output'"
}

foreach output $outputs {
    set out [msg::getValue $output plugin]
    msg::printReply $out $output
}

mpd disconnect
