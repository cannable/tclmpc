#! /usr/bin/env tclsh

# tclmpc.tcl --
#
#     Provides playback functions for tclmpc.
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

package provide tclmpc::playback 0.1


namespace eval mpd {
    namespace eval is {

        # mpd::is::playing --
        #
        #           See if MPD is playing
        #
        # Arguments:
        #           none
        #
        # Results:
        #           Returns 1 if MPD is playing
        #
        proc playing {} {
            set state [msg::getValue [mpd info status] state]

            if {[string match play $state]} {
                return 1
            }

            return 0
        }


        # mpd::is::paused --
        #
        #           See if MPD is paused
        #
        # Arguments:
        #           none
        #
        # Results:
        #           Returns 1 if MPD is paused
        #
        proc paused {} {
            set state [msg::getValue [mpd info status] state]

            if {[string match pause $state]} {
                return 1
            }

            return 0
        }


        # mpd::is::stopped --
        #
        #           See if MPD is stopped
        #
        # Arguments:
        #           none
        #
        # Results:
        #           Returns 1 if MPD is stopped
        #
        proc stopped {} {
            set state [msg::getValue [mpd info status] state]

            if {[string match stop $state]} {
                return 1
            }

            return 0
        }


        namespace export *
        namespace ensemble create
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

            return [comm::simpleSendCommand pause $sendValue]
        }
    }


    # mpd::toggle --
    #
    #           Toggle playback
    #
    # Arguments:
    #           none
    #
    # Results:
    #           If MPD is paused, it will start playing; if it is playing, it
    #           will pause.
    #
    proc toggle {} {
        if {[mpd is playing]} {
            debug Pausing
            mpd pause 1
        } else {
            if {[mpd is stopped]} {
                # Play the current song
                set songpos [msg::getValue [mpd info status] Pos]
                mpd play $songpos
            } else {
                debug Unpausing
                mpd pause 0
            }
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
        comm::simpleSendCommand next
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
        comm::simpleSendCommand previous
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
        comm::simpleSendCommand "play $songpos"
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
        comm::simpleSendCommand stop
    }


    # mpd::seek --
    #
    #           Seek in the current song
    #
    # Arguments:
    #           s   Seconds to seek. Can be negative and fractional.
    #
    # Results:
    #           Returns 0 if the seek was successful, 1 otherwise.
    #
    proc seek {s} {
        # Immediately bail if we're not playing
        if {![mpd is playing]} {
            return 1
        }

        # Likewise, bail if we didn't get a double in s
        if {![string is double $s]} {
            error "Seek seconds must be a double.'
        }

        return [comm::simpleSendCommand "seekcur $s"]
    }


    namespace export *
    namespace ensemble create
}

