*** Settings ***
Documentation     show running config with parameter append
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_append
    [Documentation]    show running config with parameter append
    [Tags]    @author=AnsonZhang    @user=root   @tcid=AXOS_E72_PARENT-TC-917    @globalid=2162202
    [Setup]    E7_Rel-TC-801 setup
    log    STEP:show running config with parameter append
    log    clear the file
    ${res}    show_running_with_parameter    n1_root    policy-map ${policy_map_name}
    should contain    ${res}    policy-map ${policy_map_name}
    ${res}    show_running_with_parameter    n1_root    policy-map ${policy_map_name} | append ${startrunbackup}
    ${res}    show_file_content    n1_root    ${startrunbackup}
    should contain    ${res}    policy-map ${policy_map_name}
    [Teardown]    E7_Rel-TC-801 teardown

*** Keywords ***
E7_Rel-TC-801 setup
    log    Enter E7_Rel-TC-801 setup
    log    generate random file name
    ${startrunbackup}    Generate Random String    32
    set suite variable    ${startrunbackup}    ${startrunbackup}
    clear_the_file    n1_root    ${startrunbackup}

E7_Rel-TC-801 teardown
    log    Enter E7_Rel-TC-801 teardown
    delete_file    n1_root    ${startrunbackup}


