*** Settings ***
Documentation     show running config with parameter linnum
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_show_running_config_with_parameter_linnum
    [Documentation]    show running config with parameter linnum
    [Tags]       @author=AnsonZhang     @tcid=AXOS_E72_PARENT-TC-925    @globalid=2162502
    [Setup]      E7_Rel-TC-809 setup
    [Teardown]   E7_Rel-TC-809 teardown
    log    STEP:show running config with parameter linnum
    ${res}    show_running_with_parameter    n1_sysadmin    policy-map ${policy_map_name} | linnum
    Should Match Regexp    ${res}    ^show[\\w \\-]+(\\|) linnum\\r\\n([\\d]+:[\\S \\-]+\\r\\n)+([\\w \\-]+)$

*** Keywords ***
E7_Rel-TC-809 setup
    [Documentation]
    [Arguments]
    log    Enter E7_Rel-TC-809 setup


E7_Rel-TC-809 teardown
    [Documentation]
    [Arguments]
    log    Enter E7_Rel-TC-809 teardown