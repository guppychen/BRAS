*** Settings ***
Documentation     PM test_suite keyword lib

*** Keywords ***

Verify Ethernet PM Session All MI Values
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM session of all supported MI is created
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    start-time
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration five-minutes bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    start-time
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    start-time
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-hour bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    start-time
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-day bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    start-time
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration infinite bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    start-time

Disable Ethernet PM Session Minimum One hour
    [Arguments]    ${device}    ${port}
    [Documentation]    Disable Ethernet PM Session Minimum One hour
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    no rmon-session one-minute 60    timeout=10    timeout_exception=0    prompt=\\#
    cli    ${device}    no rmon-session five-minutes 12    timeout=10    timeout_exception=0    prompt=\\#
    cli    ${device}    no rmon-session fifteen-minutes 4
    cli    ${device}    no rmon-session one-hour 1
    cli    ${device}    no rmon-session one-day 1
    cli    ${device}    no rmon-session infinite 1
    cli    ${device}    end

Bin Wait Time
    [Arguments]    ${bin_time}
    [Documentation]    Wait time for bin to complete
    [Tags]    @author=llim
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}

Verify Current Ethernet Performance Monitoring Bin
    [Arguments]    ${device}    ${port}    ${session_number}
    [Documentation]    Verify Current Ethernet Performance Monitoring session
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number ${session_number}

Verify Not Synced TOD Common Bin Attribites
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Common attributes specific to the bins are present
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    start-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect TRUE
    Result Should Contain    cause PM Bin is partial
    Result Should Contain    is-current TRUE
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect TRUE
    Result Should Contain    cause PM Bin is partial
    Result Should Contain    is-current FALSE
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    start-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current TRUE
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed ${wait_time} Secs
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current FALSE

Verify Monitored entity
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify all entities needs to be monitored in the bins
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    drop-events
    Result Should Contain    octets
    Result Should Contain    pkts
    Result Should Contain    broadcast-pkts
    Result Should Contain    multicast-pkts
    Result Should Contain    crc-align-errors
    Result Should Contain    undersize-pkts
    Result Should Contain    oversize-pkts
    Result Should Contain    fragments
    Result Should Contain    pkts-64
    Result Should Contain    pkts-65to127
    Result Should Contain    pkts-128to255
    Result Should Contain    pkts-256to511
    Result Should Contain    pkts-512to1023
    Result Should Contain    pkts-1024to1518
    Result Should Contain    pkts-1024to1518
    Result Should Contain    pkts-1519to2047
    Result Should Contain    pkts-2048to4095
    Result Should Contain    pkts-4096to9216
    Result Should Contain    pkts-9217to16383
    Result Should Contain    rx-pkts
    Result Should Contain    rx-octets
    Result Should Contain    rx-unicast-pkts
    Result Should Contain    rx-multicast-pkts
    Result Should Contain    rx-broadcast-pkts
    Result Should Contain    rx-discards
    Result Should Contain    rx-pause-frames
    Result Should Contain    rx-errors
    Result Should Contain    rx-unknown-protos
    Result Should Contain    tx-pkts
    Result Should Contain    tx-octets
    Result Should Contain    tx-unicast-pkts
    Result Should Contain    tx-multicast-pkts
    Result Should Contain    tx-broadcast-pkts
    Result Should Contain    tx-discards
    Result Should Contain    tx-pause-frames
    Result Should Contain    tx-errors
    Result Should Contain    align-errors
    Result Should Contain    fcs-errors
    Result Should Contain    jabbers
    Result Should Contain    rx-utilization
    Result Should Contain    rx-utilization-max
    Result Should Contain    rx-utilization-min
    Result Should Contain    rx-utilization-avg
    Result Should Contain    tx-utilization
    Result Should Contain    tx-utilization-max
    Result Should Contain    tx-utilization-min
    Result Should Contain    tx-utilization-avg

Verify Synced TOD Common Bin Attribites
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Common attributes specific to the bins are present
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    start-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current TRUE
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current FALSE
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    start-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current TRUE
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed ${wait_time} Secs
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current FALSE

Verify Second Performance Monitoring Bin
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Second Ethernet Performance Monitoring session
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0   
    Result Should Contain    is-current TRUE
    Result Should Contain    number 1

Verify Next Performance Monitoring Bin
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Next Performance Monitoring session
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 1

Verify Performance Monitoring Bin Exists
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM bin exists
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 2

Verify Historical Performance Monitoring Session
    [Arguments]    ${device}    ${port}    ${session_number}
    [Documentation]    Verify Historical Performance Monitoring session
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back ${session_number}
    Result Should Contain    number 0
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    is-current FALSE

Verify First Historical PM bin
    [Arguments]    ${device}    ${port}    ${session_number}
    [Documentation]    Verify First Historical PM bin
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back ${session_number}
    Result Should Contain    number 1

Verify Maximum Bins
    [Arguments]    ${device}    ${port}    ${session_number}
    [Documentation]    Verify maximum bins accomodated
    [Tags]    @author=llim
    ${pushed_bin}    Evaluate    ${session_number} + 1
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back ${pushed_bin}
    Result Should Contain    Command Rejected
    Result Should Not Contain    number 0

Start Traffic Stream
    [Arguments]    ${stc_device_ip}
    [Documentation]    Start Traffic For PM Session
    [Tags]    @author=llim
    Tg Load Config File    ${stc_device_ip}    ${stc_filepath}
    Tg Start All Traffic    ${stc_device_ip}

Verify Ethernet PM Session Counters One Minute
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet PM Session counters
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s58\\d{4}|pkts-512to1023\\s59\\d{4}|pkts-512to1023\\s60\\d{4}

Verify Ethernet PM Session Counters Five Minutes
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet PM Session counters
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s29\\d{5}|pkts-512to1023\\s30\\d{5}

Verify Ethernet PM Session Counters Fifteen Minutes
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet PM Session counters
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s89\\d{5}|pkts-512to1023\\s90\\d{5}

Verify Ethernet PM Session Counters One Hour
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet PM Session counters for one hour
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s35\\d{6}|pkts-512to1023\\s36\\d{6}

Verify Ethernet PM Session Counters One Day
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Ethernet PM Session counters for one hour
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s86\\d{7}|pkts-512to1023\\s85\\d{7}

Configure Users
    [Arguments]    ${device}
    [Documentation]    Configure Authorized User
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    aaa user authorizeduser password authorized role admin
    cli    ${device}    aaa user unauthorizeduser password unauthorized role oper
    cli    ${device}    end

