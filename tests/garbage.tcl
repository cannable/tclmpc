#! /usr/bin/env tclsh

# All of these commands will fail - These tests are of exception handling

# Load the library & connect to MPD running on localhost
source ../tclmpc.tcl

# Output debug logs to stdout
proc debug {text} {
    puts "DEBUG:$text"
}

# Connect to MPD and run some tests

mpd connect localhost 6600

# This will fail
::msg::registerReplyHandler stop ::msg::batman

# These will fail - here for testing ACK handling
::comm::sendCommand "bork"
::comm::sendCommand "seek"

mpd disconnect
