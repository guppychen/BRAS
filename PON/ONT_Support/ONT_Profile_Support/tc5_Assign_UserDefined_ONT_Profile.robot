*** Settings ***
Documentation     WI-283: ONT Profile TC - Assign an user defined ONT Profile
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Assign an Userdefined ONT Profile
    [Documentation]    Assign an user created ONT Profile
    ...   Verify that the user defined profile maybe used for ONT provisioning.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=Kumari Kandra    @tcid=AXOS_E72_PARENT-TC-495    @priority=P1

    Axos Cli With Error Check   n1   config

    #Create an ONT profile
    Create ONT Profile    n1    ${usrdefontProfName}

    #Verify userdefined ont profile in running config
    Axos Cli With Error Check   n1   do show running-config ont-profile ${usrdefontProfName}
    Result Should Contain   ont-profile ${usrdefontProfName}
    Result Should Contain   interface ont-ethernet x1

    #Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    Wait Until Keyword Succeeds  30    5s   Send Command And Confirm Expect   n1    do show discovered-onts   ${ONT.ontSerNum}

    #Assign Pre-defined ont profile 811NG to the ONT Provisioning
    ONT_prof_kw.Provision ONT    n1   ${ONT.ontNum}   ${usrdefontProfName}   ${ONT.ontSerNum}

    #Verifiaction of pre-defined ont profile has been assigned to ONT Provisioning
    Axos Cli With Error Check    n1   do show running-config ont ${ONT.ontNum}
    Result Should Contain   ${ONT.ontNum}
    Result Should Contain   ${usrdefontProfName}
    Result Should Contain   ${ONT.ontSerNum}

    [Teardown]   AXOS_E72_PARENT-TC-495 teardown    n1    ${usrdefontProfName}    ${ONT.ontNum}    ${ONT.ontSerNum}   ${PORT.porttype}   ${PORT.gponport}


*** Keywords ***
AXOS_E72_PARENT-TC-495 teardown
    [Arguments]    ${DUT}   ${USRPROFID}   ${ONTNUM}   ${SERNUM}  ${PORT_TYPE}    ${PORT}
    [Tags]    @author=Kumari Kandra
    [Documentation]    Delete user defined ONT profile
    Axos Cli With Error Check    ${DUT}    ont ${ONTNUM}
    Axos Cli With Error Check    ${DUT}    no serial-number ${SERNUM}
    Axos Cli With Error Check    ${DUT}    no profile-id ${USRPROFID}
    Axos Cli With Error Check    ${DUT}    top
    Axos Cli With Error Check    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Axos Cli With Error Check    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Axos Cli With Error Check    ${DUT}    no ont-profile ${USRPROFID}
    cli    ${DUT}     end


