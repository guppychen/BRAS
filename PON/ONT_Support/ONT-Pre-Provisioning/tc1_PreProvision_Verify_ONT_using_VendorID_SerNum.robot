*** Settings ***
Documentation     ONT Pre-provision test case
Resource          base.robot
Force Tags   @eut=NGPON2-4

*** Variables ***
${showONTSerNum}    do show running-config ont serial-number ${ONT.ontSerNum}

*** Test Cases ***
PreProvision_Verify_ONT_using_VendorID_SerNum
    [Documentation]    Pre-provision ONT using a Global ID a ONT vendor and the serial number.Plug in the ONT. Verify using a cli command that the ont record is there.
    ...   Pre-provision ONT using a Global ID a ONT vendor and the serial number.
    ...   Plug in the ONT. Verify using a cli command that the ont record is there.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He   @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-452

    Cli    n1_session1   config
    Cli    n1_session1    ont ${ONT.ontNum}
    Cli    n1_session1    no vendor-id ${ONT.ontVenId}
    Cli    n1_session1    no serial-number ${ONT.ontSerNum}
    Cli    n1_session1    top
    cli    n1_session1    do show running-config ont
    # ***  Disabling PON port to Pre-Provision ONT ***
    Disable Port    n1_session1    ${PORT.porttype}    ${PORT.gponport}
#    Cli    n1_session1    do perform ont unlink ont-id ${ONT.ontNum}

    #*** time to check ONT relink status after PON disabled ***
    Sleep   5
    wait until keyword succeeds    5 x     5 sec   Show ONT-linkages Should Not Contain    n1_session1    ${ONT.ontNum}    ${ONT.ontPort}

    # Step1: *** Pre-provision ONT using a Global ID a ONT vendor and the serial number. ***
    PreProvision ONT with VendorID and SerialNumber    n1_session1    ${ONT.ontNum}    ${ONT.ontVenId}    ${ONT.ontSerNum}
    Cli    n1_session1   ${showONTSerNum}
    Result Should Contain   ${showONTSerNum}   ${ONT.ontSerNum}

    #Step2: *** Plug in the ONT. Verify using a cli command that the ont record is there. ***
    Enable Port    n1_session1    ${PORT.porttype}    ${PORT.gponport}
    # ***  Time to come up the PON and to get linked to ONT   ***
    Sleep    10
    # ***  Verify ONT linkages ***
    Wait Until Keyword Succeeds  60    5s   Show ont-link and Status   n1_session1    ${ONT.ontNum}    ${ONT.ontPort}

    [Teardown]    AXOS_E72_PARENT-TC-452 teardown    n1_session1    ${ONT.ontNum}    ${ONT.ontVenId}    ${ONT.ontSerNum}
    ...    ${PORT.porttype}    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-452 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${VENID}    ${SERNUM}    ${PORT_TYPE}
    ...    ${PORT}
    [Tags]    @author=<kkandra> Kumari
    [Documentation]    Delete ONT using a Global ID a ONT vendor and the serial number.
    ...
    ...    *Args:*
    ...
    ...    *DUT* - Topo file equipment reference name
    ...
    ...    *ONTNUM* - The ONT number
    ...
    ...    *VENID* - The ONT VendorID to use
    ...
    ...    *SERNUM* - The ONT Serial Number
    ...
    ...    *ONTPORT* - ONT linked port
    ...
    ...    *PORT_TYPE* - Type of interface
    ...
    ...    *PORT* - Interface Value
    ...
    ...    _Example:_
    ...
    ...    | Provision ONT | n1 | 1 | CXNK | EFA653 | pon | 1/1/gp1 |
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no vendor-id ${VENID}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit

