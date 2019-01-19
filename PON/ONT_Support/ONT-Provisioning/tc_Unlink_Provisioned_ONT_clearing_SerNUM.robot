*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Force Tags    @eut=NGPON2-4
Resource          ./base.robot

*** Test Cases ***
Unlink_Provisioned_ONT_clearing_SerNUM
    [Documentation]    ONT is provisioned and linked. Unlink the ONT and clear the serial number.
    ...    Verify that the system allows the user to unlink the ONT.
    ...    Verify that traffic no longer gets to the CPE device once the ONT is unlinked.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-464
    Cli    n1    config
    #Making sure no ONT link existing
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}

    #*** Step 1: enable PON port    ***
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #    ***    time to PON to come up and discover the ONT connected    ***
    Sleep    20
    Cli    n1    do show discovered-ont sum
    Result Should Contain    ${ONT.ontSerNum}

    #Step2: Provision ONT
    Provision ONT    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    ${ONT.ontPort}
    #*** time to get ONT provisioning linked with discovered ONT    ***
    Sleep    5
    Wait Until Keyword Succeeds    60    5s   Show ont-link and Status    n1    ${ONT.ontNum}    ${ONT.ontPort}

    #Step3: Unlink ONT and Clear Serial Number, Verify that the system allows the user to unlink the ONT.
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}
    Result Should Not contain    Error
    Result Should Not contain    Invalid
    #Clear serial number
    Cli    n1    ont ${ONT.ontNum}
    Cli    n1    no serial-number ${ONT.ontSerNum}
    Cli    n1    top
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}
    #    ***    time to ONT to check the    relink is not happening after clearing the serial number    ***
    Sleep    10
    #Verify that ONT didnot get re-linked
    Show ONT-linkages Should Not Contain    n1    ${ONT.ontNum}    ${ONT.ontPort}

    #Step4: Verify that traffic no longer gets to the CPE device once the ONT is unlinked.
    ${Res1}=    Cli    n1    do show interface pon ${PORT.gponport} counters interface-counters rx-pkts
    #*** Time to get the counters increase if the traffic running ***
    Sleep    10
    ${Res2}=    Cli    n1    do show interface pon ${PORT.gponport} counters interface-counters rx-pkts
    Should Be Equal    ${Res1}    ${Res2}
    [Teardown]    AXOS_E72_PARENT-TC-464 teardown    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontPort}    ${PORT.porttype}
    ...    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-464 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${PROVPON}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT
    [Tags]    @author=<kkandra> Kumari
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no provisioned-pon ${PROVPON}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit

