*** Settings ***
Documentation     WI-283: ONT Profile TC - Create and delete an unassigned user defined ONT Profile
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Delete an unassigned Userdefined ONT Profile
    [Documentation]    Create and delete an unassigned ONT Profile
    ...   Verify that the user is allowed to delete the ONT profile.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=Kumari Kandra    @tcid=AXOS_E72_PARENT-TC-496    @priority=P1

    Axos Cli With Error Check   n1   config

    #Create an ONT profile
    Create ONT Profile    n1    ${usrdefontProfName}

    #Verify userdefined ont profile in running config
    Axos Cli With Error Check   n1   do show running-config ont-profile ${usrdefontProfName}
    Result Should Contain   ont-profile ${usrdefontProfName}
    Result Should Contain   interface ont-ethernet x1

    #Delete above unassigned userdefined ONT Profile
    Axos Cli With Error Check   n1   no ont-profile ${usrdefontProfName}

    #Verify running config should not contain user defined ONT Profile after deletion
    Axos Cli With Error Check   n1   do show running-config ont-profile
    Result Should Not Contain   ont-profile ${usrdefontProfName}

    [Teardown]    AXOS_E72_PARENT-TC-496 Teardown   n1   ${usrdefontProfName}


*** Keywords ***
AXOS_E72_PARENT-TC-496 Teardown
    [Arguments]    ${DUT}    ${USRONTPROF}
    [Tags]    @author=Kumari Kandra
    [Documentation]    delete userdefined ont-profile
    ${T1}=   Cli   ${DUT}   do show running-config ont-profile ${USRONTPROF}
    ${T1}=   Get Line  ${T1}   1
    ${T1}=   Remove String   ${T1}   ont-profile \
    Run Keyword If   '${T1}' == '${USRONTPROF}'   Cli   ${DUT}   no ont-profile ${USRONTPROF}
    cli   ${DUT}   end

