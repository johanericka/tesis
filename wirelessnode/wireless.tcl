#preset
Mac/Simple set bandwidth_ 1Mb

set MESSAGE_PORT 42
set BROADCAST_ADDR -1

#radio
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type

#protokol
set val(mac)            Mac/802_11                 ;# MAC type
#set val(mac)            Mac                 ;# MAC type
#set val(mac)		Mac/Simple

set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq


#agen
set val(rp) DumbAgent
#set val(rp)             DSDV
#set val(rp)		 AODV


# bidang kerja
set val(y)		1500
set val(x)		1500

#simulatornya
set ns [new Simulator]

set f [open wireless-$val(rp).tr w]
$ns trace-all $f
set nf [open wireless-$val(rp).nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

$ns use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
#create-god $num_nodes
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
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace OFF \
                -macTrace ON \
                -movementTrace OFF \
                -channel $chan_1_ 


# subclass Agent/MessagePassing to make it do flooding

Class Agent/MessagePassing/Flooding -superclass Agent/MessagePassing

Agent/MessagePassing/Flooding instproc recv {source sport size data} {
    $self instvar messages_seen node_
    global ns BROADCAST_ADDR 

    # extract message ID from message
    set message_id [lindex [split $data ":"] 0]
    puts "\nNode [$node_ node-addr] got message $message_id\n"

    if {[lsearch $messages_seen $message_id] == -1} {
	lappend messages_seen $message_id
        $ns trace-annotate "[$node_ node-addr] received {$data} from $source"
        $ns trace-annotate "[$node_ node-addr] sending message $message_id"
	$self sendto $size $data $BROADCAST_ADDR $sport
    } else {
        $ns trace-annotate "[$node_ node-addr] received redundant message $message_id from $source"
    }
}

Agent/MessagePassing/Flooding instproc send_message {size message_id data port} {
    $self instvar messages_seen node_
    global ns MESSAGE_PORT BROADCAST_ADDR

    lappend messages_seen $message_id
    $ns trace-annotate "[$node_ node-addr] sending message $message_id"
    $self sendto $size "$message_id:$data" $BROADCAST_ADDR $port
}



#posisi node
set n(0) [$ns node]
set n(1) [$ns node]
set n(2) [$ns node]
set n(3) [$ns node]
set n(4) [$ns node]
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

$ns initial_node_pos $n(0) 100
$ns initial_node_pos $n(1) 100
$ns initial_node_pos $n(2) 100
$ns initial_node_pos $n(3) 100
$ns initial_node_pos $n(4) 100

# attach a new Agent/MessagePassing/Flooding to each node on port $MESSAGE_PORT
set a(0) [new Agent/MessagePassing/Flooding]
$n(0) attach $a(0) $MESSAGE_PORT
$a(0) set messages_seen {}

set a(1) [new Agent/MessagePassing/Flooding]
$n(1) attach $a(1) $MESSAGE_PORT
$a(1) set messages_seen {}

set a(2) [new Agent/MessagePassing/Flooding]
$n(2) attach $a(2) $MESSAGE_PORT
$a(2) set messages_seen {}

set a(3) [new Agent/MessagePassing/Flooding]
$n(3) attach $a(3) $MESSAGE_PORT
$a(3) set messages_seen {}

set a(4) [new Agent/MessagePassing/Flooding]
$n(4) attach $a(4) $MESSAGE_PORT
$a(4) set messages_seen {}


#broadcast
$ns at 0.1 "$a(0) send_message 100 1 {emergency message A}  $MESSAGE_PORT"
$ns at 0.2 "$a(3) send_message 100 1 {emergency message B}  $MESSAGE_PORT"

$ns at 1.0 "finish"

proc finish {} {
        global ns f nf val
        $ns flush-trace
        close $f
        close $nf

#        puts "running nam..."
        exec nam wireless-$val(rp).nam &
        exit 0
}

$ns run