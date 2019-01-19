*** Settings ***
Suite Setup       provision
Suite Teardown    deprovision
Force Tags        @feature=VLAN    @author=Lincoln Yu    @subfeature=1:1 VLAN Support      @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***

*** Keywords ***
provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=Lincoln Yu
    set_eut_version
    log    suite provision for sub_feature
    log    enable uplink-port
    service_point_prov    service_point_list1
    log    create ont
    subscriber_point_prov    subscriber_point1
    #    Wait Until Keyword Succeeds    1 min    5 sec    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}
    ...    # oper-state=present
    subscriber_point_check_status_up    subscriber_point1

deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=Lincoln Yu
    log    suite deprovision for sub_feature
    log    delete ont and disable pon port
    subscriber_point_dprov    subscriber_point1
    log    disable uplink port
    service_point_dprov    service_point_list1
