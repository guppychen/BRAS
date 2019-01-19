*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Delete_Linked_ONT
    [Documentation]    Assigned, linked ONT. Delete the ONT.
    ...  Verify that an assigned ONT cannot be deleted before it is unlinked.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He   @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-469   @EXA-17157
    Cli   n1   config

    #Step1: Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${Uont.pon}
    #  ***  time to PON to come up and discover the ONT connected  ***
    Sleep    20
    Cli    n1    do show discovered-ont sum
    Result Should Contain    ${Uont.SerNum}

    #Step2: Provision ONT and verify linkages
    Provision ONT    n1    ${Uont.Num}    ${Uont.Profile}    ${Uont.SerNum}    ${Uont.Port}
    #*** time to get ONT provisioning linked with discovered ONT  ***
    Sleep    10
    Wait Until Keyword Succeeds  60    5s   Show ont-link and Status   n1   ${Uont.Num}    ${Uont.Port}

    #Step3: Add services to the ont-ethernet
    Cli    n1    vlan ${Uont.serviceVlan}
    Cli    n1    l3-service DISABLED
    Cli    n1    top
    L2 Create ClassMap and Add Rule    n1    ${classMapName}    ${classRule}
    Create PolicyMap Add L2 class Map    n1    ${policyName}    ${classMapName}
    Cli    n1    int ont-ether ${Uont.ethernet}
    Cli    n1    vlan ${Uont.serviceVlan}
    Cli    n1    policy-map ${policyName}
    Cli    n1    top

    #Step4: Verify that an assigned ONT cannot be deleted before it is unlinked.
    Cli    n1    no ont ${Uont.Num}
    Result Should Contain    ERR: ont-profile could not be removed

    [Teardown]    AXOS_E72_PARENT-TC-469 teardown    n1    ${Uont.Num}    ${Uont.Profile}   ${Uont.SerNum}    ${Uont.Port}
    ...    ${PORT.porttype}    ${Uont.serviceVlan}   ${Uont.ethernet}   ${Uont.pon}

*** Keywords ***
AXOS_E72_PARENT-TC-469 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${PROVPON}    ${PORT_TYPE}   ${VLAN}    ${ONTETHR}
    ...    ${PORT}
    [Documentation]   Teardown-3555
    [Tags]    @author=<kkandra> Kumari
    Unlink ONT   n1   ${policyName}    ${classMapName}    ${Uont.ethernet}    ${Uont.serviceVlan}
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    no provisioned-pon ${PROVPON}
    Cli    ${DUT}    top
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit
