*** Settings ***
Documentation    IGMP Proxy Test_suite keyword lib

*** Keywords ***    
configure_whitelist_profile
    [Arguments]    ${device}    ${each}
    [Documentation]    configure_whitelist_profile
    [Tags]    @author=llim
    Cli With Error Check    ${device}    configure
    Cli With Error Check    ${device}    multicast-whitelist-profile ${each}
    Cli With Error Check    ${device}    end
