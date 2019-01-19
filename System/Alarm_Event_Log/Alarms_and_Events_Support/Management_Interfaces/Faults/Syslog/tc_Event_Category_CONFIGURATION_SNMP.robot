*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
Resource          ./base.robot
Force Tags  @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=gpalanis
Library           robot.libraries.OperatingSystem
 
*** Variables ***
${parameter}    Copy into running configuration was done

*** Test Cases ***
tc_Event_Category_CONFIGURATION_SNMP
    [Documentation]    1	Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.		
    ...    2	Perform actions to trigger the events above.		
    ...    3	Look at the details of the event from the CLI.	All information in the event is correct.	
    ...    4	Verify the event is shown on the syslog server.	Information from the CLI is available in the syslog message.	
    ...    5	Verify the Netconf notification was sent to the logging host.	All information in the alarm is shown in the notification.	
    ...    6	Trap should be sent to the trap host configured.	PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-290    @globalid=2226211    @eut=NGPON2-4    @user_interface=SNMP
    [Setup]      RLT-TC-4320 setup

    # Retrieve Machine IP as trap host IP
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    # Configuring v2 trap host
    Configure V2 Trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}    trap-type=${trap_type}
    
    log    Perform actions to trigger the events above.
    #start trap host
    snmp start trap host    n_snmp_v2

    # Event - copy-to-running-config
    log    copy-to-running-config
    cli    n1_session1    acc run
    cli    n1_session1    copy run start
    cli    n1_session1    copy config from startup-config to running-config
    Result should contain    Copy completed.
    #sleep to generate trap 
    Sleep    10

    # Stop trap host and verify
    snmp stop trap host       n_snmp_v2

    #Verify the generated traps
    ${result}    snmp get trap host results    n_snmp_v2
    log    ${result}
    : FOR    ${var}    IN    @{result}
    \    ${output}    Get Dictionary Values    ${var}
    \    ${verify}=    Validate MIB Result    ${output}    ${parameter}
    \    Run Keyword If   "${verify}" == "True"     Exit For Loop
    \    ...    ELSE    Continue For Loop
    Run Keyword If   "${verify}" != "True"    Fail    Alarm '${parameter}' not found

    [Teardown]   RLT-TC-4320 teardown    ${trap_host}

  
*** Keywords ***
RLT-TC-4320 setup
    [Documentation]     RLT-TC-4320 setup
    [Arguments]
    log    Enter RLT-TC-4320 setup

    # Retrieve Machine IP as trap host IP
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    # Configuring SNMPV2 user
    Configure SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30


RLT-TC-4320 teardown
    [Documentation]     RLT-TC-4320 teardown
    [Arguments]    ${trap_host}
    log    Enter RLT-TC-4320 teardown

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

    #Remove snmp v2 user and its trap-host
    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
    
    # [AT-666] add step to make sure startup-config is clean
    log    recover startup-config
    cli    n1_session1    acc run
    cli    n1_session1    copy run start
    # [AT-666] add step to make sure startup-config is clean #end
