*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       packet_capture_suite_provision
Suite Teardown    packet_capture_suite_deprovision
Force Tags        @feature=AXOS-WI-6945 10GE-12: Packet Capture support    @author=MinGu
Resource          ./base.robot

*** Variables ***


*** Keywords ***
packet_capture_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version         
    log    configure packet-capture
    cli    eutA    config
    cli    eutA    packet-capture server-address ${server_add}  
    cli    eutA    packet-capture server-udp-port ${server_udp_port}
    cli    eutA    packet-capture packets ${packets} 
    cli    eutA    end
    
packet_capture_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    packet-capture deprovision
    cli    eutA    config
    cli    eutA    no packet-capture server-address ${server_add}  
    cli    eutA    no packet-capture server-udp-port ${server_udp_port}
    cli    eutA    no packet-capture packets ${packets} 
    cli    eutA    end
    
    
