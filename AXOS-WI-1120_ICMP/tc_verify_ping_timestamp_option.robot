*** Settings ***
Documentation     Test suite to verify ICMP Ping Timestamp option
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Ping And Verify Ipv4 Localhost Using Timestamp Option Via Serial 
     [Documentation]    Test case verifies ICMP Ping using Timestamp option can be executed successfully
     ...                1. Ping IPV4 localhost 5 times using -T tsonly option via serial
     ...                2. Verify that all 5 pings were successful
     ...                3. Ping IPV4 localhost 5 times using -T tsandaddr option via serial
     ...                4. Verify that all 5 pings were successful
     ...                5. Ping IPV4 localhost 5 times using -T tsprespec option via serial
     ...                6. Verify that all 5 pings were successful
     ...                7. Ping IPV4 localhost 5 times using -D option via serial
     ...                8. Verify that all 5 pings were successful   

     [Tags]    @globalid=2197117    @tcid=AXOS_E72_PARENT-TC-943    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI

    cli    n1_console    ping -T tsonly ${ipv4_localhost} -c ${ping_count}
    Result Should Contain      ${ping_count} packets transmitted
    Result Should Contain      ${ping_count} received    
    
    cli    n1_console    ping -T tsandaddr ${ipv4_localhost} -c ${ping_count}
    Result Should Contain      ${ping_count} packets transmitted
    Result Should Contain      ${ping_count} received    
    
    cli    n1_console    ping -T tsprespec ${ipv4_localhost} -c ${ping_count}
    Result Should Contain      ${ping_count} packets transmitted
    Result Should Contain      ${ping_count} received    

    cli    n1_console    ping -D ${ipv4_localhost} -c ${ping_count}
    Result Should Contain      ${ping_count} packets transmitted
    Result Should Contain      ${ping_count} received  
    
*** Keywords ***
