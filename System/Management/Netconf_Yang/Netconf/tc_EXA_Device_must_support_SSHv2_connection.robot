*** Settings ***
Documentation     The EXA device establishes an SSHv2 transport connection with the NETCONF management server. As part of the authorization and authentication mechanism, the EXA device and server exchange keys for security and password encryption. The user used in the prior authorization/authentication step is used to determine the privilege level (See RBAC requirements) to enforce for the NETCONF session. The client invokes the SSHv2 connection protocol and the SSHv2 session is established. The NETCONF management server then proceeds to enter the "netconf" SSH subsystem before starting a NETCONF exchange (hello, requests and close session).
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=rakrishn
Resource          base.robot

*** Variables ***

*** Test Cases ***
tc_EXA_Device_must_support_SSHv2_connection
    [Documentation]    1 Open netconf session: ssh -2 < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1784        @globalid=2322315

    log    STEP:1 Open netconf session: ssh -2 < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password.
    cli    n1_session1    ssh -o StrictHostKeyChecking=no ${DEVICES.n1_session3.user}@${DEVICES.n1_session3.ip} -p ${DEVICES.n1_session3.port} -s netconf    prompt=password    timeout=30
    cli    n1_session1    ${DEVICES.n1_session3.password}    promt=hello    timeout=10    timeout_exception=0
    Result should contain    <capability>urn:ietf:params:netconf:base:1.0</capability>
    Result should contain    <capability>urn:ietf:params:netconf:base:1.1</capability>
    cli    n1_session1    \x03    \\#
    [Teardown]    AXOS_E72_PARENT-TC-1784 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1784 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1784 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1784 teardown
    cli    n1_session1    \x03    \\#
