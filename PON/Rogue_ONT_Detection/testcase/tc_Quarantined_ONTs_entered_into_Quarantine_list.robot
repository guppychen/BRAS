*** Settings ***
Documentation     The purpose of this test case is to Verify that an ONT can be manually quarantined.
...               1.Create ont
...               2.add ont to quarantined-ont
...               3.Check quarantined-ont

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Quarantined_ONTs_entered_into_Quarantine_list.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-3507    @user_interface=CLI      @globalid=2487602    @eut=GPON-8r2    @feature=ONT Support    @subfeature=Rouge ONT    @author=pzhang
    [Documentation]   The purpose of this test case is to Verify that an ONT can be manually quarantined.
    ...               1.Create ont
    ...               2.add ont to quarantined-ont
    ...               3.Check quarantined-ont
    [Setup]      setup

    log     Check quarantined-ont
    check_quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}    manual

    log     discover_ont is unull
    Wait Until Keyword Succeeds   1 min  2s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=missing

    [Teardown]   teardown


*** Keywords ***
setup
    Wait Until Keyword Succeeds   1 min  5s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    log     add ont to quarantined-ont
    quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}





teardown
    log      remove ont from quarantined-ont
    quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}    no