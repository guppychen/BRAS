*** Settings ***
Documentation    keyword library



*** Keywords ***
Verify Cmd Working After Reload
    [Arguments]          ${device}      ${cmd}
    [Documentation]      Verify OLT Image Version matches today's date
    [Tags]               @author=chxu
    run keyword and ignore error   disconnect    ${device}
    ${res}    Axos Cli With Error Check    ${device}    ${cmd}
    result should not contain    started: lmd
    should Match Regexp      ${res}    \\w+\-\\w+\-\\d+

Reload The Device With Default Startup
    [Arguments]    ${device}
    [Tags]    @author=chxu
    [Documentation]     Performs a system reload and device up with default startup configuration
    ...    Copy default startup configuration  to startup cofiguration
    ...    Reload the device

    cli    ${device}    copy config from rolt1_tc_config to startup-config
    cli    ${device}    accept running-config
    reload    ${device}


Ping_Device
    [Documentation]  Check if device is reachable
    [Tags]    @author=chxu
    [Arguments]    ${session}    ${device_ip}    ${timeout}=30
    ${ret} =    Session Command    h1    ${SPACE}
    ${prompt} =    get last command prompt    h1
    ${prompt} =    regexp escape  ${prompt}
    ${res}    cli    ${session}    ping ${device_ip} -c 4    ${prompt}    ${timeout}
    should Match Regexp      ${res}    ,\\s0% packet loss

Send Command And Confirm Expect
    [Arguments]    ${DUT}    ${CMD}   ${PROMPT}
    [Documentation]    Sends a command and confirms the expected prompt is in the response
    ${txt}=    Cli    ${DUT}    ${CMD}
    Result Match Regexp  ${PROMPT}
    Result Should not Contain    Fail

check version
    [Arguments]   ${DUT}
    [Documentation]   check ROLT version
    ${res}    Cli   ${DUT}   show version
    Result Should not contain    command not found
    Result Should not contain    Error
    cli   ${DUT}   show int sum sta

check interface states
    [Arguments]  ${DUT}

    ${res}   check interface state should be up    ${DUT}    1/3/x2
#    Run keyword if    '${res}' == 'down'   generate diag and reload system   ${DUT}

check interface state should be up
    [Arguments]  ${DUT}    ${interface}
    ${res}   cli    ${DUT}   show interface ethernet ${interface} status oper-state
        ${res}=    Get Line    ${res}    -1

    @{result}    Get Regexp Matches    ${res}    status oper-state\\s+(\\S+)    1
    ${res}      Get From List     ${result}      -1
    log   ${res}
    [Return]    ${res}

generate diag and reload system
   [Arguments]  ${DUT}
   cli    ${DUT}    generate techlog     timeout=10    timeout_exception=0      prompt=\\#
   wait until keyword succeeds   20 min   1 min   verify diag   ${DUT}
   Reload The Device With Default Startup    ${DUT}
   wait until keyword succeeds    10 min    1 min    ping_device   h1    ${DEVICES.n1.ip}
   wait until keyword succeeds    10 min    1 min    ping_device   h1    ${DEVICES.n2.ip}
   wait until keyword succeeds    10 min    1 min    ping_device   h1    ${DEVICES.n3.ip}
   wait until keyword succeeds    5 min    1 min    check version    ${DUT}
   wait until keyword succeeds    5 min    1 min    check version    ${DUT}


verify diag
    [Arguments]  ${DUT}
    cli    ${DUT}    show techlog status     timeout=10    timeout_exception=0      prompt=\\#
    Result Should contain     Success

Configure Craft Port
    [Documentation]    Configure Craft port
    [Arguments]    ${device}      ${craft_port}     ${ipaddr}      ${cidr}      ${gateway}
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface craft ${craft_port}
    cli    ${device}    ip address ${ipaddr}/${cidr} gateway ${gateway} dhcp server disable
    cli    ${device}    no shutdown
    [Teardown]    cli    ${device}    end

