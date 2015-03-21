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
set val(x)              500   			   ;# X dimension of topography
set val(y)              400   			   ;# Y dimension of topography  
set val(stop)		10			   ;# time of simulation end

#simulatornya
set ns [new Simulator]

set f [open wireless3.tr w]
$ns trace-all $f
set nf [open wireless3.nam w]
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

$n(0) set X_ 1000
$n(0) set Y_ 100
$n(0) set Z_ 0

$n(1) set X_ 800
$n(1) set Y_ 100
$n(1) set Z_ 0

$n(2) set X_ 600
$n(2) set Y_ 100
$n(2) set Z_ 0

$n(3) set X_ 400
$n(3) set Y_ 100
$n(3) set Z_ 0

$n(4) set X_ 200
$n(4) set Y_ 100
$n(4) set Z_ 0

$n(5) set X_ 900
$n(5) set Y_ 300
$n(5) set Z_ 0

$n(6) set X_ 700
$n(6) set Y_ 300
$n(6) set Z_ 0

$n(7) set X_ 500
$n(7) set Y_ 300
$n(7) set Z_ 0

$n(8) set X_ 300
$n(8) set Y_ 300
$n(8) set Z_ 0

$n(9) set X_ 100
$n(9) set Y_ 300
$n(9) set Z_ 0

# Set a TCP connection between node_(0) and node_(9)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp
$ns attach-agent $n(9) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 01.0 "$ftp start" 

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
$ns at 10.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
}

$ns run