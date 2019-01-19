*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Unassigned_ONT_Discovered
    [Documentation]    Discovered not yet linked unassigned ONT
    ...  Verify that this ONT shows up on the unassigned ONT list.
    ...  Verify that an ONT arrival event is generated when an unassigned ONT arrives.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-465
    Cli    n1   config

    #Making sure ONT is not already discovered
    Disable Port    n1    ${PORT.porttype}    ${Uont.pon}
    Cli    n1    do show unassigned-ont
    Result Should Not Contain    ${Uont.SerNum}

    #Clearing old even log
    Cli    n1    do clear active event-log

    #Step1: Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${Uont.pon}
    #  ***  time to PON to come up and discover the ONT connected  ***
    #modified by llin
    #    Sleep    20
    #
    #    #Step2: Verify that this ONT shows up on the unassigned ONT list.
    #    Cli    n1    do show unassigned-ont
    #    Wait Until Keyword Succeeds    60    5s   Result Should Contain    ${Uont.SerNum}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts sum    ${Uont.SerNum}
    #modified by llin

    #Verify that an ONT arrival event is generated when an unassigned ONT arrives.
    Cli    n1    do show event address value 1/1/${Uont.Port}
    Result Should Contain    name ont-arrival
    Result Should Contain    ${Uont.SerNum}

    [Teardown]    AXOS_E72_PARENT-TC-465 teardown    n1    ${PORT.porttype}    ${Uont.pon}

*** Keywords ***
AXOS_E72_PARENT-TC-465 teardown
    [Arguments]    ${DUT}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Disable PON port
    [Tags]    @author=<kkandra> Kumari
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit
