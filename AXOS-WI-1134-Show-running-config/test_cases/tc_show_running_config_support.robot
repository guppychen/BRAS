*** Settings ***
Documentation     show running config support
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_support
    [Documentation]    show running config support
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-916    @globalid=2162201
    [Setup]    E7_Rel-TC-800 setup
    log    STEP:show running config support
    ${res}    show_running_with_parameter    n1_sysadmin    policy-map ${policy_map_name}
    should contain    ${res}    flow ${g_flow_index[0]}
    [Teardown]    E7_Rel-TC-800 teardown

*** Keywords ***
E7_Rel-TC-800 setup
    log    Enter E7_Rel-TC-800 setup

E7_Rel-TC-800 teardown
    log    Enter E7_Rel-TC-800 teardownd
