*** Settings ***
Documentation     Test suite verifies Interface PM attributes maintains a running counter which increment counting and once the bin completes it wraps to zero and start counting again, Also Utilazation statistics of PM bins can be cleared like other PM statistics
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Variables ***
${bin_duration}            five-minutes 
${historical_bin}          12 
${bin_time}                5 

*** Test Case ***

TC1: Verify PM session attributes maintains a running counter which increment counting and once the bin completes it wraps to zero and start again

     [Documentation]    Test case verifies PM attributes maintains a running counter which collects PM statistics including utilazation of interface
     ...                1.  Create 100 K Frames of traffic stream for each attributes defined in RFC 2819 RMON MIB 
     ...                2.  Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful
     ...                3.  Verify PM attributes maintains a running counter which wraps to zero and start counting again,Utilazation statistics can be cleared 

     [Tags]    @globalid=2201646    @tcid=AXOS_E72_PARENT-TC-37    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI  @jira=EXA-17540
     [Teardown]   PM Teardown

     Log  ******************** Create 100 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful ******************** 
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1
     Clear Ethernet Interface Counter    n1    ${DEVICES.n1.ports.p1.port}
     Tg Stc Create Device On Port     tg1    device1    p1    intf_ip_addr=${stc_ethernet_ip}    gateway_ip_addr=${stc_ethernet_gateway}    resolve_gateway_mac=true
     ...                                  enable_ping_response=1     mac_addr=${src_mac}
     Tg Stc Create Device On Port     tg1    device2    p2    intf_ip_addr=${stc_ethernet_ip}    gateway_ip_addr=${stc_pon_gateway}    resolve_gateway_mac=true
     ...                                  enable_ping_response=1     mac_addr=${dst_mac}
     Tg Create Untagged Stream On Port    tg1    stream1    p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=64   length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream2    p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=60   length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream3    p2    p1    mac_src=${src_mac}    mac_dst=${bcast_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${bcast_ip}    rate_pps=10000    frame_size=65   length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream4    p2    p1    mac_src=${src_mac}    mac_dst=${mcast_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${mcast_ip}    rate_pps=10000    frame_size=128   length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream5    p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${mcast_ip}    rate_pps=10000    frame_size=1520   length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream6   p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=256   length_mode=fixed
     ...                                  fcs_error=1
     Tg Create Untagged Stream On Port    tg1    stream7   p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=1540   length_mode=fixed
     ...                                  ip_fragment=1     fcs_error=1
     Tg Create Untagged Stream On Port    tg1    stream8   p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=60   length_mode=fixed
     ...                                  ip_fragment=1     fcs_error=1
     Tg Create Untagged Stream On Port    tg1    stream9   p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=520  length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream10   p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=1040  length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream11    p1    p2    mac_src=${src_mac}    mac_dst=${vlan_mac}   l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_pon_ip}    ip_dst_addr=${stc_ethernet_ip}    rate_percent=50  frame_size=2040  length_mode=fixed
     Tg Start All Traffic    tg1


     
     Verify Ethernet Interface Traffic    n1    ${DEVICES.n1.ports.p1.port}

     Log  ******************** Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Check Time Of Day    n1
     Enable Ethernet PM Session    n1    ${DEVICES.n1.ports.p1.port}
     Verify Ethernet PM Session Is Created    n1    ${DEVICES.n1.ports.p1.port}    ${session_number}

     Log  ****** Verify PM attributes maintains a running counter which wraps to zero and start counting again,Utilazation statistics can be cleared *********
     Verify Counter Reset To Zero And Start Again     n1    ${DEVICES.n1.ports.p1.port}

*** Keywords ***
PM Teardown
    [Documentation]    teardown

     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}

     Log  ***************** stop the traffic********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1