*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4            @jira=AT-4212
Resource          base.robot

*** Variables ***
${upgrade-activate}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" > <activate xmlns="http://www.calix.com/ns/exa/base">    <filename>${bamboo.eolus}</filename> </activate> </rpc>

*** Test Cases ***
ManagementInterfaces-Faults-Event-reboot to finish activation_Netconf
    [Documentation]    Testcase to verify the events are generated when the image is succesfully activated.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-327    @globalid=2226248    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    Command    n1_session1    clear active event
    ${upgrade}=    Netconf Raw    n1_session3    xml=${upgrade-activate}
    : FOR    ${i}    IN RANGE    5000
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Exit For Loop If    '${string}' == 'Reload required to finish activation"'
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    Download Requested Event
    Should contain    ${events}    Download Started Event
    Should contain    ${events}    Download Finished Event
    Should contain    ${events}    Verification Started Event
    Should contain    ${events}    Verification Finished Event
    Should contain    ${events}    Installation Started Event
    Should contain    ${events}    Installation Finished Event
    Should contain    ${events}    Reload Required To Finish Activation Event
    [Teardown]    Teardown ManagementInterfaces-Faults-Event-reboot to finish activation_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces-Faults-Event-reboot to finish activation_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade cancel    ${DUT}
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
