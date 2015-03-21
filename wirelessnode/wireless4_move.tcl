#preset
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             16                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              500  			   ;# X dimension of topography
set val(y)              500   			   ;# Y dimensionode_ of topography  
set val(stop)		265			   ;# time of simulation end

#simulatornya
set ns_ [new Simulator]

set f [open wireless4_move.tr w]
$ns_ trace-all $f
set nf [open wireless4_move.nam w]
$ns_ namtrace-all-wireless $nf $val(x) $val(y)

$ns_ use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#

create-god 16

set chan_1_ [new $val(chan)]

$ns_ node-config -adhocRouting $val(rp) \
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

#node
for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns_ node]}

#panggil tcl sumo
source "mobility.tcl"

# Set a TCP connection between node_(0) and node_(9)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(9) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 2.0 "$ftp start" 

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns_ initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns_ at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"
$ns_ at 10.00 "puts \"end simulation\" ; $ns_ halt"
proc stop {} {
    global ns_ f nf
    $ns_ flush-trace
    close $f
    close $nf
}

$ns_ run