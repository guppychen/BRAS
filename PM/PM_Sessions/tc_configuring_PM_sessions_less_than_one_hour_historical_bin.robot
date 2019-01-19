*** Settings ***
Documentation     Test suite verifies,Configuring PM sessions with less than one hour historical bins for all supported MI needs to be rejected 
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Test Cases ***

TC1: Configuring PM sessions with less than one hour historical bins for all supported MI. 

     [Documentation]    Test case verifies PM sessions PM session should not be created with less than one hour historical bins values
     ...                1. Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful
     ...                2. Configure PM sessions with less than one hour historical bins for all supported MI
     ...                3. Verify the command is getting rejected and session also not created

     [Tags]    @globalid=2201648    @tcid=AXOS_E72_PARENT-TC-39    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI
     [Teardown]   PM Teardown

     Log  ******************** Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful ******************** 
     Configure Grade Of Service Profile    n1    ${profile_name}    ${threshold}
     Verify Grade Of Service Profile Configured    n1   ${profile_name}

     Log  ********* Configure PM sessions with less than one hour historical bins for all supported MI and verify sessions are not created *******
     Verify Ethernet PM Session Less Than One Hour Historical Bin    n1    ${DEVICES.n1.ports.p1.port}



*** Keywords ***
PM Teardown
    [Documentation]    teardown
    Log  ******************** Unconfigure Grade Of Service profile ********************
    Unconfigure Grade Of Service Profile    n1
