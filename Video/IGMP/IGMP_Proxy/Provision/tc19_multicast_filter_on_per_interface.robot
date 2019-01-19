*** Settings ***
Documentation     Test suite verifies multicast filter on per interface
Resource          ../base.robot

*** Variables ***
# ${default_l2cp_action}    discard
${subscriber_port_l2cp_action}    tunnel
${illegal_value}    auto
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}

*** Test Cases ***
tc_multicast_filter_on_per_interface
    [Documentation]       Test suite verifies multicast filter on per interface
     ...    1.  verify_subscriber port l2cp-action default value is set to discard
     ...    2.  Toggle subscriber port l2cp-action value and verify change
     ...    3.  Change subscriber port l2cp-action value to outside of acceptable range and verify change
     ...    4.  unconfigure_subscriber port l2cp-action value and verify change
    [Tags]    @author=llim    @globalid=2276046    @tcid=AXOS_E72_PARENT-TC-530    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Teardown]   case teardown
    log    STEP:1 verify_subscriber port l2cp-action default value is set to discard
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    | detail    l2cp-action=${p_default_l2cp_action}

    log    STEP:2 Toggle subscriber port l2cp-action value and verify change
    prov_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}   l2cp-action=${subscriber_port_l2cp_action}  
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    l2cp-action=${subscriber_port_l2cp_action}
    
    log    STEP:3 Change subscriber port l2cp-action value to outside of acceptable range and verify change
    ${status}    run keyword and return status        prov_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}  l2cp-action=${illegal_value}
    run keyword if     ${status}==True    Fail    '${illegal_value}' illegal_value (beyond max limit) shouldn't be provisioned successfully.
        
*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    STEP:4 unconfigure_subscriber port l2cp-action value and verify change
    prov_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}   l2cp-action=${p_default_l2cp_action}
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    | detail    l2cp-action=${p_default_l2cp_action}