Clear Current Bin Authorized User
    [Arguments]    ${device}    ${port}
    [Documentation]    Clear current bin and verify it got cleared
    [Tags]    @author=llim
    cli    ${device}    session notification set-category GENERAL severity WARNING
    sleep    120
    cli    ${device}    clear interface ethernet ${port} performance-monitoring rmon-session bin-or-interval bin bin-duration ${bin_duration} all-or-current current 
    Result Should Contain    ethernet-rmon-pmdata-cleared
    Result Should Contain    GENERAL EVENT
    cli    ${device}    show event log category GENERAL start-value 1 end-value 1
    Result Should Contain    name ethernet-rmon-pmdata-cleared
    Result Should Contain    category GENERAL
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    cause User cleared pm bins
    Result Should Contain    suspect TRUE
    ${match}    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    ${match11}    Should Match Regexp    ${match}    (time-elapsed)(\\s)(\\d+)
    ${match12}    Evaluate    300 - ${match11[3]}
    ${match21}    Evaluate    ${match12} + 1
    ${match31}    Evaluate    ${match12} - 1
    sleep    180
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s15\\d{5}|pkts-512to1023\\s16\\d{5}|pkts-512to1023\\s17\\d{5}

Clear All Bin Authorized User
    [Arguments]    ${device}    ${port}
    [Documentation]    Clear all bin and verify it got cleared
    [Tags]    @author=llim
    cli    ${device}    session notification set-category GENERAL severity WARNING
    sleep    120
    cli    ${device}    clear interface ethernet ${port} performance-monitoring rmon-session bin-or-interval bin bin-duration ${bin_duration} all-or-current all
    Result Should Contain    ethernet-rmon-pmdata-cleared
    Result Should Contain    GENERAL EVENT
    cli    ${device}    show event log category GENERAL start-value 1 end-value 1
    Result Should Contain    name ethernet-rmon-pmdata-cleared
    Result Should Contain    category GENERAL
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    cause User cleared pm bins
    Result Should Contain    suspect TRUE
    ${match}    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    ${match11}    Should Match Regexp    ${match}    (time-elapsed)(\\s)(\\d+)
    ${match12}    Evaluate    300 - ${match11[3]}
    ${match21}    Evaluate    ${match12} + 1
    ${match31}    Evaluate    ${match12} - 1
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    cause User cleared pm bins
    Result Should Contain    suspect TRUE
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 2
    Result Should Contain    cause User cleared pm bins
    Result Should Contain    suspect TRUE
    sleep    180
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s15\\d{5}|pkts-512to1023\\s16\\d{5}|pkts-512to1023\\s17\\d{5}

Clear Ethernet Interface Counters Authorized User
    [Arguments]    ${device}    ${port}
    [Documentation]    Clear interface counters and verify the PM bin counters resets to zero and starts counting again
    [Tags]    @author=llim
    cli    ${device}    session notification set-category GENERAL severity WARNING
    cli    ${device}    session notification set-category DBCHANGE severity WARNING
    sleep    110
    cli    ${device}    clear interface ethernet ${port} counters
    sleep    10
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    cause User reset hardware counters
    Result Should Contain    suspect TRUE
    sleep    180
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s29\\d{5}|pkts-512to1023\\s30\\d{5}

Clear Bin Unauthorized User
    [Arguments]    ${device}    ${port}
    [Documentation]    Clear bins with user who doesnt have appropriate role to clear
    [Tags]    @author=llim
    cli    ${device}    clear interface ethernet ${port} performance-monitoring rmon-session bin-or-interval bin bin-duration ${bin_duration} all-or-current all
    Result Should Contain    syntax error
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Not Contain    cause User cleared pm bins
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Not Contain    cause User cleared pm bins

Disable Bin Unauthorized User
    [Arguments]    ${device}    ${port}
    [Documentation]    Disabling bins with users does not have valid role is not permitted
    [Tags]    @author=llim
    cli    ${device}    configure
    Result Should Contain    syntax error
    cli    ${device}    end
    cli    ${device}    interface ethernet ${port}
    Result Should Contain    syntax error
    cli    ${device}    end
    cli    ${device}    no rmon-session ${bin_duration} ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} admin-state disable
    Result Should Contain    syntax error
    cli    ${device}    end

Disable Bin Authorized User
    [Arguments]    ${device}    ${port}
    [Documentation]    Disable Ethernet PM bin and verify it got disabled
    [Tags]    @author=llim
    cli    ${device}    session notification set-category GENERAL severity WARNING
    cli    ${device}    session notification set-category DBCHANGE severity WARNING
    sleep    120
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session ${bin_duration} ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} admin-state disable
    Result Should Contain    DBCHANGE EVENT
    Result Should Contain    db-change
    cli    ${device}    end
    cli    ${device}    show event log category DBCHANGE start-value 1 end-value 1
    Result Should Contain    category DBCHANGE
    Result Should Contain    name db-change
    Result Should Contain    session-login authorizeduser
    sleep    10
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    User disabled the pm session
    ${output1}    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    ${match1}    Should Match Regexp    ${output1}    pkts-512to1023\\s\\d+
    sleep    110
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    ${match1}
    sleep    60
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session ${bin_duration} ${historical_bin} gos-profile-name ${profile_name} session-name ${session_name} admin-state enable
    Result Should Contain    DBCHANGE EVENT
    Result Should Contain    db-change
    cli    ${device}    end
    cli    ${device}    show event log category DBCHANGE start-value 1 end-value 1
    Result Should Contain    category DBCHANGE
    Result Should Contain    name db-change
    Result Should Contain    session-login authorizeduser
    sleep    300
    ${match}    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    ${match11}    Should Match Regexp    ${match}    (time-elapsed)(\\s)(\\d+)
    ${match21}    Evaluate    ${match11[3]} + 1
    ${match31}    Evaluate    ${match11[3]} - 1
    ${match41}    Evaluate    ${match11[3]} - 2
    Result Match Regexp    pkts-512to1023\\s${match11[3]}\\d{4}|pkts-512to1023\\s${match21}\\d{4}|pkts-512to1023\\s${match31}\\d{4}|pkts-512to1023\\s${match41}\\d{4}

Check Time Of Day
    [Arguments]    ${device}
    [Documentation]    Check Time Of Day
    [Tags]    @author=llim
    ${time}    cli    ${device}    show clock
    ${time1}    Should Match Regexp    ${time}    (\\d+)(\\:)(\\d)(\\d)(\\:)(\\d)(\\d)
    ${time21}    Should Match Regexp    ${time1[6]}    \\d
    ${time22}    Should Match Regexp    ${time1[7]}    \\d
    ${time2}    Evaluate    (${time21} * 10) + ${time22}
    ${time31}    Should Match Regexp    ${time1[3]}    \\d
    ${time32}    Should Match Regexp    ${time1[4]}    \\d
    ${time3}    Evaluate    (${time31} * 10) + ${time32}
    ${bintime1}    Evaluate    ${bin_time} - 1
    ${wait1}    Evaluate    (${bintime1} - ${time3} % ${bin_time}) * 60
    ${wait}    Evaluate    60 - ${time2}
    ${totalwait}    Evaluate    ${wait} + ${wait1}
    sleep    ${totalwait}
    
