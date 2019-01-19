*** Settings ***
Documentation     show running config with parameter display
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_running_config_with_parameter_display
    [Documentation]    show running config with parameter display
    [Tags]    @author=AnsonZhang    @user=root  @tcid=AXOS_E72_PARENT-TC-922    @globalid=2162208
    [Setup]    E7_Rel-TC-806 setup
    log    STEP:show running config with parameter display
    ${res1}    show_running_with_parameter    n1_root    policy-map ${policy_map_name} | display xml
    ${res2}    show_running_with_parameter    n1_root    policy-map ${policy_map_name} | display xpath
    ${res3}    Should Match Regexp    ${res1}    <config[ \\S]+.0">\\r\\n([ \\S]*\\r\\n)+</config>
    ${xml}    Set Variable    ${res3[0]}
    ${root}    Parse XML    ${xml}
    Should Be Equal    ${root.tag}    config
    log    get the flow-id
    ${texts}    Get Elements    ${xml}    .//name
    Length Should Be    ${texts}    2
    Should Be Equal    ${texts[0].text}    ${policy_map_name}
    Should Be Equal    ${texts[1].text}    ${class_map_name}
    ${fid}    Get Element    ${xml}    .//flow-id
    ${id}    convert to integer    ${fid.text}
    Should Be Equal    ${id}    ${g_flow_index[0]}
    log    check the xpath
    Should contain    ${res2}    /base:config/base:profile/base:policy-map[base:name='${policy_map_name}']/base:class-map-ethernet[base:name='${class_map_name}']/base:flow[base:flow-id='${g_flow_index[0]}']
    [Teardown]    E7_Rel-TC-806 teardown

*** Keywords ***
E7_Rel-TC-806 setup
    log    Enter E7_Rel-TC-806 setup

E7_Rel-TC-806 teardown
    log    Enter E7_Rel-TC-806 teardown
