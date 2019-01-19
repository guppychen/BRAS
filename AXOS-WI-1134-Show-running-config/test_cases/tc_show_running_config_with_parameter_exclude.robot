*** Settings ***
Documentation     show running config with parameter exclude
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_exclude
    [Documentation]    show running config with parameter exclude
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-923    @globalid=2162210
    [Setup]    E7_Rel-TC-807 setup
    log    STEP:show running config with parameter exclude
    ${res}    show_running_with_parameter    n1_sysadmin    policy-map ${policy_map_name} | exclude policy
    ${lines}    Get Lines Containing String    ${res}    policy
    Should Not Match Regexp    ${lines}    \\n
    [Teardown]    E7_Rel-TC-807 teardown

*** Keywords ***
E7_Rel-TC-807 setup
    log    Enter E7_Rel-TC-807 setup

E7_Rel-TC-807 teardown
    log    Enter E7_Rel-TC-807 teardown
