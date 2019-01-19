*** Settings ***
Documentation     show running config with parameter nomore
Resource          ./base.robot
Library           XML

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_nomore
    [Documentation]    show running config with parameter nomore
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-927    @globalid=2162504
    [Setup]    E7_Rel-TC-811 setup
    ${res}    show_running_with_parameter    n1_sysadmin    | nomore
#    Should Match Regexp    ${res}    ^show[\\S ]+nomore\\r\\nversion[\\S \\-]+\\r\\n([\\S \\r\\n])+cpe-image-mgmt match-rule default NONE\\r\\n([\\S]+)$
    Should Match Regexp    ${res}    ^show[\\S ]+nomore\\r\\nversion[\\S \\-]+\\r\\n([\\S \\r\\n])+${devices.n1_sysadmin.model}$

    log    STEP:show running config with parameter nomore
    [Teardown]    E7_Rel-TC-811 teardown

*** Keywords ***
E7_Rel-TC-811 setup
    log    Enter E7_Rel-TC-811 setup
    ${tmp}    cli    n1_sysadmin    end
    ${tmp}    cli    n1_sysadmin    config
    ${tmp}    cli    n1_sysadmin    cli show-defaults enable
    sleep  2s   wait for cli cmd active


E7_Rel-TC-811 teardown
    log    Enter E7_Rel-TC-811 teardown
    ${tmp}    cli    n1_sysadmin    end
    ${tmp}    cli    n1_sysadmin    config
    ${tmp}    cli    n1_sysadmin    cli show-defaults disable
    ${tmp}    cli    n1_sysadmin    end
