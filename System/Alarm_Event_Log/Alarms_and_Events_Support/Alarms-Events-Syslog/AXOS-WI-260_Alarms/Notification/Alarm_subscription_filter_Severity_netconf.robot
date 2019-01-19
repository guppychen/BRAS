*** Settings ***
Documentation     This test suite is going to verify whether Alarms can be subscribed based on Severity
Suite Setup       alarm_setup      n1_netconf      ${DEVICES.n1_netconf.ip}      ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}
  ...   ${DEVICES.n1_netconf.port}        ${DEVICES.n1_local_pc.ip}
Library           String
Library           Collections
Library           SSHLibrary      120 seconds
Resource          base.robot
Force Tags

*** Test Cases ***

Alarm_subscription_filter_Severity
    [Documentation]    Test case verifies whether Alarms can be subscribed based on Severity
    ...        1. Connect to Netconf Agent.
    ...        2. Subscribe to Alarms from various severity. Alarms should only be sent when severity is equal or greater than the severity configured.
    [Tags]       @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2863   @user=root     @functional    @priority=P1      @user_interface=netconf
   
    Log    *** Alarm notification for different severities ***
    Wait Until Keyword Succeeds      2 min     10 sec            Alarm_notification_for_various_severities     ${DEVICES.n1_netconf.ip}      ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}    ${DEVICES.n1_netconf.port}        ${DEVICES.n1_local_pc.ip}       n1_netconf      ${DEVICES.n1.ports.p1.port}     n1_sh

     
*** Keyword ***
alarm_setup
    [Arguments]            ${device_netconf}      ${device_ip}     ${username}     ${password}    ${port}       ${local_pc_ip}      
    [Documentation]    Subscribing to Alarms

    Log    *** Initiating SSH connection using SSHLibrary keyword to capture automatic alarm notification on console ***
    Wait Until Keyword Succeeds      2 min     10 sec     Connection_establishment_using_SSHLibrary     ${device_ip}         ${username}      ${password}    ${port}       ${local_pc_ip}     ${device_netconf} 

