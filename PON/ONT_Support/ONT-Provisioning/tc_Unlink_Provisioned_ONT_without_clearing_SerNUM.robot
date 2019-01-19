*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Unlink_Provisioned_ONT_without_clearing_SerNUM
    [Documentation]    ONT is provisioned and linked. Unlink the ONT and do not clear the serial number.
    ...  Verify that the system allows the user to unlink the ONT.
    ...  Verify that after unlinking the ONT that the ONT quickly relinks.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-463
    Cli    n1   config

    #Making sure no ONT link existing
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}

    #*** Step 1: enable PON port  ***
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #  ***  time to PON to come up and discover the ONT connected  ***
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

    #Step3: Unlink ONT with out clearing serial number, Verify that the system allows the user to unlink the ONT.
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}
    Result Should Not contain  Error
    Result Should Not contain  Invalid
    #   ***  time to ONT to get relink with provisioning   ***
    Sleep    10

    #Step4: Verify that after unlinking the ONT that the ONT quickly relinks.
    Wait Until Keyword Succeeds    60    5s   Show ont-link and Status   n1    ${ONT.ontNum}    ${ONT.ontPort}

    [Teardown]    AXOS_E72_PARENT-TC-463 teardown    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    ${ONT.ontPort}
    ...    ${PORT.porttype}    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-463 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${PROVPON}    ${PORT_TYPE}
    ...    ${PORT}
    [Documentation]    Deprovision ONT
    [Tags]    @author=<kkandra> Kumari
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    no provisioned-pon ${PROVPON}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit
