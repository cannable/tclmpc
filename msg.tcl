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

        foreach {key value} $data {
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


    # msg:checkReply --
    #
    #           Checks a reply from MPD to see if the corresponding command
    #           sent was successful. This is a helper proc for the simple
    #           send-command-then-wait-for-OK procedures. There are many such
    #           procs in this library, so I want to reduce as much copy &
    #           pasted code as possible.
    #
    # Arguments:
    #           command The command to which this is a reply
    #           reply   Message back from MPD
    #
    # Results:
    #           This is mostly just a debugging procedure to make message
    #           content easier to read.
    #
    proc checkReply {reply} {
        # Check for error state
        if {[string match {ACK*} $reply]} {
            return 1
        }

        return 0
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
    #           Given a reply string, return the value for the passed, key.
    #           This is a really stupid function, as it could match against a
    #           value and the next pair's key. This should be fine within the
    #           context of MPD, but I'm probably going to re-write it.
    #
    # Arguments:
    #           msg list-format reply string
    #
    # Results:
    #           0 if no value found
    #           Otherwise, the value of the requested key
    #
    proc getValue {reply key} {
        # TODO: Re-write this so that it is less stupid
        set index [lsearch $reply $key]

        # MPD doesn't always return the status of config items that are off
        # As a result, assume that anything not included in the data is 0
        if {$index < 0} {
            return 0
        }
        return [lindex $reply $index+1]
    }


    # msg::mkStructuredList --
    #
    #           Creates a structured list from a flat, unstructured one.
    #           Extracts list items between marker indexes, then lappends the
    #           extracted items as a new list item.
    #
    # Arguments:
    #           data    Flat list of many objects
    #           marker  List element that indicates the start of a list of
    #                   related attributes
    #
    # Results:
    #           Returns a multi-level list 
    #
    proc mkStructuredList {data marker} {
        set output {}

        # Find all file keys
        set keys [lsearch -exact -all $data $marker]

        debug "keys: $keys"

        # If we only have one key, return right away
        if {[llength $keys] == 1} {
            debug "There's only one item in this list. Returning."
            return [list $data]
        }

        # Guess at the length of each record
        set recordLength [expr [lindex $keys 1] - 1]

        debug "recordLength: $recordLength"

        # Extract list elements between markers, appending them to output
        foreach index $keys {
            set itemInfo [lrange $data $index [expr $index + $recordLength]]
            lappend output $itemInfo
        }

        debug "output: '$output'"

        return $output
    }
}
