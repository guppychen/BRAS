*** Settings ***
Documentation     EXA device MUST support a default System Administrator user profile with the System Administrator role profile
...    
...    This supports the inital bring up of the box.
Force Tags        @author=rakrishn    @feature=AXOS-WI-297 User Support    @subfeature=AXOS_WI_297_user_support
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Security_Permissions_Default_System_Admin_user_profile_with_system_Admin_role_profile
    [Documentation]    1	Log in as sysadmin	logged in successfully	
    ...    2	show system administrator user profile with sysadmin role profile as supported	system administrator user and role profile shown
    [Tags]       @author=rakrishn     @TCID=AXOS_E72_PARENT-TC-2677

    log    STEP:1 Log in as sysadmin logged in successfully
    log    STEP:2 show system administrator user profile with sysadmin role profile as supported system administrator user and role profile shown
    cli    n1_session1    show running-config aaa user | nomore   prompt=[^\\r\\n]+\\#
    Result should contain     user ${DEVICES.n1_session1.user}
    Result should contain     role admin
