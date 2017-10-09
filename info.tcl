#! /usr/bin/env tclsh

# info.tcl --
#
#     Provides mpd info namespace functions for tclmpc.
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

package provide tclmpc::info 0.1

namespace eval mpd::info {


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


    # mpd::info::decoders --
    #
    #           Gets a list of lists of decoder info
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns a list of decoders and their details (lists)
    #
    proc decoders {} {
        set msg [comm::sendCommand "decoders"]

        # Check for error state
        if {[string match {ACK*} $msg]} {
            return 1
        }

        return [msg::mkStructuredList $msg plugin]
    }


    namespace export *
    namespace ensemble create
}
