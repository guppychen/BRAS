*** Settings ***
Documentation     Test suite to verify ping utility version
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Verify Ping Utility Version Via Serial 

     [Documentation]    Test case verifies ICMP ping utility version
     ...                1. Verify Ping utility version via serial

     [Tags]    @globalid=2197118    @tcid=AXOS_E72_PARENT-TC-944    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI
    set_eut_version
    ${ping_version_get}    release_cmd_adapter    n1    ${ping_version}
    cli    n1_console    ping -V
    Result Should Contain      ping utility, iputils-s${ping_version_get}
    Result Should Not Contain    unknown
    
*** Keywords ***
