*** Settings ***
Documentation     show running config with parameter details
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_details
    [Documentation]    show running config with parameter details
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-921    @globalid=2162207
    [Setup]    E7_Rel-TC-805 setup
    log    STEP:show running config with parameter details
    log    set cli show-default disable
    ${res}    show_running_with_parameter    n1_sysadmin    policy-map ${policy_map_name} | details
    should contain    ${res}    no remove-cevlan
    [Teardown]    E7_Rel-TC-805 teardown

*** Keywords ***
E7_Rel-TC-805 setup
    log    Enter E7_Rel-TC-805 setup

E7_Rel-TC-805 teardown
    log    Enter E7_Rel-TC-805 teardown
