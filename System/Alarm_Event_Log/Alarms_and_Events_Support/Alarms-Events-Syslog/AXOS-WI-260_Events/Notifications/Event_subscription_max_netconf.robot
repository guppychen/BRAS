*** Settings ***
Documentation     This test suite is going to verify DUT must support the ability to configure at least 8 distinct event subscriptions
Suite Setup       event_setup     n1_sh       ${DEVICES.n1_netconf.user}
Suite Teardown    event_teardown    n1_sh
Library           String
Library           Collections
Library           SSHLibrary      120 seconds     width=100      height=100
Resource          base.robot
Force Tags

*** Test Cases ***
Event_subscription_max
    [Documentation]    Test case verifies DUT must support the ability to configure at least 8 distinct event subscriptions
    ...                1. Create 8 subscription by add subscription command Verify by show subscription command to make sure subscription added correctly  
    ...                2. Try creating 9th subscription make sure you get the error   
    ...                3. Verify all 8 subscription UA  Verify by show command to check all events are reported in UA  
    ...                4. Trigger alarms and events and verify notification is actually sent to each subscription. 

    [Tags]         @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar    @tcid=AXOS_E72_PARENT-TC-343   @user=root    @GID=2226266    @functional    @priority=P3       @user_interface=netconf

    Log         *** Verifying DUT must support the ability to configure at least 8 distinct event subscriptions ***
    Wait Until Keyword Succeeds      2 min     10 sec            Verifying_Event_subscription_max     ${DEVICES.n1_netconf.ip}      ${DEVICES.n1_netconf.user} 
    ...    ${DEVICES.n1_netconf.password}    ${DEVICES.n1_netconf.port}        ${DEVICES.n1_local_pc.ip}       n1_netconf      ${DEVICES.n1.ports.p1.port} 
    ...    n1_sh     n1

*** Keyword ***
event_setup
    [Arguments]            ${linux}      ${netconf_user}
    [Documentation]        Closing existing netconf connections if there is any

    Log    *** Closing existing netconf connections ***
    Wait Until Keyword Succeeds      2 min     10 sec         Closing existing netconf connections      ${linux}      ${netconf_user}

event_teardown
    [Arguments]    ${device}
    [Documentation]     Closing all netconf sessions if there is any

    SSHLibrary.Close All Connections

