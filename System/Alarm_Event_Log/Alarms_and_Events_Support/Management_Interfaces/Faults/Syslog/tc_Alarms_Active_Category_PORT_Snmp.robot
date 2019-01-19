*** Settings ***
Documentation     The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, the alarm is sent to the syslog server, and an SNMP trap/inform is sent:
...
...        CLI - Information is correct.
...        Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...        Trap/Inform - A trap/inform should be sent to the logging host.
...        Syslog - Alarm/alarm should be logged in the remote syslog.
Force Tags        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=kshettar
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Alarms_Active_Category_PORT
    [Documentation]    1    Open a CLI session to the EUT, have it discovered by a CMS server, configure a trap host, and set up a PC to capture traps.
    ...    2    Perform actions to trigger the alarms above.
    ...    3    Look at the details of the active alarms from the CLI.  All information in the alarm is correct and matches the alarm definition.
    ...    4    Verify the Netconf notification was sent to the logging host.   All information in the alarm is shown in the notification.
    ...    5    Trap should be sent to the trap host configured.    PC (trap host) should receive the trap.
    ...    6    Clear the condition used to trigger the alarms above.
    ...    7    Alarm should clear and be shown in the alarm history.   Alarm is no longer in active, and shows in alarm History.
    ...    8    Verify the Netconf notification is sent to the server.  Notification trap is sent to clear the alarm.
    ...    9    Trap should be sent to the trap host configured.    PC (trap host) should receive the clear trap.
    [Tags]       @author=kshettar     @tcid=AXOS_E72_PARENT-TC-2899    @globalid=2226125    @eut=NGPON2-4    @user_interface=SNMP
    [Setup]      RLT-TC-4336 setup

    # Start trap host
    snmp start trap host    n_snmp_v2
    
    # Unshut interface to clear the alarm
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    # Trigger shutdown command to generate alarm
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    # Unshut interface to clear the alarm
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    # Sleep provided to wait for event
    sleep    10

    # Stop trap host and verify
    snmp stop trap host       n_snmp_v2
    @{port}    Evaluate    "${DEVICES.n1_session1.ports.service_p2.port}".split("/")
    ${parameter}    Set Variable    /config/shelf[shelf-id=\'@{port}[0]\']/slot[slot-id=\'@{port}[1]\']/interface/ethernet[port=\'@{port}[2]\']
    ${parameter1}    Set Variable    loss-of-signal

    # Verifying the Trap receive
    ${result}    snmp get trap host results    n_snmp_v2
    log    ${result}
    : FOR    ${var}    IN    @{result}
    \    ${output}    Get Dictionary Values    ${var}
    \    ${verify}=    Validate MIB Result    ${output}    ${parameter}
    \    ${verify1}=    Validate MIB Result    ${output}    ${parameter1}
    \    Run Keyword If   "${verify}" == "True" and "${verify1}" == "True"     Exit For Loop
    \    ...    ELSE    Continue For Loop

    Run Keyword If   "${verify}" != "True"    Fail    Alarm '${parameter}' not found

    [Teardown]   RLT-TC-4336 teardown

*** Keywords ***
RLT-TC-4336 setup
    [Documentation]    Setup
    [Arguments]
    log    Enter RLT-TC-4336 setup

    # Retrieve Machine IP as trap host IP
    ${ip_addr}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    Remove V2 trap    n1_session1    ${ip_addr}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    # Configuring SNMPV2 user
    Configure SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    # Configuring v2 trap host
    Configure V2 Trap    n1_session1    ${ip_addr}    ${DEVICES.n_snmp_v2.community}    trap-type=${trap_type}

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}


RLT-TC-4336 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter RLT-TC-4336 teardown

    # Retrieve Machine IP as trap host IP
    ${ip_addr}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    # To remove snmp v2 user and its trap-host
    Remove V2 trap    n1_session1    ${ip_addr}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}
