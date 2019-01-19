*** Settings ***
Documentation     WI-283: ONT Profile TC - Listing predefined ONT Profiles
...
...               Notes:
...               This TC is written on currently supported pre-defined ONT profiles. All the calix ONT profiles are not yet defined.
...               A JIRA ticket enterred on this(EXA-13022) and it is differed currently.
...               Now test case will pass for the available currenltly supported ont-profiles.
...
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
List Predefined ONT Profiles
    [Documentation]    List the Pre-defined ONT Profiles
    ...  Verify that the pre-defined ONT profiles can be listed.
    ...  Verify that there are pre-defined ONT profiles for all supported Calix ONTs.
    ...  Verify that each pre-defined profile specifies an ONT model number and describes the number and type of ports supported by the ONT.
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=Kumari Kandra    @tcid=AXOS_E72_PARENT-TC-491    @priority=P1

    Log   List pre-defined ONT profile
    ${ontprof}=    Cli   n1   show running-config ont-profile
    Log   ${ontprof}
    Should Contain    ${ontprof}    ont-profile 811NG
    Should Contain    ${ontprof}    ont-profile GP1000X
    Should Contain    ${ontprof}    ont-profile 882NG

    #ONT Profile Specifications
    811NG ONT Profile Specification    n1   811NG
    882NG ONT Profile Specification    n1   882NG
    811NG ONT Profile Specification    n1   GP1000X



