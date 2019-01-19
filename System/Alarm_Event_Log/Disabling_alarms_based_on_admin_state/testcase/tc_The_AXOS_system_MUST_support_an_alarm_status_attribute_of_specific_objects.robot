*** Settings ***
Documentation     The AXOS system MUST support an alarm status attribute on specific objects that may be queried for current alarm states.
...    The attribute MUST be supported on the following objects:
...    - cards
...    - ports
...    - onts
...    - fans
...    - lags 
...    This attribute should identify any alarm conditions that have been detected on the object, whether they be active or suppressed.
...    If the object is administratively disabled, then the attribute should indicate this, and no further status will be available.
Resource          ./base.robot
Force Tags        @feature=Disabling_alarms_based_on_admin_state    @subfeature=Disabling_alarms_based_on_admin_state

*** Variables ***

*** Test Cases ***
tc_The_AXOS_system_MUST_support_an_alarm_status_attribute_of_specific_objects
    [Documentation]    Contour Test case description
    ...    1 Create different alarms on DUT for: - cards - ports - onts - lags - Not for fans as not supported for E3-2
    ...    2 Verify that attribute should identify any alarm conditions that have been detected on the object, whether they be active or suppressed. If the object is administratively disabled, then the attribute should indicate this, and no further status will be available.  As stated
    
    [Setup]    Case_Test_Setup
    [Teardown]    Case_Test_Teardown
    [Tags]    @author=Meiqin_Wang    @tcid=AXOS_E72_PARENT-TC-3481   @globalid=2474931    @eut=GPON-8R2    @priority=P3
    
    no_shutdown_port    eutA    ${service_model.service_point2.type}    ${service_model.service_point2.name}
    no_shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    Wait Until Keyword Succeeds    1 min    5 sec    verify_alarm_is_exist    eutA    ${service_model.service_point2.name}
    Wait Until Keyword Succeeds    1 min    5 sec    verify_alarm_is_exist    eutA    port='${ont_eth_alarm_port}'
    
    ${alarm_instance_id_lag}    verify_alarm_is_exist    eutA    ${service_model.service_point2.name}
    ${alarm_instance_id_ont}    verify_alarm_is_exist    eutA    port='${ont_eth_alarm_port}'
    
    shutdown_port    eutA    ${service_model.service_point2.type}    ${service_model.service_point2.name}
    shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    check_port_admin_status_disable    eutA    ${service_model.service_point2.type}    ${service_model.service_point2.name}
    check_port_admin_status_disable    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    wait until keyword succeeds   2min   5sec   verify_alarm_is_cleared    eutA    ${alarm_instance_id_lag}
    wait until keyword succeeds   2min   5sec    verify_alarm_is_cleared    eutA    ${alarm_instance_id_ont}
    
    log    SUCCESS
    
*** Keyword ***
Case_Test_Setup
    [Documentation]    test case setup
    log    test case setup
    
    
Case_Test_Teardown
    [Documentation]    test case teardown
    log    deprovision other configuration in test step
    shutdown_port    eutA    ${service_model.service_point2.type}    ${service_model.service_point2.name}
    shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}

    
    