Unconfigure Craft Port
    [Documentation]    Unconfigure Craft port
    [Arguments]    ${device}      ${craft_port}
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface craft ${craft_port}
    cli    ${device}    no ip address
    [Teardown]    cli    ${device}    end

Enable Craft Port
    [Documentation]    Enable Craft port
    [Arguments]    ${device}      ${craft_port}
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface craft ${craft_port}
    cli    ${device}    no shutdown
    [Teardown]    cli    ${device}    end

Disable Craft Port
    [Documentation]    Disable Craft port
    [Arguments]    ${device}      ${craft_port}
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface craft ${craft_port}
    cli    ${device}    shutdown
    [Teardown]    cli    ${device}    end

Verify Craft Port Entity
    [Documentation]    Verify that Craft port paramaters did not change
    [Arguments]    ${device}      ${craft_port}
    [Tags]    @author=llim
    cli    ${device}    show interface craft ${craft_port} status
    Result Should Contain      name
    Result Should Contain      admin-state
    Result Should Contain      oper-state
    Result Should Contain      last-change
    Result Should Contain      mac-addr
    Result Should Contain      net-config-type
    Result Should Contain      ip-address ipv4
    Result Should Contain      ip-address ipv6
    Result Should Contain      rx-pkts
    Result Should Contain      rx-octets
    Result Should Contain      tx-pkts
    Result Should Contain      tx-octets
    Result Should Contain      in-discards
    Result Should Contain      in-errors
    Result Should Contain      out-errors
    Result Should Contain      dhcp-server
    Result Should Contain      ip-gateway

Verify Ethernet Interface Status
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet Interface Status on Platform
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    no shutdown
    cli    ${device}    end
    cli    ${device}    show interface ethernet ${port} status admin-state
    Result Should Contain    enable
    cli    ${device}    show interface ethernet ${port} status oper-state
    Result Should Contain    up

Configure Grade Of Service Profile
    [Arguments]    ${device}    ${profile_name}    ${threshold}
    [Documentation]    Configure Grade Of Service
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    grade-of-service rmon-gos-profile ${profile_name} bin-gos octets threshold ${threshold} tca-name octets
    cli    ${device}    grade-of-service rmon-gos-profile ${profile_name} bin-gos pkts-512to1023 threshold ${threshold} tca-name pkts-512to1023
    cli    ${device}    grade-of-service rmon-gos-profile ${profile_name} bin-gos rx-pkts threshold ${threshold} tca-name rx-pkts
    [Teardown]    cli    ${device}    end

Verify Grade Of Service Profile Configured
    [Arguments]    ${device}    ${profile_name}
    [Documentation]    Verify Grade Of Service Profile Configured is successful
    [Tags]    @author=llim
    cli    ${device}    show running-config grade-of-service
    Result Should Contain    grade-of-service
    Result Should Contain    rmon-gos-profile ${profile_name}
    Result Should Contain    bin-gos octets
    Result Should Contain    bin-gos pkts-512to1023
    Result Should Contain    bin-gos rx-pkts

Enable Ethernet PM Session In Interface
    [Arguments]    ${device}    ${port}
    [Documentation]    Enable Ethernet PM session in corresponding interface
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session ${bin_duration} ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} bin-gos enable interval-gos enable
    [Teardown]    cli    ${device}    end

Enable Ethernet PM Session
    [Arguments]    ${device}    ${port}
    [Documentation]    Enable Ethernet PM session in corresponding interface
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session ${bin_duration} ${historical_bin}
    [Teardown]    cli    ${device}    end

Enable Ethernet PM Session All MI Values
    [Arguments]    ${device}    ${port}
    [Documentation]    Enable Ethernet PM Session with all supported MI values in interface
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session one-minute ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} bin-gos enable interval-gos enable
    cli    ${device}    rmon-session five-minutes ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} bin-gos enable interval-gos enable
    cli    ${device}    rmon-session fifteen-minutes ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} bin-gos enable interval-gos enable
    cli    ${device}    rmon-session one-hour ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} bin-gos enable interval-gos enable
    cli    ${device}    rmon-session one-day ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} bin-gos enable interval-gos enable
    cli    ${device}    rmon-session infinite 1 gos-profile-name ${profile_name} session-name ${session_name} bin-gos enable interval-gos enable
    [Teardown]    cli    ${device}    end