Not Sync TOD
    [Arguments]    ${device}
    [Documentation]    Enable Ethernet PM session at time not synced to Time of Day
    [Tags]    @author=llim
    ${time}    cli    ${device}    show clock
    ${time1}    Should Match Regexp    ${time}    (\\d+)(\\:)(\\d)(\\d)(\\:)(\\d)(\\d)
    ${time21}    Should Match Regexp    ${time1[6]}    \\d
    ${time22}    Should Match Regexp    ${time1[7]}    \\d
    ${time2}    Evaluate    (${time21} * 10) + ${time22}
    ${time31}    Should Match Regexp    ${time1[3]}    \\d
    ${time32}    Should Match Regexp    ${time1[4]}    \\d
    ${time3}    Evaluate    (${time31} * 10) + ${time32}
    ${bintime1}    Evaluate    ${bin_time} - 1
    ${wait1}    Evaluate    (${bintime1} - ${time3} % ${bin_time}) * 60
    ${wait}    Evaluate    59 - ${time2}
    ${totalwait}    Evaluate    ${wait} + ${wait1} + 5
    sleep    ${totalwait}

Verify Partial Bin MI value
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify MI value of first partial bin is remaining time till start of next bin which is locked to time of day
    [Tags]    @author=llim
    ${time}    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    ${time1}    Should Match Regexp    ${time}    (\\d+)(\\:)(\\d)(\\d)(\\:)(\\d)(\\d)
    ${time21}    Should Match Regexp    ${time1[6]}    \\d
    ${time22}    Should Match Regexp    ${time1[7]}    \\d
    ${time2}    Evaluate    (${time21} * 10) + ${time22}
    ${time31}    Should Match Regexp    ${time1[3]}    \\d
    ${time32}    Should Match Regexp    ${time1[4]}    \\d
    ${time3}    Evaluate    (${time31} * 10) + ${time32}
    ${bintime1}    Evaluate    ${bin_time} - 1
    ${wait1}    Evaluate    (${bintime1} - ${time3} % ${bin_time}) * 60
    ${wait}    Evaluate    60 - ${time2}
    ${totalwait}    Evaluate    ${wait} + ${wait1}
    ${totalwait1}    Evaluate    ${totalwait} + 1
    ${totalwait2}    Evaluate    ${totalwait} - 1
    sleep    ${totalwait}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Match Regexp    time-elapsed ${totalwait2} Secs|time-elapsed ${totalwait} Secs|time-elapsed ${totalwait1} Secs
    Result Should Contain    suspect TRUE
    Result Should Contain    cause PM Bin is partial
    Result Should Contain    is-current FALSE
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed ${wait_time} Secs
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current FALSE

Verify One Day Bin Partial
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify MI value of one day first partial bin is remaining time till start of next bin which is locked to time of day
    [Tags]    @author=llim
    ${time}    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    ${time1}    Should Match Regexp    ${time}    (\\d+)(\\:)(\\d)(\\d)(\\:)(\\d)(\\d)
    ${time21}    Should Match Regexp    ${time1[6]}    \\d
    ${time22}    Should Match Regexp    ${time1[7]}    \\d
    ${time2}    Evaluate    (${time21} * 10) + ${time22}
    ${time31}    Should Match Regexp    ${time1[3]}    \\d
    ${time32}    Should Match Regexp    ${time1[4]}    \\d
    ${time3}    Evaluate    (${time31} * 10) + ${time32}
    ${time4}    Should Match Regexp    ${time1[1]}    \\d\\d
    ${wait1}    Evaluate    (59 - ${time3}) * 60
    ${wait}    Evaluate    60 - ${time2}
    ${wait2}    Evaluate    (23 - ${time4}) * 3600
    ${totalwait}    Evaluate    ${wait} + ${wait1} + ${wait2}
    ${totalwait1}    Evaluate    ${totalwait} + 1
    ${totalwait2}    Evaluate    ${totalwait} - 1
    sleep    ${totalwait}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Match Regexp    time-elapsed ${totalwait2} Secs|time-elapsed ${totalwait} Secs|time-elapsed ${totalwait1} Secs
    Result Should Contain    suspect TRUE
    Result Should Contain    cause PM Bin is partial
    Result Should Contain    is-current FALSE
    sleep    86400
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s86\\d{7}|pkts-512to1023\\s85\\d{7}
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed 86400 Secs
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Should Contain    is-current FALSE

Verify Infinite Bin
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM session with infinite MI value maintains single bin which is not cleared/disabled till user clears/disables bin
    [Tags]    @author=llim
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    sleep    18000
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    Result Should Contain    suspect FALSE
    Result Should Contain    cause None
    Result Match Regexp    pkts-512to1023\\s17\\d{7}|pkts-512to1023\\s18\\d{7}
    cli    ${device}    clear interface ethernet ${port} performance-monitoring rmon-session bin-or-interval bin bin-duration ${bin_duration} all-or-current current
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    cause User cleared pm bins
    Result Should Contain    suspect TRUE
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    sleep    10
    cli    ${device}    clear interface ethernet ${port} counters
    sleep    10
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    cause User reset hardware counters
    Result Should Contain    suspect TRUE
    sleep    10
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session ${bin_duration} ${historical_bin} admin-state disable
    cli    ${device}    end
    sleep    10
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    User disabled the pm session
    Result Should Contain    suspect TRUE
    Result Should Contain    is-current TRUE
    Result Should Contain    number 0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    Command Rejected
    Result Should Contain    num-back 1 is greater than maximum of 0 historical bins available for this session

Verify Ethernet PM Session Minimum One hour Historical Bin
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify all created PM session shows the historical bin data of atleast one hour
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session one-minute 60 gos-profile-name ethernet session-name ethernet-10G
    cli    ${device}    rmon-session five-minutes 12 gos-profile-name ethernet session-name ethernet-10G
    cli    ${device}    rmon-session fifteen-minutes 4 gos-profile-name ethernet session-name ethernet-10G
    cli    ${device}    rmon-session one-hour 1 gos-profile-name ethernet session-name ethernet-10G
    cli    ${device}    rmon-session one-day 1 gos-profile-name ethernet session-name ethernet-10G
    cli    ${device}    rmon-session infinite 1 gos-profile-name ethernet session-name ethernet-10G
    cli    ${device}    end
    sleep    3600 
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 60
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 59
    Result Should Contain    number 1
    Result Should Contain    time-elapsed 60 Secs
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s58\\d{4}|pkts-512to1023\\s59\\d{4}|pkts-512to1023\\s60\\d{4}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration five-minutes bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 12
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration five-minutes bin-or-interval bin num-show 1 num-back 11
    Result Should Contain    number 1
    Result Should Contain    time-elapsed 300 Secs
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration five-minutes bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s29\\d{5}|pkts-512to1023\\s30\\d{5}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 4
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 3
    Result Should Contain    number 1
    Result Should Contain    time-elapsed 900 Secs
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s89\\d{5}|pkts-512to1023\\s90\\d{5}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-hour bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 1
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-hour bin-or-interval bin num-show 1 num-back 2
    Result Should Contain    Command Rejected
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-day bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 0
    Result Match Regexp    time-elapsed\\s36\\d\\d\\sSecs
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration infinite bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 0
    Result Match Regexp    time-elapsed\\s36\\d\\d\\sSecs

