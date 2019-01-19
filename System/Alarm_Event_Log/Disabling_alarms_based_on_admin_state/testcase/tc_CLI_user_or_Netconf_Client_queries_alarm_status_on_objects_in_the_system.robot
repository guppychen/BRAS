*** Settings ***
Documentation     This use case describes how a CLI user or Netconf client may query object in the system to determine the alarm status for that object.
Resource          ./base.robot
Force Tags        @feature=Disabling_alarms_based_on_admin_state    @subfeature=Disabling_alarms_based_on_admin_state

*** Variables ***

*** Test Cases ***
tc_CLI_user_or_Netconf_Client_queries_alarm_status_on_objects_in_the_system
    [Documentation]    Contour Test case description
    ...    1 Pre-Conditions: The system is deployed and running with several ONTs connected on a PON.
    ...    2 There are several alarm conditions that will be shown to the user in this use case. These are numbered here, and the user will step through these in the sequence of events: 1) a 10G port is in service running with no issues (3/x1) 2) a 10G port is enabled and has an active LOS alarm (3/x2) 3) a 10G port is enabled, has suppression enabled and has a suppressed LOS alarm (3/x3) 4) a 10G port is disabled (3/x4) 5) the is an ONT (ont-123), has alarm(any alarm, such as "eth-down" or "battery")
    ...    3 The CLI user or Netconf client has successfully determined the alarm status for the desired object Primary Sequence of Events: The CLI user or netconf client request the alarm status for the following: 1) 10G port 3/x1 The status should show the port is in-service with no issues 2) 10G port 3/x2 The status should show the port has detected an LOS 3) 10G port 3/x3 The status should show the port has detected an LOS 4) 10G port 3/x4 The status should show the port is administratively out of service 5) ont-123 The status should show that the ONT has alarm. 
    
    [Setup]    Case_Test_Setup
    [Teardown]    Case_Test_Teardown
    [Tags]    @author=Meiqin_Wang    @tcid=AXOS_E72_PARENT-TC-3482   @globalid=2474932    @eut=GPON-8R2    @priority=P3
    
    no_shutdown_port    eutA    pon    ${pon_alarm_port}
    no_shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}

     wait until keyword succeeds   2min   5sec   verify_alarm_is_exist    eutA    ${pon_alarm_port}
     wait until keyword succeeds   2min   5sec   verify_alarm_is_exist    eutA    port='${ont_eth_alarm_port}'

    ${alarm_instance_id_pon}    verify_alarm_is_exist    eutA    ${pon_alarm_port}
    ${alarm_instance_id_ont}    verify_alarm_is_exist    eutA    port='${ont_eth_alarm_port}'
    
    shutdown_port    eutA    pon    ${pon_alarm_port}
    shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    wait until keyword succeeds   2min   5sec    verify_alarm_is_cleared    eutA    ${alarm_instance_id_pon}
    wait until keyword succeeds   2min   5sec    verify_alarm_is_cleared    eutA    ${alarm_instance_id_ont}
    
    log    SUCCESS
    
*** Keyword ***
Case_Test_Setup
    [Documentation]    test case setup
    log    test case setup
    
Case_Test_Teardown
    [Documentation]    test case teardown
    log    deprovision other configuration in test step
    shutdown_port    eutA    pon    ${pon_alarm_port}
    shutdown_port    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}

    
    