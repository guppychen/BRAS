*** Settings ***
Documentation     Test suite to verify ICMP Ping Interface option
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Ping And Verify Ipv4 Localhost Using Interface Option Via Serial 
     [Documentation]    Test case verifies ICMP Ping using interface option can be executed successfully
     ...                1. Ping craft port 5 times using -I option via serial
     ...                2. Verify that all 5 pings were successful

     [Tags]    @globalid=219718    @tcid=AXOS_E72_PARENT-TC-937    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI

    cli    n1_console    ping -I ${ipaddr} ${gateway} -c 5
    Result Should Contain      5 packets transmitted
    Result Should Contain      5 received    

*** Keywords ***
