#! /usr/bin/env tclsh

# comm.tcl --
#
#     Provides comm namespace functions for tclmpc.
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

package provide tclmpc::comm 0.1


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
        debug "Connecting to $server:$port"
        variable mpd_socket

        if {! [string length $mpd_socket]} {
            set mpd_socket [socket $server $port]
            gets $mpd_socket banner
            debug "MPD Banner: '$banner'"

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
            debug "Sending command: '$command' '$args'"
            puts $mpd_socket "$command $args"
        } else {
            debug "Sending single command: '$command'"
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
                debug "OK: '$line'"
                return $line
            }
            {ACK*} {
                # MPD has told us something is horribly wrong
                set cmdline $command

                if {[string length $args]} {
                    append cmdline $args
                }

                return \
                    -code error \
                    -errorinfo [format "%s\nCommand:\t'%s'\nResponse:\t'%s'" \
                        "MPD threw an error after we sent it a directive." \
                        "$cmdline" \
                        $line]
            }
        }

        lappend message "$line"
        # There's more data to get, read from the socket until we get an 'OK'
        while {![string match OK $line]} {
            gets $mpd_socket line
            debug "line: '$line"

            if {![string match OK $line]} { 
                lappend message "$line"
            }
        }

        debug "Received: '$message'"
        return [msg::decodeReply $message]
    }
}
