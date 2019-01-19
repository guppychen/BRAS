*** Settings ***
Documentation     The purpose of this test case is to Verify that Rogue ONT Detection  can be enabled/disabled at PON level
...               1.Verify that Rogue ONT Detection  can be enabled/disabled at PON level


Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Rogue_ONT_Detection_enabled_disabled_at_PON_level.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-3519    @user_interface=CLI      @globalid=2487614    @eut=GPON-8r2    @feature=ONT Support    @subfeature=Rouge ONT    @author=pzhang
    [Documentation]   The purpose of this test case is to Verify that Rogue ONT Detection  can be enabled/disabled at PON level
    ...               1.Verify that Rogue ONT Detection  can be enabled/disabled at PON level

    [Setup]      setup

    log     Check quarantined-ont
    check_quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}    manual

    log     discover_ont is null
    Wait Until Keyword Succeeds   1 min  2s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=missing

    log    check pon Rogue ONT Detection status
    ${port_type} =    set variable     pon
    ${pon_name}    subscriber_point_get_pon_port_name    subscriber_point1
    check_interface    eutA    ${port_type}    ${pon_name}     status     rogue-ont-detection     enable

    log    disable pon Rogue ONT Detection
    ${pon_name}    subscriber_point_get_pon_port_name    subscriber_point1
    perform_interface_pon    eutA    ${pon_name}    stop
    ${port_type} =    set variable     pon
    check_interface    eutA    ${port_type}    ${pon_name}     status     rogue-ont-detection     disable

    log    enable pon Rogue ONT Detection
    ${pon_name}    subscriber_point_get_pon_port_name    subscriber_point1
    perform_interface_pon    eutA    ${pon_name}    start
    ${port_type} =    set variable     pon
    check_interface    eutA    ${port_type}    ${pon_name}     status     rogue-ont-detection     enable
    [Teardown]   teardown


*** Keywords ***
setup
    Wait Until Keyword Succeeds   1 min  5s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    log     add ont to quarantined-ont
    quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}





teardown
    log      remove ont from quarantined-ont
    quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}    no