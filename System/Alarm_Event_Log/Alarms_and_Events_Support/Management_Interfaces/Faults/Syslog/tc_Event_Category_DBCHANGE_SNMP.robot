*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
...
...
...               ======================================================================================
...               The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...               CLI - Information is correct.
...               Netconf- A netconf notification should be sent to the logging host. This could be a ssh session, activate server, or CMS.
...               Trap/Inform - A trap/inform should be sent to the logging host.
...
...               Feature Events
...               DBCHANGE Different Source based on configuration changes
Force Tags        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=dzala
Resource          ./base.robot

*** Variables ***
${parameter}      loss of signal

*** Test Cases ***
tc_Event_Category_DBCHANGE_SNMP
    [Documentation]    1 Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host and set up a PC to capture traps.
    ...    2 Perform actions to trigger the events above.
    ...    3 Look at the details of the event from the CLI.
    ...    4 Verify the event is shown on the syslog server.
    ...    5 Verify the Netconf notification was sent to the logging host.
    ...    6 Trap should be sent to the trap host configured.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-295    @globalid=2226216    @eut=NGPON2-4    @user_interface=SNMP
    [Setup]    RLT-TC-4323 setup

    # Retrieve Machine IP as trap host IP
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    #Configure trap host
    Configure V2 Trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}    trap-type=${trap_type}    timeout=${timeout}    retries=${retries}

    #start trap host
    snmp start trap host    n_snmp_v2

    # Trigger shutdown command to generate alarm
    Shut Interface    n1_session1   ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port} 
    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}
    # Sleep added so that trap message is captured
    sleep     10

    #Stop trap host
    snmp stop trap host    n_snmp_v2

    # Verifying the Trap receive
    ${result}    snmp get trap host results    n_snmp_v2
    log    ${result}
    : FOR    ${var}    IN    @{result}
    \    ${output}    Get Dictionary Values    ${var}
    \    ${verify}=    Validate MIB Result    ${output}    ${parameter}
    \    Run Keyword If   "${verify}" == "True"     Exit For Loop
    \    ...    ELSE    Continue For Loop

    Run Keyword If   "${verify}" != "True"    Fail    Alarm '${parameter}' not found


    [Teardown]    RLT-TC-4323 teardown    ${trap_host}

*** Keywords ***
RLT-TC-4323 setup
    [Documentation]    RLT-TC-4323 setup
    [Arguments]    
    log    Entering RLT-TC-4323 setup

    # Retrieve Machine IP as trap host IP
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    # Configuring SNMPV2 user
    Configure SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
    
    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

RLT-TC-4323 teardown
    [Documentation]    RLT-TC-4323 teardown
    [Arguments]    ${trap_host}
    log    Entering RLT-TC-4323 teardown

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    #Remove snmp v2 user and its trap-host
    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
