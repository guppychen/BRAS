*** Settings ***
Documentation     contour case description
Resource          ./base.robot
Force Tags        @feature=PON_PM    @subfeature=PON_PM
*** Variables ***
${bin_count}    1440
${pon_counter_name}    rx-errors
*** Test Cases ***
Disable_a_PM_Bin
    [Documentation]    A user with the appropriate permissions must be able to enable/Disable a PM Session - this operation MUST be recorded. We need topersistentlyrecord who did the enable/disable operation - this needs to be reportable on the mgmt plane (EWI, CLI, NetConf) in association with the PM Session.
    ...    Step 1: Provision a rmon-session on the PON interface.
    ...    Step 2: Change the admin-state to disable.
    ...    Step 3: Check the running config to confirm the change is taking effect.
    [Setup]    setup
    [Teardown]    teardown
    [Tags]    @author=JerryWu    @tcid=AXOS_E72_PARENT-TC-767   @globalid=2307627    @eut=NGPON2-4    @priority=P1
    prov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}    disable
    ${pon_pm_state}    get_pon_pm_state    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}
    Should Be Equal    '${pon_pm_state}'    'disable'
    log    The rmon-session is disabled successfully.
    prov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}    enable
    ${pon_pm_state}    get_pon_pm_state    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}
    Should Be Equal    '${pon_pm_state}'    'enable'
    log    The rmon-session is enabled successfully.      
*** Keywords ***
setup
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
     ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
     log    Add pm task to pon port.
     Set Test Variable    ${pon_port}
     prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}
teardown
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}