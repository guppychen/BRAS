*** Settings ***
Documentation     This test suite is going to verify events can be simantaneously received for maximum user subscriptions while configurations can still be modified
Suite Setup       event_setup     n1_sh       ${DEVICES.n1_netconf.user}
Suite Teardown    event_teardown    n1_sh
Library           String
Library           Collections
Library           SSHLibrary      120 seconds     width=100      height=100
Resource          base.robot
Force Tags

*** Test Cases ***

Event_subscription_multipleSubscription
    [Documentation]    Test case verifies events can be simantaneously received for maximum user subscriptions while configurations can still be modified
    ...                1. Make sure all 8 user subscriptions get the above events simantaneously Make sure by viewing them from user agents  
    ...                2. Verify configurations can be modified while notifications are sent. Configuration is not blocked by notifications. 

    [Tags]         @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-344   @user=root    @GID=2226267    @functional    @priority=P3       @user_interface=netconf

    Log         *** Verify events can be simantaneously received for maximum user subscriptions while configurations can still be modified ***
    Wait Until Keyword Succeeds      2 min     10 sec            Verifying_Event_multiple_subscription      ${DEVICES.n1_netconf.ip}      ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}    ${DEVICES.n1_netconf.port}        ${DEVICES.n1_local_pc.ip}       n1_netconf      ${DEVICES.n1.ports.p1.port}     n1_sh     n1


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

