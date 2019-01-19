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
    log    create ont
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
    Wait Until Keyword Succeeds    1 min         5 sec           check_ont_status       eutA        ${service_model.subscriber_point1.attribute.ont_id}          oper-state=present
    Wait Until Keyword Succeeds    1 min         5 sec           check_ont_status       eutA        ${service_model.subscriber_point2.attribute.ont_id}          oper-state=present
#    CLI    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
#    CLI    eutA    perform ont reset ont-id ${service_model.subscriber_point2.attribute.ont_id}
#    Wait Until Keyword Succeeds    1 min         5 sec           check_ont_status       eutA        ${service_model.subscriber_point1.attribute.ont_id}          oper-state=present
#    Wait Until Keyword Succeeds    1 min         5 sec           check_ont_status       eutA        ${service_model.subscriber_point2.attribute.ont_id}          oper-state=present
#    log    wait ${ont_reset_time} s after reset ont
#    sleep    ${ont_reset_time}
deprovision
   [Documentation]    suite deprovision for sub_feature
   [Tags]    @author=AnneLi
    log    suite deprovision for sub_feature
    log    delete ont and disable pon port
    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
    log    disable uplink port
    service_point_dprov    service_point_list1

