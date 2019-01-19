*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Unplug_Discovered_Unassigned_ONT
    [Documentation]    Unplug Discovered not yet link unassigned ONT
    ...  Verify that this ONT shows up on the un-assinged ONT list.
    ...  Verify that when a discovered but-not-linked ONT departs it is removed from the unassigned ONT list.
    ...  Verify that this ONT is no longer visible to the user.
    ...  Verify that the system will generate an event to note the departure.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-466
    Cli    n1   config

    #Making sure ONT is not already discovered
    Disable Port    n1    ${PORT.porttype}    ${Uont.pon}
    Cli    n1    do show unassigned-ont
    Result Should Not Contain    ${Uont.SerNum}

    #Step1: Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${Uont.pon}
    #  ***  time to PON to come up and discover the ONT connected  ***
    Sleep    20
    #Step2: Verify that this ONT shows up on the unassigned ONT list.
    Cli    n1    do show unassigned-ont
    Wait Until Keyword Succeeds    60    5s   Result Should Contain    ${Uont.SerNum}

    #Clearing old event log
    Command    n1    do clear active event-log

    #Step3: Verify that when a discovered but-not-linked ONT departs it is removed from the unassigned ONT list.
    Disable Port    n1    ${PORT.porttype}    ${Uont.pon}
    #Sleep    5
    Cli    n1    do show unassigned-ont
    Result Should Not Contain    ${Uont.SerNum}

    #Step4: Verify that the system will generate an event to note the departure.
    Cli    n1    do show event address value 1/1/${Uont.Port}
    Result Should Contain    name ont-departure
    Result Should Contain    ${Uont.SerNum}

    [Teardown]    AXOS_E72_PARENT-TC-466 teardown    n1    ${PORT.porttype}    ${Uont.pon}

*** Keywords ***
AXOS_E72_PARENT-TC-466 teardown
    [Arguments]    ${DUT}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT using a ONT Serial Number
    [Tags]    @author=<kkandra> Kumari
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit
