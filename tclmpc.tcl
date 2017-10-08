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

package require tclmpc::comm 0.1
package require tclmpc::msg 0.1
package require tclmpc::info 0.1
package require tclmpc::config 0.1
package require tclmpc::queue 0.1
package require tclmpc::playback 0.1

package provide tclmpc 0.1

# Define this proc in your code to test the library
proc debug {text} {
    #puts "DEBUG:$text"
}


namespace eval mpd {


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


    namespace export *
    namespace ensemble create
}

