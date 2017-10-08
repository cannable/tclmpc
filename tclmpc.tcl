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
package provide tclmpc 0.1

# Define this proc in your code to test the library
proc debug {text} {
    #puts "DEBUG:$text"
}


namespace eval mpd {

    namespace eval info {
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
            set allDecoders {}

            # Find all file keys
            set keys [lsearch -exact -all $msg plugin]

            # Guess at the length of each record
            set recordLength [expr [lindex $keys 1] - 1]

            # Extract the track info at each offset and assemble a list of
            # lists for track info
            foreach index $keys {
                set decInfo [lrange $msg $index [expr $index + $recordLength]]
                lappend allDecoders $decInfo
            }

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            return $allDecoders
        }


        namespace export *
        namespace ensemble create
    }


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

            return [msg::checkReply [comm::sendCommand pause $sendValue]]
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
        return [msg::checkReply [comm::sendCommand next]]
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
        return [msg::checkReply [comm::sendCommand previous]]
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
        return [msg::checkReply [comm::sendCommand "play $songpos"]]
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
        return [msg::checkReply [comm::sendCommand stop]]
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

        return [msg::checkReply [comm::sendCommand "seekcur $s"]]
    }


    namespace eval config {


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

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            # Verify the config change happened
            set consume [msg::getValue [mpd info status] consume]
            if {$consume!=$sendValue} {
                debug "consume>Failed to change consume"
                return 1
            }

            debug "consume>Succeeded in changing consume"
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

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            # Verify the config change happened
            set consume [msg::getValue [mpd info status] random]
            if {$consume!=$sendValue} {
                debug "random>Failed to change random"
                return 1
            }

            debug "random>Succeeded in changing random"
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

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            # Verify the config change happened
            set consume [msg::getValue [mpd info status] repeat]
            if {$consume!=$sendValue} {
                debug "repeat>Failed to change repeat"
                return 1
            }

            debug "repeat>Succeeded in changing repeat"
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

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            # Verify the config change happened
            set consume [msg::getValue [mpd info status] single]
            if {$consume!=$sendValue} {
                debug "single>Failed to change single"
                return 1
            }

            debug "single>Succeeded in changing single"
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

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            # Verify the config change happened
            set mpdvol [msg::getValue [mpd info status] volume]
            if {$mpdvol!=$vol} {
                debug "single>Failed to set volume"
                return 1
            }

            debug "single>Succeeded in setting volume"
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

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            # Verify the config change happened
            set xfade [msg::getValue [mpd info status] xfade]
            if {$xfade!=$s} {
                debug "single>Failed to set crossfade duration"
                return 1
            }

            debug "single>Succeeded in setting crossfade duration"
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

            # Check for error state
            if {[string match {ACK*} $msg]} {
                return 1
            }

            # Verify the config change happened
            set msg [comm::sendCommand "replay_gain_status"]

            set rgstate [msg::getValue $msg replay_gain_state]
            if {[string match $state $rgstate]} {
                debug "replaygain>Failed to set replaygain state"
                return 1
            }

            debug "replaygain>Succeeded in setting replaygain state"
            return 0
        }


        namespace export *
        namespace ensemble create
    }

    namespace eval queue {


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
    namespace export *
    namespace ensemble create
}

