*** Settings ***
Documentation     EXA device MUST support a password algorithm for the TAC user profile that always allows a TAC engineer access to an EXA device
...    The user password generation should be the same as the E7's TAC password generator and this should be the same as for the E-series.
...    Attached to the SR is the E7 perl version of the TAC password algorithm ecrack.pdf .
...    Also attached is the C7 version of the algorithm ForgottenPassword.java for reference.
...    A single algorithm is preferable, and the intent was to have the same on E7 and C7, but somehow they diverged (the history was lost at least as far as the TAC, Development and SysEng people polled were concerned).  Consistency across E-series is important and thus the requirement to be consistent with the existing E7 TAC password generator.
Force Tags        @author=upandiri    @feature=AXOS-WI-297 User Support    @subfeature=AXOS_WI_297_user_support
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Permissions_TAC_user_profile_password_algorithm
    [Documentation]    1	Log in as sysadmin	log in successful 	
    ...    2	show default TAC user and role profile is supported defualt TAC	user and role profile shown 	
    ...    3	Verify that a password algorithm exists for a Calix tac user to access the EXA device		
    ...    4	Verify that a user can gain access to the OS shell after using a valid e-crack password		
    ...    5	Verify in the audit log that it logged the information of the user trying to access the OS	
    [Tags]       @author=upandiri     @TCID=AXOS_E72_PARENT-TC-2678    @jira=EXA-30910

    log    STEP:1 Log in as sysadmin log in successful
    log    STEP:2 show default TAC user and role profile is supported defualt TAC user and role profile shown
    cli    n1_session1    show running aaa | nomore   prompt=\\#
    Result should contain    user ${tac_usr}
    Result should contain    role ${tac_role}

    log    STEP:3 Verify that a password algorithm exists for a Calix tac user to access the EXA device

    ${login_date_time}   wait until keyword succeeds   6x   20    check clock by dynamic passwaord    dynamic_password_dpu

    # Creating local session for calixsupport user and log into the DUT
    ${login_date_time}    cli    n1_session1    show clock
    ${login_date_time}    cli    dynamic_password_dpu        show clock

    log    STEP:4 Verify that a user can gain access to the OS shell after using a valid e-crack password
    cli    dynamic_password_dpu    shell
    Result Should not contain     syntax error


    log    STEP:5 Verify in the audit log that it logged the information of the user trying to access the OS
    ${formatted_time}    Get formatted date time    ${login_date_time}
    Wait Until Keyword Succeeds   2 min   5 sec   Verify AuditLog Entry     n1_session1    ${formatted_time}   audit user: ${calixsupport_usr}