Verify Ethernet PM Session Is Created
    [Arguments]    ${device}    ${port}    ${session_number}
    [Documentation]    Verify Current Ethernet Performance Monitoring session
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number ${session_number}

Disable Ethernet PM Session In Interface
    [Arguments]    ${device}    ${port}
    [Documentation]    Disable Ethernet PM session in corresponding interface
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    no rmon-session one-minute ${historical_bin}
    cli    ${device}    no rmon-session five-minutes ${historical_bin}
    cli    ${device}    no rmon-session fifteen-minutes ${historical_bin}
    cli    ${device}    no rmon-session one-hour ${historical_bin}
    cli    ${device}    no rmon-session one-day ${historical_bin}
    cli    ${device}    no rmon-session infinite 1
    cli    ${device}    no rmon-session one-minute 60
    cli    ${device}    no rmon-session five-minutes 12
    cli    ${device}    no rmon-session fifteen-minutes 4
    cli    ${device}    no rmon-session one-hour 12
    cli    ${device}    no rmon-session one-day 1
    [Teardown]    cli    ${device}    end

Unconfigure Grade Of Service Profile
    [Arguments]    ${device}
    [Documentation]    Unonfigure Grade Of Service
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    no grade-of-service rmon-gos-profile ${profile_name}
    [Teardown]    cli    ${device}    end

Clear Ethernet Interface Counter
    [Arguments]    ${device}    ${port}
    [Documentation]    clearing interface counter before starting traffic
    [Tags]    @author=llim
    cli    ${device}    clear interface ethernet ${port} counters

Start Traffic Stream
    [Arguments]    ${stc_device_ip}
    [Documentation]    Start Traffic Stream
    [Tags]    @author=llim
    Tg Load Config File    ${stc_device_ip}    /drv1/sandbox/rf_demo/test_suites/ROLT_INITIAL/config/STCconfigs/test1.xml
    Tg Start All Traffic    ${stc_device_ip}

Stop Traffic Stream
    [Arguments]    ${stc_device_ip}
    [Documentation]    Stop Traffic Stream
    [Tags]    @author=llim
    Tg Stop All Traffic    ${stc_device_ip}

Verify Ethernet Interface Traffic
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet Interface Traffic
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} counters
    Result Match Regexp    pkts-512to1023\\s+\\d+

Reload Device
    [Arguments]    ${device}
    [Documentation]    Reload the device to bring back to system default configuration
    [Tags]    @author=llim
    cli    ${device}    accept running-config
    cli    ${device}    copy config from running-config to running-config-safe
    Result Should Contain    Copy completed
    cli    ${device}    delete file config filename startup-config.xml
    Result Should Contain    OK
    reload    ${device}

Configure
    [Arguments]    ${device}    ${conf_cmd}    ${TIMEOUT}=10
    [Documentation]    [Author:jbin] Description: Configure the device.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | conf_cmd | configure command |
    ...    | TIMEOUT | The wait in seconds for a timeout to occur. Default is 10. |
    ...
    ...    Example:
    ...    | Configure | n1 | interface craft 1/g1 ip address 10.10.10.11 |
    [Tags]    @author=jbin
    cli    ${device}    configure    timeout=${TIMEOUT}
    cli    ${device}    ${conf_cmd}    timeout=${TIMEOUT}
    [Teardown]    cli    ${device}    end

Get DateTime
    [Arguments]    ${device}
    [Documentation]    [Author:jbin] Description: Get date time.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...
    ...    Example:
    ...    | Get DateTime | n1 |
    ${cmd_string}    set variable    date "+%Y-%m-%d %H:%M:%S"
    ${res}    cli    ${device}    ${cmd_string}
    ${result}    Get Regexp Matches    ${res}    (\\d{4}-\\d+-\\d+\\s\\d+:\\d+:\\d+)    1
    ${NewDate}    set variable    ${result[0]}
    [Return]    ${NewDate}

