*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4     @jira=AT-4212
Resource          base.robot

*** Variables ***
${upgrade-activate}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" > <activate xmlns="http://www.calix.com/ns/exa/base">    <filename>${bamboo.eolus}</filename> </activate> </rpc>

*** Test Cases ***
ManagementInterfaces_Faults_Event_Upgrade_image_activation_Netconf
    [Documentation]    Testcase to verify the events are generated when the image is succesfully activated.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-317    @globalid=2226238    @priority=P1    @user_interface=Netconf
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
    Should contain    ${events}    upgrade-requested
    Should contain    ${events}    upgrade-downloading-image
    Should contain    ${events}    upgrade-downloaded-image
    Should contain    ${events}    upgrade-verifying-image
    Should contain    ${events}    upgrade-image-verified
    Should contain    ${events}    upgrade-installing-image
    Should contain    ${events}    upgrade-installed-image
    Should contain    ${events}    upgrade-reload-required-to-act
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Upgrade_image_activation_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Upgrade_image_activation_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    show upgrade status
    upgrade cancel    ${DUT}
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
