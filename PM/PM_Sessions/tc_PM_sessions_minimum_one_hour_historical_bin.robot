*** Settings ***
Documentation     Test suite verifies PM sessions are created with all supported MI value and maintains historical bins of minimum one hour data 
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Variables ***
${historical_bin}          12 
${bin_time}                60 

*** Test Case ***

TC1: Verify Performance monitoring sessions are created with all supported MI value and maintains historical bins of minimum one hour data 

     [Documentation]    Test case verifies PM sessions are created with historical bins of minimum one hour data
     ...                1. Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful
     ...                2. Create 10 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful
     ...                3. Enable Ethernet PM sessions with all supported MI value and support historical bin data of one hour 
     ...                4. Verify all created PM session shows the historical bin data of atleast one hour 
     ...                5. Verify packet counters of each attributes shows correct value for the bin duration 

     [Tags]    @globalid=2201640    @tcid=AXOS_E72_PARENT-TC-31    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI   @jira=EXA-17540
     [Teardown]   PM Teardown

     Log  ******************** Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful ******************** 
     Configure Grade Of Service Profile    n1    ${profile_name}    ${threshold}
     Verify Grade Of Service Profile Configured    n1   ${profile_name}

     Log  ******************** Create 10 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful ******************** 
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1
     Clear Ethernet Interface Counter    n1    ${DEVICES.n1.ports.p1.port}
     Tg Create Untagged Stream On Port    tg1    framesize    p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=512   length_mode=fixed
     Tg Start All Traffic    tg1
     Verify Ethernet Interface Traffic    n1    ${DEVICES.n1.ports.p1.port}

     Log  ********* Enable Ethernet PM sessions with all supported MI value and verify all created PM session shows the historical bin data of atleast one hour *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Check Time Of Day    n1
     Verify Ethernet PM Session Minimum One hour Historical Bin    n1    ${DEVICES.n1.ports.p1.port}
     Verify First Historical PM bin One Five Fifteen Minutes     n1    ${DEVICES.n1.ports.p1.port}

*** Keywords ***
PM Teardown
    [Documentation]    teardown
     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable Ethernet PM Session Minimum One hour    n1    ${DEVICES.n1.ports.p1.port}
     Unconfigure Grade Of Service Profile    n1

     Log  ***************** stop the traffic********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1