*** Settings ***
Documentation     The EXA device MUST support showing active NetConf session information in the CLI and EWI. This means, we need to enumerate the active sessions (as a subset of the overall active management sessions). For each session, we want to show the:
...
...
...
...               User id used to initiate the sessions
...               the remote host the session was initiated from
...               the session start date and time
...               the locks held by the session and duration of the locks held
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=kshettar
Resource          ./base.robot

*** Variables ***
${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>

*** Test Cases ***
tc_The_EXA_device_MUST_support_showing_active_NetConf_sessions_information_in_the_CLI_and_EWI
    [Tags]    @author=kshettar    @TCID=AXOS_E72_PARENT-TC-1770        @globalid=2322301
    [Documentation]    EXA device MUST support showing active NetConf sessions information in the CLI and EWI    
    # To retrieve the login-time
    Netconf Raw    n1_session3    ${close-session}
    cli    n1_session1    logout user sysadmin    timeout_exception=0
    @{t}    Get attributes netconf    n1_session3    //clock    time-status
    ${timestamp} =    Convert Date    ${t[0].text}    result_format=%Y-%m-%d %H:%M
    
    # To verify the user-id used to initiate the Netconf session
    @{var}    Get attributes netconf    n1_session3    //system/user-sessions    session-login
    ${count}    Get Length    ${var}
    should be equal as strings    ${var[${count}-1].text}    ${DEVICES.n1_session3.user}
    
    # To verify the session login time
    @{var}    Get attributes netconf    n1_session3    //system/user-sessions    login-time
    ${count}    Get Length    ${var}
    ${date} =    Convert Date    ${var[${count}-1].text}    result_format=%Y-%m-%d %H:%M
    ${var}    Subtract Date From Date    ${date}    ${timestamp}
    Should Be True    ${var} < 2
    
    # To verify the running session
    @{var}    Get attributes netconf    n1_session3    //system/user-sessions    is-our-session
    ${count}    Get Length    ${var}
    should be equal as strings    ${var[${count}-1].text}    TRUE
    
    # To verify whether the session has running locks
    @{var}    Get attributes netconf    n1_session3    //system/user-sessions    has-running-lock
    ${count}    Get Length    ${var}
    should be equal as strings    ${var[${count}-1].text}    FALSE
    
    # To verify whether the session has candidate lock
    @{var}    Get attributes netconf    n1_session3    //system/user-sessions    has-candidate-lock
    ${count}    Get Length    ${var}
    should be equal as strings    ${var[${count}-1].text}    FALSE
    
    # To verify the remote host the session was initiated from
    ${host}    cli    h1    ifconfig ${ifconfig} | grep -oP "inet addr:\\K\\S+"
    @{remote_host}    Split To Lines    ${host}    1
    @{var}    Get attributes netconf    n1_session3    //system/user-sessions    session-ip
    ${count}    Get Length    ${var}
    should be equal as strings    ${var[${count}-1].text}    @{remote_host}[0]

