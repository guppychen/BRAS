*** Settings ***
Documentation      
...    For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
...     
...     
...    
...    Id
...    
...    
...    Unique id of event type. Statically defined
...    
...    Name
...    
...    
...    Display name of event type
...    
...    Description
...    
...    
...    Static description of event type. Defines purpose of the event.
...    
...    Source
...    
...    
...    Source object identifier for event -  specific component (chassis, shelf, slot/port, power supply, radio etc.)
...    Category         Category of event identifying some logic group of events significant from an external usage perspective
...    
...    Additional text
...    
...    
...    May contain a default message format. The intent is to include Instance specific detailed information augmenting  description. These details may also be encoded in additional info
...    
...    Sequence number
...    
...    
...    Whether or not this event supports sequence numbers
...    
...    Module
...    
...    
...    Module generating the event (may include file and line # when available)
...     
...    ======================================================================================
...    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
...     
...    Feature  Events
...    PON 
...    
...    name ont-arrival
...    
...    ont-departure
...    
...    ont-link
...    
...    ont-unlink
Force Tags        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao      @author=ysnigdha
Resource          ./base.robot

*** Variables ***
${get-event}      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get> <filter><status xmlns="http://www.calix.com/ns/exa/base"><system><instances><event><detail></detail></event></instances></system></status></filter></get></rpc>
@{list_netconf}     <description>ONT has arrived on PON port</description>

${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>


*** Test Cases ***
tc_Event_Category_PON
    [Documentation]    1 Open a CLI session to the EUT open netconf session and subscribe to notifications configure a trap host and set up a PC to capture traps.
    ...    2 Perform actions to trigger the events above.
    ...    3 Look at the details of the event from the CLI. All information in the event is correct.
    ...    4 Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.
    ...    5 Verify the Netconf notification was sent to the logging host. All information in the alarm is shown in the notification.
    ...    6 Trap should be sent to the trap host configured.PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2880    @skip=limitation
    [Setup]    RLT-TC-8836 setup
    [Teardown]   RLT-TC-8836 teardown

    #Create notification Subscription
    ${subscription}    set variable    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"> <create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter><db-change xmlns="http://www.calix.com/ns/exa/base"/></filter></create-subscription></rpc>
    
    Raw netconf configure    n1_session3    ${subscription}    ok
  
    # Trigger shutdown command to generate alarm
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p2.type}    ${DEVICES.n1_session1.ports.subscriber_p2.port}
    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p2.type}    ${DEVICES.n1_session1.ports.subscriber_p2.port}
    # Sleep added so that event alarm is triggered
    sleep     10

    # Verify the Netconf notification .
    ${events}=    Netconf Raw    n1_session3    xml=${get-event}
    log    ${events.xml}
    : FOR    ${value}    IN    @{list_netconf}
    \    Should Contain    ${events.xml}    ${value}



*** Keywords ***
RLT-TC-8836 setup
    [Documentation]       RLT-TC-8836 setup
    [Arguments]
    log    Enter RLT-TC-8836 setup

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p2.type}    ${DEVICES.n1_session1.ports.subscriber_p2.port}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

RLT-TC-8836 teardown
    [Documentation]    RLT-TC-8836 teardown 
    [Arguments]
    log    Enter RLT-TC-8836 teardown

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p2.type}    ${DEVICES.n1_session1.ports.subscriber_p2.port}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}
