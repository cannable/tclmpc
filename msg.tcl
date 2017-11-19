#! /usr/bin/env tclsh

# msg.tcl --
#
#     Provides msg namespace functions for tclmpc.
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

package provide tclmpc::msg 0.1


namespace eval msg {


    # msg::printReply --
    #
    #           Prints nicely-formatted messages to stdout
    #
    # Arguments:
    #           title   String to show in the title field
    #           data    key-value list data to show
    #
    # Results:
    #           This is mostly just a debugging procedure to make message
    #           content easier to read.
    #
    proc printReply {title data} {
        puts [string repeat - 20]
        puts ">>> $title <<<"

        dict for {key value} $data {
            puts "|$key|$value|"
        }

        puts [string repeat - 20]
    }


    # msg::printFileList --
    #
    #           Prints a nicely-formatted list of files to stdout
    #
    # Arguments:
    #           data    File info list
    #
    # Results:
    #           Prints the file list to stdout. This is here mostly for
    #           debugging purposes.
    #
    proc printFileList {data} {
        foreach file $data {
            puts [string repeat - 20]
            puts ">>> [getValue $file Title] <<<"

            foreach {key value} $file {
                puts "|$key|$value|"
            }
        }
        puts [string repeat - 20]
    }


    # msg::decodeReply --
    #
    #           Assembles a key-value list of message contents.
    #
    # Arguments:
    #           reply   Message back from MPD
    #
    # Results:
    #           Takes the "key: value" message format and returns the data in
    #           list form.
    #
    proc decodeReply {reply} {
        set elements {}

        foreach line $reply {
            regexp -- {([^:]+): (.+)$} $line -> key value
            debug "'$key'->'$value'"
            lappend elements $key $value
        }

        return $elements
    }


    # msg::decodeAck --
    #
    #           Decodes ACK message (errors)
    #
    # Arguments:
    #           reply   Message back from MPD
    #
    # Results:
    #           Return an ack key-value list
    #
    proc decodeAck {reply} {

#ACK [error@command_listNum] {current_command} message_text\n

        regexp -- \
                {^ACK *\[([^@]+)@([^]]+)] * \{([^\}]*)\} (.*)} \
                $reply -> \
                ack(error) \
                ack(commandList) \
                ack(command) \
                ack(messageText)
        debug "ack: '[array get ack]'"

        return [array get ack]
    }


    # msg::getValue --
    #
    #           Simple wrapper around dict get to return 0 if no key exists.
    #
    # Arguments:
    #           data    dict, key-value, data
    #           key     key to retrieve
    #
    # Results:
    #           Returns the value of the requested key.
    #           If the key doesn't exist, return 0
    #
    proc getValue {data key} {

        # MPD doesn't always return the status of config items that are off
        # As a result, assume that anything not included in the data is 0
        if {![dict exists $data $key]} {
            return 0
        }

        return [dict get $data $key]
    }


    # msg::mkTrackInfo --
    #
    #           Assembles a multi-level dict from a flat key-value list.
    #           Extracts list items between marker indexes and inserts this
    #           into a dict. Specifically, this proc creates trackInfo-format
    #           dicts. To stay out of danger, read through some of the
    #           pre-canned structures in the documentation.
    #
    # Arguments:
    #           data    Flat list of many tracks
    #
    # Results:
    #           Returns a multi-level dict
    #
    proc mkTrackInfo {data} {
        set output [dict create]

        # Find all file keys
        set keys [lsearch -exact -all $data file]

        debug "keys: $keys"

        # If we only have one key, return right away
        if {[llength $keys] == 1} {
            debug "There's only one item in this list. Returning."

            dict set output 0 $data

            return $output
        }

        # Guess at the length of each record
        set recordLength [expr [lindex $keys 1] - 1]

        debug "recordLength: $recordLength"

        # Extract list elements between markers, appending them to output
        set counter -1
        foreach index $keys {
            set key [lindex $data $index+1]
            set itemInfo [lrange $data $index [expr $index + $recordLength]]
            dict set output [incr counter] $itemInfo
        }

        return $output
    }


    # msg::mkDecoderInfo --
    #
    #           Assembles a multi-level dict from a flat key-value list.
    #           Extracts list items between marker indexes and inserts this
    #           into a decoderInfo dict.
    #
    # Arguments:
    #           data    Flat list of many tracks
    #
    # Results:
    #           Returns a multi-level dict
    #
    proc mkDecoderInfo {data} {
        set output [dict create]

        set pluginData [dict create]
        set counter -1

        foreach {key value} $data {
            if {[string match plugin $key]} {
                # Found new plugin
                debug "New plugin"
                debug "dict size: '[dict size $pluginData]'"
                if {[dict size $pluginData]} {
                    # Stash data for last plugin
                    debug "dict set output [incr counter] $pluginData"
                    dict set output [incr counter] $pluginData
                }

                # Reset data for new plugin
                set pluginData [dict create]
                dict set pluginData $key $value
            } else {
                # Tack on data to this plugin
                dict lappend pluginData $key $value
            }
         }

        # Stash data for last plugin
        dict set output [incr counter] $pluginData

        return $output

    }


    # msg::mkStructuredList --
    #
    #           Assembles a multi-level dict from a flat key-value list.
    #           Extracts list items between marker indexes and inserts this
    #           into a dict.
    #
    #           NOTE: This can be dangerous. Only use this proc on data where
    #           the marker field is unique (as in, a proper index). For
    #           converting track data into trackInfo structures, see the
    #           mkTrackInfo proc.
    #
    # Arguments:
    #           data    Flat list of many objects
    #           marker  List element that indicates the start of a list of
    #                   related attributes
    #
    # Results:
    #           Returns a multi-level dict
    #
    proc mkStructuredList {data marker} {
        set output [dict create]

        # Find all file keys
        set keys [lsearch -exact -all $data $marker]

        debug "keys: $keys"

        # If we only have one key, return right away
        if {[llength $keys] == 1} {
            debug "There's only one item in this list. Returning."

            dict set output [lindex $data 1] $data

            return $output
        }

        # Guess at the length of each record
        set recordLength [expr [lindex $keys 1] - 1]

        debug "recordLength: $recordLength"

        # Extract list elements between markers, appending them to output
        foreach index $keys {
            set key [lindex $data $index+1]
            set itemInfo [lrange $data $index [expr $index + $recordLength]]

            dict set output $key $itemInfo
        }

        return $output
    }


    # msg::sanitize --
    #
    #           Alters the passed string to make it comply with the formatting
    #           that MPD expects.
    #
    #           ex. Replace all curly braces with double quotes.
    #
    # Arguments:
    #           string  String to manipulate
    #
    # Results:
    #           Returns a "cleaned" string
    #
    proc sanitize {string} {
        return [regsub -all -- {\{|\}} $string \"]
    }
}
