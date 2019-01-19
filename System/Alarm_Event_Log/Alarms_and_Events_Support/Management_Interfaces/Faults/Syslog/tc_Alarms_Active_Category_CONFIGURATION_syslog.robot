*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf seesion with subscription, Syslog Server setup and configured, and have a trap host configured for capturing the traps.  Once you have these set up for testing, trigger the alarm/event being tested.
...
...    Trap should include:
...            axosTrapSequenceNo,
...            axosAlarmIndex,
...            axosAlarmType,
...            axosAlarmCategory,
...            axosAlarmInstanceId,
...            axosAlarmSeverity,
...            axosAlarmServiceAffecting,
...            axosAlarmAddress,
...            axosAlarmText,
...            axosAlarmTimeStamp,
...            axosAlarmTime,
...            axosAlarmAdditionalInfo
...    AXOS Severity     Syslog Severity
...    
...    CRITICAL                Critical
...    MAJOR                   Error
...    MINOR                    Error
...    WARNING               Warning
...    INFO                       Informational
...    CLEAR                    Informational
...    ======================================================================================
...    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, the alarm is sent to the syslog server, and an SNMP trap/inform is sent:
...    
...        CLI - Information is correct.
...        Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...        Trap/Inform - A trap/inform should be sent to the logging host.
...        Syslog - Alarm/Event should be logged in the remote syslog.
Resource          ./base.robot
Force Tags     @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao       @author=gpalanis

*** Variables ***
${protocol}    ${DEVICES.n1_session1.ports.service_p1.type}
${int_port}    ${DEVICES.n1_session1.ports.service_p1.port}


*** Test Cases ***
tc_Alarms_Active_Category_CONFIGURATION
    [Documentation]    1	Open a CLI session to the EUT, have it discovered by a CMS server, configure a trap host, and set up a PC to capture traps. 		
    ...    2	Perform actions to trigger the alarms above.		
    ...    3	Look at the details of the active alarms from the CLI.	All information in the alarm is correct and matches the alarm definition.	
    ...    4	Look for the notification on the syslog server.	All information in the alarm is shown on the syslog server.	
    ...    5	Verify the Netconf notification was sent to the logging host. 	All information in the alarm is shown in the notification. 	
    ...    6	Trap should be sent to the trap host configured. 	PC (trap host) should receive the trap. 	
    ...    7	Clear the condition used to trigger the alarms above.		
    ...    8	Alarm should clear and be shown in the alarm history.	Alarm is no longer in active, and shows in alarm History. 	
    ...    9	Verify the Netconf notification is sent to the server. 	Notification trap is sent to clear the alarm. 	
    ...    10	Trap should be sent to the trap host configured. 	PC (trap host) should receive the clear trap. 
    [Tags]       @tcid=AXOS_E72_PARENT-TC-290    @globalid=2226211    @eut=NGPON2-4    new    @skip=limitation
    [Setup]      RLT-TC-1004 setup
    [Teardown]   RLT-TC-1004 teardown
    log    STEP:1 Open a CLI session to the EUT, have it discovered by a CMS server, configure a trap host, and set up a PC to capture traps.

    # Check version
    ${version}    cli    n1_session1    show version
    log    ${version}

    # Check the current alarm in alarm table in the device - should have running-config-unsaved
    ${current_alarm}    cli    n1_session1    show alarm active | nomore    \\#    30
    log    ${current_alarm}

    log    STEP:2 Perform actions to trigger the alarms above.

    #Confifure syslog server to trigger alarm
    Configure syslog server    n1_session1    ${sys_server1}    admin-state=ENABLED

    # Copy running configuration as startup configuration
    cli    n1_session1    acc run
    cli    n1_session1    copy running-config startup-config
    Result Should Contain    Copy completed

    # Check the current alarm in alarm table in the device - should not have running-config-unsaved
    ${current_alarm}    cli    n1_session1    show alarm active | nomore    \\#     30
    log    ${current_alarm}
    Result Should Not Contain    id 702 name running-config-unsaved

    #Confifure syslog server to trigger alarm
    Configure syslog server    n1_session1    ${dummy_sys_server}    admin-state=ENABLED

    # Check the current alarm in alarm table in the device - running-config-unsaved should be present
    ${current_alarm}    cli    n1_session1    show alarm active | nomore    \\#    30
    log    ${current_alarm}
    Result Should Contain    id 702 name running-config-unsaved

    # Display alarm in table
    ${output}    cli    n1_session1    show alarm active subscope id 702    \\#    30
    Should Not Be Empty    ${output}

    # Verify the alarm in syslog server
    # Creating local session for Server 
    ${conn}=    Session copy info    h1    ip=${sys_server1}
    Session build local    h1_localsession_server1    ${conn}

    #Capture the syslog
    Capture syslog    h1_localsession_server1    n1_session1    ${protocol}    ${int_port}

    #Verify the syslog
