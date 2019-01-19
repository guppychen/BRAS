*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***


*** Keywords ***


generate_pcap_name
    [Arguments]          ${case_name}
    [Documentation]      generate pcap file name with case name
    [Tags]               @author=WanlinSun
    ${pcap_name}    Set Variable    /tmp/${case_name}_pkt.pcap
    [Return]    ${pcap_name}