#! /usr/bin/env tclsh

# Load the library & connect to MPD running on localhost
lappend auto_path [file normalize ..]
package require tclmpc

# Output debug logs to stdout
proc debug {text} {
    #puts "DEBUG:[lindex [uplevel 1 {info level 0} ] 0]> $text"
}

if {! [llength $argv]} {
    puts stderr {You must pass some search criteria as script arguments.}
    puts stderr {ex. Artist Paramore Album "Brand New Eyes"}
    exit 1
}

# Connect to MPD and run some tests

mpd connect localhost 6600

msg::printFileList [mpd db find {*}$argv]

mpd disconnect
