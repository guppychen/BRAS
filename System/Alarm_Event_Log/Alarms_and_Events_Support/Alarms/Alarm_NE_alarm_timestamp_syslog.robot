*** Settings ***
Documentation     EXA device MUST support at the alarm instance level displaying the NE alarm timestamp
...               This is the timestamp (wall clock and not relative if time synchronized) when the alarm condition originated
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
Alarm_NE_alarm_timestamp_syslog
    [Documentation]    Testcase to verify the timestamp will be equal in all the user interface(CLI,SNMP,SYSLOG,NETCONF) when an alarm is generated .
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-233    @globalid=2226143    @priority=P1    @user_interface=SYSLOG
    command    sjccafe-shchandr    cd /var/log/${syslog.filename}
    command    sjccafe-shchandr    sudo rm sys.log    timeout_exception=0
    command    sjccafe-shchandr    ${cafe.password}    timeout_exception=0
    command    n1_session1    configure
    #Create the syslog server to store the data and clear the alarm
    Syslog logging-host-creation    n1_session1    ${serverIp.vm_addr}
    command    n1_session1    do copy running-config startup-config
    ${prompt}=    get last command prompt    n1_session1
    ${prompt}=    String.Fetch From Left    ${prompt}    (
    #get the time from the device
    command    n1_session1    do show logging host
    ${time}=    command    n1_session1    do show clock
    #syslog creation generates an 702 alarm
    Syslog logging-host-creation    n1_session1    ${serverIp.v4_addr}
    ${curr_time}=    Convert date    ${time}    result_format=%Y-%m-%dT%H:%M:%S
    ${curr_time+1}=    Add Time To Date    ${curr_time}    1    result_format=%Y-%m-%dT%H:%M:%S
    #verify if the alarm is generated
    ${alarm}=    command    n1_session1    do show alarm active subscope id 702
    Should contain    ${alarm}    id 702
    ${cevent_time}=    Get Lines Containing String    ${alarm}    ne-event-time    702
    ${cevent_time}=    Remove string    ${cevent_time}    ne-event-time
    ${cevent_time}=    Remove string    ${cevent_time}    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    #${cEvent_time}=    Convert date    ${cevent_time}    epoch
    #VALIDATION OF THE SYSLOG EVENT-TIME
    command    sjccafe-shchandr    cd ${syslog.path}/${syslog.filename}
    #Copy the data into a new file as we dont have permission to get the syslog.log file
    command    sjccafe-shchandr    sudo cp syslog.log sys.log    timeout_exception=0
    command    sjccafe-shchandr    ${cafe.password}    timeout_exception=0
    command    sjccafe-shchandr    ll
    command    sjccafe-shchandr    pwd
    command    sjccafe-shchandr    sudo chmod 777 sys.log    timeout_exception=0
    command    sjccafe-shchandr    ${cafe.password}    timeout_exception=0
    ${file1}=    cli   sjccafe-shchandr   sudo cat /var/log/${prompt}/sys.log | tail -n 10
    ${sevent_time}=    Get Lines Containing String    ${file1}    ${curr_time}
    ${sevent_time}=    Get Lines Containing String    ${sevent_time}    702
    ${sEvent_time}=    String.Fetch From Left    ${sevent_time}    ${SPACE}
    ${sevent_time+1}=    Get Lines Containing String    ${file1}    ${curr_time+1}
    ${sevent_time+1}=    Get Lines Containing String    ${sevent_time+1}    702
    ${sEvent_time+1}=    String.Fetch From Left    ${sevent_time+1}    ${SPACE}
    Run Keyword If    '${cEvent_time}' == '${sEvent_time}' or '${cEvent_time}' == '${sEvent_time+1}'    Log    Syslog event-time matches with Cli event-time
    Run Keyword If    '${cEvent_time}' == '${sEvent_time}' and '${cEvent_time}' == '${sEvent_time+1}'    Fail    Syslog event-time doesnot match with Cli event-time
    [Teardown]    Teardown Alarm_NE_alarm_timestamp_syslog    n1_session1    ${prompt}

*** Keywords ***
Teardown Alarm_NE_alarm_timestamp_syslog
    [Arguments]    ${DUT}    ${prompt}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    end
    command    ${DUT}    config
    command    ${DUT}    no logging host ${serverIp.v4_addr}
    command    ${DUT}    no logging host ${serverIp.vm_addr}
    command    ${DUT}    do copy running-config startup-config
    Disconnect    ${DUT}
