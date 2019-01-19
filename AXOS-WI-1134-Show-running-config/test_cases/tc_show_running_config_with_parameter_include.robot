*** Settings ***
Documentation     show running config with parameter include
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_include
    [Documentation]    show running config with parameter include
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-924    @globalid=2162501
    [Setup]    E7_Rel-TC-808 setup
    log    STEP:show running config with parameter include
    ${res}    show_running_with_parameter    n1_sysadmin    policy-map ${policy_map_name} | include policy
    Should Match Regexp    ${res}    ^show([\\S ]*policy[\\S\\s]+)*([\\w ]+)$
    [Teardown]    E7_Rel-TC-808 teardown

*** Keywords ***
E7_Rel-TC-808 setup
    log    Enter E7_Rel-TC-808 setup

E7_Rel-TC-808 teardown
    log    Enter E7_Rel-TC-808 teardown
