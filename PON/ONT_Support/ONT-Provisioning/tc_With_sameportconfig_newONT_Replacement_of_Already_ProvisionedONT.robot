*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Change_Provisioned_ONT_with_new_sameportconfig_ONT
    [Documentation]    Replace a provisioned, linked ONT with a new ONT type that has the same port configuration as the original ONT.
    ...  Change the ONT profile and the provisioned serial number to match the newly inserted ONT profile type and the serial number.
    ...  Verify  that all child objects and services defined for the original ONT can be supported by the new ONT.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-473     @notsupport
    Cli   n1   config

    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #  ***  time to PON to come up and discover the ONT connected  ***
    Sleep    20
    Cli    n1    do show discovered-ont sum
    Result Should Contain    ${ONT.ontSerNum}
    Result Should Contain    ${ONTSamePort.ontSerNum}

    #Provision ONT
    Provision ONT    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    ${ONT.ontPort}
    #*** time to get ONT provisioning linked with discovered ONT  ***
    Sleep    5
    Wait Until Keyword Succeeds    60    5s   Show ont-link and Status   n1    ${ONT.ontNum}    ${ONT.ontPort}

    #Add services to the ont-ethernet
    Cli    n1    vlan ${serVlan}
    Cli    n1    l3-service DISABLED
    Cli    n1    top
    L2 Create ClassMap and Add Rule    n1    ${classMapName}    ${classRule}
    Create PolicyMap Add L2 class Map    n1    ${policyName}    ${classMapName}
    Cli    n1    int ont-ether ${ONT.ethernet}
    Cli    n1    vlan ${serVlan}
    Cli    n1    policy-map ${policyName}
    Cli    n1    top

    #Capture ont-ethernet services before ONT replacement
#    ${Childobject1}=    Cli     n1    do show running-config interface ont-ethernet

    #***  Step1: Change ONT Type  ***
    cli    n1    no ont ${ONT.ontNum}
    Provision ONT    n1    ${ONT.ontNum}    ${ONTSamePort.ontProfile}    ${ONTSamePort.ontSerNum}    ${ONT.ontPort}
#    Cli    n1    ont ${ONT.ontNum}
#    Cli    n1    profile-id ${ONTSamePort.ontProfile}
#    Cli    n1    serial-number ${ONTSamePort.ontSerNum}
#    Cli    n1    top
    cli    n1    interface pon 1/1/${ONT.ontPort}
    cli    n1    shut
    cli    n1    no shut
    #Perform Unlink ONT
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}
    #***   Time to relink with new ONT type   ***
    Sleep    30

    #Verify ONT linkages with serial number
    Cli    n1    do show ont-linkages
    Result Should Contain    ${ONTSamePort.ontSerNum}
    Result Should Contain    ${ONT.ontPort}
    Result Should Contain    Confirmed

    #*** Step2: Need to Verify Child Objects here ***
#    ${Childobject2}=    Cli    n1    do show running-config interface ont-ethernet
#    Should Be Equal   ${Childobject1}   ${Childobject2}
    [Teardown]    AXOS_E72_PARENT-TC-473 teardown    n1    ${ONT.ontNum}    ${ONTSamePort.ontProfile}    ${ONTSamePort.ontSerNum}    ${ONT.ontPort}   ${PORT.porttype}
    ...    ${PORT.gponport}

*** Keywords ***

AXOS_E72_PARENT-TC-473 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${ONTPORT}  ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT
    #Unlink ONT   n1   ${policyName}    ${classMapName}    ${ONT.ethernet}    ${serVlan}
    Cli    ${DUT}    int ont-ether ${ONT.ethernet}
    Cli    ${DUT}    vlan ${serVlan}
    Cli    ${DUT}    no policy-map ${policyName}
    Cli    ${DUT}    exit
    Cli    ${DUT}    no vlan ${serVlan}
    Cli    ${DUT}    top
    Cli    ${DUT}    no policy-map ${policyName}
    Cli    ${DUT}    no class-map ethernet ${classMapName}
    Cli    ${DUT}    no vlan ${serVlan}
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no profile-id ${PRFID}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    no provisioned-pon ${ONTPORT}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit
