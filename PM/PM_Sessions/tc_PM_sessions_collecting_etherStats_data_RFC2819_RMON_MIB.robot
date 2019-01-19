*** Settings ***
Documentation     Test suite verifies ethernet interface supports collection of PM session etherStats data defined in RFC 2819 RMON MIB and its Utilization Statistics  
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Variables ***
${bin_duration}            five-minutes 
${historical_bin}          12 
${bin_time}                5 

*** Test Case ***

TC1: Verify PM session etherStats data defined in RFC 2819 RMON MIB and its Utilization Statistics of bins are collected 

     [Documentation]    Test case verifies PM sessions etherStats data defined in RFC 2819 RMON MIB and Utilization Statistics of bins are collected
     ...                1.  Create 100 K Frames of traffic stream for each attributes defined in RFC 2819 RMON MIB 
     ...                2.  Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful
     ...                3.  Verify packet counters of each attributes defined in RFC 2819 RMON MIB have 30000000 in the bins

     [Tags]    @globalid=2201641    @tcid=AXOS_E72_PARENT-TC-32    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI    @jira=EXA-17082
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
     Tg Start All Traffic    tg1
     
     Verify Ethernet Interface Traffic    n1    ${DEVICES.n1.ports.p1.port}

     Log  ******************** Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Check Time Of Day    n1
     Enable Ethernet PM Session    n1    ${DEVICES.n1.ports.p1.port}
     Verify Ethernet PM Session Is Created    n1    ${DEVICES.n1.ports.p1.port}    ${session_number}

     Log  ****** Verify packet counters of each attributes defined in RFC 2819 RMON MIB have 30000000 in the bins *********
     Run Keyword And Continue On Failure     Verify Ether Stats Data RFC 2819 RMON MIB     n1    ${DEVICES.n1.ports.p1.port}

     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Run Keyword And Continue On Failure     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}

*** Keywords ***
PM Teardown
    [Documentation]    teardown
     Log  ***************** stop the traffic********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1