Get hwclock Time with Changetime
    [Arguments]    ${device}    ${change_time}=0h
    [Documentation]    [Author:jbin] Description: Get hardware clock time with change time.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | change_time | the time need to change, default is 0h |
    ...
    ...    Example:
    ...    | Get hwclock Time with Changetime | n1 |
    ...    | Get hwclock Time with Changetime | n1 | 8h |
    ...    | Get hwclock Time with Changetime | n1 | 8 hours |
    ...    | Get hwclock Time with Changetime | n1 | 8d |
    ...    | Get hwclock Time with Changetime | n1 | 8 days |
    ...    | Get hwclock Time with Changetime | n1 | 3d8h2m5s |
    ...    | Get hwclock Time with Changetime | n1 | -3d8h2m5s |
    ${cmd_string}    set variable    hwclock
    ${res}    cli    ${device}    ${cmd_string}
    # modify by llin@20170904
    ${result}    Get Regexp Matches    ${res}    \\w{3}\\s*(\\w{3})\\s*(\\d+\\s*\\d+:\\d+:\\d+\\s*\\d{4})\\s+\\d+\\.\\d+\\sseconds    1    2
    # modify by llin@20170904
    ${result}    set variable    ${result[0]}
    ${Mon}    set variable    ${result[0]}
    ${result}    set variable    ${result[1]}
    &{Mon_Num}    create dictionary    Jan=01    Feb=02    Mar=03    Apr=04    May=05    Jun=06
    ...    Jul=07    Aug=08    Sep=09    Oct=10    Nov=11    Dec=12
    ${Date}    Catenate    SEPARATOR=${SPACE}     &{Mon_Num}[${Mon}]     ${result}
    ${NewDate}    add time to date    ${Date}    ${change_time}    result_format=%Y-%m-%d %H:%M:%S    date_format=%m %d %H:%M:%S %Y
    [Return]    ${NewDate}

Get System Clock Time with Changetime
    [Arguments]    ${device}    ${change_time}=0h
    [Documentation]    [Author:jbin] Description: Get system clock time with change time.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | change_time | the time need to change, default is 0h |
    ...
    ...    Example:
    ...    | Get System Clock Time with Changetime | n1 |
    ...    | Get System Clock Time with Changetime | n1 | 8h |
    ...    | Get System Clock Time with Changetime | n1 | 8 hours |
    ...    | Get System Clock Time with Changetime | n1 | 8d |
    ...    | Get System Clock Time with Changetime | n1 | 8 days |
    ...    | Get System Clock Time with Changetime | n1 | 3d8h2m5s |
    ...    | Get System Clock Time with Changetime | n1 | -3d8h2m5s |
    ${cmd_string}    set variable    show clock
    ${res}    cli    ${device}    ${cmd_string}
    ${result}    Get Regexp Matches    ${res}    (\\d{4}-\\d+-\\d+\\s\\d+:\\d+:\\d+)    1
    ${Date}    set variable    ${result[0]}
    ${NewDate}    add time to date    ${Date}    ${change_time}    result_format=%Y-%m-%d %H:%M:%S    date_format=%Y-%m-%d %H:%M:%S
    [Return]    ${NewDate}

Reload System
    [Arguments]    ${device}
    [Documentation]    [Author:jbin] Description: Reload the system and check it is ready or not.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ip | device ip address |
    ...
    ...    Example:
    ...    | Reload System | n1 | 10.192.110.101 |
    cli   ${device}    accept running-config
    ${res}    cli   ${device}    copy running-config startup-config    timeout=10
    should contain    ${res}    Copy completed
    reload    ${device}

Wait System Restart Ready
    [Arguments]    ${device}    ${ip}
    [Documentation]    [Author:jbin] Description: Wait System Restart Ready.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ip | device ip address |
    ...
    ...    Example:
    ...    | Wait System Restart Ready | n1 | 10.192.110.101 |
    Wait Until Keyword Succeeds    600    5    Run Keyword And Expect Error    *    ping    ${ip}
    Wait Until Keyword Succeeds    600    5    ping    ${ip}
    Wait Until Keyword Succeeds    3x    5s    cli    ${device}    sysadmin    \\#

