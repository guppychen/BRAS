*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Disabling_alarms_based_on_admin_state_suite_provision
Suite Teardown    Disabling_alarms_based_on_admin_state_suite_deprovision
Force Tags        @feature=Disabling_alarms_based_on_admin_state    @subfeature=Disabling_alarms_based_on_admin_state    @author=Meiqin_Wang
Resource          ./base.robot

*** Variables ***

*** Keywords ***
Disabling_alarms_based_on_admin_state_suite_provision
    [Documentation]    suite provision for Disabling_alarms_based_on_admin_state
    log    suite provision for Disabling_alarms_based_on_admin_state
    
    service_point_prov    service_point_list1
    subscriber_point_prov    subscriber_point1
    Wait Until Keyword Succeeds    1 min    5 sec    subscriber_point_check_status_up    subscriber_point1
    
   
     
Disabling_alarms_based_on_admin_state_suite_deprovision
    [Documentation]    suite deprovision for Disabling_alarms_based_on_admin_state
    log    suite deprovision for Disabling_alarms_based_on_admin_state
    
    subscriber_point_dprov    subscriber_point1
    service_point_dprov    service_point_list1

    