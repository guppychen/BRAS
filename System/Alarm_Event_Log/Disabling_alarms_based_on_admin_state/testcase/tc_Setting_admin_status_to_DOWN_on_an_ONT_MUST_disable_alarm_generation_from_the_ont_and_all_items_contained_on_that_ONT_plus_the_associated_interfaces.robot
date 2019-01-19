*** Settings ***
Documentation     When the admin status of an ONT is set to DOWN, the system MUST disable alarm generation for this ONT, and all associated ports and interfaces. 
...    Any outstanding alarms in this hierarchy should be closed when this transition is applied (active or suppressed alarms).
Resource          ./base.robot
Force Tags        @feature=Disabling_alarms_based_on_admin_state    @subfeature=Disabling_alarms_based_on_admin_state

*** Variables ***

*** Test Cases ***
 tc_Setting_admin_status_to_DOWN_on_an_ONT_MUST_disable_alarm_generation_from_the_ont_and_all_items_contained_on_that_ONT_plus_the_associated_interfaces
    [Documentation]    Contour Test case description
    ...    1 From ONT, execute an admin status to DOWN, the system MUST disable alarm generation for this ONT, and all associated ports and interfaces.
    ...      As Stated
    ...    2 Verify that any outstanding alarms in this hierarchy should be closed when this transition is applied (active or suppressed alarms).
    ...      As Stated
    [Setup]    Case_Test_Setup
    [Teardown]    Case_Test_Teardown
    [Tags]    @author=Meiqin_Wang    @tcid=AXOS_E72_PARENT-TC-3479   @globalid=2474929    @eut=GPON-8R2    @priority=P3
    
    no_shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    ${alarm_instance_id_ont}    verify_alarm_is_exist    eutA    port='${ont_eth_alarm_port}'
    
    check_port_admin_status_enable    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    check_port_admin_status_disable    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    wait until keyword succeeds   2min   5sec   verify_alarm_is_cleared    eutA    ${alarm_instance_id_ont}

    log    SUCCESS
    
*** Keyword ***
Case_Test_Setup
    [Documentation]    test case setup
    log    test case setup
    
Case_Test_Teardown
    [Documentation]    test case teardown
    log    deprovision other configuration in test step
    shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}

    
    