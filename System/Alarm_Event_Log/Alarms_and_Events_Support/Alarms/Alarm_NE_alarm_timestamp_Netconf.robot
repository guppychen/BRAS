*** Settings ***
Documentation     EXA device MUST support at the alarm instance level displaying the NE alarm timestamp
...               This is the timestamp (wall clock and not relative if time synchronized) when the alarm condition originated
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${subscope-id-702}    <?xml version="1.0" encoding="utf-8"?> <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="101"> <show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"> <id>702</id> \ </show-alarm-instances-active-subscope> </rpc>]]>]]>

*** Test Cases ***
Alarm_NE_alarm_timestamp_Netconf
    [Documentation]    Testcase to verify the timestamp will be equal in all the user interface(CLI,SNMP,SYSLOG,NETCONF) when an alarm is generated .
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-233    @globalid=2226143    @priority=P1    @user_interface=NETCONF
    command    n1_session1    configure
    command    n1_session1    do copy running-config startup-config
    #get the time from the device
    command    n1_session1    do show logging host
    ${time}=    command    n1_session1    do show clock
    #syslog creation generates an 702 alarm
    Syslog logging-host-creation    n1_session1    ${serverIp.v4_addr}
    ${curr_time}=    Convert date    ${time}    result_format=%Y-%m-%dT%H:%M
    #verify if the alarm is generated
    ${alarm}=    command    n1_session1    do show alarm active subscope id 702
    Should contain    ${alarm}    id 702
    #get the time of the alarm
    ${cevent_time}=    Get Lines Containing String    ${alarm}    ${curr_time}    702
    ${cevent_time}=    Remove string    ${cevent_time}    ne-event-time
    ${cEvent_time}=    Convert date    ${cevent_time}    epoch
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${message}=    Netconf Raw    n1_session3    xml=${subscope-id-702}
    Should contain    ${message.xml}    702
    ${nalarm}=    Convert to string    ${message}
    ${nevent_time}=    Get Lines Containing String    ${nalarm}    ne-event-time
    ${nevent_time}=    Remove string    ${nevent_time}    <ne-event-time>    </ne-event-time>
    ${nEvent_time}=    Convert date    ${nevent_time}    epoch
    Run Keyword If    '${cEvent_time}' == '${nEvent_time}'    Log    Netconf event-time matches with Cli event-time
    Run Keyword Unless    '${cEvent_time}' == '${nEvent_time}'    Fail    Netconf event-time doesnot match with Cli event-time
    [Teardown]    Teardown Alarm_NE_alarm_timestamp_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown Alarm_NE_alarm_timestamp_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    no logging host ${serverIp.v4_addr}
    command    ${DUT}    no logging host ${serverIp.vm_addr}
    command    ${DUT}    do copy running-config startup-config
    Disconnect    ${DUT}
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
