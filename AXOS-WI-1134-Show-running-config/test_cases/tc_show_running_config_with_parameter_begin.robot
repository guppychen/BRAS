*** Settings ***
Documentation     show running config with parameter begin
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_begin
    [Documentation]    show running config with parameter begin
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-918    @globalid=2162203
    [Setup]    E7_Rel-TC-802 setup
    log    STEP:show running config with parameter begin
    ${res}    show_running_with_parameter    n1_sysadmin    | begin policy-map\\\\s{1}${policy_map_name}.*
    Should Match Regexp    ${res}    show\.\*\\spolicy-map ${policy_map_name}
    [Teardown]    E7_Rel-TC-802 teardown

*** Keywords ***
E7_Rel-TC-802 setup
    log    Enter E7_Rel-TC-802 setup

E7_Rel-TC-802 teardown
    log    Enter E7_Rel-TC-802 teardown
