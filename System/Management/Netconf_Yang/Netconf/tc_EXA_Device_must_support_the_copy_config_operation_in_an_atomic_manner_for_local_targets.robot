*** Settings ***
Documentation     The copy-config either completes successfully or fails and has no affect on the target returning an appropriate error response describing the reason for the failure.
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao   @author=rakrishn
Resource          ./base.robot

*** Variables ***
${copy}           <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"> <copy-config> <target> <url>file:///file_ROLT</url> </target> <source> <running/> </source> </copy-config> </rpc>

*** Test Cases ***
tc_EXA_device_MUST_support_the_copy_config_operation_in_an_atomic_manner_for_local_targets
    [Documentation]    1.Copy running to startup and verify copy completed.
    ...    2.Copy startup to running and verify copy completed.
    ...    3.Copy to external file and verify no error.
    [Tags]      @user=root   @TCID=AXOS_E72_PARENT-TC-1823        @globalid=2322354
    #AT-4773
    cli    n1_session1    accept running-config

    log    STEP:1.Copy running to startup and verify copy completed.
    ${copy_config}    set variable    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="4"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"/></rpc>
    @{elem}    Raw netconf configure    n1_session3    ${copy_config}    status
    Element text should match    @{elem}    Copy completed.

    log    STEP:2.Copy startup to running and verify copy completed.
    ${copy_config1}    set variable    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="4"><copy-startup-running xmlns="http://www.calix.com/ns/exa/base"/></rpc>
    @{elem}    Raw netconf configure    n1_session3    ${copy_config1}    status
    Element text should match    @{elem}    Copy completed.

    log    STEP:3.Copy to external file and verify no error.
    ${step1}=    Netconf Raw    n1_session3    xml=${copy}
    Should Contain    ${step1.xml}    <ok/>