Axos Cli With Error Check
    [Tags]    @author=dfarwell
    [Arguments]    ${DUT}    ${CMD}    ${TIMEOUT}=${devices.${DUT}.timeout}
    [Documentation]    Sends a CLI command to DUT and confirms response has no errors, if there is no prompt in your topo file this may need to be adjusted
    ...
    ...    *Args:*
    ...
    ...    *DUT* - Topo file equipment reference name
    ...
    ...    *CMD* - The ONT number
    ...
    ...    *TIMEOUT* - The wait in seconds for a timeout to occur. Default is 10.
    ...
    ...    _Example:_
    ...
    ...    | Axos Cli With Error Check | n1 | show version | 10 |
    ${res}    Cli    ${DUT}    ${CMD}    prompt=${devices.${DUT}.prompt}    timeout=${TIMEOUT}
    # Run Keyword And Continue On Failure    Result Should Not Contain    Invalid
    # Run Keyword And Continue On Failure    Result Should Not Contain    syntax error
    # Run Keyword And Continue On Failure    Result Should Not Contain    Aborted:
    # Run Keyword And Continue On Failure    Result Should Not Contain    Error:
    Should Not Contain Any    ${res}    Invalid    syntax error    Aborted:    Error:
    [Return]    ${res}
    

Verify OLT Image Version
    [Arguments]          ${device}
    [Documentation]      Verify OLT Image Version matches today's date
    [Tags]               @author=llim
    ${imagetime}    Cli    ${device}    show version
    ${imagedate}    Should Match Regexp    ${imagetime}    (\\d+)(\\.)(\\d+)(\\.)(\\d+)
    ${clocktime}    Cli    ${device}    show clock
    ${clockdate}    Should Match Regexp    ${clocktime}    (\\d+)(\\-)(\\d+)(\\-)(\\d+)
    Should Match    ${imagedate[1]}    ${clockdate[1]}
    Should Match    ${imagedate[3]}    ${clockdate[3]}
    Should Match    ${imagedate[5]}    ${clockdate[5]}

Verify Hardware Inventory
    [Arguments]          ${device}
    [Documentation]      Verify Hardware Inventory
    [Tags]               @author=llim
    Cli    ${device}    show inventory
    Result Should Contain    E7-2 NGPON2-4

Enable Ethernet Interface
     [Arguments]          ${device}    ${port}
     [Documentation]      Configure Ethernet Interface
     [Tags]               @author=llim
     Cli With Error Check    ${device}     configure
     Cli With Error Check    ${device}     interface ethernet ${port}
     Cli With Error Check    ${device}     no shutdown
     Cli With Error Check    ${device}     end

Enable Pon Interface
    [Arguments]          ${device}    ${port}
    [Documentation]      Enable Pon Interface
    [Tags]               @author=llim
    Cli With Error Check    ${device}     configure
    Cli With Error Check    ${device}     interface pon ${port}
    Cli With Error Check    ${device}     no shutdown
    Cli With Error Check    ${device}     end


Configure Ont Profile
    [Arguments]          ${device}    ${prof_id}    ${ont_port}
    [Documentation]      Configure Ont Profile
    [Tags]               @author=llim
    Cli With Error Check    ${device}     configure
    Cli With Error Check    ${device}     ont-profile ${prof_id}
    Cli With Error Check    ${device}     interface ont-ethernet ${ont_port}
    Cli With Error Check    ${device}     end

Configure Ont
    [Arguments]          ${device}    ${ont_num}    ${ont_desc}    ${prof_id}    ${serial_num}
    [Documentation]      Configure Ont
    [Tags]               @author=llim
    Cli With Error Check    ${device}     configure
    Cli With Error Check    ${device}     ont ${ont_num}
    Cli With Error Check    ${device}     description ${ont_desc}
    Cli With Error Check    ${device}     profile-id ${prof_id}
    Cli With Error Check    ${device}     serial-number ${serial_num}
    Cli With Error Check    ${device}     end

