*** Settings ***
Documentation     show running config with parameter context-match
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_context_match
    [Documentation]    show running config with parameter context-match
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-919    @globalid=2162205
    [Setup]    E7_Rel-TC-803 setup
    log    STEP:show running config with parameter context-match
    ${res}    show_running_with_parameter    n1_sysadmin    | context-match policy-map\\\\s{1}${policy_map_name}.*
    should contain    ${res}    policy-map ${policy_map_name}
    Should Match Regexp    ${res}    show\.\*\\spolicy-map ${policy_map_name}\.\*
    [Teardown]    E7_Rel-TC-803 teardown

*** Keywords ***
E7_Rel-TC-803 setup
    log    Enter E7_Rel-TC-803 setup

E7_Rel-TC-803 teardown
    log    Enter E7_Rel-TC-803 teardown
