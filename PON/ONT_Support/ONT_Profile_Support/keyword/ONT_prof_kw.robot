*** Settings ***
Documentation    AXOS-WI-324_ONT-Profile Support keyword lib

*** Keywords ***
811NG ONT Profile Specification
   [Arguments]    ${DUT}    ${ONTPROF}
   [Documentation]    811NG ONT Profile specifications
   [Tags]    @author=Doris He
   Axos Cli With Error Check    ${DUT}    show running-config ont-profile ${ONTPROF}
   Result Should Contain    ${ONTPROF}
   Result Should Contain    interface ont-ethernet x1

882NG ONT Profile Specification
   [Arguments]    ${DUT}    ${ONTPROF}
   [Documentation]    811NG ONT Profile specifications
   [Tags]    @author=Doris He
   Axos Cli With Error Check    ${DUT}    show running-config ont-profile ${ONTPROF}
   Result Should Contain    ${ONTPROF}
   Result Should Contain    interface ont-ethernet x1
   Result Should Contain    interface ont-ethernet g1

711XX ONT Profile Specification
   [Arguments]    ${DUT}    ${ONTPROF}
   [Documentation]    711XX series ONT Profile specifications
   [Tags]    @author=Kumari Kandra
   Axos Cli With Error Check    ${DUT}    show running-config ont-profile ${ONTPROF}
   Result Should Contain    ${ONTPROF}
   Result Should Contain    interface ont-ethernet g1
   Result Should Contain    interface ont-ethernet g2
   Result Should Contain    interface pots p1
   Result Should Contain    interface pots p2
   Result Should Contain    interface rg G1
   Result Should Contain    interface full-bridge F1

725XX ONT Profile Specification
   [Arguments]    ${DUT}    ${ONTPROF}
   [Documentation]    725XX series ONT Profile specifications
   [Tags]    @author=Kumari Kandra
   Axos Cli With Error Check    ${DUT}    show running-config ont-profile ${ONTPROF}
   Result Should Contain    ${ONTPROF}
   Result Should Contain    interface ont-ethernet g1
   Result Should Contain    interface pots p1
   Result Should Contain    interface pots p2
   Result Should Contain    interface rf-video r1
   Result Should Contain    interface rg G1
   Result Should Contain    interface full-bridge F1

801XX ONT Profile Specification
   [Arguments]    ${DUT}    ${ONTPROF}
   [Documentation]    801XX series ONT Profile specifications
   [Tags]    @author=Kumari Kandra
   Axos Cli With Error Check    ${DUT}    show running-config ont-profile ${ONTPROF}
   Result Should Contain    ${ONTPROF}
   Result Should Contain    interface ont-ethernet g1

803XX ONT Profile Specification
   [Arguments]    ${DUT}    ${ONTPROF}
   [Documentation]    803XX series ONT Profile specifications
   [Tags]    @author=Kumari Kandra
   Axos Cli With Error Check    ${DUT}    show running-config ont-profile ${ONTPROF}
   Result Should Contain    ${ONTPROF}
   Result Should Contain    interface ont-ethernet g1
   Result Should Contain    interface pots p1

844XX ONT Profile Specification
   [Arguments]    ${DUT}    ${ONTPROF}
   [Documentation]    844XX series ONT Profile specifications
   [Tags]    @author=Kumari Kandra
   Axos Cli With Error Check    ${DUT}    show running-config ont-profile ${ONTPROF}
   Result Should Contain    ${ONTPROF}
   Result Should Contain    interface ont-ethernet g1
   Result Should Contain    interface ont-ethernet g2
   Result Should Contain    interface ont-ethernet g3
   Result Should Contain    interface ont-ethernet g4
   Result Should Contain    interface pots p1
   Result Should Contain    interface pots p2
   Result Should Contain    interface rg G1
   Result Should Contain    interface full-bridge F1

Provision ONT
   [Arguments]      ${DUT}    ${ONTNUM}    ${PROFID}   ${SERNUM}
   [Tags]    @author=<kkandra> Kumari
   [Documentation]    Provision discovered ONT
   Axos Cli With Error Check    n1    ont ${ONTNUM}
   Axos Cli With Error Check    n1    profile-id ${PROFID}
   Axos Cli With Error Check    n1    serial-number ${SERNUM}

Create ONT Profile
   [Arguments]      ${DUT}    ${USRONTPROF}
   [Tags]    @author=<kkandra> Kumari
   [Documentation]    Creats user defined ONT profile
   Axos Cli With Error Check   ${DUT}   ont-profile ${USRONTPROF}
   Axos Cli With Error Check   ${DUT}   interface ont-ethernet x1
   Axos Cli With Error Check   ${DUT}   exit
#   Axos Cli With Error Check   ${DUT}   interface ont-ethernet g2
   Axos Cli With Error Check   ${DUT}   top

Verify ONT Linkages and ONT Status
   [Arguments]      ${DUT}    ${ONTNUM}   ${SERNUM}
   [Tags]    @author=<kkandra> Kumari
   [Documentation]    Shows ont-linkages and ont status
   Axos Cli With Error Check    n1   do show ont-linkages
    Result Should Contain   ont-id ${ONTNUM}
    Result Should Contain   ${SERNUM}
    Result Match Regexp     state[\\s]+Confirmed
    Axos Cli With Error Check    n1   do show ont ${ONTNUM} status
    Result Should Contain   ${SERNUM}
    Result Match Regexp     oper-state[\\s]+present




