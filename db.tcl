#! /usr/bin/env tclsh

# db.tcl --
#
#     Provides mpd db namespace functions for tclmpc.
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

package provide tclmpc::db 0.1

namespace eval mpd::db {


    # mpd::db::find --
    #
    #           Perform a case-sensitive search of the MPD DB.
    #
    # Arguments:
    #           none
    #
    # Results:
    #           MPD will send us a message with the requested info
    #
    proc find {args} {
        set query [regsub -all -- {\{|\}} $args \"]
        debug "db::find>query: $query"
        debug "db::find>find $args"
        set msg [comm::sendCommand "find $query"]

        # Check for error state
        if {[string match {ACK*} $msg]} {
            error [msg::decodeAck $msg]
        }

        return [msg::parseFileList $msg]
    }


    # mpd::db::search --
    #
    #           Perform a case-insensitive search of the MPD DB.
    #
    # Arguments:
    #           none
    #
    # Results:
    #           MPD will send us a message with the requested info
    #
    proc search {args} {
        set query [regsub -all -- {\{|\}} $args \"]
        debug "db::search>query: $query"
        debug "db::search>search $args"
        set msg [comm::sendCommand "search $query"]

        # Check for error state
        if {[string match {ACK*} $msg]} {
            error [msg::decodeAck $msg]
        }

        return [msg::parseFileList $msg]
    }

    namespace export *
    namespace ensemble create
}