Verify Configured Ont
    [Arguments]          ${device}     ${ont_num}   ${prof_id}    ${serial_num}
    [Documentation]      Verify provisioned Ont port
    [Tags]               @author=llim
    ${ont_num_str}    Convert To String    ${ont_num}
    Wait Until Keyword Succeeds    30    5s    Is Ont Up    ${device}
    Cli With Error Check    ${device}     show running-config ont ${ont_num_str}
    Result Should Contain   ont ${ont_num_str}
    Result Should Contain   profile-id      ${prof_id}
    Result Should Contain   serial-number   ${serial_num}

Is Ont Up
    [Arguments]          ${device}
    [Documentation]      Check if provisioned Ont is up
    [Tags]               @author=llim
    Cli    ${device}     show discovered-ont
    Result Should Contain   VENDOR

Enable Session Notifications
    [Arguments]          ${device}
    [Documentation]      Enable Session Notifications
    [Tags]               @author=llim
    Cli With Error Check    ${device}     session notification set-category ALL

Clear Session Notifications
    [Arguments]          ${device}
    [Documentation]      Clear Session Notifications
    [Tags]               @author=llim
    Cli With Error Check    ${device}     session notification clear-category ALL

Verify Session Notifications
    [Arguments]          ${device}
    [Documentation]      Verify Session Notifications
    [Tags]               @author=llim
    Cli     ${device}     show session notifications
    Result Should Contain    no severity sessions
    #    Result Should Contain    no category sessions

Verify Ethernet Interface
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet Interface
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} status admin-state
    Result Should Contain    enable
    Wait Until Keyword Succeeds    30    5s    Is Ethernet Interface Up    ${device}    ${port}

Is Ethernet Interface Up
    [Arguments]    ${device}    ${port}
    [Documentation]    Check Ethernet Interface state
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} status oper-state
    Result Should Contain    up

Verify Pon Interface
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Pon Interface
    [Tags]    @author=llim
    cli    ${device}    show interface pon ${port} status admin-state
    Result Should Contain    enable
    Wait Until Keyword Succeeds    30    5s    Is Pon Interface Up    ${device}    ${port}

Is Pon Interface Up
    [Arguments]    ${device}    ${port}
    [Documentation]    Check Pon Interface state
    [Tags]    @author=llim
    Cli    ${device}    show interface pon ${port} status oper-state
    Result Should Contain    up

Clear Ethernet Interface Counters
    [Arguments]          ${device}      ${port}
    [Documentation]      Clear Ethernet Pon Interface Counters
    [Tags]               @author=llim
    Cli With Error Check    ${device}    clear interface ethernet ${port} counters

Clear Pon Interface Counters
    [Arguments]          ${device}      ${port}
    [Documentation]      Clear Pon Interface Counters
    [Tags]               @author=llim
    Cli With Error Check    ${device}    clear interface pon ${port} counters

Clear Ont Ethernet Interface Counters
    [Arguments]          ${device}      ${ont_num}    ${ont_port}
    [Documentation]      Clear Ont Ethernet Interface Counters
    [Tags]               @author=llim
    Wait Until Keyword Succeeds    60    5s    Is Ont Up    ${device}
    Cli    ${device}    clear interface ont-ethernet ${ont_num}/${ont_port} counters

Verify Startup Config Exist
    [Arguments]          ${device}
    [Documentation]      Verify that Startup-config exist
    [Tags]               @author=llim
    Cli With Error Check    ${device}    show file contents config | include startup-config.xml | exclude revert
    Result Should Contain    startup-config.xml

Verify file and expect value
    [Arguments]          ${device}  ${filetype}   ${filename}     ${value}
    [Documentation]      Verify that Startup-config exist
    [Tags]               @author=chxu
    Cli With Error Check    ${device}    show file contents ${filetype} filename ${filename} | include ${value}
    Result Should Contain    ${value}

