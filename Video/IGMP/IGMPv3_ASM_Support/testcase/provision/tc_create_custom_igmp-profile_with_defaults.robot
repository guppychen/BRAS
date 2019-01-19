*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_create_custom_igmp_profile_with_defaults_robot
    [Documentation]    Step1	Create a new igmp-profile with no parameter change. show igmp-profile.	Verify the system-default “Proxy VLAN IGMP Version” is auto
    [Tags]       @author=Philip_Chen     @TCID=AXOS_E72_PARENT-TC-2234
    [Setup]      AXOS_E72_PARENT-TC-2234 setup
    [Teardown]   AXOS_E72_PARENT-TC-2234 teardown
    log    STEP:Step1 Create a new igmp-profile with no parameter change. show igmp-profile. Verify the system-default “Proxy VLAN IGMP Version” is auto
    prov_igmp_profile    eutA    ${p_igmp_profile_1}
    ${res}    cli    eutA    show running-config igmp-profile ${p_igmp_profile_1}
    Should Match Regexp    ${res}    igmp-version\\s+AUTO


*** Keywords ***
AXOS_E72_PARENT-TC-2234 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2234 setup


AXOS_E72_PARENT-TC-2234 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2234 teardown
    dprov_igmp_profile    eutA    ${p_igmp_profile_1}

