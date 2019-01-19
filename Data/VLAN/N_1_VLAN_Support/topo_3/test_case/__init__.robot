*** Settings ***
Suite Setup       provision
Suite Teardown    deprovision
Force Tags        @feature=VLAN    @subfeature=N:1 VLAN Support    @author=AnneLi
Resource          ./base.robot

*** Variables ***

*** Keywords ***
provision
  [Documentation]    suite provision for sub_feature
  [Tags]    @author=AnneLi
    log    suite provision for sub_feature
    log    enable uplink-port
    service_point_prov    service_point_list1



deprovision
   [Documentation]    suite deprovision for sub_feature
   [Tags]    @author=AnneLi
    log    suite deprovision for sub_feature
    service_point_dprov    service_point_list1

