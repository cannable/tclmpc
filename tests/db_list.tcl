#! /usr/bin/env tclsh

# Load the library & connect to MPD running on localhost
lappend auto_path [file normalize ..]
package require tclmpc

# Output debug logs to stdout
proc debug {text} {
    puts "DEBUG:$text"
}

if {! [llength $argv]} {
    puts stderr {You must pass some list search criteria as script arguments.}
    puts stderr {ex. Album Artist Paramore}
    exit 1
}

# Connect to MPD and run some tests

mpd connect localhost 6600

set items [mpd db list {*}$argv]

puts [string repeat - 20]
puts ">>> $argv <<<"

set counter -1
foreach item $items {
    puts "\t[incr counter]. $item"
}

mpd disconnect
