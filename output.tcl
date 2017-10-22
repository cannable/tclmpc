#! /usr/bin/env tclsh

# output.tcl --
#
#     Provides mpd output namespace functions for tclmpc.
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

package provide tclmpc::output 0.1

namespace eval mpd::output {


    # mpd::output::list --
    #
    #           Returns a list of MPD outputs
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns a list of MPD outputs and related atributes
    #
    proc list {} {
        set msg [comm::sendCommand "outputs"]

        debug "msg: $msg"

        return [msg::mkStructuredList $msg outputid]
    }


    # mpd::output::disable --
    #
    #           Disable output
    #
    # Arguments:
    #           id  Output ID
    #
    # Results:
    #           MPD will disable the passed output
    #
    proc disable {id} {
        comm::simpleSendCommand "disableoutput $id"
    }


    # mpd::output::enable --
    #
    #           Enable output
    #
    # Arguments:
    #           id  Output ID
    #
    # Results:
    #           MPD will enable the passed output
    #
    proc enable {id} {
        comm::simpleSendCommand "enableoutput $id"
    }


    # mpd::output::toggle --
    #
    #           Toggle output
    #
    # Arguments:
    #           id  Output ID
    #
    # Results:
    #           MPD will enable or disable the passed output
    #
    proc toggle {id} {
        comm::simpleSendCommand "toggleoutput $id"
    }


    namespace export *
    namespace ensemble create
}
