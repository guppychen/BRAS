*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Syslog_Support_suite_provision
Suite Teardown    Syslog_Support_suite_deprovision
Force Tags        @feature=Alaem_Evevnt_Log    @subfeature=Syslog_Support    @author=Ronnie_Yi  @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
Syslog_Support_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=Ronnie_yi
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    service_point_add_vlan for uplink service
    prov_vlan    eutA    ${stag_vlan}
    service_point_add_vlan    service_point_list1    ${stag_vlan}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}



Syslog_Support_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=Ronnie_yi
    log    suite deprovision for sub_feature
    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${stag_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${stag_vlan}
    log    service_point deprovision
    service_point_dprov    service_point_list1
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}

