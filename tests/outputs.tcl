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

dict for {idx outputInfo} [mpd output list] {
    msg::printReply [dict get $outputInfo outputname] $outputInfo
}

mpd disconnect
