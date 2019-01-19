*** Settings ***
Documentation     The ethernet interface YANG definitions needs to be provided in a distinct sub-module (named in accordance with YANG file naming SRs) that contains the ethernet interface configuration and state parameters in appropriate YANG containers (i.e. augments) as illustrated by the following for configuration and state respectively
Force Tags     @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=sdas
Resource          ./base.robot


*** Variables ***
${get_interface_details}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="111"> <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <filter type="xpath" select="/*/interface[name='${DEVICES.n1_session1.ports.service_p1.port}']"/> </get> </rpc>

${param1}    speed
${param2}    duplex
@{list1}
@{list2}

*** Test Cases ***
tc_The_EXA_device_MUST_support_modelling_its_Ethernet_interface_per_RFC_7223
    [Documentation]    EXA device MUST support modelling its Ethernet interface per RFC 7223
    [Tags]       @TCID=AXOS_E72_PARENT-TC-1805        @globalid=2322336
    ### Verification for speed field in Ethernet interface(1/3/x1) as per RFC_7223
    @{output}=    Raw netconf configure    n1_session3    ${get_interface_details}    ${param1}
    log    ${output[0].text}

    ${count}    Get Length    ${output}
    : FOR    ${index}    IN RANGE    0     ${count}
    \      Append To List       ${list1}    ${output[${index}].text}
    Should Not Be Empty    ${list1}

    ### Verification for duplex field in Ethernet interface(1/3/x1) as per RFC_7223
    @{output1}=    Raw netconf configure    n1_session3    ${get_interface_details}    ${param2}
    log    ${output[0].text}

    ${count1}    Get Length    ${output1}
    : FOR    ${index}    IN RANGE    0     ${count1}
    \      Append To List       ${list2}    ${output1[${index}].text}
    Should Not Be Empty    ${list2}
