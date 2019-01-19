*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
...
...
...
...               Id
...
...
...               Unique id of event type. Statically defined
...
...               Name
...
...
...               Display name of event type
...
...               Description
...
...
...               Static description of event type. Defines purpose of the event.
...
...               Source
...
...
...               Source object identifier for event - specific component (chassis, shelf, slot/port, power supply, radio etc.)
...               Category Category of event identifying some logic group of events significant from an external usage perspective
...
...               Additional text
...
...
...               May contain a default message format. The intent is to include Instance specific detailed information augmenting description. These details may also be encoded in additional info
...
...               Sequence number
...
...
...               Whether or not this event supports sequence numbers
...
...               Module
...
...
...               Module generating the event (may include file and line # when available)
...
...               ======================================================================================
...               The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...
...               CLI - Information is correct.
...               Netconf- A netconf notification should be sent to the logging host. This could be a ssh session, activate server, or CMS.
...               Trap/Inform - A trap/inform should be sent to the logging host.
...
...               Feature Events
...               PORT
Force Tags   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=upandiri
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Event_Category_PORT_SNMP
    [Documentation]    1 Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.    #    Action    Expected Result    Notes
    ...    2 Perform actions to trigger the events above.
    ...    3 Look at the details of the event from the CLI. All information in the event is correct.
    ...    4 Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.
    ...    5 Verify the Netconf notification was sent to the logging host. All information in the alarm is shown in the notification.
    ...    6 Trap should be sent to the trap host configured. PC (trap host) should receive the trap.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-312    @globalid=2226233    @eut=NGPON2-4    @user_interface=SNMP
    [Setup]    RLT-TC-8837 setup
    log    STEP:# Action Expected Result Notes

    # To retrieve the remote ip
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
	
    # Configuring SNMPV2 user
    Configure SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    # Configuring v2 trap host
    Configure V2 Trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}    trap-type=${trap_type}    timeout=${timeout}    retries=${retries}

    log    STEP:2 Perform actions to trigger the events above.
    #start trap host
    snmp start trap host    n_snmp_v2

    #Triggering event
    # Trigger shutdown command to generate alarm
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}
    # Wait for event trigger
    sleep    10
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}
    sleep   10
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}
    # Wait for event trigger
    sleep    10
    ##Stop trap host
    snmp stop trap host    n_snmp_v2

    @{port}    Evaluate    "${DEVICES.n1_session1.ports.service_p2.port}".split("/")
    ${parameter}    Set Variable    /config/shelf[shelf-id=\'@{port}[0]\']/slot[slot-id=\'@{port}[1]\']/interface/ethernet[port=\'@{port}[2]\']
    ${parameter1}    Set Variable    loss-of-signal

    ${result}    snmp get trap host results    n_snmp_v2
    log    ${result}

    : FOR    ${var}    IN    @{result}
    \    ${output}    Get Dictionary Values    ${var}
    \    ${verify}=    Validate MIB Result    ${output}    ${parameter}
    \    ${verify1}=    Validate MIB Result    ${output}    ${parameter1}
    \    Run Keyword If   "${verify}" == "True" and "${verify1}" == "True"     Exit For Loop
    \    ...    ELSE    Continue For Loop
    Run Keyword If   "${verify}" != "True"    Fail    Alarm '${parameter}' not found

    [Teardown]    RLT-TC-8837 teardown    ${trap_host}

*** Keywords ***

RLT-TC-8837 setup
    [Documentation]   The setup section of RLT-TC-8837
    [Arguments]
    log    Enter RLT-TC-8837 setup

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    # Retrieve Machine IP as trap host IP
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}


RLT-TC-8837 teardown
    [Documentation]   The setup section of RLT-TC-8837
    [Arguments]    ${trap_host}
    log    Enter RLT-TC-8837 teardown

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    #To remove snmp v2 user and its trap-host
    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
