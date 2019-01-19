*** Settings ***
Documentation     Changing ONT profile to Same port config ONT profile
Force Tags    @eut=NGPON2-4
Resource          ./base.robot

*** Test Cases ***
Change ONT Profile with Profile has same ports
    [Documentation]    Change ONT Profile on an ONT
    ...    Assign an ONT profile that has the same ports as the ONT its being assigned to.
    ...    Verify that the user is allowed to change an ONT profile.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=Kumari Kandra    @tcid=AXOS_E72_PARENT-TC-497    @priority=P1
    Axos Cli With Error Check    n1    config

    #Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    Wait Until Keyword Succeeds  30    5s   Send Command And Confirm Expect   n1    do show discovered-onts   ${ONT.ontSerNum}

    #Assign Pre-defined ont profile 811NG to the ONT Provisioning
    ONT_prof_kw.Provision ONT    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}

    #Verifiaction of pre-defined ont profile has been assigned to ONT Provisioning
    Axos Cli With Error Check    n1    do show running-config ont ${ONT.ontNum}
    Result Should Contain    ont ${ONT.ontNum}
    Result Should Contain    ${ONT.ontProfile}
    Result Should Contain    ${ONT.ontSerNum}

    #Verify Ont linkgaes and ont status
    #time given to link ONT with provisioned data
    Sleep   10
    Wait Until Keyword Succeeds    5 min    20 sec    Cli    n1   do show version
    Verify ONT Linkages and ONT Status    n1    ${ONT.ontNum}    ${ONT.ontSerNum}

    #Create an ONT profile which has same port with 811NG
    Create ONT Profile    n1    ${usrdefontProfName}

    #Change ont-profile which has same port config
    Axos Cli With Error Check    n1    ont ${ONT.ontNum}
    Axos Cli With Error Check    n1    no profile-id
    Axos Cli With Error Check    n1    profile-id ${usrdefontProfName}

    #Verifiaction of pre-defined ont profile has been assigned to ONT Provisioning
    Axos Cli With Error Check    n1    do show running-config ont ${ONT.ontNum}
    Result Should Contain    ont ${ONT.ontNum}
    Result Should Contain    ${usrdefontProfName}
    Result Should Contain    ${ONT.ontSerNum}

    #Perform unlink ONT after ONT profile change
#    Axos Cli With Error Check    n1    do perform ont unlink ont-id ${ONT.ontNum}
    #Time to relink ONT
    Sleep    10
    Wait Until Keyword Succeeds    5 min    20 sec    Cli    n1    do show version

    #Verify Ont linkgaes and ont status after ONT Profile change
    Verify ONT Linkages and ONT Status    n1    ${ONT.ontNum}    ${ONT.ontSerNum}


    [Teardown]    AXOS_E72_PARENT-TC-497 teardown    n1    ${ONT.ontNum}    ${ONT.ontSerNum}    ${usrdefontProfName}    ${PORT.porttype}
    ...    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-497 Teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${SERNUM}    ${PROFID}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT using a ONT Serial Number and Profile ID
    [Tags]    @author=Kumari Kandra
    Axos Cli With Error Check    ${DUT}    ont ${ONTNUM}
    Axos Cli With Error Check    ${DUT}    no serial-number ${SERNUM}
    Axos Cli With Error Check    ${DUT}    no profile-id ${PROFID}
    Axos Cli With Error Check    ${DUT}    top
    Axos Cli With Error Check    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Axos Cli With Error Check    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Axos Cli With Error Check    ${DUT}    no ont-profile ${PROFID}
    Axos Cli With Error Check    ${DUT}    end
