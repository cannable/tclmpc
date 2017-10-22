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

set decoders [mpd info decoders]

set counter 0

dict for {decoder info} $decoders {
    puts "[incr counter]. $decoder"

    foreach prop [dict keys $info] {
        puts "\t$prop: [dict get $info $prop]"
    }
}

mpd disconnect
