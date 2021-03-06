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
        set msg [comm::sendCommand "commands"]
        set rights {}

        foreach {right command} $msg {
            lappend rights $command allow
        }

        # Repeat logic to grab denies
        set msg [comm::sendCommand "notcommands"]

        # Bail right now if there are no denies
        if {[string match {OK*} $msg]} {
            debug "No denies"
            debug "rights: '[lsort -stride 2 $rights]'"
            return [lsort -stride 2 $rights]
        }

        foreach {right command} $msg {
            lappend rights $command deny
        }

        debug "rights: '[lsort -stride 2 $rights]'"
        return [lsort -stride 2 $rights]
    }


    # mpd::info::currentsong --
    #
    #           Ask MPD for info on the current song
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns a key-value list of info on the current song
    #
    proc currentsong {} {
        if {[mpd is stopped]} {
            return {}
        }

        return [dict create {*}[comm::sendCommand "currentsong"]]
    }


    # mpd::info::status --
    #
    #           Ask MPD for info on its current state
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns a key-value list of the status info
    #
    proc status {} {
        return [dict create {*}[comm::sendCommand "status"]]
    }


    # mpd::info::stats --
    #
    #           Ask MPD to send us stats
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns a key-value list of various stats
    #
    proc stats {} {
        return [dict create {*}[comm::sendCommand "stats"]]
    }


    # mpd::info::replaygain --
    #
    #           Gets the current replay gain status
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns the current replay gain state
    #
    proc replaygain {} {
        set msg [comm::sendCommand "replay_gain_status"]

        return [lindex $msg end]
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

        return [msg::mkDecoderInfo $msg]
    }


    namespace export *
    namespace ensemble create
}
