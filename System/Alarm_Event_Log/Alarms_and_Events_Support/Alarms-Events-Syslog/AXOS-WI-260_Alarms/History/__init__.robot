*** Settings ***
Documentation   Initialization file of feature_x test suites
...             It is for putting suite level setup and teardown keywords
...             And setting the forced tags for all the test cases in  "feature_x" folder and its subfolder
Suite Setup       alarm_setup    n1    ${DEVICES.n1.ports.p1.port}      n1_local_pc      ${DEVICES.n1_local_pc.ip}      ${DEVICES.n1_local_pc.password}
Suite Teardown    alarm_teardown    n1    ${DEVICES.n1.ports.p1.port}      n1_sh      n1_local_pc      ${DEVICES.n1_local_pc.ip}      ${DEVICES.n1_local_pc.password}
Resource          ./base.robot

*** Keywords ***
alarm_setup
    [Arguments]    ${device1}    ${DEVICES.n1.ports.p1.port}     ${local_pc}     ${local_pc_ip}       ${local_pc_password}
    [Documentation]    Getting Alarm history total count

    Log         *** Configure SYSLOG server on DUT ***
    Configure SYSLOG server on DUT      ${device1}      ${local_pc_ip}

    Wait Until Keyword Succeeds      2 min     10 sec     Syslog_server_configure_on_local_PC        ${local_pc}      ${local_pc_ip}       ${local_pc_password}



alarm_teardown
    [Arguments]    ${device1}    ${DEVICES.n1.ports.p1.port}     ${linux}     ${local_pc}     ${local_pc_ip}       ${local_pc_password}
    [Documentation]    Clearing alarms

    Log    *** Clearing Alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm      ${device1}

    Log    *** Unconfigure SYSLOG server on DUT ***
    Unconfigure SYSLOG server on DUT     ${device1}     ${local_pc_ip}

