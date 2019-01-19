*** Settings ***
Documentation     Test suite verifies Max/Min/Ave Utilization Statistics of PM session bins calculated on its sample period 
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Variables ***
${bin_duration}            one-minute 
${historical_bin}          60 
${bin_time}                1 

*** Test Case ***

TC1: Verify PM Max/Min/Ave Utilization Statistics of PM session bins calculated on its sample period 

     [Documentation]    Test case verifies Max/Min/Ave Utilization Statistics of PM session bins calculated on its sample period
     ...                1.  Create a traffic stream of Rx/Tx packets with 20 percent rate
     ...                2.  Enable Ethernet PM session of 1 minutes MI and verify its Utilization Statistics for every sample period 30 seconds
     ...                3.  Verify Utilization Statistics for every sample period shows a correct value
     ...                4.  Create a traffic stream of Rx/Tx packets with 20 percent rate
     ...                5.  Enable Ethernet PM session of 1 minutes MI and verify its Utilization Statistics for every sample period 30 seconds
     ...                6.  Verify Utilization Statistics for every sample period shows a correct value
     ...                7.  Create a traffic stream of Rx/Tx packets with 50 percent rate
     ...                8.  Enable Ethernet PM session of 1 minutes MI and verify its Utilization Statistics for every sample period 30 seconds
     ...                9.  Verify Utilization Statistics for every sample period shows a correct value
     ...                10.  Create a traffic stream of Rx/Tx packets with 50 percent rate
     ...                11.  Enable Ethernet PM session of 1 minutes MI and verify its Utilization Statistics for every sample period 30 seconds
     ...                12.  Verify Utilization Statistics for every sample period shows a correct value

     [Tags]    @globalid=2201647    @tcid=AXOS_E72_PARENT-TC-38    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI
     [Teardown]   PM Teardown

     Log  ******************** Create a traffic stream of Rx/Tx packets with 20 percent rate ********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1
     Clear Ethernet Interface Counter    n1    ${DEVICES.n1.ports.p1.port}
     Tg Stc Create Device On Port     tg1    device1    p1    intf_ip_addr=${stc_ethernet_ip}    gateway_ip_addr=${stc_ethernet_gateway}    resolve_gateway_mac=true
     ...                                  enable_ping_response=1     mac_addr=${src_mac}
     Tg Stc Create Device On Port     tg1    device2    p2    intf_ip_addr=${stc_ethernet_ip}    gateway_ip_addr=${stc_pon_gateway}    resolve_gateway_mac=true
     ...                                  enable_ping_response=1     mac_addr=${dst_mac}
     Tg Create Untagged Stream On Port    tg1    stream4    p2    p1    mac_src=${src_mac}    mac_dst=${mcast_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${mcast_ip}    rate_percent=20    frame_size=128   length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream9    p1    p2    mac_src=${src_mac}    mac_dst=${vlan_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_pon_ip}    ip_dst_addr=${stc_ethernet_ip}    rate_percent=20     frame_size=1000    length_mode=fixed
     Tg Start All Traffic    tg1

     Log  ******************** Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Check Time Of Day    n1
     Enable Ethernet PM Session    n1    ${DEVICES.n1.ports.p1.port}

     Verify PM Utilization Statistics PM First Bin Sample Period     n1    ${DEVICES.n1.ports.p1.port}

     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}

     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1

     Log  ******************** Create a traffic stream of Rx/Tx packets with 50 percent rate ********************
     Clear Ethernet Interface Counter    n1    ${DEVICES.n1.ports.p1.port}
     Tg Stc Create Device On Port     tg1    device1    p1    intf_ip_addr=${stc_ethernet_ip}    gateway_ip_addr=${stc_ethernet_gateway}    resolve_gateway_mac=true
     ...                                  enable_ping_response=1     mac_addr=${src_mac}
     Tg Stc Create Device On Port     tg1    device2    p2    intf_ip_addr=${stc_ethernet_ip}    gateway_ip_addr=${stc_pon_gateway}    resolve_gateway_mac=true
     ...                                  enable_ping_response=1     mac_addr=${dst_mac}
     Tg Create Untagged Stream On Port    tg1    stream4    p2    p1    mac_src=${src_mac}    mac_dst=${mcast_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${mcast_ip}    rate_percent=50    frame_size=128   length_mode=fixed
     Tg Create Untagged Stream On Port    tg1    stream9    p1    p2    mac_src=${src_mac}    mac_dst=${vlan_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_pon_ip}    ip_dst_addr=${stc_ethernet_ip}    rate_percent=50     frame_size=1000    length_mode=fixed
     Tg Start All Traffic    tg1

     Log  ******************** Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Check Time Of Day    n1
     Enable Ethernet PM Session    n1    ${DEVICES.n1.ports.p1.port}
     Verify PM Utilization Statistics PM Second Bin Sample Period    n1    ${DEVICES.n1.ports.p1.port}

*** Keywords ***
PM Teardown
    [Documentation]    teardown
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1

     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}

