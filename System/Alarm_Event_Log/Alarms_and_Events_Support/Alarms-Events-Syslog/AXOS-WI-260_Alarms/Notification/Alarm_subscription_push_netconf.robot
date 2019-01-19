*** Settings ***
Documentation     This test suite is going to verify multiple Alarm notifications can be sent at the same time
Suite Setup       alarm_setup      n1_netconf      ${DEVICES.n1_netconf.ip}      ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}
     ...    ${DEVICES.n1_netconf.port}        ${DEVICES.n1_local_pc.ip}      ${DEVICES.n1_local_pc.password}      n1_local_pc
     ...   ${DEVICES.n1_local_pc.ip_trap}
Suite Teardown    alarm_teardown    n1_netconf       n1     ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.ip_trap}
Library           String
Library           Collections
Library           SSHLibrary      120 seconds
Resource          base.robot
Force Tags

*** Test Cases ***

Alarm_subscription_push
    [Documentation]    Test case verifies multiple Alarm notifications can be sent at the same time
    ...        1. Configure logging host. Logging host configured and reachable. logging host x.x.x.x 
    ...        2. Configure SNMP trap host. Trap host is configured and reachable. snmp v3 user calixauth authentication protocol MD5 key calixauth privacy protocol DES key calixauth ! v3 trap-host 10.0.1.18 calixauth security-level authPriv 
    ...        3. Subscribe to Netconf notifications. Netconf notification is set.  exa-events   ]]>]]>  
    ...        4. Trigger any alarm repeatedly. Verify all 3 types of notifications are sent.  
    ...        5. Make configuration changes from the netconf interface while the alarms/events are being posted at the same time. Very configuration changes don't block the notifications from being sent.  
    ...        6. Make configuration changes from the CLI interface while alarms/events are being posted at the same time. Very configuration changes don't block the notifications from being sent. 
    [Tags]       @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2864   @user=root     @functional    @priority=P1      @user_interface=netconf
   
    Log    *** Alarm notification for different severities ***
    Wait Until Keyword Succeeds      2 min     10 sec            Multiple_Alarm_Notifications     ${DEVICES.n1_netconf.ip}      ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}    ${DEVICES.n1_netconf.port}        ${DEVICES.n1_local_pc.ip}       n1_netconf     n1_snmp_v2     ${DEVICES.n1_snmp_v2.redirect}      n1_sh    n1_local_pc      ${DEVICES.n1_local_pc.password}      n1

*** Keyword ***
alarm_setup
    [Arguments]            ${device_netconf}      ${device_ip}     ${username}     ${password}    ${port}       ${local_pc_ip}
         ...   ${local_pc_password}     ${localpc}   ${local_pc_ip_trap}
    [Documentation]        Subscribing to Alarms

    Log    *** Configure SYSLOG server on DUT and local PC ***
    Wait Until Keyword Succeeds      2 min     10 sec       Configure SYSLOG server on DUT using netconf           ${device_netconf}     ${local_pc_ip}

    Wait Until Keyword Succeeds      2 min     10 sec      Syslog_server_configure_on_local_PC         ${localpc}      ${local_pc_ip}        ${local_pc_password}

    Log         *** Configuring SNMP on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT_using_netconf        ${device_netconf}       ${local_pc_ip_trap}

    Log    *** Initiating SSH connection using SSHLibrary keyword to capture automatic alarm notification on console ***
    Wait Until Keyword Succeeds      2 min     10 sec     Connection_establishment_using_SSHLibrary     ${device_ip}         ${username}      ${password}    ${port}       ${local_pc_ip}     ${device_netconf} 

alarm_teardown
    [Arguments]    ${device_netconf}    ${device1}    ${local_pc_ip}      ${local_pc_ip_trap}
    [Documentation]        Clearing INFO alarm

    Log         *** Unconfigure SYSLOG server ***
#    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfigure SYSLOG server on DUT using netconf           ${device_netconf}      ${local_pc_ip}

    Log         *** Unconfigure SNMP on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfiguring_SNMP_on_DUT       ${device1}        ${local_pc_ip_trap}
