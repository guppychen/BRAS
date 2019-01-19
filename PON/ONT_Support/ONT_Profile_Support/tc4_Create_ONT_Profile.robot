*** Settings ***
Documentation     WI-283: ONT Profile TC - Create an ONT Profile
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Create ONT Profile
    [Documentation]    Create an ONT Profile
    ...   Verify that new ONT profiles can be created.
    ...   Verify that each create profile specifies an ONT model number and describes the number and type of ports supported by the ONT.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=Kumari Kandra    @tcid=AXOS_E72_PARENT-TC-494    @priority=P1

    Axos Cli With Error Check   n1   config

    #Create an ONT profile
    Create ONT Profile    n1    ${usrdefontProfName}

    #Verify userdefined ont profile in running config
    Axos Cli With Error Check   n1   do show running-config ont-profile ${usrdefontProfName}
    Result Should Contain   ont-profile ${usrdefontProfName}
    Result Should Contain   interface ont-ethernet x1

    [Teardown]   AXOS_E72_PARENT-TC-494 teardown    n1    ${usrdefontProfName}


*** Keywords ***
AXOS_E72_PARENT-TC-494 teardown
    [Arguments]    ${DUT}   ${USRPROFID}
    [Tags]    @author=Kumari Kandra
    [Documentation]    Delete user defined ONT profile
    Axos Cli With Error Check    ${DUT}    no ont-profile ${USRPROFID}
    cli    ${DUT}     end