Verify First Historical PM bin One Five Fifteen Minutes
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify First Historical PM bin for one five fifteen minutes respectively
    [Tags]    @author=llim
    sleep     60
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 59
    Result Should Not Contain    number 0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 60
    Result Should Not Contain    number 0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 61
    Result Should Not Contain    number 0
    sleep     240
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration five-minutes bin-or-interval bin num-show 1 num-back 11
    Result Should Not Contain    number 0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration five-minutes bin-or-interval bin num-show 1 num-back 12
    Result Should Not Contain    number 0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration five-minutes bin-or-interval bin num-show 1 num-back 13
    Result Should Not Contain    number 0
    sleep     600
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 3
    Result Should Not Contain    number 0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 4
    Result Should Not Contain    number 0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 5
    Result Should Not Contain    number 0

Verify Ethernet PM Session Less Than One Hour Historical Bin
    [Arguments]    ${device}    ${port}
    [Documentation]    Configure PM sessions with less than one hour historical bins for all supported MI and verify sessions are not created
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    rmon-session one-minute 59
    Result Should Contain    Command Rejected. Invalid number of bins.    Minimum value needed for the specified bin_duration is 60
    cli    ${device}    no rmon-session one-minute 59
    Result Should Contain    Error: element not found
    cli    ${device}    rmon-session one-minute 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    no rmon-session one-minute 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    rmon-session one-minute 10
    Result Should Contain    Command Rejected. Invalid number of bins.    Minimum value needed for the specified bin_duration is 60
    cli    ${device}    no rmon-session one-minute 10
    Result Should Contain    Error: element not found
    cli    ${device}    rmon-session one-minute 1441
    Result Should Contain    syntax error: "1441" is out of range
    cli    ${device}    rmon-session five-minutes 11
    Result Should Contain    Command Rejected. Invalid number of bins.    Minimum value needed for the specified bin_duration is 12
    cli    ${device}    no rmon-session five-minutes 11
    Result Should Contain    Error: element not found
    cli    ${device}    rmon-session five-minutes 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    no rmon-session five-minutes 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    rmon-session five-minutes 1441
    Result Should Contain    syntax error: "1441" is out of range
    cli    ${device}    no rmon-session five-minutes 1441
    Result Should Contain    syntax error: "1441" is out of range.
    cli    ${device}    rmon-session fifteen-minutes 3
    Result Should Contain    Command Rejected. Invalid number of bins.    Minimum value needed for the specified bin_duration is 4
    cli    ${device}    rmon-session fifteen-minutes 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    rmon-session fifteen-minutes 1441
    Result Should Contain    syntax error: "1441" is out of range.
    cli    ${device}    rmon-session one-hour 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    rmon-session one-hour 1441
    Result Should Contain    syntax error: "1441" is out of range.
    cli    ${device}    rmon-session one-day 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    rmon-session one-day 1441
    Result Should Contain    syntax error: "1441" is out of range.
    cli    ${device}    rmon-session infinite 2
    Result Should Contain    Command Rejected. Invalid number of bins specified.    Acceptable value is 1
    cli    ${device}    rmon-session infinite 0
    Result Should Contain    syntax error: "0" is out of range
    cli    ${device}    rmon-session infinite 1441
    Result Should Contain    syntax error: "1441" is out of range.
    cli    ${device}    end

Verify Ether Stats Data RFC 2819 RMON MIB
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM session etherStats data defined in RFC 2819 RMON MIB and Utilization Statistics of bins are collected
    [Tags]    @author=llim
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s29\\d{7}|pkts\\s30\\d{7}
    Result Match Regexp    octets\\s1\\d{11}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    crc-align-errors\\s29\\d{6}|crc-align-errors\\s30\\d{6}
    Result Match Regexp    undersize-pkts\\s29\\d{6}|undersize-pkts\\s30\\d{6}
    Result Match Regexp    oversize-pkts\\s29\\d{6}|oversize-pkts\\s30\\d{6}
    Result Match Regexp    fragments\\s29\\d{6}|fragments\\s30\\d{6}
    Result Match Regexp    pkts-64\\s29\\d{6}|pkts-64\\s30\\d{6}
    Result Match Regexp    pkts-65to127\\s29\\d{6}|pkts-65to127\\s30\\d{6}
    Result Match Regexp    pkts-128to255\\s29\\d{6}|pkts-128to255\\s30\\d{6}
    Result Match Regexp    pkts-256to511\\s29\\d{6}|pkts-256to511\\s30\\d{6}
    Result Match Regexp    pkts-512to1023\\s29\\d{6}|pkts-512to1023\\s30\\d{6}
    Result Match Regexp    pkts-1024to1518\\s29\\d{6}|pkts-1024to1518\\s30\\d{6}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    fcs-errors\\s29\\d{6}|fcs-errors\\s30\\d{6}
    Result Match Regexp    jabbers\\s29\\d{6}|jabbers\\s30\\d{6}
    Result Match Regexp    rx-pkts\\s2\\d{8}
    Result Match Regexp    rx-octets\\s1\\d{11}
    Result Match Regexp    rx-utilization\\s4\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s4\\d{1}
    Result Match Regexp    rx-utilization-max\\s4\\d{1}
    Result Match Regexp    etherStatsHighCapacityOverflowPkts
    Result Match Regexp    etherStatsHighCapacityOverflowOctets
    Result Match Regexp    etherStatsHighCapacityOverflowPkts64Octets
    Result Match Regexp    etherStatsHighCapacityOverflowPkts65to127Octets
    Result Match Regexp    etherStatsHighCapacityOverflowPkts128to255Octets
    Result Match Regexp    etherStatsHighCapacityOverflowPkts256to511Octets
    Result Match Regexp    etherStatsHighCapacityOverflowPkts512to1023Octets
    Result Match Regexp    etherStatsCollisions
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s29\\d{7}|pkts\\s30\\d{7}
    Result Match Regexp    octets\\s1\\d{11}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    crc-align-errors\\s29\\d{6}|crc-align-errors\\s30\\d{6}
    Result Match Regexp    undersize-pkts\\s29\\d{6}|undersize-pkts\\s30\\d{6}
    Result Match Regexp    oversize-pkts\\s29\\d{6}|oversize-pkts\\s30\\d{6}
    Result Match Regexp    fragments\\s29\\d{6}|fragments\\s30\\d{6}
    Result Match Regexp    pkts-64\\s29\\d{6}|pkts-64\\s30\\d{6}
    Result Match Regexp    pkts-65to127\\s29\\d{6}|pkts-65to127\\s30\\d{6}
    Result Match Regexp    pkts-128to255\\s29\\d{6}|pkts-128to255\\s30\\d{6}
    Result Match Regexp    pkts-256to511\\s29\\d{6}|pkts-256to511\\s30\\d{6}
    Result Match Regexp    pkts-512to1023\\s29\\d{6}|pkts-512to1023\\s30\\d{6}
    Result Match Regexp    pkts-1024to1518\\s29\\d{6}|pkts-1024to1518\\s30\\d{6}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    fcs-errors\\s29\\d{6}|fcs-errors\\s30\\d{6}
    Result Match Regexp    jabbers\\s29\\d{6}|jabbers\\s30\\d{6}
    Result Match Regexp    rx-pkts\\s2\\d{8}
    Result Match Regexp    rx-octets\\s1\\d{11}
    Result Match Regexp    rx-utilization\\s4\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s4\\d{1}
    Result Match Regexp    rx-utilization-max\\s4\\d{1}

