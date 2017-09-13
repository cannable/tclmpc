#! /usr/bin/env tclsh

# Info proc tests

# Load the library & connect to MPD running on localhost
source ../tclmpc.tcl

# Output debug logs to stdout
proc debug {text} {
    puts "DEBUG:$text"
}

# Connect to MPD and run some tests

puts "Pinging without a connection"
puts "Return: '[mpd ping]'"

mpd connect localhost 6600

puts "Pinging after trying to make a connection"
puts "Return: '[mpd ping]'"

mpd disconnect
