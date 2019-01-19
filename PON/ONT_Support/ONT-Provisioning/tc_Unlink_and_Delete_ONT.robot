*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Force Tags    @eut=NGPON2-4
Resource          ./base.robot

*** Test Cases ***
Unlink_and_Delete_ONT
    [Documentation]    Assigned, linked ONT. Unlink and Delete the ONT.
    ...    Verify that an unlinked ONT can be deleted and that the deleted ONT is not visible to the user.
    ...    Verify that the Global Logical ID for a deleted ONT becomes available for re-use.
    ...    Verify that the deleted ONT will be re-discovered.
    ...    It should appear in the unassigned ONT list.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-468       @EXA-17157
    Cli    n1    config
    #Step1: Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${Uont.pon}
    #    ***    time to PON to come up and discover the ONT connected    ***
    # modified by llin
    #    Sleep    20
    #    Cli    n1    do show discovered-ont sum
    #    Result Should Contain    ${Uont.SerNum}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts sum    ${Uont.SerNum}
    # modified by llin

    #Step2: Provision ONT and verify linkages
    Provision ONT    n1    ${Uont.Num}    ${Uont.Profile}    ${Uont.SerNum}    ${Uont.Port}
    #*** time to get ONT provisioning linked with discovered ONT    ***
    Sleep    5
    Wait Until Keyword Succeeds    60    5s   Show ont-link and Status    n1    ${Uont.Num}    ${Uont.Port}

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

    #Step5: Unlink ONT - delete all the service enabled on ont-ethernet
    Unlink ONT   n1   ${policyName}    ${classMapName}   ${Uont.ethernet}   ${Uont.serviceVlan}

    #Step6: Verify that an unlinked ONT can be deleted and that the deleted ONT is not visible to the user.
    Cli    n1    no ont ${Uont.Num}
    Result Should Not Contain    Error
    Result Should Not Contain    Invalid
    #*** Time to get re-discover ONT again as unassigned ***
    Sleep   20
    Show ONT-linkages Should Not Contain    n1    ${Uont.Num}    ${Uont.Port}

    #Step7: It should appear in the unassigned ONT list.
    Cli    n1    do show unassigned-ont
    Result Should Contain    ${Uont.SerNum}
    [Teardown]    AXOS_E72_PARENT-TC-468 teardown    n1    ${PORT.porttype}    ${Uont.pon}

*** Keywords ***
AXOS_E72_PARENT-TC-468 teardown
    [Arguments]    ${DUT}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Disable PON -- Teardown
    [Tags]    @author=<kkandra> Kumari
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.

    Cli    ${DUT}    exit

