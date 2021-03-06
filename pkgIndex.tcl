if {![package vsatisfies [package provide Tcl] 8.5]} {
    error "tclmpc requires Tcl 8.5+."
}

package ifneeded tclmpc 0.1 [list source [file join $dir tclmpc.tcl]]
package ifneeded tclmpc::comm 0.1 [list source [file join $dir comm.tcl]]
package ifneeded tclmpc::msg 0.1 [list source [file join $dir msg.tcl]]
package ifneeded tclmpc::info 0.1 [list source [file join $dir info.tcl]]
package ifneeded tclmpc::config 0.1 [list source [file join $dir config.tcl]]
package ifneeded tclmpc::queue 0.1 [list source [file join $dir queue.tcl]]
package ifneeded tclmpc::playback 0.1 [list source [file join $dir playback.tcl]]
package ifneeded tclmpc::db 0.1 [list source [file join $dir db.tcl]]
package ifneeded tclmpc::output 0.1 [list source [file join $dir output.tcl]]
package ifneeded tclmpc::playlist 0.1 [list source [file join $dir playlist.tcl]]
