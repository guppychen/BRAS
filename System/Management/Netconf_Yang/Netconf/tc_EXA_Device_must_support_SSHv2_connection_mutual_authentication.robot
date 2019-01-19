*** Settings ***
Documentation     Per RFC 6242 - section 8:
...
...
...               The identity of the SSH server MUST be verified and authenticated by the SSH client according to local policy before password-based authentication data or any configuration or state data is sent to or received from the SSH server. The identity of the SSH client MUST also be verified and authenticated by the SSH server according to local policy to ensure that the incoming SSH client request is legitimate before any configuration or state data is sent to or received from the SSH client. Neither side should establish a NETCONF over SSH connection with an unknown, unexpected, or incorrect identity on the opposite side.
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=rakrishn
Resource          ./base.robot

*** Variables ***
${command}        //system/user-sessions
${val}    0

*** Test Cases ***
tc_EXA_Device_must_support_SSHv2_connection_secure_authentication
    [Documentation]    1.Open netconf session and check if any get command works.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1783        @globalid=2322314

    log    STEP:1 Net config part - successful login
    @{elem}    Get attributes netconf    n1_session3    ${command}    session-manager
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0    ${count}
    \    ${val}    Run Keyword If    "${elem[${index}].text}" != "netconf"    Continue For Loop
    \    ...    ELSE    Set Variable    1
    \    Exit For Loop

    Run Keyword If    ${val} == 1    log    user ${DEVICES.n1_session3.user_interface} is logged in
    ...    ELSE    Fail    ERROR:user ${DEVICES.n1_session3.user_interface} is not logged in
