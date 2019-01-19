*** Settings ***
Documentation     Test suite to verify ICMP Ping Flood option
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Ping And Verify Ipv4 Localhost Using Flood Option Via Serial 
     [Documentation]    Test case verifies ICMP Ping using Flood option can be executed successfully
     ...                1. Ping IPV4 localhost 7000 times using -f option via serial
     ...                2. Verify that all 7000 pings were successfully received within 1 second

     [Tags]    @globalid=2197107    @tcid=AXOS_E72_PARENT-TC-936    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI

    ${time_before}    Get Time    epoch
    cli    n1_console    ping ${ipv4_localhost} -f -c ${flood_count}
    ${time_after}    Get Time   epoch
    ${elapsed_time}    Evaluate    ${time_after} - ${time_before}
    Should Be True    ${elapsed_time} <= 4
    Result Should Contain    7000 packets transmitted
    Result Should Contain    7000 received

*** Keywords ***
