*** Settings ***
Documentation     
Resource          ./base.robot


*** Variables ***
${all_or_current}    all
${bin_count}    4
${log_category}    GENERAL

*** Test Cases ***
tc_ONT_EXA_device_must_support_the_ability_to_clear_the_PM_Session_History_Bins
    [Documentation]    A user with the appropriate permissions must be able to clear the PM Session Current and History Bins. The clearing ofthe PM Session Bins needs to be recorded. We need topersistently record who did the clear and when it was done. This needs to be reportable on the mgmt plane (EWI, CLI, NetConf) in association with the PM Session Bins.
    ...    The clear also needs to be recorded in syslog.
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-765    @globalid=2307625
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP1:A user with the appropriate permissions must be able to clear the PM Session Current and History Bins. The clearing ofthe PM Session Binsneeds to berecorded. We need topersistently record who did the clear and when it was done. This needs to be reportable on the mgmt plane (EWI, CLI, NetConf) in association with the PM Session Bins.
    log    STEP2:The clear also needs to be recorded in syslog.
    Axos Cli With Error Check    eutA    clear ont ont-id ${service_model.subscriber_point1.attribute.ont_id} performance-monitoring rmon-session bin-or-interval ${rmon_type} bin-duration ${rmon_session_15_min} all-or-current ${all_or_current}
    ${log_event}    show_last_log_event    eutA    ${log_category}
    ${res}    Should Match Regexp    ${log_event}    [\\S\\s]+\\[ont-id='(\\S+)'\\]
    ${str}    Convert To String    ${service_model.subscriber_point1.attribute.ont_id}
    Should Be Equal    ${str}    @{res}[1]
    Should Contain    ${log_event}    ont-rmon-pmdata-cleared
    Should Contain    ${log_event}    details bin-duration: ${rmon_session_15_min}, bin-or-interval: ${rmon_type}, all-or-current: ${all_or_current}
    
*** Keywords ***
case setup
    [Documentation]
    [Arguments]
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
     prov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_15_min}     ${bin_count}
     
case teardown
    [Documentation]
    [Arguments]
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_15_min}     ${bin_count}