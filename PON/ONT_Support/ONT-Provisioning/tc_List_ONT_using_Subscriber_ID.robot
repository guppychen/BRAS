*** Settings ***
Documentation     ONT Provision test case
...               Preconditions:
...               1. ONTs Should be connected and deifined correctly in parameter file.
Force Tags    @eut=NGPON2-4
Resource          ./base.robot

*** Test Cases ***
List_ONT_using_Subscriber_ID
    [Documentation]    List ONT by using Subscriber ID
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-488
    Cli    n1    config
    #Step1: Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #    ***    time to PON to come up and discover the ONT connected    ***
    # modified by llin
    #    Sleep    20
    #    Cli    n1    do show discovered-ont sum
    #    Result Should Contain    ${ONT.ontSerNum}
    Wait Until Keyword Succeeds  60    5s   Send Command And Confirm Expect   n1    do show discovered-onts sum    ${ONT.ontSerNum}
    # modified by llin

    #Step2: Provision ONT
    Full ONT Provision    n1    ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    ${ONT.ontPort}    ${ONT.ontMACAdd}
    ...    ${ONT.ontSubId}
    #*** time to get ONT provisioning linked with discovered ONT    ***
    Sleep    5
    Wait Until Keyword Succeeds    60    5s    Show ont-link and Status    n1    ${ONT.ontNum}    ${ONT.ontPort}
    #Step3: List ONT using Subscriber ID
    Cli    n1    do show run ont subscriber-id ${ONT.ontSubId}
    List ONT    n1

    [Teardown]    AXOS_E72_PARENT-TC-485-78 teardown    n1   ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    1/1/${ONT.ontPort}
    ...    ${ONT.ontMACAdd}    ${ONT.ontSubId}    ${PORT.porttype}    ${PORT.gponport}
