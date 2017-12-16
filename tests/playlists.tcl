#! /usr/bin/env tclsh

# Load the library & connect to MPD running on localhost
lappend auto_path [file normalize ..]
package require tclmpc

# Output debug logs to stdout
proc debug {text} {
    #puts "DEBUG:[lindex [uplevel 1 {info level 0} ] 0]> $text"
    #puts "DEBUG:> $text"
}

# Connect to MPD and run some tests

mpd connect localhost 6600

puts Playlists:
dict for {p pInfo} [mpd playlist list] {
    puts "\t$p"

    set trackInfo [mpd playlist info $p]

    dict for {idx track} $trackInfo {
        puts "\t\t$idx - [dict get $track Title]"
    }
}

mpd disconnect
