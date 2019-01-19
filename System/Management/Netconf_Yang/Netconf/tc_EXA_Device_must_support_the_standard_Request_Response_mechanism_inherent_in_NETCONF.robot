*** Settings ***
Documentation     eg.
...               Request:
...               <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
...
...               </rpc>]]>]]>
...
...               Response:
...               <rpc-reply xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="101">
...
...               </rpc-reply>]]>]]>
Resource          ./base.robot
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=dzala


*** Variables ***
${close_session}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><close-session/></rpc>

*** Test Cases ***
tc_EXA_Device_must_support_the_standard_Request_Response_mechanism_inherent_in_NETCONF
    [Documentation]    1 Open netconf session: ssh < user >@< ip > -p 830 -s netconf.
    ...    2 Send "hello" rpc.
    ...    3 send an RPC request
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1749        @globalid=2322280

    #send an RPC request - returns an rpc-reply
    ${rpc_request}=    Netconf Raw    n1_session3    xml=${close_session}
    Should Contain    ${rpc_request.xml}    rpc-reply
    log    ${rpc_request}