Verify Media Independent Data RFC 3273 RMON MIB
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM session Media Independent Table data defined in RFC 3273 RMON MIB and its Utilization Statistics of bins are collected
    [Tags]    @author=llim
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    no shutdown
    cli    ${device}    duplex full
    cli    ${device}    end
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s1\\d{8}
    Result Match Regexp    octets\\s2\\d{10}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    crc-align-errors\\s29\\d{6}|crc-align-errors\\s30\\d{6}
    Result Match Regexp    pkts-65to127\\s29\\d{6}|pkts-65to127\\s30\\d{6}
    Result Match Regexp    pkts-128to255\\s29\\d{6}|pkts-128to255\\s30\\d{6}
    Result Match Regexp    pkts-256to511\\s29\\d{6}|pkts-256to511\\s30\\d{6}
    Result Match Regexp    pkts-512to1023\\s\\d{8}
    Result Match Regexp    rx-pkts\\s1\\d{8}
    Result Match Regexp    rx-octets\\s2\\d{10}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    fcs-errors\\s29\\d{6}|fcs-errors\\s30\\d{6}
    Result Match Regexp    rx-errors\\s29\\d{6}|rx-errors\\s30\\d{6}
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}
    Result Match Regexp    mediaIndependentIndex
    Result Match Regexp    mediaIndependentDataSource
    Result Match Regexp    mediaIndependentOutHighCapacityPkts
    Result Match Regexp    mediaIndependentInOverflowOctets
    Result Match Regexp    mediaIndependentInNUCastOverflowPkts
    Result Match Regexp    mediaIndependentOutNUCastOverflowPkts
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s1\\d{8}
    Result Match Regexp    octets\\s2\\d{10}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    crc-align-errors\\s29\\d{6}|crc-align-errors\\s30\\d{6}
    Result Match Regexp    pkts-65to127\\s29\\d{6}|pkts-65to127\\s30\\d{6}
    Result Match Regexp    pkts-128to255\\s29\\d{6}|pkts-128to255\\s30\\d{6}
    Result Match Regexp    pkts-256to511\\s29\\d{6}|pkts-256to511\\s30\\d{6}
    Result Match Regexp    pkts-512to1023\\s\\d{8}
    Result Match Regexp    rx-pkts\\s1\\d{8}
    Result Match Regexp    rx-octets\\s2\\d{10}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    fcs-errors\\s29\\d{6}|fcs-errors\\s30\\d{6}
    Result Match Regexp    rx-errors\\s29\\d{6}|rx-errors\\s30\\d{6}
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}

Verify Entry Statistics Data MEF 40 MIB
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM session Entry Statistics data defined in MEF 40 MIB for High Capacity Packet and its Utilization Statistics of bins are collected
    [Tags]    @author=llim
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s29\\d{7}|pkts\\s30\\d{7}
    Result Match Regexp    octets\\s15\\d{10}|octets\\s16\\d{10}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    crc-align-errors\\s29\\d{6}|crc-align-errors\\s30\\d{6}
    Result Match Regexp    undersize-pkts\\s29\\d{6}|undersize-pkts\\s30\\d{6}
    Result Match Regexp    oversize-pkts\\s29\\d{6}|oversize-pkts\\s30\\d{6}
    Result Match Regexp    fragments\\s29\\d{6}|fragments\\s30\\d{6}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    fcs-errors\\s29\\d{6}|fcs-errors\\s30\\d{6}
    Result Match Regexp    tx-pkts\\s\\d{7}
    Result Match Regexp    tx-octets\\s\\d{10}
    Result Match Regexp    tx-unicast-pkts\\s\\d{7}
    Result Match Regexp    tx-multicast-pkts\\s\\d{2}
    Result Match Regexp    tx-broadcast-pkts\\s\\d{1}
    Result Match Regexp    rx-pkts\\s2\\d{8}
    Result Match Regexp    rx-octets\\s1\\d{11}
    Result Match Regexp    rx-utilization\\s4\\d{1}
    Result Match Regexp    rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s4\\d{1}
    Result Match Regexp    tx-utilization-max\\s\\d{1}
    Result Match Regexp    tx-utilization\\s\\d{1}
    Result Match Regexp    tx-utilization-min\\s\\d{1}
    Result Match Regexp    mefServiceInterfaceStatisticsIngressInvalidVid
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s29\\d{7}|pkts\\s30\\d{7}
    Result Match Regexp    octets\\s15\\d{10}|octets\\s16\\d{10}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    crc-align-errors\\s29\\d{6}|crc-align-errors\\s30\\d{6}
    Result Match Regexp    undersize-pkts\\s29\\d{6}|undersize-pkts\\s30\\d{6}
    Result Match Regexp    oversize-pkts\\s29\\d{6}|oversize-pkts\\s30\\d{6}
    Result Match Regexp    fragments\\s29\\d{6}|fragments\\s30\\d{6}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    fcs-errors\\s29\\d{6}|fcs-errors\\s30\\d{6}
    Result Match Regexp    tx-pkts\\s\\d{7}
    Result Match Regexp    tx-octets\\s\\d{10}
    Result Match Regexp    tx-unicast-pkts\\s\\d{7}
    Result Match Regexp    tx-multicast-pkts\\s\\d{2}
    Result Match Regexp    tx-broadcast-pkts\\s\\d{1}
    Result Match Regexp    rx-pkts\\s2\\d{8}
    Result Match Regexp    rx-octets\\s1\\d{11}
    Result Match Regexp    rx-utilization\\s4\\d{1}
    Result Match Regexp    rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s4\\d{1}
    Result Match Regexp    tx-utilization-max\\s\\d{1}
    Result Match Regexp    tx-utilization\\s\\d{1}
    Result Match Regexp    tx-utilization-min\\s\\d{1}
    Result Match Regexp    mefServiceInterfaceStatisticsIngressInvalidVid

Verify Ifentry Data RFC 2863 Interfaces MIB
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM session Ifentry data defined in the RFC 2863 Interfaces MIB and its Utilization Statistics of bins are collected
    [Tags]    @author=llim
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s1\\d{8}
    Result Match Regexp    octets\\s1\\d{10}|octets\\s2\\d{10}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    fragments\\s29\\d{6}|fragments\\s30\\d{6}
    Result Match Regexp    pkts-65to127\\s29\\d{6}|pkts-65to127\\s30\\d{6}
    Result Match Regexp    pkts-128to255\\s29\\d{6}|pkts-128to255\\s30\\d{6}
    Result Match Regexp    pkts-256to511\\s29\\d{6}|pkts-256to511\\s30\\d{6}
    Result Match Regexp    rx-pkts\\s89\\d{6}|rx-pkts\\s90\\d{6}
    Result Match Regexp    rx-octets\\s1\\d{10}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    rx-errors\\s29\\d{6}|rx-errors\\s30\\d{6}
    Result Match Regexp    tx-pkts\\s\\d{7}
    Result Match Regexp    tx-octets\\s\\d{10}
    Result Match Regexp    tx-unicast-pkts\\s\\d{7}
    Result Match Regexp    tx-multicast-pkts\\s\\d{2}
    Result Match Regexp    tx-broadcast-pkts\\s\\d{1}
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}
    Result Match Regexp    tx-utilization-max\\s\\d{1}
    Result Match Regexp    tx-utilization\\s\\d{1}
    Result Match Regexp    tx-utilization-min\\s\\d{1}
    Result Match Regexp    ifIndex
    Result Match Regexp    ifDescr
    Result Match Regexp    ifAdminStatus
    Result Match Regexp    ifHighSpeed
    Result Match Regexp    ifOperStatus
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{6}|broadcast-pkts\\s30\\d{6}
    Result Match Regexp    pkts\\s1\\d{8}
    Result Match Regexp    octets\\s1\\d{11}|octets\\s2\\d{11}
    Result Match Regexp    multicast-pkts\\s29\\d{6}|multicast-pkts\\s30\\d{6}
    Result Match Regexp    fragments\\s29\\d{6}|fragments\\s30\\d{6}
    Result Match Regexp    pkts-65to127\\s29\\d{6}|pkts-65to127\\s30\\d{6}
    Result Match Regexp    pkts-128to255\\s29\\d{6}|pkts-128to255\\s30\\d{6}
    Result Match Regexp    pkts-256to511\\s29\\d{6}|pkts-256to511\\s30\\d{6}
    Result Match Regexp    rx-pkts\\s89\\d{6}|rx-pkts\\s90\\d{6}
    Result Match Regexp    rx-octets\\s1\\d{11}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{6}|rx-multicast-pkts\\s30\\d{6}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{6}|rx-broadcast-pkts\\s30\\d{6}
    Result Match Regexp    rx-errors\\s29\\d{6}|rx-errors\\s30\\d{6}
    Result Match Regexp    tx-pkts\\s\\d{7}
    Result Match Regexp    tx-octets\\s\\d{10}
    Result Match Regexp    tx-unicast-pkts\\s\\d{7}
    Result Match Regexp    tx-multicast-pkts\\s\\d{2}
    Result Match Regexp    tx-broadcast-pkts\\s\\d{1}
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}
    Result Match Regexp    tx-utilization-max\\s\\d{1}
    Result Match Regexp    tx-utilization\\s\\d{1}
    Result Match Regexp    tx-utilization-min\\s\\d{1}

