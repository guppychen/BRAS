*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
ONT_Departure_Linked_ONT
    [Documentation]    Unplug a provisioned linked ONT.
    ...  Verify that the provisioning record is not changed.
    ...  Verify that the ONT status is updated to reflect that the ont is no longer present.
    ...  Verify that an alarm is generated that indicates the ONT has departed.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-462
    Cli    n1   config

    #Making sure no ONT link existing
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}

    #*** Step 1: enable PON port  ***
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #  ***  given time to PON to come up and discover the ONT connected  ***
    # modified by llin
    #    Sleep    20
    #    Cli    n1    do show discovered-ont sum
    #    Result Should Contain    ${ONT.ontSerNum}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts sum    ${ONT.ontSerNum}
    # modified by llin


    #Step2: Provision ONT
    Provision ONT    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    ${ONT.ontPort}
    #*** time to get ONT provisioning linked with discovered ONT  ***
    Sleep    5
    Wait Until Keyword Succeeds    60    5s   Show ont-link and Status   n1    ${ONT.ontNum}    ${ONT.ontPort}

    #Clearing old even logs
    Command    n1    do clear active event-log

    #Step3: Unplug a provisioned linked ONT
    Disable Port    n1    ${PORT.porttype}    ${PORT.gponport}

    #Step4: Verify that the provisioning record is not changed.
    Cli   n1   do show running-config ont
    Result Should Contain    ${ONT.ontSerNum}
    Result Should Contain    ${ONT.ontProfile}
    Result Should Contain    ${ONT.ontPort}

    #Step5: Verify that the ONT status is updated to reflect that the ont is no longer present.
    Command    n1    do show ont ${ONT.ontNum} status
    Result Should Contain    missing

    #Step6: Verify ONT departure event generated
    Command    n1    do show event address value 1/1/${ONT.ontPort}
    Result Should Contain    name ont-departure
    Result Should Contain    ${ONT.ontSerNum}

    [Teardown]    AXOS_E72_PARENT-TC-462 teardown    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    ${ONT.ontPort}

*** Keywords ***
AXOS_E72_PARENT-TC-462 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${PROVPON}
    [Documentation]    Deprovision ONT
    [Tags]    @author=<kkandra> Kumari
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    no provisioned-pon 1/1/${PROVPON}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Cli    ${DUT}    exit
