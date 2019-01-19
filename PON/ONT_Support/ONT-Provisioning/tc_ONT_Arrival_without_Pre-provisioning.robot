*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Force Tags   @eut=NGPON2-4
Resource          ./base.robot

*** Test Cases ***
ONT_Arrival_without_Pre-provisioning
    [Documentation]    Verify that when the discovered ONT is not provisioned that there is no service provisioning created for it.
    ...    Plug in an ONT that has no provisioning associated with it.
    ...    Verify that when the discovered ONT is not provisioned that there is no service provisioning created for it.
    ...    Verify that the user can retrieve the HW version physical and the Physical PON location.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-459
    Cli    n1    config
    #Making sure no ONT link existing
    Cli    n1    do perform ont unlink ont-id ${ONT.ontNum}
    #*** Step1: Plug in an ONT that has no provisioning associated with it. ***
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #    ** given time to PON to come up and discover the ONT connected    ***
    # modify by llin
    #    Sleep    20
    #    #*** Step2: Verify that the user can retrieve the HW version physical and the Physical PON location. ***
    #    Cli    n1    do show discovered-ont sum
    #    Result Should Contain    ${ONT.ontSerNum}
    #    Result Should Contain    ${ONT.ontPort}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts sum    ${ONT.ontSerNum}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts sum    ${ONT.ontPort}
    # modified by llin
    # *** Verifying no provisioning associated with discovered ONT ***
    Show ONT-linkages Should Not Contain    n1    ${ONT.ontNum}    ${ONT.ontPort}
    [Teardown]    AXOS_E72_PARENT-TC-459 teardown    n1    ${PORT.porttype}    ${PORT.gponport}

*** Keywords ***
AXOS_E72_PARENT-TC-459 teardown
    [Arguments]    ${DUT}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Disable PON port
    [Tags]    @author=<kkandra> Kumari
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.

    Cli    ${DUT}    exit

