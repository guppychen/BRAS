*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${set-time-netconf}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" > <set-time xmlns="http://www.calix.com/ns/exa/base"> <time>${clock.time1}</time> </set-time> </rpc>

*** Test Cases ***
ManagementInterfaces_Faults_Event_time-set_netconf
    [Documentation]    Testcase to verify the if the events are generated when time is changed manually.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-304    @globalid=2226225    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${clock}=    Netconf Raw    n1_session3    xml=${set-time-netconf}
    Should contain    ${clock.xml}    ok
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    System time has been manually set
    #sleep    100s
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_time-set_netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_time-set_netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    ${cur_time}=    Get current date    result_format=%Y-%m-%dT%H:%M:%S
    command    n1_session1    clock set ${cur_time}
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
