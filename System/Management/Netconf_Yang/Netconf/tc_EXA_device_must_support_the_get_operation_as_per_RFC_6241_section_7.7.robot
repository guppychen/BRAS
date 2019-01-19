*** Settings ***
Documentation     EXA device must support the get operation as per RFC 6241 section 7.7
Test Setup        RLT_TC_748 setup
Test Teardown     RLT_TC_748 teardown
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=asamband
Resource          base.robot

*** Variables ***
${get}            <?xml version="1.0" encoding="utf-8"?> <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="161"> <get/> </rpc>

*** Test Cases ***
EXA device must support the get operation as per RFC 6241 section 7.7
    [Documentation]    The operation is capable of supporting retrieving both configuration and state data in single request. The user initating the session must have the permission to perform the operation.
    [Tags]    @priority=p1    @tcid=AXOS_E72_PARENT-TC-1757        @globalid=2322288
    ${step1}=    Netconf Get Config    n1_session3    filter_type=None    filter_criteria=None
    Should Contain    ${step1.xml}    <rpc-reply

*** Keywords ***
RLT_TC_748 setup
    log    Enter RLT_TC_748

RLT_TC_748 teardown
    log    Enter RLT_TC_748
    Netconf Raw    n1_session3    xml=${netconf.close_session}
