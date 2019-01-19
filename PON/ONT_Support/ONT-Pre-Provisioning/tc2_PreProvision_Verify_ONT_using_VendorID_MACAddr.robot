*** Settings ***
Documentation     ONT Pre-provision test case
Resource          base.robot
Force Tags    @eut=NGPON2-4

*** Variables ***
${showONTMACAdd}    do show running-config ont ont-mac-addr ${ONT.ontMACAdd}

*** Test Cases ***
PreProvision_Verify_ONT_using_VendorID_MACAddr
    [Documentation]    Pre-provision ONT by using only a Global ID and a ONT MAC address.Plug in the ONT. Verify using a cli command that the ont record is there.
    ...  Pre-provision ONT by using only a Global ID and a ONT MAC address.
    ...  Plug in the ONT. Verify using a cli command that the ont record is linked to the ONT.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He   @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-453

    Cli    n1_session1   config
    # ***  Disabling PON port to Pre-Provision ONT ***
    Disable Port    n1_session1    ${PORT.porttype}    ${PORT.gponport}
    Cli    n1_session1    do perform ont unlink ont-id ${ONT.ontNum}
    #*** time to check ONT relink status after PON disabled ***
    Sleep   5
    Show ONT-linkages Should Not Contain    n1_session1    ${ONT.ontNum}    ${ONT.ontPort}

    # Step 1: ***   Pre-provision ONT by using only a Global ID and a ONT MAC address. ***
    PreProvision ONT with VendorID and MAC Address    n1_session1    ${ONT.ontNum}    ${ONT.ontVenId}    ${ONT.ontMACAdd}

    # Step2:  *** Plug an ONT with a matching ONT profile and enable the gpon port. Verify using a cli command that the ont record is linked to the ONT ***
    Enable Port    n1_session1    ${PORT.porttype}    ${PORT.gponport}
    # ***  Time to come up the PON and to get linked to ONT   ***
    Sleep    20
    Cli    n1_session1    ${showONTMACAdd}
    Result Should Contain        ${ONT.ontMACAdd}
    # ***  Verify ONT linkages ***
    Wait Until Keyword Succeeds  60    5s   Show ont-link and Status   n1_session1    ${ONT.ontNum}    ${ONT.ontPort}

    [Teardown]    AXOS_E72_PARENT-TC-453 teardown    n1_session1    ${ONT.ontNum}    ${ONT.ontVenId}    ${ONT.ontMACAdd}
    ...    ${PORT.porttype}    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-453 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${VENID}    ${MACADD}   ${PORT_TYPE}
    ...    ${PORT}
    [Tags]    @author=<kkandra> Kumari
    [Documentation]    Deprovision ONT using a Global ID a ONT vendor and the MAC Address.
    ...
    ...    *Args:*
    ...
    ...    *DUT* - Topo file equipment reference name
    ...
    ...    *ONTNUM* - The ONT number
    ...
    ...    *VENID* - The ONT VendorID to use
    ...
    ...    *MACADD* - The ONT Serial Number
    ...
    ...    *ONTPORT* - ONT linked port
    ...
    ...    *PORT_TYPE* - Type of interface
    ...
    ...    *PORT* - Interface Value
    ...
    ...    _Example:_
    ...
    ...    | Provision ONT | n1 | 1 | CXNK | 00:06:31:b5:05:ba | pon | 1/1/gp1 |
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no vendor-id ${VENID}
    Cli    ${DUT}    no ont-mac ${MACADD}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit    timeout_exception=1

