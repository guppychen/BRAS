*** Settings ***
Documentation     The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
Resource          ./base.robot
Force Tags     @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=kshettar  @user=root


*** Variables ***
${parameter}   The ACO Push Button has been pressed

*** Test Cases ***
tc_Event_Category_ENVIRONMENTAL
    [Documentation]    1    Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.
    ...    2    Perform actions to trigger the events above.
    ...    3    Look at the details of the event from the CLI.  All information in the event is correct.
    ...    4    Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.
    ...    5    Verify the Netconf notification was sent to the logging host.   All information in the alarm is shown in the notification.
    ...    6    Trap should be sent to the trap host configured.    PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-297    @globalid=2226218    @eut=NGPON2-4    @user_interface=SNMP
    [Setup]      RLT-TC-4326 setup
    [Teardown]   RLT-TC-4326 teardown

    # Start trap host
    snmp start trap host    n_snmp_v2

    # Trigger the event to generate log
    cli    n1_session2    dcli evtmgrd evtpost environment-aco-ua INFO
    # Sleep added to generate event
    sleep    10

    log    STEP:3 Trap should be sent to the trap host configured. PC (trap host) should receive the trap.
    # Stop trap host and verify
    snmp stop trap host       n_snmp_v2

    # Verifying the Trap receive
    ${result}    snmp get trap host results    n_snmp_v2
    log    ${result}
    : FOR    ${var}    IN    @{result}
    \    ${output}    Get Dictionary Values    ${var}
    \    ${verify}=    Validate MIB Result    ${output}    ${parameter}
    \    Run Keyword If   "${verify}" == "True"     Exit For Loop
    \    ...    ELSE    Continue For Loop

    Run Keyword If   "${verify}" != "True"    Fail    Alarm '${parameter}' not found


*** Keywords ***
RLT-TC-4326 setup
    [Documentation]    Setup
    [Arguments]
    log    Enter RLT-TC-4326 setup

    # Retrieve Machine IP as trap host IP
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    # Configuring SNMPV2 user
    Configure SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}

    # Configuring v2 trap host
    Configure V2 Trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}    trap-type=${trap_type}


RLT-TC-4326 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter RLT-TC-4326 teardown

    # Retrieve Machine IP as trap host IP
    ${trap_host}    Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    # To remove snmp v2 user and its trap-host
    Remove V2 trap    n1_session1    ${trap_host}    ${DEVICES.n_snmp_v2.community}

    Remove SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
