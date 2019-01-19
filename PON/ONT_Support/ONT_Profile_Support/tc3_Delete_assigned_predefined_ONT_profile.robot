*** Settings ***
Documentation     WI-283: ONT Profile TC - Delete assigned predefined ONT Profile
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Delete assigned Predifined ONT Profile
    [Documentation]    ONT Management / Delete the assigned pre-defined ONT Profile.
    ...   ONT assigned pre-defined ONT Profile.  Delete the assigned pre-defined ONT Profile.
    ...   Verify that the user is not allowed to delete an assigned pre-defined ONT profile.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=Kumari Kandra    @tcid=AXOS_E72_PARENT-TC-493    @priority=P1

    Axos Cli With Error Check   n1   config

    #Verify pre-defined ONT profile is existing in running config
    Axos Cli With Error Check    n1   do show running-config ont-profile 811NG
    Result Should Contain   ont-profile 811NG
    Result Should Contain   interface ont-ethernet x1

    #Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts   ${ONT.ontSerNum}

    #Assign Pre-defined ont profile 811NG to the ONT Provisioning
    ONT_prof_kw.Provision ONT    n1   ${ONT.ontNum}   ${ONT.ontProfile}   ${ONT.ontSerNum}

    #Verifiaction of pre-defined ont profile has been assigned to ONT Provisioning
    Axos Cli With Error Check    n1   do show running-config ont ${ONT.ontNum}
    Result Should Contain   ${ONT.ontNum}
    Result Should Contain   ${ONT.ontProfile}
    Result Should Contain   ${ONT.ontSerNum}

    #Try to Delete assigned predefined ont profile
    Cli   n1   no ont-profile ${preontProfile}
    Result Should Contain   Aborted: illegal reference 'ont ${ONT.ontNum} profile-id'

    #Verify that the predefined ONt profile is still in running config
    Axos Cli With Error Check    n1   do show running-config ont-profile 811NG
    Result Should Contain   ont-profile 811NG
    Result Should Contain   interface ont-ethernet x1

    [Teardown]    AXOS_E72_PARENT-TC-492 teardown    n1    ${ONT.ontNum}    ${ONT.ontSerNum}    ${ONT.ontProfile}   ${PORT.porttype}
    ...    ${PORT.gponport}


*** Keywords ***
AXOS_E72_PARENT-TC-492 Teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${SERNUM}    ${PROFID}   ${PORT_TYPE}    ${PORT}
    [Tags]    @author=Kumari Kandra
    [Documentation]    Deprovision ONT using a ONT Serial Number and Profile ID
    Axos Cli With Error Check    ${DUT}    ont ${ONTNUM}
    Axos Cli With Error Check    ${DUT}    no serial-number ${SERNUM}
    Axos Cli With Error Check    ${DUT}    no profile-id ${ONT.ontProfile}
    Axos Cli With Error Check    ${DUT}    top
    Axos Cli With Error Check    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Axos Cli With Error Check    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Axos Cli With Error Check    ${DUT}    end
