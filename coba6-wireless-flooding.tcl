#preset
Mac/Simple set bandwidth_ 1Mb

set MESSAGE_PORT 42
set BROADCAST_ADDR -1


#jumlah node & grup
set group_size 2
set num_groups 4
set num_nodes [expr $group_size * $num_groups]


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
set val(y)              [expr 120*$group_size + 500]
set val(x)              [expr 240*$num_groups + 200]

#simulatornya
set ns [new Simulator]

set f [open coba6-wireless-flooding-$val(rp).tr w]
$ns trace-all $f
set nf [open coba6-wireless-flooding-$val(rp).nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

$ns use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
create-god $num_nodes

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
for {set i 0} {$i < $num_nodes} {incr i} {
    set n($i) [$ns node]
    $n($i) set Y_ [expr 60*floor($i/$group_size) + 60*(($i%$group_size)>=($group_size/2))]
    $n($i) set X_ [expr (20*$group_size)*($i/$group_size%2) + 20*($i%($group_size/2))]
    #$n($i) set Y_ ($i*100)
    #$n($i) set X_ ($i*100) 
    $n($i) set Z_ 0.0
    $ns initial_node_pos $n($i) 20
}



# attach a new Agent/MessagePassing/Flooding to each node on port $MESSAGE_PORT
for {set i 0} {$i < $num_nodes} {incr i} {
    set a($i) [new Agent/MessagePassing/Flooding]
    $n($i) attach  $a($i) $MESSAGE_PORT
    $a($i) set messages_seen {}
}


#broadcast
$ns at 0.1 "$a(5) send_message 100 1 {emergency message A}  $MESSAGE_PORT"

$ns at 1.0 "finish"

proc finish {} {
        global ns f nf val
        $ns flush-trace
        close $f
        close $nf

#        puts "running nam..."
        exec nam coba6-wireless-flooding-$val(rp).nam &
        exit 0
}

$ns run