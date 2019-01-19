*** Settings ***
Documentation     EXA device MUST support at the alarm instance level displaying the NE alarm timestamp
...               This is the timestamp (wall clock and not relative if time synchronized) when the alarm condition originated
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
Alarm_NE_alarm_timestamp_cli
    [Documentation]    Testcase to verify the timestamp will be equal in all the user interface(CLI,SNMP,SYSLOG,NETCONF) when an alarm is generated .
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-233    @globalid=2226143    @priority=P1    @user_interface=CLI
    command    n1_session1    configure
    command    n1_session1    do copy running-config startup-config
    #get the time from the device
    command    n1_session1    do show logging host
    ${time}=    command    n1_session1    do show clock   prompt=\\#
    #syslog creation generates an 702 alarm
    Syslog logging-host-creation    n1_session1    ${serverIp.v4_addr}
    ${curr_time}=    Convert date    ${time}    result_format=%Y-%m-%dT%H:%M
    #verify if the alarm is generated
    ${alarm}=    command    n1_session1    do show alarm active subscope id 702
    Should contain    ${alarm}    id 702
    #VALIDATION OF THE CLI EVENT-TIME
    ${cevent_time}=    Get Lines Containing String    ${alarm}    ${curr_time}    702
    ${cevent_time}=    Remove string    ${cevent_time}    ne-event-time
    ${cEvent_time}=    Convert date    ${cevent_time}    epoch
    ${dev_time}=    Convert date    ${time}    epoch
    ${cEvent_time-2}=    Evaluate    ${cEvent_time} - 2
    ${cEvent_time+2}=    Evaluate    ${cEvent_time} + 2
    Run Keyword If    ${cEvent_time-2} < ${dev_time} < ${cEvent_time+2}    Log    Cli time matches with event time in the generated alarm
    Run Keyword Unless    ${cEvent_time-2} < ${dev_time} < ${cEvent_time+2}    Fail    Cli time doesnot match with event time in the generated alarm
    [Teardown]    Teardown Alarm_NE_alarm_timestamp_cli    n1_session1

*** Keywords ***
Teardown Alarm_NE_alarm_timestamp_cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    no logging host ${serverIp.v4_addr}
    command    ${DUT}    no logging host ${serverIp.vm_addr}
    command    ${DUT}    do copy running-config startup-config
    Disconnect    ${DUT}
