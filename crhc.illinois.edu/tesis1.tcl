# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             5                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              500   			   ;# X dimension of topography
set val(y)              400   			   ;# Y dimension of topography  
set val(stop)		100			   ;# time of simulation end

set ns		  [new Simulator]
set tracefd       [open tesis1.tr w]
set windowVsTime2 [open tesis1.tr w] 
set namtrace      [open tesis1.nam w]    

$ns trace-all $tracefd
$ns use-newtrace 
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

#
#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#

# configure the nodes
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
			 -macTrace OFF \
			 -movementTrace ON
			 
	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns node]	
	}

# Provide initial location of mobilenodes
$node_(0) set X_ 300.0
$node_(0) set Y_ 50.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 300.0
$node_(1) set Y_ 100.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 200.0
$node_(2) set Y_ 50.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 100.0
$node_(3) set Y_ 100.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 50.0
$node_(4) set Y_ 50.0
$node_(4) set Z_ 0.0


# Generation of movements
$ns at 10.0 "$node_(0) setdest 400.0 50.0 3.0"
$ns at 15.0 "$node_(1) setdest 400.0 100.0 5.0"
$ns at 20.0 "$node_(2) setdest 400.0 50.0 1.0" 
$ns at 30.0 "$node_(3) setdest 400.0 50.0 2.0" 
$ns at 40.0 "$node_(4) setdest 10.0 50.0 4.0" 

# Set a TCP connection between node_(0) and node_(4)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(4) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 05.0 "$ftp start" 

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
}

$ns run