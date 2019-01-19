*** Settings ***
Suite Setup       provision
Suite Teardown    deprovision
Force Tags        @feature=VLAN    @author=Lincoln Yu    @subfeature=1:1 VLAN Support
Resource          ./base.robot

*** Variables ***

*** Keywords ***
provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=Lincoln Yu
    set_eut_version
    subscriber_point_prov    subscriber_point1
#    Wait Until Keyword Succeeds    1 min    5 sec    check_ont_status    eutB    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    subscriber_point_check_status_up    subscriber_point1
deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=Lincoln Yu
    subscriber_point_dprov    subscriber_point1
