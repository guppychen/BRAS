*** Settings ***
Documentation     ONT Pre-provision test case
Resource          base.robot
Force Tags     @eut=NGPON2-4

*** Variables ***
${showONTProfID}    do show running-config ont profile-id ${ONT.ontProfile}

*** Test Cases ***
PreProvision_Verify_ONT_using_ProfileID
    [Documentation]  Pre-provision the ONT specifying the ONT global logical ID and the ONT profile but no serial number or registration ID.
    ...   Pre-provision the ONT specifying the ONT global logical ID and the ONT profile but no serial number or registration ID.
    ...   Plug an ONT with a matching ONT profile and enable the gpon port.
    ...   Update the ONT record to include the serial number of the ONT that was inserted.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He   @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-455
    Cli    n1_session1   config
    # ***  Disabling PON port to Pre-Provision ONT ***
    Disable Port    n1_session1    ${PORT.porttype}    ${PORT.gponport}
    Cli    n1_session1    do perform ont unlink ont-id ${ONT.ontNum}
    #*** time to check ONT relink status after PON disabled ***
    Sleep   5
    Show ONT-linkages Should Not Contain    n1_session1    ${ONT.ontNum}    ${ONT.ontPort}

    # Step 1: ***   Provision ONT ***
    PreProvision ONT with ProfileID    n1_session1    ${ONT.ontNum}    ${ONT.ontProfile}
    Cli    n1_session1    ${showONTProfID}
    Result Should Contain        ${ONT.ontProfile}

    # Step2:  *** Plug an ONT with a matching ONT profile and enable the gpon port. ***
    Enable Port    n1_session1    ${PORT.porttype}    ${PORT.gponport}
    # ***  Time to come up the PON and to get linked to ONT   ***
    Sleep    30
    # ***  Verify ONT linkages ***
    Show ONT-linkages Should Not Contain    n1_session1    ${ONT.ontNum}    ${ONT.ontPort}

    # Step 3: ***  Update the ONT record to include the serial number of the ONT that was inserted. ***
    Provision ONT with SerialNumber    n1_session1    ${ONT.ontNum}    ${ONT.ontSerNum}
    #*** Time to ONT get linked with PON after provisioning ***
    Sleep    10

    # ***  Verify ONT linkages ***
    Wait Until Keyword Succeeds    60 sec    5 sec   Show ont-link and Status   n1_session1    ${ONT.ontNum}    ${ONT.ontPort}

    [Teardown]    AXOS_E72_PARENT-TC-455 teardown    n1_session1    ${ONT.ontNum}    ${ONT.ontSerNum}    ${ONT.ontProfile}
    ...    ${PORT.porttype}    ${PORT.gponport}


*** Keywords ***
AXOS_E72_PARENT-TC-455 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${SERNUM}    ${PROFID}   ${PORT_TYPE}
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
    ...    *SERNUM* - The ONT Serial Number
    ...
    ...    *PROFID* - The ONT Profile ID
    ...
    ...    *ONTPORT* - ONT linked port
    ...
    ...    *PORT_TYPE* - Type of interface
    ...
    ...    *PORT* - Interface Value
    ...
    ...    _Example:_
    ...
    ...    | Provision ONT | n1 | 1 | A1E24 | 811NG | pon | gponport |
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    cli    ${DUT}    no ont ${ONTNUM}
#    cli    ${DUT}    no ont 2    timeout_exception=1
    Cli    ${DUT}    exit