Verify Counter Reset To Zero And Start Again
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM attributes maintains a running counter which wraps to zero and start counting again,Utilazation statistics can be cleared
    [Tags]    @author=llim
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s29\\d{5}|broadcast-pkts\\s30\\d{5}
    Result Match Regexp    pkts\\s29\\d{6}|pkts\\s30\\d{6}
    Result Match Regexp    multicast-pkts\\s29\\d{5}|multicast-pkts\\s30\\d{5}
    Result Match Regexp    crc-align-errors\\s29\\d{5}|crc-align-errors\\s30\\d{5}
    Result Match Regexp    undersize-pkts\\s29\\d{5}|undersize-pkts\\s30\\d{5}
    Result Match Regexp    oversize-pkts\\s29\\d{5}|oversize-pkts\\s30\\d{5}
    Result Match Regexp    fragments\\s29\\d{5}|fragments\\s30\\d{5}
    Result Match Regexp    pkts-64\\s29\\d{5}|pkts-64\\s30\\d{5}
    Result Match Regexp    pkts-65to127\\s29\\d{5}|pkts-65to127\\s30\\d{5}
    Result Match Regexp    pkts-128to255\\s29\\d{5}|pkts-128to255\\s30\\d{5}
    Result Match Regexp    pkts-256to511\\s29\\d{5}|pkts-256to511\\s30\\d{5}
    Result Match Regexp    pkts-512to1023\\s29\\d{5}|pkts-512to1023\\s30\\d{5}
    Result Match Regexp    pkts-1024to1518\\s29\\d{5}|pkts-1024to1518\\s30\\d{5}
    Result Match Regexp    rx-multicast-pkts\\s29\\d{5}|rx-multicast-pkts\\s30\\d{5}
    Result Match Regexp    rx-broadcast-pkts\\s29\\d{5}|rx-broadcast-pkts\\s30\\d{5}
    Result Match Regexp    fcs-errors\\s29\\d{5}|fcs-errors\\s30\\d{5}
    Result Match Regexp    jabbers\\s29\\d{5}|jabbers\\s30\\d{5}
    Result Match Regexp    rx-utilization\\s4\\d{0}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s4\\d{0}
    Result Match Regexp    rx-utilization-max\\s4\\d{0}
    sleep    60
    ${match}    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    ${match11}    Should Match Regexp    ${match}    (time-elapsed)(\\s)(\\d+)
    ${match21}    Evaluate    ${match11[3]} + 1
    ${match31}    Evaluate    ${match11[3]} - 1
    ${match13}    Evaluate    300 - ${match11[3]}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Match Regexp    broadcast-pkts\\s${match11[3]}\\d{5}|broadcast-pkts\\s${match21}\\d{5}|broadcast-pkts\\s${match31}\\d{5}
    Result Match Regexp    pkts\\s${match11[3]}\\d{6}|pkts\\s${match21}\\d{6}|pkts\\s${match31}\\d{6}
    Result Match Regexp    multicast-pkts\\s${match11[3]}\\d{5}|multicast-pkts\\s${match21}\\d{5}|multicast-pkts\\s${match31}\\d{5}
    Result Match Regexp    crc-align-errors\\s${match11[3]}\\d{5}|crc-align-errors\\s${match21}\\d{5}|crc-align-errors\\s${match31}\\d{5}
    Result Match Regexp    undersize-pkts\\s${match11[3]}\\d{5}|undersize-pkts\\s${match21}\\d{5}|undersize-pkts\\s${match31}\\d{5}
    Result Match Regexp    oversize-pkts\\s${match11[3]}\\d{5}|oversize-pkts\\s${match21}\\d{5}|oversize-pkts\\s${match31}\\d{5}
    Result Match Regexp    fragments\\s${match11[3]}\\d{5}|fragments\\s${match21}\\d{5}|fragments\\s${match31}\\d{5}
    Result Match Regexp    pkts-64\\s${match11[3]}\\d{5}|pkts-64\\s${match21}\\d{5}|pkts-64\\s${match31}\\d{5}
    Result Match Regexp    pkts-65to127\\s${match11[3]}\\d{5}|pkts-65to127\\s${match21}\\d{5}|pkts-65to127\\s${match31}\\d{5}
    Result Match Regexp    pkts-128to255\\s${match11[3]}\\d{5}|pkts-128to255\\s${match21}\\d{5}|pkts-128to255\\s${match31}\\d{5}
    Result Match Regexp    pkts-256to511\\s${match11[3]}\\d{5}|pkts-256to511\\s${match21}\\d{5}|pkts-256to511\\s${match31}\\d{5}
    Result Match Regexp    pkts-512to1023\\s${match11[3]}\\d{5}|pkts-512to1023\\s${match21}\\d{5}|pkts-512to1023\\s${match31}\\d{5}
    Result Match Regexp    pkts-1024to1518\\s${match11[3]}\\d{5}|pkts-1024to1518\\s${match21}\\d{5}|pkts-1024to1518\\s${match31}\\d{5}
    Result Match Regexp    rx-multicast-pkts\\s${match11[3]}\\d{5}|rx-multicast-pkts\\s${match21}\\d{5}|rx-multicast-pkts\\s${match31}\\d{5}
    Result Match Regexp    rx-broadcast-pkts\\s${match11[3]}\\d{5}|rx-broadcast-pkts\\s${match21}\\d{5}|rx-broadcast-pkts\\s${match31}\\d{5}
    Result Match Regexp    fcs-errors\\s${match11[3]}\\d{5}|fcs-errors\\s${match21}\\d{5}|fcs-errors\\s${match31}\\d{5}
    Result Match Regexp    jabbers\\s${match11[3]}\\d{5}|jabbers\\s${match21}\\d{5}|jabbers\\s${match31}\\d{5}
    Result Match Regexp    rx-utilization\\s4\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s4\\d{1}
    Result Match Regexp    rx-utilization-max\\s4\\d{1}
    cli    ${device}    clear interface ethernet ${port} performance-monitoring rmon-session bin-or-interval bin bin-duration ${bin_duration} all-or-current current 
    sleep    240
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    broadcast-pkts\\s2\\d{7}
    Result Match Regexp    pkts\\s2\\d{8}
    Result Match Regexp    multicast-pkts\\s2\\d{7}
    Result Match Regexp    crc-align-errors\\s2\\d{7}
    Result Match Regexp    undersize-pkts\\s2\\d{7}
    Result Match Regexp    oversize-pkts\\s2\\d{7}
    Result Match Regexp    fragments\\s2\\d{7}
    Result Match Regexp    pkts-64\\s2\\d{7}
    Result Match Regexp    pkts-65to127\\s2\\d{7}
    Result Match Regexp    pkts-128to255\\s2\\d{7}
    Result Match Regexp    pkts-256to511\\s2\\d{7}
    Result Match Regexp    pkts-512to1023\\s2\\d{7}
    Result Match Regexp    pkts-1024to1518\\s2\\d{7}
    Result Match Regexp    rx-multicast-pkts\\s2\\d{7}
    Result Match Regexp    rx-broadcast-pkts\\s2\\d{7}
    Result Match Regexp    fcs-errors\\s2\\d{7}
    Result Match Regexp    jabbers\\s2\\d{7}
    Result Match Regexp    rx-utilization\\s4\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s4\\d{1}
    Result Match Regexp    rx-utilization-max\\s4\\d{1}
    cli    ${device}    clear interface ethernet ${port} performance-monitoring rmon-session bin-or-interval bin bin-duration ${bin_duration} all-or-current all
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    rx-utilization\\s0
    Result Match Regexp    rx-utilization-min\\s0
    Result Match Regexp    rx-utilization-max
    Result Match Regexp    broadcast-pkts\\s0
    Result Match Regexp    pkts\\s0
    Result Match Regexp    multicast-pkts\\s0
    Result Match Regexp    crc-align-errors\\s0
    Result Match Regexp    undersize-pkts\\s0
    Result Match Regexp    oversize-pkts\\s0
    Result Match Regexp    fragments\\s0
    Result Match Regexp    pkts-64\\s0
    Result Match Regexp    pkts-65to127\\s0
    Result Match Regexp    pkts-128to255\\s0
    Result Match Regexp    pkts-256to511\\s0
    Result Match Regexp    pkts-512to1023\\s0
    Result Match Regexp    pkts-1024to1518\\s0
    Result Match Regexp    rx-multicast-pkts\\s0
    Result Match Regexp    rx-broadcast-pkts\\s0
    Result Match Regexp    fcs-errors\\s0
    Result Match Regexp    jabbers\\s0
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 2
    Result Match Regexp    rx-utilization\\s0
    Result Match Regexp    rx-utilization-min\\s0
    Result Match Regexp    rx-utilization-max
    Result Match Regexp    broadcast-pkts\\s0
    Result Match Regexp    pkts\\s0
    Result Match Regexp    multicast-pkts\\s0
    Result Match Regexp    crc-align-errors\\s0
    Result Match Regexp    undersize-pkts\\s0
    Result Match Regexp    oversize-pkts\\s0
    Result Match Regexp    fragments\\s0
    Result Match Regexp    pkts-64\\s0
    Result Match Regexp    pkts-65to127\\s0
    Result Match Regexp    pkts-128to255\\s0
    Result Match Regexp    pkts-256to511\\s0
    Result Match Regexp    pkts-512to1023\\s0
    Result Match Regexp    pkts-1024to1518\\s0
    Result Match Regexp    rx-multicast-pkts\\s0
    Result Match Regexp    rx-broadcast-pkts\\s0
    Result Match Regexp    fcs-errors\\s0
    Result Match Regexp    jabbers\\s0

Verify System Default PM Sessions
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify the system default configuration creates two PM sessions with 15 minutes and 24 hours MI after the system startup
    [Tags]    @author=llim
    cli    ${device}    sysadmin
    cli    ${device}    sysadmin
    cli    ${device}    sysadmin
    cli    ${device}    show running-config interface ethernet ${port}
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration fifteen-minutes bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 0
    Result Should Contain    is-current TRUE
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-day    bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    number 0
    Result Should Contain    is-current TRUE
    cli    ${device}    copy config from running-config-safe to running-config
    cli    ${device}    accept running-config
    cli    ${device}    copy running-config startup-config

Verify PM Utilization Statistics PM First Bin Sample Period
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM Max/Min/Ave Utilization Statistics of PM session bins calculated on its sample period
    [Tags]    @author=llim
    sleep    60
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 0
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 0
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    rx-utilization\\s\\d{1}
    Result Match Regexp    rx-utilization-min\\s0|rx-utilization-min\\s\\d{1}
    Result Match Regexp    rx-utilization-max\\s\\d{1}

Verify PM Utilization Statistics PM Second Bin Sample Period
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM Max/Min/Ave Utilization Statistics of PM session bins calculated on its sample period
    [Tags]    @author=llim
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 0
    Result Match Regexp    rx-utilization\\s[3-5]
    Result Match Regexp    rx-utilization-min\\s[0-5]
    Result Match Regexp    rx-utilization-max\\s[3-5]
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    rx-utilization\\s[3-5]
    Result Match Regexp    rx-utilization-min\\s[0-5]
    Result Match Regexp    rx-utilization-max\\s[3-5]
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 0
    Result Match Regexp    rx-utilization\\s[3-5]
    Result Match Regexp    rx-utilization-min\\s[0-5]
    Result Match Regexp    rx-utilization-max\\s[3-5]
    sleep    30
    cli    ${device}    show interface ethernet ${port} performance-monitoring rmon-session bin-duration one-minute bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    rx-utilization\\s[3-5]
    Result Match Regexp    rx-utilization-min\\s[0-5]
    Result Match Regexp    rx-utilization-max\\s[3-5]

