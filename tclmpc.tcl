#! /usr/bin/env tclsh

# tclmpc.tcl --
#
#     Provides an API for connecting to and driving musicpd server.
# 
# Copyright 2017 C. Annable
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Define this proc in your code to test the library
proc debug {text} {
    #puts "DEBUG:$text"
}


namespace eval comm {
    variable mpd_socket {}


    # comm::connect --
    #
    #           Establish a socket connection to the MPD server.
    #
    # Arguments:
    #           server  Server name
    #           port    Port the server is available on
    #
    # Results:
    #           0
    #
    proc connect {server port} {
        debug "connect> Connecting to $server:$port"
        variable mpd_socket

        if {! [string length $mpd_socket]} {
            set mpd_socket [socket $server $port]
            gets $mpd_socket banner
            debug "MPD Banner> '$banner'"

            if {![string match {OK MPD*} $banner]} {
                error "Didn't receive banner"
            }
            #fileevent $mpd_socket readable ::comm::readData
        } else {
            error "Already connected to MPD, via '$mpd_sock'."
        }

        return 0
    }


    # comm::disconnect --
    #
    #           Disconnect from a connected MPD server
    #
    # Arguments:
    #           none
    #
    # Results:
    #           0
    #
    proc disconnect {} {
        variable mpd_socket

        if {[string length $mpd_socket]} {
            puts $mpd_socket close
            close $mpd_socket
            set mpd_socket {}
        }

        return 0
    }


    # comm::isconnected --
    #
    #           See if we have a socket set up
    #
    # Arguments:
    #           none
    #
    # Results:
    #           1 if we have a socket
    #           0 otherwise
    #
    proc isconnected {} {
        variable mpd_socket

        if {[string length $mpd_socket]} {
            return 1
        }

        return 0
    }


    # comm::sendCommand --
    #
    #           Send a command to a connected MPD server
    #
    # Arguments:
    #           command Command to send to the server
    #           args    Any command arguments to send MPD
    #
    # Results:
    #           Sends a command to an MPD server. If MPD sends us an 'OK' or
    #           'ACK', return the response line. If MPD sends us data back, read
    #           until we get the 'OK', then return the entire response,
    #           sans-OK and formatted as a list.
    #
    proc sendCommand {command args} {
        variable mpd_socket

        if {![string length $mpd_socket]} {
            error "No connection to MPD"
        }

        # Send the command to the server
        if {[string length $args]} {
            debug "comm::sendCommand>Sending command: '$command' '$args'"
            puts $mpd_socket "$command $args"
        } else {
            debug "comm::sendCommand>Sending single command: '$command'"
            puts $mpd_socket $command
        }

        flush $mpd_socket

        # TODO: Wait for reply
        set line {}
        set message {}

        # Get a line from the socket, then decide if we need to read more
        gets $mpd_socket line

        # Return the error line, if we sent a bad command
        switch -glob -- $line {
            {OK} {
                # Command was successful, and we didn't get any data back
                debug "sendCommand>OK: '$line'"
                return $line
            }
            {ACK*} {
                # Something went wrong
                debug "sendCommand>Error: '$line'"
                return $line
            }
        }

        # There's more data to get, read from the socket until we get an 'OK'
        while {![string match OK $line]} {
            gets $mpd_socket line
            puts "sendCommand>line: '$line"

            if {![string match OK $line]} { 
                lappend message "$line"
            }
        }

        debug "sendCommand>Received: '$message'"
        return [msg::decodeReply $message]

    }


}

namespace eval msg {


    # msg::printReply --
    #
    #           Prints nicely-formatted messages to stdout
    #
    # Arguments:
    #           command The command to which this is a reply
    #           reply   Message back from MPD
    #
    # Results:
    #           This is mostly just a debugging procedure to make message
    #           content easier to read.
    #
    proc printReply {command reply} {
        array set data $reply
        puts [string repeat - 20]
        puts ">>> $command <<<"
        #puts $reply
        foreach element [array names data] {
            puts "|$element|$data($element)|"
        }
        puts [string repeat - 20]
    }


    # msg::decodeReply --
    #
    #           Assembles a key-value list of message contents.
    #
    # Arguments:
    #           reply   Message back from MPD
    #
    # Results:
    #           Takes the "key: value" message format and returns the data in
    #           list form.
    #
    proc decodeReply {reply} {
        set elements {}

        foreach line $reply {
            regexp -- {([^:]+): (.+)$} $line -> key value
            debug "msg::decodeReply> '$key'->'$value'"
            lappend elements $key $value
        }

        return $elements
    }


    # msg::decodeAck --
    #
    #           Decodes ACK message (errors)
    #
    # Arguments:
    #           reply   Message back from MPD
    #
    # Results:
    #           Return an ack key-value list
    #
    proc decodeAck {reply} {

#ACK [error@command_listNum] {current_command} message_text\n

        regexp -- \
                {^ACK *\[([^@]+)@([^]]+)] * \{([^\}]*)\} (.*)} \
                $reply -> \
                ack(error) \
                ack(commandList) \
                ack(command) \
                ack(messageText)
        #debug "msg::decodAck>ack: '[array get ack]'"

        return [array get ack]
    }


    # msg::getValue --
    #
    #           Given a reply string, return the value for the passed, key.
    #           This is a really stupid function, as it could match against a
    #           value and the next pair's key. This should be fine within the
    #           context of MPD, but I'm probably going to re-write it.
    #
    # Arguments:
    #           msg list-format reply string
    #
    # Results:
    #           0 if no value found
    #           Otherwise, the value of the requested key
    #
    proc getValue {reply key} {
        # TODO: Re-write this so that it is less stupid
        set index [lsearch $reply $key]

        if {$index < 0} {
            return 0
        }
        return [lindex $reply $index+1]
    }
}

