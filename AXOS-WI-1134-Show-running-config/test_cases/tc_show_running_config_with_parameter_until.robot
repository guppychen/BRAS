*** Settings ***
Documentation     show running config with parameter until
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_until
    [Documentation]    show running config with parameter until
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-930    @globalid=2162507
    [Setup]    E7_Rel-TC-814 setup
    log    STEP:show running config with parameter until
    ${res}    show_running_with_parameter    n1_sysadmin    | until policy
    Should Match Regexp    ${res}    ^show[\\S ]*\\r\\nversion[\\S \\r\\n]*policy-map[\\S ]+\\r\\n([\\S ]+)$
    [Teardown]    E7_Rel-TC-814 teardown

*** Keywords ***
E7_Rel-TC-814 setup
    log    Enter E7_Rel-TC-814 setup

E7_Rel-TC-814 teardown
    log    Enter E7_Rel-TC-814 teardown
