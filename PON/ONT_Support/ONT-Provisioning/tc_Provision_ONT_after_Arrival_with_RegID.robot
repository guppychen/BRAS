*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***

Provision_ONT_after_Arrival_with_RegID
    [Documentation]    Auto-discovery of a newly arrived ONT with Registration ID. Add provisioned ONT record using the registration ID.
    ...  Verify that all provisioning associated with the ONT is sent to the ONT and service is brought up as provisioned.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-2882    @regid
    Cli    n1   config

    #Making sure no ONT link existing
    Cli    n1    do perform ont unlink ont-id ${ONT1.ontNum}

    #*** Step 1: enable PON port  ***
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport1}
    #  ***  given time to PON to come up and discover the ONT connected  ***
    Sleep    30
    Wait Until Keyword Succeeds    1 min    10 sec    Cli    n1    do show version
    Cli    n1    do show discovered-ont sum
    Result Should Contain    ${ONT1.ontRegId}

    #*** Step2: Verify that all provisioning associated with the ONT is sent to the ONT and service is brought up as provisioned. ***
    Provision ONT with RegID    n1    ${ONT1.ontNum}    ${ONT1.ontRegId}
    #*** time to get ONT provisioning linked with discovered ONT  ***
    Sleep    5
    Show ont-link and Status   n1    ${ONT1.ontNum}    ${ONT1.ontPort}

    [Teardown]    RLT-TC-3549 teardown    n1    ${ONT1.ontNum}    ${ONT1.ontRegId}    ${PORT.porttype}    ${PORT.gponport1}

*** Keywords ***
RLT-TC-3549 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${REGID}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT using a ONT Serial Number
    [Tags]    @author=<kkandra> Kumari
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no reg-id ${REGID}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit
