*** Settings ***
Documentation     set an existing vlan as erps-domain control vlan , fail
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_set_an_existing_vlan_as_erps_domain_control_vlan_fail
    [Documentation]    1	set an existing vlan as erps-domain control vlan	Failed
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1309    @globalid=2319059    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4     @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 set an existing vlan as erps-domain control vlan Failed
    cli    ${service_model.service_point1.device}    configure
    cli    ${service_model.service_point1.device}    erps-ring ${service_model.service_point1.name}
    ${command}    set variable    role ${service_model.service_point1.attribute.erps_role} control-vlan ${service_model.service_point1.attribute.control_vlan} admin-state enable
    ${res}    cli     ${service_model.service_point1.device}     ${command}     
    should contain    ${res}    set of domain control vlan failed : perhaps it is already in use

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    prov_vlan    ${service_model.service_point1.device}    ${service_model.service_point1.attribute.control_vlan}

case teardown
    [Documentation]
    [Arguments]
    cli    ${service_model.service_point1.device}    configure
    Axos Cli With Error Check    ${service_model.service_point1.device}    no vlan ${service_model.service_point1.attribute.control_vlan}