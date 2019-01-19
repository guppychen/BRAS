*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4         @jira=AT-4212
Resource          base.robot

*** Variables ***
${upgrade-activate}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" > <activate xmlns="http://www.calix.com/ns/exa/base">    <filename>${bamboo.patch1}</filename> </activate> </rpc>

*** Test Cases ***
ManagementInterfaces-Faults-Event-Deactivation Aborted Event_Netconf
    [Documentation]    Testcase to verify the events when the deactivation is aborted.
    [Tags]     @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-326    @globalid=2226247    @priority=P1    @user_interface=netconf
    Command    n1_session1    clear active event
    Command    n1_session1    ping 10.245.250.136 -c 1        timeout_exception=0
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    Command    n1_session1    clear active event
    ${upgrade}=    Netconf Raw    n1_session3    xml=${upgrade-activate}
    #Wait till state of the Upgrade changes to "Activated"
    : FOR    ${i}    IN RANGE    1000
    \     sleep   5s    add check interval as 5s
    \     ${upgrade}=    command    n1_session1    show upgrade status
    \    #check if the patch is already installed
    \    ${reason}=    Get Lines Containing String    ${upgrade}    install-error
    \    ${reason}=    String.Fetch From Right    ${reason}    ${SPACE}"
    \    Exit For Loop If    '${reason}' == 'Cannot install patch. Same patch has already been installed."'
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From right    ${line}    ${SPACE}
    \    Log    ${string}
    \    Exit For Loop If    '${string}' == 'Activated'
    #deactivate the patch installed
    command    n1_session1    upgrade deactivate
    : FOR    ${i}    IN RANGE    50
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Run keyword If    '${string}' == 'Reload required to finish deactivation"'    upgrade_cancel    n1_session1
    \    Exit For Loop If    '${string}' == 'Reload required to finish deactivation"'
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    Reload Required To Finish Deactivation Event
    Should contain    ${events}    Deactivation Aborted Event
    [Teardown]    Teardown ManagementInterfaces-Faults-Event-Deactivation Aborted Event_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces-Faults-Event-Deactivation Aborted Event_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