Verify Running Config In Default Settings
    [Arguments]          ${device}
    [Documentation]      Verify platform is in default settings
    [Tags]               @author=llim
    Cli With Error Check    ${device}     show running-config |nomore
    Cli With Error Check    ${device}    show interface summary status interface oper-state
#    Result Should Contain    up
#    Cli With Error Check    ${device}    show interface pon status
#    Result Should Not Contain    up
    Cli With Error Check    ${device}    show running-config ont-profile
    Result Should Contain    811NG
    Cli With Error Check    ${device}    show running-config interface ont-ethernet
    Result Should Contain    No entries found.
    Cli With Error Check    ${device}    show running-config vlan
    Result Should Contain    vlan 999
#    Cli With Error Check    ${device}    show running-config policy-map
#    Result Should Contain    No entries found.
#    Cli With Error Check    ${device}    show running-config class-map
#    Result Should Contain    No entries found.
    Cli With Error Check    ${device}    show running-config ont
    Result Should Contain    No entries found.
    Cli With Error Check    ${device}    show running-config transport-service-profile
    Result Should Contain    vlan-list 999

Verify Running Config Is Provisioned
    [Arguments]          ${device}
    [Documentation]      Verify platform is provisioned for traffic
    [Tags]               @author=llim
    Cli With Error Check    ${device}    show interface summary status interface oper-state
    Result Should Contain    up
    Cli With Error Check    ${device}    show interface pon status
    Result Should Contain    up
    Cli With Error Check    ${device}    show running-config ont-profile
    Result Should Contain    811NG
    Cli With Error Check    ${device}    show running-config interface ont-ethernet
    Result Should Not Contain    No entries found.
    Cli With Error Check    ${device}    show running-config vlan
    Result Should Not Contain    No entries found.
    Cli With Error Check    ${device}    show running-config policy-map
    Result Should Not Contain    No entries found.
    Cli With Error Check    ${device}    show running-config class-map
    Result Should Not Contain    No entries found.
    Cli With Error Check    ${device}    show running-config ont
    Result Should Not Contain    No entries found.
#    Cli With Error Check    ${device}    show running-config transport-service-profile
#    Result Should Not Contain    vlan-list 999

Delete Startup Config
    [Arguments]          ${device}
    [Documentation]      Delete startup configuration
    [Tags]               @author=llim
    Cli With Error Check    ${device}    delete file config filename startup-config.xml
    Result Should Contain    OK

Reload System To Default Config
    [Arguments]    ${device}
    [Documentation]    Reload system to bring back to system default configuration
    [Tags]    @author=llim
    cli    ${device}    delete file config filename startup-config.xml
    reload    ${device}

Copy Running Config To Startup Config
    [Arguments]          ${device}
    [Documentation]      Copy running-config file to startup-config file
    [Tags]               @author=llim
    Cli With Error Check    ${device}     acc running-config
    Cli With Error Check    ${device}     copy running-config startup-config
    Result Should Contain    Copy completed.

Reload Platform Without Saving Config
    [Arguments]    ${device}
    [Documentation]    Reload platform without saving config
    [Tags]    @author=llim
    ${reload_str}    release_cmd_adapter    ${device}    ${prov_reload_cmd}
    cli    ${device}    reload ${reload_str}     prompt=Proceed with reload\\? \\[y/N\\]
    cli    ${device}    y    timeout=60
    Disconnect    ${device}
    sleep    30s    Wait for device disconnect

Wait For Platform To Return
    [Arguments]    ${device}
    [Documentation]    Waits for platform to return from a reload via serial console/ssh
    [Tags]    @author=llim
    Log    !!!!! If connected via serial console, log out within 90 seconds !!!!!
    Sleep    180    COMPLETED: Initial wait before checking for cli to return while connection is not available
    Wait Until Keyword Succeeds    10x    20 seconds    Verify Hardware Inventory    ${device}

Disable Ont Interface
    [Arguments]          ${device}     ${ont_num}     ${ont_port}
    [Documentation]      Disable Ont Interface
    [Tags]               @author=llim
    Cli    ${device}     configure
    Cli    ${device}     interface ont-ethernet ${ont_num}/${ont_port}
    Cli    ${device}     shutdown
    Cli    ${device}     end

