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
        comm::simpleSendCommand clear
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
        return [msg::mkStructuredList $msg file]
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
        comm::simpleSendCommand shuffle
    }


    # mpd::queue::add --
    #
    #           Add song or directory (recursive) contents to the queue
    #
    # Arguments:
    #           uri     Path to the file/directory to add to the queue
    #
    # Results:
    #           Returns 0 if the track/directory was added; 1 otherwise
    #
    proc add {uri} {
        comm::simpleSendCommand [format {add "%s"} [msg::sanitize $uri]]
    }


    # mpd::queue::insert --
    #
    #           Inserts a track into the play queue
    #
    # Arguments:
    #           uri     Path to the file to add to the queue
    #           pos     Insertion position
    #
    # Results:
    #           Returns id
    #
    proc insert {uri pos} {
        set cmdline [format {addid "%s" %s} [msg::sanitize $uri] $pos]
        set msg [comm::sendCommand $cmdline]

        debug "Inserted at [lindex $msg end]"

        return [lindex $msg end]
    }


    # mpd::queue::delete --
    #
    #           Removes track(s) from the play queue
    #
    # Arguments:
    #           pos     Position or range for deletion
    #                   ex. 5 or 3:7
    #
    # Results:
    #           Removes the requested track(s) from the play queue
    #
    proc delete {pos} {
        comm::simpleSendCommand "delete $pos"
    }


    # mpd::queue::deleteid --
    #
    #           Remove track from the play queue by ID
    #
    # Arguments:
    #           id      Track ID to remove
    #
    # Results:
    #           Removes the requested track from the play queue
    #
    proc deleteid {id} {
        comm::simpleSendCommand "deleteid $id"
    }


    namespace export *
    namespace ensemble create

}
