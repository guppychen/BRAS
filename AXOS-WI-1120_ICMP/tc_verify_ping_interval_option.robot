*** Settings ***
Documentation     Test suite to verify ICMP Ping Interval option
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Ping And Verify Ipv4 Localhost Using Interval Option Via Serial 
     [Documentation]    Test case verifies ICMP Ping using Interval option can be executed successfully
     ...                1. Ping IPV4 localhost every 5 seconds using -i option via serial for default 'count' times (using -c option)
     ...                2. Verify that ping stops in 25 seconds

     [Tags]   testtest   @globalid=2197109    @tcid=AXOS_E72_PARENT-TC-938    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI
    cli   n1_console   cli
    cli   n1_console    show version
    ${time_before}    Get Time    epoch
    cli    n1_console    ping ${ipv4_localhost} -i ${interval} -c ${ping_count}
    ${time_after}    Get Time   epoch
    ${elapsed_time}    Evaluate    ${time_after} - ${time_before}
    Should Be True    ${ping_count} * (${interval}-1) <= ${elapsed_time} <= ${ping_count} * (${interval}-1) + 1

*** Keywords ***
