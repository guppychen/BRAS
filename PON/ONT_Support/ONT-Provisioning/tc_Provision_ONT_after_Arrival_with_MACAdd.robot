*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Provision_ONT_after_Arrival_with_MACAdd
    [Documentation]    Auto-discovery of a newly arrived ONT. Add provisioned ONT record using the MAC address.
    ...  Verify that all provisioning associated with the ONT is sent to the ONT and service is brought up as provisioned.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-490
    Cli    n1   config

    #Making sure no ONT link existing
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}

    #*** Step 1: enable PON port  ***
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #  ***  given time to PON to come up and discover the ONT connected  ***
    # modified by llin
    #    Sleep    20
    #
    #    Cli    n1    do show discovered-ont sum
    #    Result Should Contain    ${ONT.ontSerNum}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts sum    ${ONT.ontSerNum}
    # modified by llin

    #*** Step2: Verify that all provisioning associated with the ONT is sent to the ONT and service is brought up as provisioned. ***
    Provision ONT with MAC Address    n1    ${ONT.ontNum}    ${ONT.ontMACAdd}
    # ***  Time to ONT to get linked to Provisioned PON   ***
    Sleep    5
    Wait Until Keyword Succeeds    60    5s  Show ont-link and Status   n1    ${ONT.ontNum}    ${ONT.ontPort}

    [Teardown]    AXOS_E72_PARENT-TC-490 teardown    n1    ${ONT.ontNum}    ${ONT.ontMACAdd}    ${PORT.porttype}    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-490 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${MACADD}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT using a ONT Serial Number
    [Tags]    @author=<kkandra> Kumari
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no ont-mac-addr ${MACADD}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    Cli    ${DUT}    no ont ${ONTNUM}
    Cli    ${DUT}    exit
    #*** wating time given for next test case to start running as it is related RegID, for script stability adding sleep here.
    Sleep   10
