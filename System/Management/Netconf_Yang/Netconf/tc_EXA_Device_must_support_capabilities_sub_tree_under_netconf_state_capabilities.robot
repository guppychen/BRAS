*** Settings ***
Documentation     RFC 6241 calls for capabilities to be advertized. RFC 6022 calls for capabilities to be availbale under /netconf-state/capabilities
...
...               "Capabilities augment the base operations of the device, describing both additional operations and the content allowed inside operations. The client can discover the server's capabilities and use any additional operations, parameters, and content defined by those capabilities."
...
...               The capabilites are exhcnaged during session establishment. This SR is asking that the capabilities exist under
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=ysnigdha
Resource          ./base.robot
Library           XML    use_lxml=True

*** Variables ***
@{value_cli}
@{capability}
@{delete_values}    startup
${conf_file}      /etc/confd/yang/ietf-netconf.yang

*** Test Cases ***
tc_EXA_Device_must_support_capabilities_sub_tree_under_netconf_state_capabilities
    [Documentation]    1 Verify whether capabilites are available under /netconf-state/capabilities
    [Tags]      @user=root   @TCID=AXOS_E72_PARENT-TC-1779    @jira=EXA-25933    @globalid=2322310

    log    STEP:1 Verify whether capabilites are available under /netconf-state/capabilities
    # To verify whether capabilites are available under /netconf-state/capabilities
    @{elem}    Get attributes netconf    n1_session3    /netconf-state/capabilities    capability

    # To retrieve the capabilites from xml
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    ${count}-1
    \    ${a}    Get Regexp Matches    ${elem[${index}].text}    :capability:([a-zA-Z\-]+)    1
    \    ${length}    Get Length    ${a}
    \    Run keyword if    ${length}!=0    Append to list    ${capability}    ${a[0]}
    ${value_netconf}    Remove Duplicates    ${capability}
    log list    ${value_netconf}
    
    # To retriece capabilities from ietf-netconf.yang
    ${result}    cli    n1_session2    cat ${conf_file}    prompt=#    timeout=40
    ${result_1}    Get Regexp Matches    ${result}    ${SPACE}+feature${SPACE}([a-zA-Z\-]+)${SPACE}\{
    : FOR    ${arg}    IN    @{result_1}
    \    ${a}    Remove string    ${arg}    {
    \    ${key}    ${value}=    Evaluate    "${a}".split(${SPACE})
    \    Append to list    ${value_cli}    ${value}
    Remove Values From List    ${value_cli}    @{delete_values}
    log    ${value_cli}
    List should contain sub list    ${value_netconf}    ${value_cli}
