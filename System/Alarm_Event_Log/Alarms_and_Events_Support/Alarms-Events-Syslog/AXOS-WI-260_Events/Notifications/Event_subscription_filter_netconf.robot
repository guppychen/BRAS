*** Settings ***
Documentation     This test suite is going to verify whether subscribed events can be filtered and notified.
Suite Setup       alarm_setup     n1_sh       ${DEVICES.n1_netconf.user}
Suite Teardown    alarm_teardown      n1_sh      n1_netconf    
Library           String
Library           Collections
Library           SSHLibrary      120 seconds     width=100      height=100
Resource          base.robot
Force Tags

*** Test Cases ***

Event_subscription_filter
    [Documentation]    Test case verifies subscribed events can be filtered and notified
    ...                1. Establish netconf session and subscribe to notifications with no filters. Session and subscription are successfully started.  
    ...                2. Trigger various alarms/events. Notifications should be seen for each.  
    ...                3. Start a new session and subscription with filter for a specific category and severity. Session and subscription are successfully started.  
    ...                4. Trigger alarms/events within that category/severity. Notifications should be seen.  
    ...                5. Trigger alarms/events not within that category. Notifications should not be seen.  
    ...                6. Trigger alarms/events within the category, but not severity. Notifications should not be seen. 
    [Tags]          @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-342   @user=root    @GID=2226265    @functional    @priority=P3       @user_interface=netconf        @tag=skip_for_bug

    Log         *** Verify subscribed events can be filtered and notified ***
    Wait Until Keyword Succeeds      2 min     10 sec            Verifying_Event_subscription_filter      ${DEVICES.n1_netconf.ip}      ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}    ${DEVICES.n1_netconf.port}        ${DEVICES.n1_local_pc.ip}       n1_netconf      ${DEVICES.n1.ports.p1.port}     n1_sh


*** Keyword ***
alarm_setup
    [Arguments]            ${linux}      ${netconf_user}
    [Documentation]        Closing existing netconf connections if there is any

    Log    *** Closing existing netconf connections ***
    Wait Until Keyword Succeeds      2 min     10 sec         Closing existing netconf connections      ${linux}      ${netconf_user}

alarm_teardown
    [Arguments]            ${linux}      ${device}     
    [Documentation]        Clearing Alarms

    Log    *** Clearing Loss of signal alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec         Clearing Loss of Signal MAJOR alarm     device=${device}     user_interface=netconf
