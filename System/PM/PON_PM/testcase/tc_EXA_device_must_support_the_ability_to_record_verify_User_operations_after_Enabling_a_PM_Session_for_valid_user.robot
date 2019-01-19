*** Settings ***
Documentation     
Resource          ./base.robot


*** Variables ***
${log_category}    DBCHANGE
${bin_count}    1440

*** Test Cases ***
tc_EXA_device_must_support_the_ability_to_record_verify_User_operations_after_Enabling_a_PM_Session_for_valid_user
    [Documentation]    A user with the appropriate permissions must be able to enable/Disable a PM Session - this operation MUST be recorded. We need topersistentlyrecord who did the enable/disable operation - this needs to be reportable on the mgmt plane (EWI, CLI, NetConf) in association with the PM Session.
    ...    The enable/disable also needs to be recorded in syslog.
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-768    @globalid=2307628
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:A user with the appropriate permissions must be able to enable/Disable a PM Session - this operation MUST be recorded. We need topersistentlyrecord who did the enable/disable operation - this needs to be reportable on the mgmt plane (EWI, CLI, NetConf) in association with the PM Session.

    log    STEP:The enable/disable also needs to be recorded in syslog.
    prov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}    disable
    ${pon_pm_state}    get_pon_pm_state    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}
    log    The pm session state is ${pon_pm_state}.
    Should Be Equal    '${pon_pm_state}'    'disable'
    prov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}    enable
    ${pon_pm_state}    get_pon_pm_state    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}
    log    The pm session state is ${pon_pm_state}.
    Should Be Equal    '${pon_pm_state}'    'enable'
    ${log_event}    show_last_log_event    eutA    ${log_category}
    ${port_id}    Should Match Regexp    ${log_event}    [\\S\\s]+\\[port='(\\S+)'\\]/rmon-session
    Should Contain    ${pon_port}    @{port_id}[1]
    Should Contain    ${log_event}    new-value enable
    
*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    setup
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log     step1: create a class-map to match VLAN 600 in flow 1
    log     step2: create a policy-map to bind the class-map and add c-tag
    log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
    log     step4: apply the s-tag and policy-map to the port of ont
    subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    Set Test Variable    ${pon_port}    ${pon_port}
    log    Add pm task to pon port.
    prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}

case teardown
    [Documentation]
    [Arguments]
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}