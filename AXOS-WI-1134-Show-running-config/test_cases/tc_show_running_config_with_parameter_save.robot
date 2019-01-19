*** Settings ***
Documentation     show running config with parameter save
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_save
    [Documentation]    show running config with parameter save
    [Tags]    @author=AnsonZhang   @user=root  @tcid=AXOS_E72_PARENT-TC-928    @globalid=2162505
    [Setup]    E7_Rel-TC-812 setup
    log    STEP:show running config with parameter save
    ${res}    show_running_with_parameter    n1_root    policy-map ${policy_map_name} | save ${startupsave}
    ${res}    show_file_content    n1_root    ${startupsave}
    should contain    ${res}    policy-map ${policy_map_name}
    Should Match Regexp    ${res}    ^[\\S ]+\\r\\npolicy-map[\\S ]+\\r\\n([\\S ]+\\r\\n)+!\\r\\nroot[\\S]+$
    [Teardown]    E7_Rel-TC-812 teardown

*** Keywords ***
E7_Rel-TC-812 setup
    log    Enter E7_Rel-TC-812 setup
    ${startupsave}    Generate Random String    32
    set suite variable    ${startupsave}    ${startupsave}

E7_Rel-TC-812 teardown
    log    Enter E7_Rel-TC-812 teardown
    delete_file    n1_root    ${startupsave}
