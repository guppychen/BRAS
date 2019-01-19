*** Settings ***
Documentation     DSCP maps exist on DUT.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Apply_DSCP_map_to_Access_interfaces
    [Documentation]    DSCP maps exist on DUT.
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1244    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318906    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-1244 setup
    [Teardown]   AXOS_E72_PARENT-TC-1244 teardown
    log    STEP:DSCP maps exist on DUT.
    ${type}    set variable    ${service_model.subscriber_point1.type}
    ${port_type1}    set variable if    'ont_port'=='${type}'    ont-ethernet
    set test variable    ${port_type}    ${port_type1}

    log    Apply DSCP map to Access interface.
    prov_interface     eutA    ${port_type}    ${service_model.subscriber_point1.name}     role=uni    dscp-map=${dscp_map1}
    check_running_configure     eutA    interface      ${port_type}     ${service_model.subscriber_point1.name}     dscp-map     dscp-map=${dscp_map1}


*** Keywords ***
AXOS_E72_PARENT-TC-1244 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1244 setup

    prov_dscp_map    eutA    ${dscp_map1}    ${dscp_value1}     ${p_value1}


AXOS_E72_PARENT-TC-1244 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1244 teardown
    log    subscriber_point remove_svc
    log    Remove DSCP map from the Access interface.
    dprov_interface    eutA    ${port_type}     ${service_model.subscriber_point1.name}    dscp-map=${EMPTY}
    dprov_dscp_map    eutA    ${dscp_map1}
    # modified by llin 2017.9.30  for AT-3095
#    prov_interface     eutA    ${port_type}    ${service_model.subscriber_point1.name}     role=inni
    # modified by llin 2017.9.30  for AT-3095
    # modified by chxu 2017.12.8  for AT-3950
    prov_interface     eutA    ${port_type}    ${service_model.subscriber_point1.name}     role=uni


