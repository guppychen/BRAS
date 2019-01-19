*** Settings ***
Documentation     show running config with parameter tab
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_tab
    [Documentation]    show running config with parameter tab
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-929    @globalid=2162506
    [Setup]    E7_Rel-TC-813 setup
    ${res}    show_running_with_parameter    n1_sysadmin    class-map ethernet ${class_map_name} | tab
    ${line0}    Get Line    ${res}    0
    Should Match Regexp    ${line0}    ^show[\\S ]+
    ${line1}    Get Line    ${res}    1
    Should Match Regexp    ${line1}    ^ [ ]+FLOW[ ]+PRIORITY[ ]+SRC[ ]+SRC[ ]+
    ${line2}    Get Line    ${res}    2
#    Should Match Regexp    ${line2}    ^NAME[ ]+INDEX[ ]+DESCRIPTION[ ][ ]+INDEX[ ]+DESCRIPTION[ ]+ANY[ ]+VLAN[ ]+UNTAGGED[ ]+TAGGED[ ]+OUI[ ]+MAC[ ]+ETHERTYPE[ ]+PCP
    Should Match Regexp    ${line2}    ^NAME[ ]+INDEX[ ]+DESCRIPTION[ ][ ]+INDEX[ ]+DESCRIPTION[ ]+ANY[ ]+VLAN[ ]+UNTAGGED[ ]+DSCP[ ]+TAGGED[ ]+OUI[ ]+MAC[ ]+ETHERTYPE[ ]+PCP
    ${line3}    Get Line    ${res}    3
    Should Match Regexp    ${line3}    [\\-]+
    ${line4}    Get Line    ${res}    4
    Should Match Regexp    ${line4}    ${class_map_name}[ ]+${g_flow_index[0]}[ ]+\\-[ ]+
    log    STEP:show running config with parameter tab
    [Teardown]    E7_Rel-TC-813 teardown

*** Keywords ***
E7_Rel-TC-813 setup
    log    Enter E7_Rel-TC-813 setup

E7_Rel-TC-813 teardown
    log    Enter E7_Rel-TC-813 teardown
