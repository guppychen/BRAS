*** Settings ***
Documentation     Test suite to verify ICMP Ping Deadline option
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Ping And Verify Ipv4 Localhost Using Deadline Option Via Serial 
     [Documentation]    Test case verifies ICMP Ping using count Deadline can be executed successfully
     ...                1. Ping IPV4 localhost for 10 seconds using -w option via serial
     ...                2. Verify that ping stops in 10 seconds

     [Tags]    @globalid=2197106    @tcid=AXOS_E72_PARENT-TC-935    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI
    cli    n1_console    cli
    cli    n1_console    show version
    ${time_before}    Get Time    epoch
    cli    n1_console    ping ${ipv4_localhost} -w ${deadline}
    ${time_after}    Get Time   epoch
    ${elapsed_time}    Evaluate    ${time_after} - ${time_before}
    Should Be True    ${deadline} <= ${elapsed_time} <= ${deadline} + 1

*** Keywords ***