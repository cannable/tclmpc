#! /usr/bin/env tclsh

# config.tcl --
#
#     Provides config namespace functions for tclmpc.
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

package provide tclmpc::config 0.1


namespace eval mpd::config {


    # mpd::config::consume --
    #
    #           Enables/Disables consume mode
    #
    # Arguments:
    #           on  Boolean
    #
    # Results:
    #           Returns 0 if the config change was successful; 1 otherwise
    #
    proc consume {on} {
        # Validate 'on'
        if {![string is boolean $on]} {
            return 1
        }

        # Since we can take different booleans, send MPD 1 or 0
        if {$on} {
            set sendValue 1
        } else {
            set sendValue 0
        }

        # Send the config change command
        set msg [comm::sendCommand "consume $sendValue"]

        # Verify the config change happened
        set consume [msg::getValue [mpd info status] consume]
        if {$consume!=$sendValue} {
            debug "Failed to change consume"
            return 1
        }

        debug "Succeeded in changing consume"
        return 0
    }


    # mpd::config::random --
    #
    #           Enables/Disables random mode
    #
    # Arguments:
    #           on  Boolean
    #
    # Results:
    #           Returns 0 if the config change was successful; 1 otherwise
    #
    proc random {on} {
        # Validate 'on'
        if {![string is boolean $on]} {
            return 1
        }

        # Since we can take different booleans, send MPD 1 or 0
        if {$on} {
            set sendValue 1
        } else {
            set sendValue 0
        }

        # Send the config change command
        set msg [comm::sendCommand "random $sendValue"]

        # Verify the config change happened
        set consume [msg::getValue [mpd info status] random]
        if {$consume!=$sendValue} {
            debug "Failed to change random"
            return 1
        }

        debug "Succeeded in changing random"
        return 0
    }


    # mpd::config::repeat --
    #
    #           Enables/Disables repeat mode
    #
    # Arguments:
    #           on  Boolean
    #
    # Results:
    #           Returns 0 if the config change was successful; 1 otherwise
    #
    proc repeat {on} {
        # Validate 'on'
        if {![string is boolean $on]} {
            return 1
        }

        # Since we can take different booleans, send MPD 1 or 0
        if {$on} {
            set sendValue 1
        } else {
            set sendValue 0
        }

        # Send the config change command
        set msg [comm::sendCommand "repeat $sendValue"]

        # Verify the config change happened
        set consume [msg::getValue [mpd info status] repeat]
        if {$consume!=$sendValue} {
            debug "Failed to change repeat"
            return 1
        }

        debug "Succeeded in changing repeat"
        return 0
    }


    # mpd::config::single --
    #
    #           Enables/Disables single mode
    #
    # Arguments:
    #           on  Boolean
    #
    # Results:
    #           Returns 0 if the config change was successful; 1 otherwise
    #
    proc single {on} {
        # Validate 'on'
        if {![string is boolean $on]} {
            return 1
        }

        # Since we can take different booleans, send MPD 1 or 0
        if {$on} {
            set sendValue 1
        } else {
            set sendValue 0
        }

        # Send the config change command
        set msg [comm::sendCommand "single $sendValue"]

        # Verify the config change happened
        set consume [msg::getValue [mpd info status] single]
        if {$consume!=$sendValue} {
            debug "Failed to change single"
            return 1
        }

        debug "Succeeded in changing single"
        return 0
    }


    # mpd::config::setvol --
    #
    #           Set the output volume
    #
    # Arguments:
    #           vol Output volume. 0-100
    #
    # Results:
    #           Returns 0 if the volume change was successful; 1 otherwise
    #
    proc setvol {vol} {
        # Validate 'vol'
        if {![string is integer $vol]} {
            return 1
        }

        if {($vol<0) | ($vol>100)} {
            return 1
        }

        # Send the config change command
        set msg [comm::sendCommand "setvol $vol"]

        # Verify the config change happened
        set mpdvol [msg::getValue [mpd info status] volume]
        if {$mpdvol!=$vol} {
            debug "Failed to set volume"
            return 1
        }

        debug "Succeeded in setting volume"
        return 0
    }


    # mpd::config::crossfade --
    #
    #           Set the crossfade duration
    #
    # Arguments:
    #           s   Crossfade duration in seconds
    #
    # Results:
    #           Returns 0 if the change was successful; 1 otherwise
    #
    proc crossfade {s} {
        # Validate 's'
        if {![string is double $s]} {
            return 1
        }

        # Send the config change command
        set msg [comm::sendCommand "crossfade $s"]

        # Verify the config change happened
        set xfade [msg::getValue [mpd info status] xfade]
        if {$xfade!=$s} {
            debug "Failed to set crossfade duration"
            return 1
        }

        debug "Succeeded in setting crossfade duration"
        return 0
    }


    # mpd::config::replaygain --
    #
    #           Set the crossfade duration
    #
    # Arguments:
    #           state   Replaygain state, where state=off,track,album,auto
    #
    # Results:
    #           Returns 0 if the change was successful; 1 otherwise
    #
    proc replaygain {state} {
        # Validate 'state'
        if {[lsearch {off track album auto} $state] < 0} {
            return 1
        }

        # Send the config change command
        set msg [comm::sendCommand "replay_gain_mode $state"]

        # Verify the config change happened
        set msg [comm::sendCommand "replay_gain_status"]

        set rgstate [msg::getValue $msg replay_gain_state]
        if {[string match $state $rgstate]} {
            debug "Failed to set replaygain state"
            return 1
        }

        debug "Succeeded in setting replaygain state"
        return 0
    }


    namespace export *
    namespace ensemble create
}