Unconfigure Ont Profile
    [Arguments]          ${device}    ${prof_id}
    [Documentation]      Unconfigure Ont Profile
    [Tags]               @author=llim
    Cli With Error Check    ${device}     configure
    Cli With Error Check    ${device}     no ont-profile ${prof_id}
    Cli With Error Check    ${device}     end

Unconfigure Ont
    [Arguments]          ${device}     ${ont_num}     ${ont_desc}     ${prof_id}      ${serial_num}
    [Documentation]      Unconfigure Ont
    [Tags]               @author=llim
    Cli    ${device}     configure
    Cli    ${device}     no ont ${ont_num}
    Cli    ${device}     end

Disable Ethernet Interface
    [Arguments]          ${device}     ${port}
    [Documentation]      Disable Ethernet Interface
    [Tags]               @author=llim
    Cli With Error Check    ${device}     configure
    Cli With Error Check    ${device}     interface ethernet ${port}
    Cli With Error Check    ${device}     shutdown
    Cli With Error Check    ${device}     end

Disable Pon Interface
    [Arguments]          ${device}     ${port}
    [Documentation]      Disable Pon Interface
    [Tags]               @author=llim
    Cli With Error Check    ${device}     configure
    Cli With Error Check    ${device}     interface pon ${port}
    Cli With Error Check    ${device}     shutdown
    Cli With Error Check    ${device}     end

Clear Event Log
    [Arguments]          ${device}
    [Documentation]      Clear Event Log
    [Tags]               @author=llim
    Cli With Error Check    ${device}      clear active event-log

Cli With Error Check
    [Arguments]    ${device}    ${cli}
    [Documentation]    Sends a CLI command to DUT & confirms response has no errors
    [Tags]    @author=llim
    Cli    ${device}    ${cli}
    Run Keyword And Continue On Failure    Result Should Not Contain    Invalid
    Run Keyword And Continue On Failure    Result Should Not Contain    syntax error
    Run Keyword And Continue On Failure    Result Should Not Contain    Aborted:
    Run Keyword And Continue On Failure    Result Should Not Contain    Error:

Check Response Params
    [Arguments]    ${device}   ${command}    @{parameters}
    [Documentation]    Verify cli output parameters
    ...    Example:
    ...   |     Check Response Params  eutA     show interface ethernet 1/1/x1 counters       counters   interface-counters   pkts-256to511
    ...   |     Check Response Params  eutA     show interface pon 1/1/xp1 counters interface-counters rx-pkts    counters   interface-counters    rx-pkts
    ...   |     Check Response Params  eutA     show interface pon 1/1/xp1 counters     counters   interface-counters   rx-octets
    [Tags]    @author=chxu
    ${output}    cli   ${device}   ${command}
    ${res}    Build Response Map    ${output}
    ${resp}    Parse Nested Text    ${res}
    ${result}    Get Value From Nested Text    ${resp}    @{parameters}
    [Return]    ${result}

Application Restart Check
    [Arguments]    ${device}
    ${output}=    Check Response Params   ${device}    show event subscope category ARC      total-count
#    ${output}=    Check Response Params   ${device}    show alarm active subscope name temperature-tca      total-count
    Run Keyword If  ${output}!=0    Log  Warning:Application Restart!\n${output}  WARN
    ${output}=    cli   ${device}    show file contents core

#Reload The System using netconf
#    [Arguments]    ${device}      ${cli_session}
#    [Documentation]    Performs a system reload and confirms reload occurs.
#    [Tags]    @author=ssekar
#
#    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
#    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
#    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><reload xmlns="http://www.calix.com/ns/exa/base"></reload></rpc>]]>]]>
#    #Sleep for 250s until DUT comes UP
#    Log      The system is going down for reboot NOW!
#    Sleep    250
#    Run Keyword If     '${linux}' != 'None'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${linux}
#    #Sleep for 5s
#    Sleep     5
