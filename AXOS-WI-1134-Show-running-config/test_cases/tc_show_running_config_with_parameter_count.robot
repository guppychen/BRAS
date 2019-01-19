*** Settings ***
Documentation     show running config with parameter count
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_count
    [Documentation]    show running config with parameter count
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-920    @globalid=2162206
    [Setup]    E7_Rel-TC-804 setup
    log    STEP:show running config with parameter count
    ${res}    show_running_with_parameter    n1_sysadmin    | count
    should contain    ${res}    lines
    Should Match Regexp    ${res}    ^show[\\w \\-]+(\\|) count\\r\\nCount: [\\d]+ lines\\r\\n([\\w\\-]+)$
    [Teardown]    E7_Rel-TC-804 teardown

*** Keywords ***
E7_Rel-TC-804 setup
    log    Enter E7_Rel-TC-804 setup

E7_Rel-TC-804 teardown
    log    Enter E7_Rel-TC-804 teardown