namespace eval mpd {

    namespace eval info {
        # mpd::info::rights --
        #
        #           Ask MPD for our rights
        #
        # Arguments:
        #           none
        #
        # Results:
        #           MPD will send us commands and notcommands replies
        #
        proc rights {} {
            comm::sendCommand commands
            comm::sendCommand notcommands
        }


        # mpd::info::currentsong --
        #
        #           Tell MPD to send us the current song details
        #
        # Arguments:
        #           none
        #
        # Results:
        #           MPD will send us a message with the requested info
        #
        proc currentsong {} {
            set msg [comm::sendCommand "currentsong"]

            # Check for error state
            switch -glob -- $msg {
                {OK} {
                    # Nothing is playing
                    return {}
                }
                {ACK*} {
                    error [msg::decodeAck $msg]
                }
                default {
                    msg::printReply currentsong $msg
                }
            }

            return $msg

        }


        # mpd::info::status --
        #
        #           Tell MPD to send us info about MPD's status
        #
        # Arguments:
        #           none
        #
        # Results:
        #           MPD will send us a message with the requested info
        #
        proc status {} {
            set msg [comm::sendCommand "status"]

            # Check for error state
            if {[string match {ACK*} $msg]} {
                error [msg::decodeAck $msg]
            }

            msg::printReply status $msg

            return $msg
        }


        # mpd::info::stats --
        #
        #           Tell MPD to send us info about MPD stats
        #
        # Arguments:
        #           none
        #
        # Results:
        #           MPD will send us a message with the requested info
        #
        proc stats {} {
            set msg [comm::sendCommand "stats"]

            # Check for error state
            if {[string match {ACK*} $msg]} {
                error [msg::decodeAck $msg]
            }

            msg::printReply stats $msg

            return $msg
        }

        # mpd::info::isplaying --
        #
        #           See if MPD is playing
        #
        # Arguments:
        #           none
        #
        # Results:
        #           Returns 1 if MPD is playing
        #
        proc isplaying {} {
            set state [msg::getValue [mpd info status] state]

            if {[string match play $state]} {
                puts playing
                return 1
            }

            return 0
        }

        namespace export *
        namespace ensemble create
    }


    # mpd::ping --
    #
    #           Pings MPD
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns 1 if we have an active connection to MPD.
    #           Returns 0 if we don't have a usable connection to MPD.
    #
    proc ping {} {
        # If we don't even have an open socket, fail
        if {! [comm::isconnected]} {
            return 0
        }

        set msg [comm::sendCommand "ping"]
        
        # If we got an OK from MPD, we're all set
        if {[string match {OK} $msg]} {
            return 1
        }

        return 0
    }


    # mpd::connect --
    #
    #           Connect to an MPD server
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Connects to MPD
    #
    proc connect {server port} {
        comm::connect $server $port
    }


    # mpd::disconnect --
    #
    #           Close connection to MPD
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Closes MPD connection
    #
    proc disconnect {} {
        comm::disconnect
    }


    # mpd::pause --
    #
    #           Pause or resume playback
    #
    # Arguments:
    #           on      Boolean: Set to true to pause
    #
    # Results:
    #           MPD will start or stop playing
    #
    proc pause {on} {
        # Validate that on is boolean
        if {! [string is boolean $on]} {
                error "Value for on must be boolean"
        } else {
            # Since we can take different booleans, send MPD 1 or 0
            if {$on} {
                set sendValue 1
            } else {
                set sendValue 0
            }

            set msg [comm::sendCommand pause $sendValue]

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            return 0
        }
    }


    # mpd::next --
    #
    #           play next track
    #
    # arguments:
    #           none
    #
    # results:
    #           mpd will start playing the next track
    #
    proc next {} {
        set msg [comm::sendCommand "next"]

        # Check for error state
        if {[string match {ACK*} $msg]} {
            return 1
        }

        return 0
    }


    # mpd::prev --
    #
    #           Play previous track
    #
    # Arguments:
    #           none
    #
    # Results:
    #           MPD will start playing the previous track
    #
    proc prev {} {
        set msg [comm::sendCommand "previous"]

        # Check for error state
        if {[string match {ACK*} $msg]} {
            return 1
        }

        return 0
    }


    # mpd::play --
    #
    #           Play song at songpos from the queue
    #
    # Arguments:
    #           songpos Song index in the playback queue
    #
    # Results:
    #           MPD will start playing the requested song
    #
    proc play {songpos} {
        set msg [comm::sendCommand "play $songpos"]

        # Check for error state
        if {[string match {ACK*} $msg]} {
            return 1
        }

        return 0
    }


    # mpd::stop --
    #
    #           Stop playback
    #
    # Arguments:
    #           none
    #
    # Results:
    #           MPD will stop playing
    #
    proc stop {} {
        set msg [comm::sendCommand "stop"]

        # Check for error state
        if {[string match {ACK*} $msg]} {
            return 1
        }

        return 0
    }

    namespace export *
    namespace ensemble create
}