#    wait until keyword succeeds  30  5     Verify syslog file    h1_localsession_server1     702   Name:running-config-unsaved   Details:alarm was set due to configuration update
    wait until keyword succeeds  30  5     Verify syslog file    h1     702   Name:running-config-unsaved   Details:alarm was set due to configuration update


    # Delete the configuration changes made and check for the active alarm table
    Remove syslog server    n1_session1    ${dummy_sys_server}

    # Check the current alarm in alarm table in the device - running-config-unsaved should be present
    ${current_alarm}    cli    n1_session1    show alarm active | nomore    \\#    30
    log    ${current_alarm}
    Result Should Contain    id 702 name running-config-unsaved
    @{inst_id}    should match regexp    ${current_alarm}    702.*instance-id[\\s]+([\\d.]+)    1

    # Start alarm capture in syslog
#    cli    h1_localsession_server1    rm -rf /tmp/${filename}
#    cli    h1_localsession_server1    \x03
#    cli    h1_localsession_server1    sudo ls -ltr    prompt=(password|$)    timeout=30
#    cli    h1_localsession_server1    ${DEVICES.h1.password}
#    cli    h1_localsession_server1    sudo tail -f /var/log/messages > /tmp/${filename}

    # Copy running configuration as startup configuration
    cli    n1_session1    copy running-config startup-config
    Result Should Contain    Copy completed

    # Check the current alarm in alarm table in the device - should not have running-config-unsaved
    ${current_alarm}    cli    n1_session1    show alarm active | nomore    \\#    30
    log    ${current_alarm}
    Result Should Not Contain    id 702 name running-config-unsaved

    # Check the alarm history
    cli    n1_session1    show alarm history subscope instance-id @{inst_id}[1]    \\#    30
    Result Should Contain    details alarm was cleared due to copy of running-config into startup-config
    Result Should Contain    repair-action copy running-configuration to startup-configuration

    # Breaking the packet capture in syslog
    cli    h1_localsession_server1    \x03

    #Verify the syslog
    ${value}  wait until keyword succeeds  30s   5s   Verify syslog file    h1      2406     Name:config-file-copied   Cause:Configuration was copied via command

*** Keywords ***
RLT-TC-1004 setup
    [Documentation]      setup
    [Arguments]
    log    Enter RLT-TC-1004 setup

    Remove syslog server    n1_session1    ${sys_server1}
    Remove syslog server    n1_session1    ${dummy_sys_server}
    cli    h1   echo > ${syslog_dir}/${syslog_file}.log
    Session destroy local    h1_localsession_server1


RLT-TC-1004 teardown
    [Documentation]    teardown
    [Arguments]
    log    Enter RLT-TC-1004 teardown

    cli    h1_localsession_server1    echo > ${syslog_dir}/${syslog_file}.log

    # Breaking the packet capture in syslog
    Remove syslog server    n1_session1    ${sys_server1}
    Remove syslog server    n1_session1    ${dummy_sys_server}
    Session destroy local    h1_localsession_server1

Capture syslog
    [Arguments]    ${session1}    ${session2}    ${protocol}    ${int_port}
    [Documentation]    Key word for generating syslog event
    [Tags]    @author=gpalanis
    #Confifure syslog server to trigger alarm
    Configure syslog server    ${session2}    ${dummy_sys_server}    admin-state=ENABLED
	

Verify syslog file
    [Arguments]    ${session1}   ${id}  @{content}
    [Documentation]    Key word for Verify syslog file
    [Tags]    @author=gpalanis
    cli    ${session1}    \r\n   prompt=\\~\\]\\$

    ${output}    cli    ${session1}    cat ${syslog_dir}/${syslog_file}.log | grep ${id}   prompt=\\~\\]\\$
    cli    ${session1}    \r\n   prompt=\\~\\]\\$
    :For   ${check point}   in    @{content}
    \    should contain    ${output}    ${id}
    \    should contain    ${output}    ${check point}
    [Return]    ${output}
