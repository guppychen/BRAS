*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Library           String
Library           Collections
Force Tags    @eut=NGPON2-4

*** Test Cases ***
Change_Provisioned_ONT_with_new_moreportconfig_ONT
    [Documentation]    Replace a provisioned, linked ONT with a new ONT type that has the same port configuration as the original ONT plus some additional ports.
    ...   Change the provisioned serial number to match the newly inserted ONT serial number.
    ...   Verify that changing the ONT profile (ONT type) is allowed and that all child objects and services defined for the original ONT can be supported by the new ONT.
    ...   Change the ONT profile to match the new ONT type that was plugged in.
    ...   Verify that the system allows this transition, and will automatically create the ONT child objects needed to match the new ONT Profile.
    ...   Add services to the new ports.
    ...   Verify that  the user can add services to the new ports.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-474     @notsupport
    Cli   n1   config

    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #  ***  time to PON to come up and discover the ONT connected  ***
    Sleep    40
    Cli    n1    do show discovered-ont sum
    Result Should Contain    ${ONT.ontSerNum}
    Result Should Contain    ${ONTMorePort.ontSerNum}

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
#    ${Childobject1}=    Cli    n1    do show running-config interface ont-ethernet

    #Create ONT profile for the ONT which needs to replace old one with more ont port configuration
    ${RTRN}=     Cli    n1     do show running-config ont-profile ${ONTMorePort.ontProfile}
    ${RTRN}=    Replace String    ${RTRN}    \r\n    ${EMPTY}
    Log   ${RTRN}
    ${EXIST}=    Evaluate    'unknown match' in "${RTRN}"
    Run Keyword If    '${EXIST}' == 'True'    Create ONT-Profile    n1   ${ONTMorePort.ontProfile}    ${ONTMorePort.ethernet1}    ${ONTMorePort.ethernet2}
    #Create ONT-Profile    n1   ${ONTMorePort.ontProfile}    ${ONTMorePort.ethernet1}    ${ONTMorePort.ethernet2}

    #***  Step1: Change ONT Type  ***
    cli    n1    no ont ${ONT.ontNum}
    Provision ONT    n1    ${ONT.ontNum}    ${ONTMorePort.ontProfile}    ${ONTMorePort.ontSerNum}    ${ONT.ontPort}
#    Cli    n1    ont ${ONT.ontNum}
#    Cli    n1    profile-id ${ONTMorePort.ontProfile}
#    Cli    n1    serial-number ${ONTMorePort.ontSerNum}
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
    Result Should Contain    ${ONTMorePort.ontSerNum}
    Result Should Contain    ${ONT.ontPort}
    Result Should Contain    Confirmed

    #*** Step2: Need to Verify Child Objects here ***
#    ${Childobject2}=    Cli    n1    do show running-config interface ont-ethernet
#    Should Contain   ${Childobject2}   ${Childobject1}

    #Add Services to the new ONT-profile
    Cli    n1    vlan ${serVlan1}
    Cli    n1    l3-service disabled
    Cli    n1    top
    Cli    n1    int ont-ether ${ONT.ontNum}/${ONTMorePort.ethernet2}
    Cli    n1    vlan ${serVlan1}
    Result Should Not Contain   Aborted
    Result Should Not Contain   Error
    Cli    n1    policy-map ${policyName}
    Cli    n1    top

    #Verify newly added services in running config
    Cli   n1    do show running-config interface ont-ethernet
#    Result Should Contain   vlan ${serVlan}
    Result Should Contain   vlan ${serVlan1}
    Result Should Contain   ${ONTMorePort.ethernet2}

    [Teardown]    AXOS_E72_PARENT-TC-474 teardown    n1    ${ONT.ontNum}    ${ONTMorePort.ontProfile}    ${ONTMorePort.ontSerNum}    ${ONT.ontPort}   ${PORT.porttype}
    ...    ${PORT.gponport}

*** Keywords ***

AXOS_E72_PARENT-TC-474 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${ONTPORT}  ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT
    Unlink ONT Services  n1   ${policyName}    ${classMapName}    ${ONT.ethernet}   ${ONTMorePort.ethernet2}    ${serVlan}   ${serVlan1}
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no profile-id ${PRFID}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    no provisioned-pon ${ONTPORT}
    Cli    ${DUT}    top
    Cli    ${DUT}    do perform ont unlink ont-id ${ONTNUM}
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit
