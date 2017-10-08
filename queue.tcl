#! /usr/bin/env tclsh

# queue.tcl --
#
#     Provides queue namespace functions for tclmpc.
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

package provide tclmpc::queue 0.1


namespace eval mpd::queue {


    # mpd::queue::clear --
    #
    #           Purge the play queue
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns 0 if the queue was purged; 1 otherwise
    #
    proc clear {} {
        return [msg::checkReply [comm::sendCommand clear]]
    }


    # mpd::queue::info --
    #
    #           Get track info for the play queue
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns 0 if the queue was purged; 1 otherwise
    #
    proc info {} {
        set msg [comm::sendCommand "playlistinfo"]
        set queueTracks {}

        # Find all file keys
        set filekeys [lsearch -exact -all $msg file]

        # Guess at the length of each record
        set recordLength [expr [lindex $filekeys 1] - 1]

        # Extract the track info at each offset and assemble a list of
        # lists for track info
        foreach index $filekeys {
            set trackInfo [lrange $msg $index [expr $index + $recordLength]]
            lappend queueTracks $trackInfo
        }

        # Check for error state
        if {[string match {ACK*} $msg]} {
            return 1
        }

        return $queueTracks
    }


    # mpd::queue::shuffle --
    #
    #           Shuffle the play queue
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns 0 if the queue was shuffled; 1 otherwise
    #
    proc shuffle {} {
        return [msg::checkReply [comm::sendCommand shuffle]]
    }

    namespace export *
    namespace ensemble create
}