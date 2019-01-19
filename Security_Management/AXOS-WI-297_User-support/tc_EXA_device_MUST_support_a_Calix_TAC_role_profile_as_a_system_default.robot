*** Settings ***
Documentation     The TAC role is a Calix support role user. Calix users will use a user profile with this role to provide support to the CSP.
Resource          base.robot
Test Setup        AXOS_E72_PARENT-TC-2676 setup
Test Teardown     AXOS_E72_PARENT-TC-2676 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira 

*** Variables ***


*** Test Cases ***
tc_EXA_device_MUST_support_a_Calix_TAC_role_profile_as_a_system_default
    [Documentation]    1	Log in as sysadmin 	log in successful 	
    ...    2	show default TAC user and role profile is supported defualt TAC	user and role profile shown 
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2676    @feature=AXOS-WI-297 User Support    @EUT=E3-2

    cli    n1    cli
    cli    n1    conf
    cli    n1    aaa user tac role    prompt=\\):    timeout=30
    Result Should Contain    admin
	cli    n1    admin  timeout=30

*** Keywords ***
AXOS_E72_PARENT-TC-2676 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2676 setup


AXOS_E72_PARENT-TC-2676 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2676 teardown
	cli    n1    end
