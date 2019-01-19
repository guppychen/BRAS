*** Settings ***
Documentation     EXA device MUST support at the alarm instance level displaying the NE alarm timestamp
...               This is the timestamp (wall clock and not relative if time synchronized) when the alarm condition originated
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
Alarm_NE_alarm_timestamp_snmp
    [Documentation]    Testcase to verify the timestamp will be equal in all the user interface(CLI,SNMP,SYSLOG,NETCONF) when an alarm is generated .
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-233    @globalid=2226143    @priority=P1    @user_interface=SNMP
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    command    n1_session1    end
    command    n1_session1    copy running-config startup-config
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    command    n1_session1    configure
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
    ${cevent_time}=    Remove string    ${cevent_time}    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    Log    ${cevent_time}
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    ${cevent_time}
    [Teardown]    Teardown Alarm_NE_alarm_timestamp_snmp    n1_session1

*** Keywords ***
Teardown Alarm_NE_alarm_timestamp_snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    SNMP_v2_teardown    n1_session1
    command    ${DUT}    configure
    command    ${DUT}    no logging host ${serverIp.v4_addr}
    command    ${DUT}    end
    command    ${DUT}    copy running-config startup-config
    Disconnect    ${DUT}
