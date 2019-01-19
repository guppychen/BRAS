*** Settings ***
Documentation     ONT Pre-provision test case
Resource          base.robot
Force Tags   @eut=NGPON2-4

*** Variables ***
${showONTregId}    do show running-config ont reg-id ${ONT1.ontRegId}
${showDcli}       dcli lmd debug dump olm link count 0

*** Test Cases ***
Provision_Verify_ONT_using_RegID
    [Documentation]    Provision an ONT using the registration number. Plug in the physical ONT that matches the registration id configured.
    ...  Provision an ONT using the registration id.
    ...  Plug in the physical ONT that matches the registration id configured.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He   @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-2881   @regid
    [Setup]    ONT-Pre-Provision setup    n1_session2    cli
    # ***  Disabling PON port to Pre-Provision ONT ***
    Disable Port    n1_session2    ${PORT.porttype}    ${PORT.gponport1}
    Cli    n1_session2    do perform ont unlink ont-id ${ONT1.ontNum}   prompt=#    timeout=30
    #*** time to check ONT relink status after PON disabled ***
    Sleep   5
    Cli    n1_session2    do show discovered-ont
    Result Should Not Contain    ${ONT1.ontPort}
    Result Should Not Contain    ${ONT1.ontSerNum}
    Show ONT-linkages Should Not Contain    n1_session2    ${ONT1.ontNum}    ${ONT1.ontPort}

    #Step1: *** Provision an ONT using the registration id.  ***
    Provision ONT with RegID    n1_session2    ${ONT1.ontNum}    ${ONT1.ontRegId}
    Cli    n1_session2    ${showONTregId}
    Result Should Contain     ${ONT1.ontRegId}

    #Step2: *** Plug in the physical ONT that matches the registration id configured ***
    Enable Port    n1_session2    ${PORT.porttype}    ${PORT.gponport1}
    # ***  Time to come up the PON and to get linked to ONT   ***
    Sleep   30
    # modify by llin
    wait until keyword succeeds    60s    3s    wait ont discosver     n1_session2    ${ONT1.ontPort}
    wait until keyword succeeds    60s    3s    wait ont discosver     n1_session2    ${ONT1.ontRegId}
    #    Cli    n1_session2    do show discovered-ont
    #    Result Should Contain    ${ONT1.ontPort}
    #    Result Should Contain    ${ONT1.ontRegId}
    # modify by llin

    # ***  Verify ONT linkages ***
    ${R}=   Cli   n1_session2   do show ont-linkages
    Log   ${R}

    Wait Until Keyword Succeeds    60 sec    5 sec  Show ont-link and Status   n1_session2    ${ONT1.ontNum}    ${ONT1.ontPort}
    Wait Until Keyword Succeeds    4 min    20 sec    Cli    n1_session2    config
    Command    n1_session2   end
    Command    n1_session2   exit   prompt=#    timeout=30

    # *** Verify ONT dcli output ***
    Cli   n1_session2    ${showDcli}   prompt=#    timeout=30
    Result Should Contain   ${OUTPUT.dcli}
    Command    n1_session2   cli

    [Teardown]    RLT-TC-4240 teardown    n1_session2    ${ONT1.ontNum}    ${ONT1.ontRegId}    ${PORT.porttype}    ${PORT.gponport1}

*** Keywords ***
RLT-TC-4240 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${REGID}   ${PORT_TYPE}    ${PORT}
    [Tags]    @author=<kkandra> Kumari
    [Documentation]    Deprovision ONT using a ONT Serial Number
    ...
    ...    *Args:*
    ...
    ...    *DUT* - Topo file equipment reference name
    ...
    ...    *ONTNUM* - The ONT number
    ...
    ...    *ONTPORT* - ONT linked port
    ...
    ...    *PORT_TYPE* - Type of interface
    ...
    ...    *PORT* - Interface Value
    ...
    ...    *REGID* - The ONT Serial Number
    ...
    ...    _Example:_
    ...
    ...    | RLT-TC-4240 teardown | n1 | 1 | 1234A | pon | 1/1/gp1 |
    Cli    ${DUT}    config
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no reg-id ${REGID}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    cli    ${DUT}    no ont ${ONTNUM}
    Cli    ${DUT}    exit

