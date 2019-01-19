  
*** Settings ***
Documentation     ROLT EXA device must support at least 8 concurrent CLI sessions by default Note: It must be possible for a user with permissions who is trying to login in when there are already 8 concurrent sessions active to force out another CLI session - starting with the least privileged.
Force Tags     @author=gpalanis    @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support
Resource          ./base.robot


*** Variables ***
${max_session_count}    8

*** Test Cases ***
tc_ROLT_EXA_device_must_support_at_least_8_concurrent_CLI_sesions_by_default
    [Documentation]    1	Verify 8 concurrent users can be logged into the management port. Verify that a 9th user can not get logged in and is prompted with "Enter SID of session to terminate or 'exit':" Verify a user with the least privilege is exited from their session when their SID is entered.	As Stated	
    [Tags]       @author=gpalanis     @TCID=AXOS_E72_PARENT-TC-2428
    cli    n1_session1    logout user sysadmin        timeout_exception=0
    log    STEP:1 Verify 8 concurrent users can be logged into the management port. Verify that a 9th user can not get logged in and is prompted with "Enter SID of session to terminate or 'exit':" Verify a user with the least privilege is exited from their session when their SID is entered.

    # Retreive the existing user-sessions count
    ${resp_txt}   Get nested text   n1_session1    show user-sessions
    ${list1}     Get Value List From Nested Text   ${resp_txt}    user-sessions    session     display-index
    ${count}    Get length   ${list1}

    # Create local sessions for 8 concurrent users login
    ${local_session_list}     Run Keyword if   ${count}<8
    ...   Create Local Session   ${count}   n1_session1    show version

    # Add a 9th user
    ${conn}=    Session copy info     n1_session1
    Session build local   n1_localsession9    ${conn}

    # Verify that a 9th user cannot login concurrently
    ${error}    Run Keyword And Expect Error   *     cli   n1_localsession9   show version
    Should contain   ${error}   SSHLoginException

    # Get the session-id of all the users
    ${resp_txt}   Get nested text   n1_session1    show user-sessions
    ${list2}     Get Value List From Nested Text   ${resp_txt}    user-sessions    session     display-index
    ${session_id_list}    Create List
    : FOR   ${index}   IN   @{list2}
    \     ${value}   Get Value From Nested Text  ${resp_txt}  user-sessions  session  display-index   ${index}   session-id
    \     Append to list   ${session_id_list}   ${value}

    # Verify that active session can force out another CLI session
    cli    h1   ssh -o StrictHostKeyChecking=no ${DEVICES.n1_session1.user}@${DEVICES.n1_session1.ip}    prompt=password    timeout=30
    cli    h1   ${DEVICES.n1_session1.password}    prompt='exit':   timeout=30
    ${res}    cli    h1   @{session_id_list}[0]
    Should contain  ${res}    Terminating session @{session_id_list}[0]

    [Teardown]   AXOS_E72_PARENT-TC-2428 teardown    ${local_session_list}

*** Keywords ***
AXOS_E72_PARENT-TC-2428 teardown
    [Documentation]    teardown
    [Arguments]   ${local_session_list}
    log    Enter AXOS_E72_PARENT-TC-2428 teardown

    # Destroy the Local sessions created
    : FOR   ${index}   IN   @{local_session_list}
    \    Session destroy local   ${index}

Get nested text
    [Arguments]     ${conn}    ${command}
    [Documentation]
    ...      Example    Get nested text    n1_localsession3    show user-sessions
    ${res}     cli    ${conn}    ${command}     \#    timeout=30
    ${resp_map}     Build Response Map   ${res}
    ${resp_txt}     Parse Nested Text   ${resp_map}
    [Return]        ${resp_txt}


Create Local Session
    [Arguments]     ${count}   ${conn}    ${command}
    [Documentation]
    ...    Example   Create Local Session   ${count}   n1_session1    show version
    ${local_session_list}    Create List
    : FOR   ${index}    IN RANGE   ${count}    ${max_session_count}
    \   ${local_conn}=    Session copy info     ${conn}
    \   Session build local   n1_localsession${index}    ${local_conn}
    \   cli    n1_localsession${index}    ${command}   \\#   30
    \   Append to list   ${local_session_list}   n1_localsession${index}
    [Return]        ${local_session_list}  
