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

set f [open wireless5_udp.tr w]
$ns trace-all $f
set nf [open wireless5_udp.nam w]
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

#transmission range
#Phy/WirelessPhy set CPThresh_ 10.0
#Phy/WirelessPhy set CSThresh_ 19.21756e-11 ;#550m
#Phy/WirelessPhy set RXThresh_ 14.4613e-10 ;#250m
#Phy/WirelessPhy set bandwidth_ 512kb
#Phy/WirelessPhy set Pt_ 0.2818
#Phy/WirelessPhy set freq_ 2.4e+9
#Phy/WirelessPhy set L_ 1.0
#Antenna/OmniAntenna set X_ 0
#Antenna/OmniAntenna set Y_ 0
#Antenna/OmniAntenna set Z_ 0.25
#Antenna/OmniAntenna set Gt_ 1
#Antenna/OmniAntenna set Gr_ 1

#posisi node
for {set i 0} {$i < $val(nn) } { incr i } {
		set n($i) [$ns node]}

#panggil posisi
source "wireless5_posisi.tcl"

# UDP connections between from node_(0) to node_(6)
set udp_(0) [new Agent/UDP]
$ns attach-agent $n(0) $udp_(0)
$udp_(0) set fid_ 1
set null_(0) [new Agent/Null]
$ns attach-agent $n(6) $null_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set rate_ 200kb
$cbr_(0) set maxpkts_ 1
$cbr_(0) attach-agent $udp_(0)
$ns connect $udp_(0) $null_(0)
$ns at 1.0 "$cbr_(0) start"

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