*** Settings ***
Documentation     ONT Pre-provision test case
Resource          base.robot
Force Tags     @eut=NGPON2-4   @user=root

*** Variables ***
${showONTSerNum}    do show running-config ont serial-number ${ONT.ontSerNum}
${showDcli}       dcli lmd debug dump olm link count 0

*** Test Cases ***
Provision_Verify_ONT_using_SerNum
    [Documentation]    Provision an ONT using the serial number. Plug in the physical ONT that matches the serial number configured.
    ...  Provision an ONT using the serial number.
    ...  Plug in the physical ONT that matches the serial number configured.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He   @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-456
    [Setup]    ONT-Pre-Provision setup    n1_session2    cli
    # ***  Disabling PON port to Pre-Provision ONT ***
    Disable Port    n1_session2    ${PORT.porttype}    ${PORT.gponport}
    Cli    n1_session2    do perform ont unlink ont-id ${ONT.ontNum}
    #*** time to check ONT relink status after PON disabled ***
    Sleep   5
    Cli    n1_session2    do show discovered-ont

    Result Should Not contain    ${ONT.ontPort}
    Result Should Not contain    ${ONT.ontSerNum}
    Show ONT-linkages Should Not Contain    n1_session2    ${ONT.ontNum}    ${ONT.ontPort}

    #Step1: Provision an ONT using the serial number.
    Provision ONT with SerialNumber    n1_session2    ${ONT.ontNum}    ${ONT.ontSerNum}

    #Step2: Plug in the physical ONT that matches the serial number configured.
    Enable Port    n1_session2    ${PORT.porttype}    ${PORT.gponport}
    # ***  Time to come up the PON and to get linked to ONT   ***
    Sleep    20

    # ***  Verify ONT linkages ***
    Cli    n1_session2    ${showONTSerNum}
    Result Should Contain    ${ONT.ontSerNum}
    Wait Until Keyword Succeeds  60    5s   Show ont-link and Status   n1_session2    ${ONT.ontNum}    ${ONT.ontPort}
    Wait Until Keyword Succeeds    4 min    20 sec    Cli    n1_session2    config
    Cli    n1_session2    end
    Cli    n1_session2    exit   prompt=#    timeout=30

    # *** Verify ONT dcli output ***
    Cli    n1_session2    ${showDcli}   prompt=#    timeout=30
    Result Should Contain   ${OUTPUT.dcli}

    [Teardown]    AXOS_E72_PARENT-TC-456 teardown    n1_session2    ${ONT.ontNum}    ${ONT.ontSerNum}    ${PORT.porttype}
    ...    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-456 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${SERNUM}    ${PORT_TYPE}    ${PORT}
    [Tags]    @author=<kkandra> Kumari
    [Documentation]    Deprovision ONT using a ONT Serial Number
    ...
    ...    *Args:*
    ...
    ...    *DUT* - Topo file equipment reference name
    ...
    ...    *ONTNUM* - The ONT number
    ...
    ...    *SERNUM* - The ONT Serial Number
    ...
    ...    *PORT_TYPE* - Type of interface
    ...
    ...    *PORT* - Interface Value
    ...
    ...    _Example:_
    ...
    ...    | AXOS_E72_PARENT-TC-456 teardown | n1 | 1 | A1E24 | pon | 1/1/gp1 |
    Cli    ${DUT}    cli
    Cli    ${DUT}    config
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit

