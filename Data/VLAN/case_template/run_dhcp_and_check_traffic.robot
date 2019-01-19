*** Settings ***
Documentation    test_suite keyword lib
Resource          ../base.robot

*** Variable ***

*** Keywords ***
run_dhcp_and_check_traffic
    [Arguments]    ${dhcp_server_name}    ${dhcp_client_group_name}    ${dhcp_server_port}    ${dhcp_client_port}    ${dhcp_negociate_time}=60
    ...    ${traffic_rate_mbps}=5    ${wait_time_to_learn_mac}=5    ${wait_time_after_stop_traffic}=5    ${traffic_run_time}=30    ${traffic_loss_rate}=0.001
    [Documentation]    start dhcp server and client and verify the bound traffic
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | dhcp_server_name | dhcp server name |
    ...    | dhcp_client_group_name | dhcp client group name |
    ...    | dhcp_server_port | dhcp server port on stc |
    ...    | dhcp_client_port | dhcp client port on stc |
    ...    | dhcp_negociate_time | dhcp client bound time |
    ...    | traffic_rate_mbps | traffic rate |
    ...    | wait_time_to_learn_mac | time to learn mac via traffic |
    ...    | wait_time_after_stop_traffic | traffic wait time, default=5s |
    ...    | traffic_run_time | traffic run time, default=10s |
    ...    | traffic_loss_rate | acceptable traffic loss rate |
    [Tags]       @author=AnsonZhang
    log    start the dhcp server and client
    Tg Control Dhcp Server    tg1    ${dhcp_server_name}    start
    Tg Control Dhcp Client    tg1    ${dhcp_client_group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    ${dhcp_client_port}    ${dhcp_negociate_time}

    log    create bound traffic
    create_bound_traffic_udp    tg1    dhcp_us    ${dhcp_client_port}    ${dhcp_server_name}    ${dhcp_client_group_name}    ${traffic_rate_mbps}
    create_bound_traffic_udp    tg1    dhcp_ds    ${dhcp_server_port}    ${dhcp_client_group_name}    ${dhcp_server_name}    ${traffic_rate_mbps}
    log    learn the mac
    Tg Start All Traffic    tg1
    sleep    ${wait_time_to_learn_mac}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    log    start the traffic to verify the performance
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    log    stop and check traffic
    Tg Stop All Traffic    tg1
    log    wait for stc traffic stop
    sleep    ${wait_time_after_stop_traffic}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}