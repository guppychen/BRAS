*** Settings ***
Documentation     
Resource          ./base.robot


*** Variables ***
${bin_count}    4

*** Test Cases ***
tc_R400_Each_Measurement_Interval_will_support_a_common_set_of_attributes_and_attributes_specific_to_the_Monitored_Entity_The_PM_Session_Type_Data_Set
    [Documentation]    Each current/history PM Bin will contain at a Minimum: Start Time ;Time stamp when Current Interval Began Elapsed Time ;Time since bin started collection Suspect Flag ; Defines whether the Measurement Interval has been marked as suspect. This can be set if the Measurement interval was started at a point in time not aligned to Time of Day (eg a 15 minute bin started at 10:05) or there is a local time-of-day clock change of greater than 10 seconds, some disruption in the collection of the PM data etc. Plus Entity Specific attributes (The PM Session Type Data Set)
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-747    @globalid=2307607
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Each current/history PM Bin will contain at a Minimum: Start Time ;Time stamp when Current Interval Began Elapsed Time ;Time since bin started collection Suspect Flag ; Defines whether the Measurement Interval has been marked as suspect. This can be set if the Measurement interval was started at a point in time not aligned to Time of Day (eg a 15 minute bin started at 10:05) or there is a local time-of-day clock change of greater than 10 seconds, some disruption in the collection of the PM data etc. Plus Entity Specific attributes (The PM Session Type Data Set)

    ${output}    show_latest_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${rmon_type}    ${num_back}
    Should Contain    ${output}    start-time
    Should Contain    ${output}    time-elapsed
    Should Contain    ${output}    suspect
    Should Contain    ${output}    cause
    Should Contain    ${output}    is-current

*** Keywords ***
case setup
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
     ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
     log    Add pm task to pon port.
     Set Test Variable    ${pon_port}    ${pon_port}
     prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}

case teardown
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}    
