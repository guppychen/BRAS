*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a
...    syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
...    ======================================================================================
...    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
...
...    Feature  Events
...    ENVIRONMENTAL    environment-aco-ua
Force Tags     @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=gpalanis  @user=root
Resource          ./base.robot


*** Variables ***
${event}    environment-aco-ua
${severity_value}    INFO
${filter}         Name
${syslog_event1}    The ACO Push Button has been pressed

*** Test Cases ***
tc_Event_Category_ENVIRONMENTAL
    [Documentation]    1        Open a CLI session to the EUT   open netconf session and subscribe to notifications     configure a trap host   and set up a PC to capture traps.
    ...    2    Perform actions to trigger the events above.
    ...    3    Look at the details of the event from the CLI.  All information in the event is correct.
    ...    4    Verify the event is shown on the syslog server.         Information from the CLI is available in the syslog message.
    ...    5    Verify the Netconf notification was sent to the logging host.   All information in the alarm is shown in the notification.
    ...    6    Trap should be sent to the trap host configured.        PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-297    @globalid=2226218    @eut=NGPON2-4    @skip=limitation
    [Teardown]   RLT-TC-4326 teardown

    # .	Configure logging host
    Configure syslog server    n1_session1    ${sys_server1}    admin-state=ENABLED

    # Creating local session for syslog Server
    ${conn}=    Session copy info    h1    ip=${sys_server1}
    Session build local    h1_localsession_server1    ${conn}

    # start capturing the syslog
    cli    h1_localsession_server1    sudo ls    password    30
    cli    h1_localsession_server1    ${DEVICES.h1.password}
    cli    h1_localsession_server1    sudo tail -f ${syslog_dir}/${syslog_file}.log > /tmp/${filename}




    #verify the event in syslog
    wait until keyword succeeds  60s   10s   Verify event in syslog file    ${event}     ${syslog_event1}


*** Keywords ***

RLT-TC-4326 teardown
    [Documentation]     Removing the configuration
    [Arguments]
    log    Enter RLT-TC-4326 teardown
    # Remove alarm File
    cli     h1_localsession_server1    rm -rf /tmp/${filename}
    # Remove syslog server
    Remove syslog server    n1_session1    ${sys_server1}
    # Destroy local session
    Session Destroy Local     h1_localsession_server1

Verify event in syslog file
    [Documentation]     verify event in syslog file
    [Arguments]    ${event}     ${syslog_event1}
    # Perform actions to trigger the events above.
    cli    n1_session2    dcli evtmgrd evtpost ${event} ${severity_value}
    cli    h1_localsession_server1    \x03
    cli    h1_localsession_server1    cd /tmp

    ${output}    run keyword    cli    h1_localsession_server1    cat ${filename} | grep ${filter}
    should contain    ${output}    ${event}
    Should Contain    ${output}    ${syslog_event1}