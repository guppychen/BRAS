*** Settings ***
Documentation     verify that third uni port should not accept the same vlan with ELINE mode which have 2 UNI ports already.
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_verify_that_third_uni_port_should_not_accept_the_same_vlan_with_ELINE_mode_which_have_2_UNI_ports_already
    [Documentation]    verify that third uni port should not accept the same vlan with ELINE mode which have 2 UNI ports already.
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-394    @globalid=2256501    @eut=NGPON2-4    @priority=P2   @jira=EXA-18041
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:verify that third uni port should not accept the same vlan with ELINE mode which have 2 UNI ports already.


*** Keywords ***
setup
    [Documentation]    setup
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    mac-learning=enable    mode=ELINE

    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan2}    ${p_data_vlan}    cevlan_action=remove-cevlan    cfg_prefix=auto2
    prov_interface_err    eutA    ont-ethernet    22/x1   ${p_data_vlan}

teardown
    [Documentation]    teardown
    run keyword and ignore error  tg delete all traffic    tg1

    log    subscriber_point remove_svc
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan2}    ${p_data_vlan}    cfg_prefix=auto2

    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan}
