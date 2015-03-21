#preset
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             10                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              1000   			   ;# X dimension of topography
set val(y)              1000   			   ;# Y dimension of topography  
set val(stop)		50			   ;# time of simulation end

#simulatornya
set ns [new Simulator]

set f [open wireless3_move.tr w]
$ns trace-all $f
set nf [open wireless3_move.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

$ns use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#

create-god 10

set chan_1_ [new $val(chan)]

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
		-channelType $val(chan) \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON \
                -movementTrace ON \

#posisi node
for {set i 0} {$i < $val(nn) } { incr i } {
		set n($i) [$ns node]}

#initial location

$n(0) set X_ 5
$n(0) set Y_ 100
$n(0) set Z_ 0

$n(1) set X_ 5
$n(1) set Y_ 100
$n(1) set Z_ 0

$n(2) set X_ 5
$n(2) set Y_ 100
$n(2) set Z_ 0

$n(3) set X_ 5
$n(3) set Y_ 100
$n(3) set Z_ 0

$n(4) set X_ 5
$n(4) set Y_ 100
$n(4) set Z_ 0

$n(5) set X_ 5
$n(5) set Y_ 150
$n(5) set Z_ 0

$n(6) set X_ 5
$n(6) set Y_ 150
$n(6) set Z_ 0

$n(7) set X_ 5
$n(7) set Y_ 150
$n(7) set Z_ 0

$n(8) set X_ 5
$n(8) set Y_ 150
$n(8) set Z_ 0

$n(9) set X_ 5
$n(9) set Y_ 150
$n(9) set Z_ 0

# Generation of movements
$ns at 0.5 "$n(0) setdest 999.0 100.0 100.0"
$ns at 0.8 "$n(1) setdest 800.0 100.0 90.0"
$ns at 1.0 "$n(2) setdest 600.0 100.0 80.0" 
$ns at 1.2 "$n(3) setdest 400.0 100.0 70.0" 
$ns at 1.4 "$n(4) setdest 200.0 100.0 60.0" 
$ns at 1.6 "$n(5) setdest 900.0 150.0 70.0"
$ns at 1.8 "$n(6) setdest 700.0 150.0 60.0"
$ns at 2.0 "$n(7) setdest 500.0 150.0 50.0" 
$ns at 2.2 "$n(8) setdest 300.0 150.0 40.0" 
$ns at 2.4 "$n(9) setdest 100.0 150.0 30.0" 

# Set a TCP connection between node_(0) and node_(9)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp
$ns attach-agent $n(9) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 20.0 "$ftp start" 

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $n($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$n($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 50.00 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
}

$ns run