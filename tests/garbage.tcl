#! /usr/bin/env tclsh

# All of these commands will fail - These tests are of exception handling

# Load the library & connect to MPD running on localhost
lappend auto_path [file normalize ..]
package require tclmpc

# Output debug logs to stdout
proc debug {text} {
    #puts "DEBUG:[lindex [uplevel 1 {info level 0} ] 0]> $text"
}

# Connect to MPD and run some tests

mpd connect localhost 6600

# This will fail
::msg::registerReplyHandler stop ::msg::batman

# These will fail - here for testing ACK handling
::comm::sendCommand "bork"
::comm::sendCommand "seek"

mpd disconnect
