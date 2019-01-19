*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${event-definition-101}    <?xml version="1.0" encoding="utf-8"?> <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="101"> <show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"> <id>101</id> </show-event-definitions-subscope> </rpc> ]]>]]>
${event-details}    <?xml version="1.0" encoding="utf-8"?> <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <get> <filter> <status xmlns="http://www.calix.com/ns/exa/base"> <system> <instances> <event> <detail> </detail> </event> </instances> </system> </status> </filter> </get> </rpc> ]]>]]>

*** Test Cases ***
ManagementInterfaces_Faults_Event_Id_Netconf
    [Documentation]    To verify if the event-id matches it's definition.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-337    @globalid=2226259    @priority=P1    @user_interface=Netconf
    cli    n1_session1    clear active event
    Disconnect    n1_session1
    command    n1_session1    Show version
    #Verify the scenario from NETCONF
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${event-details}=    Netconf Raw    n1_session3    xml=${event-details}
    ${event-details}=    Convert to string    ${event-details}
    ${event-def}=    Netconf Raw    n1_session3    xml=${event-definition-101}
    ${event-def}=    Convert to string    ${event-def}
    ${description}=    String.Get Lines Containing String    ${event-def}    description
    ${description}=    Remove string    ${description}    ${SPACE}${SPACE}<description>
    ${description}=    Remove string    ${description}    </description>
    ${details}=    String.Get Lines Containing String    ${event-def}    details
    ${details}=    Remove string    ${details}    ${SPACE}${SPACE}<details>
    ${details}=    Remove string    ${details}    </details>
    ${name}=    String.Get Lines Containing String    ${event-def}    <name>
    ${name}=    Remove string    ${name}    ${SPACE}${SPACE}<name>
    ${name}=    Remove string    ${name}    </name>
    ${category}=    String.Get Lines Containing String    ${event-def}    category
    ${category}=    Remove string    ${category}    ${SPACE}${SPACE}<category>
    ${category}=    Remove string    ${category}    </category>
    Should contain    ${event-details}    ${description}
    Should contain    ${event-details}    ${details}
    Should contain    ${event-details}    ${category}
    Should contain    ${event-details}    ${name}
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Id_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Id_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
