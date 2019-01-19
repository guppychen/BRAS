*** Settings ***
Documentation     A capability is a service or transport feature such as:
...
...
...    ERPSv1 impl1
...    ERPSv2 impl2
...    IGMPv2 impl3
...    IGMPv3 impl4
...
...    EXAMgmtProtocolV1 impl5
Force Tags     @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=sdas
Resource          ./base.robot


*** Variables ***
${get_schema}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"> <get> <filter type="subtree"> <ncm:netconf-state xmlns:ncm="urn:ietf:params:xml:ns:yang:ietf-netconf-monitoring"> <ncm:schemas/> </ncm:netconf-state> </filter> </get> </rpc>

${retrive_schema}    /schema
${vefify_version}    <version>

*** Test Cases ***
tc_The_EXA_platform_must_support_semantic_versioning_of_each_data_and_control_plane_capability
    [Documentation]     Action                                                               Expected Result
    ...    1    Perform "get" rpc to retrieve schema                                         returns schema
    ...    2    Verify version field exists for each data / control plan capability     it is present for all of them.
    [Tags]       @TCID=AXOS_E72_PARENT-TC-1807        @globalid=2322338   dual_card_not_support   @jira=EXA-29537
    

    log    Perform "get" rpc to retrieve schema returns schema
    #get-schema
    ${step1}=    Netconf Raw    n1_session3    xml=${get_schema}
    Should Contain    ${step1.xml}    ${retrive_schema}

    log    Verify version field exists for each data / control plan capability it is present for all of them.
    @{var} =	Split String    ${step1.xml}    <${retrive_schema}>
    log many    @{var}
    ${count}   Get length  ${var}
    :FOR    ${ELEMENT}    IN RANGE  0  ${count}-1
    \    log    @{var}[${ELEMENT}]
    \    should contain    @{var}[${ELEMENT}]    ${vefify_version}

