*** Settings ***
Documentation     Test suite verifies the system supports configuring PM session with all supported MI value with its Historical bins values and session got created
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Variables ***
${historical_bin}          1440 
${bin_time}                1

*** Test Case ***

TC1: Verify the system supports configuring PM session with all supported MI value with its Historical bins values 

     [Documentation]    Test case verifies PM sessions are created with configured bin interval
     ...                1.  Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful
     ...                2.  Create 10 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful
     ...                3.  Enable Ethernet PM sessions with all supported Measurement interval (MI) and its historical bins in the Eternet interface
     ...                4.  Verify all the PM sesssions configured are created
     ...                5.  Verify packet counters of each attributes have correct value atleast for one bin duration

     [Tags]    @globalid=2201630    @tcid=AXOS_E72_PARENT-TC-21    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI
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

     Log  ************* Enable Ethernet PM sessions with all supported Measurement interval (MI) and its historical bins in the Eternet interface and verify its created *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Check Time Of Day    n1
     Enable Ethernet PM Session All MI Values    n1    ${DEVICES.n1.ports.p1.port}
     Verify Ethernet PM Session All MI Values    n1    ${DEVICES.n1.ports.p1.port}

     Log  ****** Verify packet counetrs of 1 minute bin matches 600 K for each attributes in the bins ***********
     Bin Wait Time    ${bin_time}
     Verify Next Performance Monitoring Bin    n1    ${DEVICES.n1.ports.p1.port}
     Bin Wait Time    ${bin_time}
     Verify Ethernet PM Session Counters One Minute    n1    ${DEVICES.n1.ports.p1.port}

*** Keywords ***
PM Teardown
    [Documentation]    teardown
     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Unconfigure Grade Of Service Profile    n1

     Log  ***************** stop the traffic********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1