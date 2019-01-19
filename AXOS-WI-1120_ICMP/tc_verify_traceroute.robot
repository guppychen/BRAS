*** Settings ***
Documentation     Test suite to verify ICMP Traceroute
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Ping And Verify Ipv4 Localhost Using Traceroute hops Via Serial 
     [Documentation]    Test case verifies ICMP Traceroute can be executed successfully
     ...                1. Traceroute local NTP server via serial
     ...                2. Verify that all 4 hops were successful

     [Tags]    @globalid=2197119    @tcid=AXOS_E72_PARENT-TC-945    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI

    cli    n1_console    traceroute ${ntp_server}
    Result Should Contain      ${gateway} 
    Result Should Contain      ${ntp_server}    

*** Keywords ***
