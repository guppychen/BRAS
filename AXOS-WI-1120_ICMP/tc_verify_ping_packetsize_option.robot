*** Settings ***
Documentation     Test suite to verify ICMP Ping packetsize option
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***
${rtn_size}    8

*** Test Case ***

Ping And Verify Ipv4 Localhost using Packetsize Option Via Serial 

     [Documentation]    Test case verifies ICMP ping using Packetsize option can be executed successfully
     ...                1. Ping IPV4 localhost 5 times using -s option via serial
     ...                2. Verify that all 5 pings were successful

     [Tags]    @globalid=2197111    @tcid=AXOS_E72_PARENT-TC-940    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI

    cli    n1_console    ping ${ipv4_localhost} -s ${packetsize} -c 5
    ${rtn_size}    Evaluate    ${packetsize} + 8
    Result Should Contain      ${rtn_size} bytes
    Result Should Not Contain     0 received
    
*** Keywords ***
