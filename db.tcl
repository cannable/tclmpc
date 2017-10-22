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
    #           Perform a case-sensitive search of the MPD DB. No validation is
    #           performed on the arguments passed to this procedure. If MPD
    #           doesn't like the search query, it will tell us.
    #
    # Arguments:
    #           args    a list of arguments to pass to MPD with the root command
    #
    # Results:
    #           Returns a list of files and their attributes
    #
    proc find {args} {
        set query [msg::sanitize $args]
        debug "query: $query"
        debug "find $args"
        set msg [comm::sendCommand "find $query"]

        return [msg::mkStructuredList $msg file]
    }


    # mpd::db::search --
    #
    #           Perform a case-insensitive search of the MPD DB. No validation
    #           is performed on the arguments passed to this procedure. If MPD
    #           doesn't like the search query, it will tell us.
    #
    # Arguments:
    #           args    a list of arguments to pass to MPD with the root command
    #
    # Results:
    #           Returns a list of files and their attributes
    #
    proc search {args} {
        set query [msg::sanitize $args]
        debug "query: $query"
        debug "search $args"
        set msg [comm::sendCommand "search $query"]

        return [msg::mkStructuredList $msg file]
    }


    # mpd::db::list --
    #
    #           Retrieve a list of objects based on the passed filter and group
    #           arguments. This is a direct line to the MPD list function - no
    #           validation is performed on any of the arguments you pass to
    #           this procedure. If this errors out, you should confirm that MPD
    #           likes your query.
    #
    # Arguments:
    #           args    a list of arguments to pass to MPD with the root command
    #
    # Results:
    #           Returns a list of results from the query
    #
    proc list {args} {
        set query [msg::sanitize $args]
        set msg [comm::sendCommand "list $query"]
        set results {}

        foreach {type item} $msg {
            lappend results $item
        }

        return $results
    }


    # mpd::db::update --
    #
    #           Scan for modified files and update the DB. Scope of the scan is
    #           controlled by args: if nothing is passed, everything is
    #           scanned. Pass a file or directory to scan a fragment of the
    #           library.
    #
    # Arguments:
    #           args    URI to update
    #
    # Results:
    #           The entire DB, or the passed URI, will be rescanned by MPD.
    #           Returns a jobid.
    #
    proc update {args} {
        if {[llength $args] > 1} {
            error "Update must receive 0 or 1 arguments."
        }

        if {[llength $args]} {
            set cmd "update [msg::sanitize $args]"
        } else {
            set cmd update
        }

        set msg [comm::sendCommand $cmd]

        set jobid [msg::getValue $msg updating_db]

        debug "jobid: $jobid"
        return $jobid
    }


    namespace export *
    namespace ensemble create
}
