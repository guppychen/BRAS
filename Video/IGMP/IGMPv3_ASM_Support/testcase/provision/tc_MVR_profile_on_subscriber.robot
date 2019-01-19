*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_MVR_profile_on_subscriber
    [Documentation]    1	create MVR profile on system and add the mvr-profile to multicast-porofile then assign the multicast-profile to ont-port	Successful
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2242    @GlobalID=2346509
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create MVR profile on system and add the mvr-profile to multicast-porofile then assign the multicast-profile to ont-port Successful

    ${result}    cli    eutA    show running-config interface ont-ethernet ${service_model.subscriber_point1.member.interface1}
    Should Match Regexp    ${result}    igmp multicast-profile\\s+${p_mcast_prf1}

    ${result}    cli    eutA    show running-config multicast-profile ${p_mcast_prf1}
    Should Match Regexp    ${result}    mvr-profile\\s+${p_mvr_prf1}    

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2242 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2242 teardown