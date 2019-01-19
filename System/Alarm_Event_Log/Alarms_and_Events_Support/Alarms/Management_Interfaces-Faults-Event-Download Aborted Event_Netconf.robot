*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4    @jira=AT-4212
Resource          base.robot

*** Variables ***
${upgrade-activate}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" > <activate xmlns="http://www.calix.com/ns/exa/base">    <filename>${bamboo.eolus}</filename> </activate> </rpc>

*** Test Cases ***
Management_Interfaces-Faults-Event-Download Aborted Event_Netconf
    [Documentation]    Testcase to verify the events are generated when the download of the image is aborted by user.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-323    @globalid=2226244    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    Command    n1_session1    clear active event
    ${upgrade}=    Netconf Raw    n1_session3    xml=${upgrade-activate}
    : FOR    ${i}    IN RANGE    500
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Exit For Loop If    '${string}' == 'Download aborted by user, image not installed"'
    \    Run keyword If    '${string}' == 'Download in progress"'    upgrade_cancel    n1_session1
    \    should not contain    ${string}    Verification in progress
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    Download Requested Event
    Should contain    ${events}    Download Started Event
    Should contain    ${events}    Download Aborted Event
    [Teardown]    Teardown Management_Interfaces-Faults-Event-Download Aborted Event_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown Management_Interfaces-Faults-Event-Download Aborted Event_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade_cancel    n1_session1
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
