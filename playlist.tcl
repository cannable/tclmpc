#! /usr/bin/env tclsh

# playlist.tcl --
#
#     Provides mpd playlist namespace functions for tclmpc.
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

package provide tclmpc::playlist 0.1

namespace eval mpd::playlist {


    # mpd::playlist::list --
    #
    #           Get a list of all playlists in MPD
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns a list of all playlists.
    #
    proc list {} {
        set msg [comm::sendCommand listplaylists]

        # Bail right now if there are no denies
        if {[string match {OK*} $msg]} {
            debug "No playlists"
            return {}
        }

        # Assemble a playlistList dict
        # TODO: Add in track info for each playlist
        return [msg::mkStructuredList $msg playlist]
    }


    # mpd::playlist::info --
    #
    #           Retrieves the track info for the passed playlist
    #
    # Arguments:
    #           name    Name of the playlist
    #
    # Results:
    #           Returns a trackInfo dict for the passed playlist
    #
    proc info {name} {
        # Check for existing playlist
        if {![mpd playlist exists $name]} {
            return \
                -code error \
                -errorinfo "Playlist '$name' does not exist."
        }

        # This is a two-step process because of the phrasing used in the MPD
        # docs for listplaylistinfo. Specifically, "lists the songs with
        # metadata in the playlist." This implies that files without metadata
        # will not be returned. Just in case, we're doing this two-pass.

        # Step 1: Get the track list
        set cmd [format {listplaylist "%s"} [msg::sanitize $name]]
        set msg [comm::sendCommand {*}$cmd]

        # The playlist contains no tracks, return an empty dict
        if {[string match {OK*} $msg]} {
            return [dict create]
        }

        set tracks [msg::mkTrackInfo $msg]

        # Step 2: Get metadata
        set cmd [format {listplaylistinfo "%s"} [msg::sanitize $name]]
        set msg [comm::sendCommand {*}$cmd]

        set trackInfo [msg::mkTrackInfo $msg]

        return [dict merge $tracks $trackInfo]
    }


    # mpd::playlist::allInfo --
    #
    #           Retrieves all track info for all playlists. This is here for
    #           convenience.
    #
    # Arguments:
    #           none
    #
    # Results:
    #           Returns a playlistInfo dict with trackInfo dicts stashed in the
    #           Tracks
    #
    proc allInfo {} {
        set playlistInfo [mpd playlist list]

        # Loop through each playlist and tack on track info
        dict for {playlist data} $playlistInfo {
            set trackInfo [mpd playlist info $playlist]
            dict set playlistInfo $playlist Tracks $trackInfo
        }

        return $playlistInfo
    }


    # mpd::playlist::exists --
    #
    #           Check to see if the passed playlist name exists
    #
    # Arguments:
    #           name
    #
    # Results:
    #           Returns 1 if the playlist exists, 0 otherwise
    #
    proc exists {name} {
        dict exists [mpd playlist list] $name
    }


    # mpd::playlist::save --
    #
    #           Save the current queue as a new playlist
    #
    # Arguments:
    #           name    Name of the playlist to create
    #
    # Results:
    #           Returns 0 if the playlist was successfully created.
    #
    proc save {name} {
        # Check for existing playlist
        if {[mpd playlist exists $name]} {
            return \
                -code error \
                -errorinfo "Playlist '$name' already exists."
        }

        comm::simpleSendCommand [format {save "%s"} [msg::sanitize $name]]
    }


    # mpd::playlist::rm --
    #
    #           Remove a playlist
    #
    # Arguments:
    #           name    Name of the playlist to remove
    #
    # Results:
    #           Returns 0 if the playlist was successfully removed.
    #
    proc rm {name} {
        # Check for existing playlist
        if {![mpd playlist exists $name]} {
            return \
                -code error \
                -errorinfo "Playlist '$name' does not exist."
        }

        comm::simpleSendCommand [format {rm "%s"} [msg::sanitize $name]]
    }


    # mpd::playlist::clear --
    #
    #           Wipe the contents a playlist
    #
    # Arguments:
    #           name    Name of the playlist to blank
    #
    # Results:
    #           Returns 0 if the playlist was successfully cleared.
    #
    proc clear {name} {
        # Check for existing playlist
        if {![mpd playlist exists $name]} {
            return \
                -code error \
                -errorinfo "Playlist '$name' does not exist."
        }

        set cmd [format {playlistclear "%s"} [msg::sanitize $name]]
        return [comm::simpleSendCommand {*}$cmd]
    }


    # mpd::playlist::append --
    #
    #           Append the contents of playlist into the play queue
    #
    # Arguments:
    #           name    Name of the playlist to load
    #
    # Results:
    #           Returns 0 if the playlist was successfully appended.
    #
    proc append {name} {
        # Check for existing playlist
        if {![mpd playlist exists $name]} {
            return \
                -code error \
                -errorinfo "Playlist '$name' does not exist."
        }

        set cmd [format {load "%s"} [msg::sanitize $name]]
        return [comm::simpleSendCommand {*}$cmd]
    }


    # mpd::playlist::load --
    #
    #           Load the contents of playlist into the play queue, emptying the
    #           queue in the process.
    #
    #           NOTE: This is a break from the expected behaviour when thinking
    #           in an MPD mindset - MPD will 'load' a playlist by appending the
    #           tracks to the end of the queue. To make this more Tcl-like,
    #           this was implemented as mpd::playlist::append instead.
    #
    # Arguments:
    #           name    Name of the playlist to load
    #
    # Results:
    #           Returns 0 if the playlist was successfully loaded.
    #
    proc load {name} {
        # Check for existing playlist
        if {![mpd playlist exists $name]} {
            return \
                -code error \
                -errorinfo "Playlist '$name' does not exist."
        }

        mpd queue clear
        return [mpd playlist append $name]
    }


    # mpd::playlist::rename --
    #
    #           Rename a playlist
    #
    # Arguments:
    #           name    Current name of the playlist
    #           newName Future name of the playlist
    #
    # Results:
    #           Returns 0 if the playlist was successfully renamed.
    #
    proc rename {name newName} {
        # Check for existing playlists
        if {![mpd playlist exists $name]} {
            return \
                -code error \
                -errorinfo "Playlist '$name' does not exist."
        }

        if {[mpd playlist exists $newName]} {
            return \
                -code error \
                -errorinfo "Playlist '$newName' exists."
        }

        set cmd [format {rename "%s" "%s"} \
            [msg::sanitize $name] \
            [msg::sanitize $newName]]

        return [comm::simpleSendCommand {*}$cmd]
    }


    namespace export *
    namespace ensemble create

}