Configure Class Map
	[Arguments]     ${device}     ${Cmaptype}     ${Cmapname}    ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Configure Class Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Configure Class Map | n1 | ethernet | CM1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     class-map ${Cmaptype} ${Cmapname}
	Cli With Error Check     ${device}     flow 1 rule 1 match untagged
	Cli With Error Check     ${device}     exit
	Cli With Error Check     ${device}     flow 1 rule 2 match vlan ${service_vlan_1}
	Cli With Error Check     ${device}     end 

Configure Policy Map
	[Arguments]     ${device}     ${Pmapname}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Configure Policy Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Pmapname | policy-map name |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Configure Policy Map | n1 | PM1 | ethernet | CM1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     policy-map ${Pmapname}
	Cli With Error Check     ${device}     class-map-${Cmaptype} ${Cmapname}
	Cli With Error Check     ${device}     flow 1
	Cli With Error Check     ${device}     end 

Configure Transport Service Profile
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Configure Transport Service Profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Configure Transport Service Profile | n1 | 103 |
	Cli With Error Check     ${device}	   configure
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     vlan-list ${service_vlan_1}
	Cli With Error Check     ${device}     end 

Verify Transport Service
	[Arguments]     ${device} 	${service_vlan_1}
	[Documentation]     [Author:llim] Description: Verify Transport Service
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Verify Transport Service | n1 | 103 |
	Cli With Error Check     ${device}     show running-config transport-service-profile
	Result Should Contain     transport-service-profile SYSTEM_TSP
	${vlan_str}     Convert to String     ${service_vlan_1}
	Result Should Contain     ${vlan_str}

Verify Class Map
	[Arguments]     ${device}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Verify Class Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Verify Class Map | n1 | ethernet | CM1 |
	Cli With Error Check     ${device}     show running-config class-map ${Cmaptype} ${Cmapname} | details
	Result Should Contain	 ${Cmaptype}
	Result Should Contain    ${Cmapname}

Verify Policy Map
	[Arguments]     ${device}     ${Pmapname}
	[Documentation]     [Author:llim] Description: Verify Policy Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Pmapname | policy-map name |
    ...
    ...    Example:
    ...    | Verify Policy Map | n1 | PM1 |
	Cli With Error Check     ${device}     show running-config policy-map | details
	Result Should Contain    ${Pmapname}

Configure Ethernet Interface
	[Arguments]     ${device}     ${port1}
	[Documentation]     [Author:llim] Description: Configure Ethernet Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port1 | ethernet port |
    ...
    ...    Example:
    ...    | Configure Ethernet Interface | n1 | 1/1/x1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     interface ethernet ${port1}
	Cli With Error Check     ${device}     switchport ENABLED
	Cli With Error Check     ${device}     role inni
	Cli With Error Check     ${device}     lldp admin-state enable
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     end 

Configure Vlan
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Configure Vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Configure Vlan | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     vlan ${service_vlan_1}
	Cli With Error Check	 ${device}     mode N2ONE
	Cli With Error Check     ${device}     l3-service DISABLED
	Cli With Error Check     ${device}     end 

Configure Ont Interface
	[Arguments]     ${device}     ${ont_num}     ${service_vlan_1}    ${Pmapname}    ${ont_port}    
	[Documentation]     [Author:llim] Description: Configure Ont Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_num | ont ID/number |
    ...    | service_vlan_1 | service vlan value |
    ...    | Pmapname | policy-map name |
    ...    | ont_port | ont-ethernet port |
    ...
    ...    Example:
    ...    | Configure Ont Interface | n1 | 882 | 103 | PM1 | g1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     interface ont-ethernet ${ont_num}/${ont_port}
	Cli With Error Check     ${device}     role uni
	Cli With Error Check     ${device}     vlan ${service_vlan_1}
	Cli With Error Check     ${device}     policy-map ${Pmapname}
	Cli With Error Check     ${device}     end 

Verify Ont Interface
	[Arguments]     ${device}     ${service_vlan_1}     ${Pmapname}     ${ont_num}     ${ont_port}
	[Documentation]     [Author:llim] Description: Verify Ont Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...    | Pmapname | policy-map name |
    ...    | ont_num | ont ID/number |
    ...    | ont_port | ont-ethernet port |
    ...
    ...    Example:
    ...    | Verify Ont Interface | n1 | 103 | PM1 | 882 | g1 |
	Cli With Error Check      ${device}     show running-config interface ont-ethernet
	Result Should Contain     vlan ${service_vlan_1}
	Result Should Contain     policy-map ${Pmapname}
	Result Should Contain     interface ont-ethernet ${ont_num}/${ont_port}

Unconfigure Ont Interface
	[Arguments]     ${device}     ${ont_num}     ${ont_port}     ${service_vlan_1}     ${Pmapname}
	[Documentation]     [Author:llim] Description: Unconfigure Ont Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_num | ont ID/number |
    ...    | ont_port | ont-ethernet port |
    ...    | service_vlan_1 | service vlan value |
    ...    | Pmapname | policy-map name |
    ...
    ...    Example:
    ...    | Unconfigure Ont Interface | n1 | 882 | g1 | 103 | PM1 |
    Cli     ${device}     configure
	Cli     ${device}     interface ont-ethernet ${ont_num}/${ont_port}
	Cli     ${device}     vlan ${service_vlan_1}
	Cli     ${device}     no policy-map ${Pmapname}
	Cli     ${device}     exit
	Cli     ${device}	  no vlan ${service_vlan_1}
	Cli     ${device}     end 

Unconfigure Class Map
	[Arguments]     ${device}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Unconfigure Class Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Unconfigure Class Map | n1 | ethernet | CM1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     no class-map ${Cmaptype} ${Cmapname}
	Cli With Error Check     ${device}     end 

Unconfigure Policy Map
	[Arguments]     ${device}     ${Pmapname}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Unconfigure Policy Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Pmapname | policy-map name |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Unconfigure Policy Map | n1 | PM1 | ethernet | CM1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     no policy-map ${Pmapname}
	Cli With Error Check     ${device}     end 

Unconfigure Transport Service Profile
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Unconfigure Transport Service Profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Unconfigure Transport Service Profile | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     no vlan-list ${service_vlan_1}
	Cli With Error Check     ${device}     end 

Unconfigure Ethernet Interface
	[Arguments]     ${device}     ${port1}
	[Documentation]     [Author:llim] Description: Unconfigure Ethernet Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port1 | ethernet port name |
    ...
    ...    Example:
    ...    | Unconfigure Ethernet Interface | n1 | 1/1/x1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     interface ethernet ${port1}
	Cli With Error Check     ${device}     no transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     lldp admin-state disable
	Cli With Error Check     ${device}     no role 
	Cli With Error Check     ${device}     switchport DISABLED
	Cli With Error Check     ${device}     end

Unconfigure Vlan From Transport Service Profile
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Unconfigure Vlan From Transport Service Profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Unconfigure Vlan From Transport Service Profile | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     no vlan ${service_vlan_1}
	Cli With Error Check     ${device}     end

Unconfigure Vlan
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Unconfigure Vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Unconfigure Vlan | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     no vlan ${service_vlan_1}
	Cli With Error Check     ${device}     end