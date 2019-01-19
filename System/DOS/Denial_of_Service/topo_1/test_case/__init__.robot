*** Settings ***
Suite Setup       provision
Suite Teardown    deprovision
Force Tags        @feature=DOS    @author=Lincoln Yu    @subfeature=Denial of Service
Resource          ./base.robot

*** Variables ***

*** Keywords ***
provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=Lincoln Yu
    log    suite provision for sub_feature
    log    enable uplink-port
    service_point_prov    service_point_list1

deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=Lincoln Yu
    log    suite deprovision for sub_feature
    log    disable uplink port
    service_point_dprov    service_point_list1
