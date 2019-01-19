*** Settings ***
Documentation     ONT Pre-provision test case
Resource          base.robot
Force Tags    @eut=NGPON2-4   @user=root

*** Variables ***
${showONTMACAdd}    do show running-config ont ont-mac-addr ${ONT.ontMACAdd}
${showDcli}       dcli lmd debug dump olm link count 0


*** Test Cases ***
Provision_Verify_ONT_using_MacAddr
    [Documentation]    Provision an ONT using the mac address. Plug in the physical ONT that matches the mac address configured.
    ...  Provision an ONT using the Mac Address.
    ...  Plug in the physical ONT that matches the MAC ID configured.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He   @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-458
    [Setup]    ONT-Pre-Provision setup    n1_session2    cli
    # ***  Disabling PON port to Pre-Provision ONT ***
    Disable Port    n1_session2    ${PORT.porttype}    ${PORT.gponport}
    Cli    n1_session2    do perform ont unlink ont-id ${ONT.ontNum}
    #*** time to check ONT relink status after PON disabled ***
    Sleep   5
    Show ONT-linkages Should Not Contain    n1_session2    ${ONT.ontNum}    ${ONT.ontPort}

    #Step1: *** Provision an ONT using the Mac Address ***
    Provision ONT with MAC Address    n1_session2    ${ONT.ontNum}    ${ONT.ontMACAdd}

    #Step2: *** Plug in the physical ONT that matches the MAC ID configured. ***
    Enable Port    n1_session2    ${PORT.porttype}    ${PORT.gponport}
    # ***  Time to come up the PON and to get linked to ONT   ***
    Sleep   20
    Cli    n1_session2    ${showONTMACAdd}
    Result Should Contain        ${ONT.ontMACAdd}

    # ***  Verify ONT linkages ***
    Wait Until Keyword Succeeds  60    5s   Show ont-link and Status   n1_session2    ${ONT.ontNum}    ${ONT.ontPort}
    Wait Until Keyword Succeeds    4 min    20 sec    Cli    n1_session2    config
    Cli    n1_session2    end
    Cli    n1_session2    exit

    # *** Verify ONT dcli output ***
    Cli   n1_session2    ${showDcli}   prompt=#    timeout=30
    Result Should Contain   ${OUTPUT.dcli}

    [Teardown]    AXOS_E72_PARENT-TC-458 teardown    n1_session1    ${ONT.ontNum}    ${ONT.ontMACAdd}    ${PORT.porttype}    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-458 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${MACADD}   ${PORT_TYPE}    ${PORT}
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
    ...    *MACADD* - The ONT mac address
    ...
    ...    _Example:_
    ...
    ...    | AXOS_E72_PARENT-TC-458 teardown | n1 | 1 | 00:01:02:00:01:02 | pon | 1/1/gp1 |
#    Cli    ${DUT}    cli
    Cli    ${DUT}    config
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no ont-mac-addr ${MACADD}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    Cli    ${DUT}    exit
    #*** wating time given for next test case to start running as it is related RegID, for script stability adding sleep here.
    Sleep   10

