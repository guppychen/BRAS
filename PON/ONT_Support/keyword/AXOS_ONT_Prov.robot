*** Settings ***
Documentation    AXOS-WI-322_ONT-Provisioning keyword lib

*** Keywords ***
ONT-Pre-Provision setup
            [Arguments]    ${DUT}    ${CMD}
            [Tags]    @author=<kkandra> Kumari
            [Documentation]     ONT provisioned setup
            Cli    ${DUT}    ${CMD}
            Cli    ${DUT}    idle-timeout 0
            Command    ${DUT}   config

PreProvision ONT with VendorID and SerialNumber
             [Arguments]    ${DUT}    ${ONTNUM}    ${VENID}    ${SERNUM}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Pre-provision ONT using a Global ID a ONT vendor and the serial number.
             Cli    ${DUT}    ont ${ONTNUM}
             Cli    ${DUT}    vendor-id ${VENID}
             Cli    ${DUT}    serial-number ${SERNUM}
             Cli    ${DUT}    top

PreProvision ONT with VendorID and MAC Address
             [Arguments]    ${DUT}    ${ONTNUM}    ${VENID}    ${MACADD}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Pre-provision ONT using a Global ID a ONT vendor and the MAC address
             Cli    ${DUT}    ont ${ONTNUM}
             Cli    ${DUT}    vendor-id ${VENID}
             Cli    ${DUT}    ont-mac-addr ${MACADD}
             Cli    ${DUT}    top

PreProvision ONT with ProfileID
             [Arguments]    ${DUT}    ${ONTNUM}    ${PROFID}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Pre-provision ONT using a Global ID a ONT vendor and the serial number.
             Cli    ${DUT}    ont ${ONTNUM}
             Cli    ${DUT}    profile-id ${PROFID}
             Cli    ${DUT}    top

Show ONT-linkages
             [Arguments]    ${DUT}    ${ONTNUM}    ${ONTPORT}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Show ONT linkages to find the ONT linked to pon port
             Cli    ${DUT}    do show ont-linkages    timeout_exception=0
             Result Should Contain   ont-id ${ONTNUM}
             Result Should Contain   pon-port ${ONTPORT}
             Result Should Contain   Confirmed

Show ONT-linkages Should Not Contain
             [Arguments]    ${DUT}   ${ONTNUM}   ${ONTPORT}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Show ONT linkages to find the ONT linked to pon port
             Cli    ${DUT}    do show ont-linkages
             Result Should Not Contain   ont-id ${ONTNUM}
             Result Should Not Contain   pon-port 1/1/${ONTPORT}

Enable Port
             [Arguments]    ${DUT}    ${PORT_TYPE}    ${PORT}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Puts an interface in no shutdown mode.

			 Cli     ${DUT}    interface ${PORT_TYPE} ${PORT}
			 Cli     ${DUT}    no shut   prompt=#    timeout=30
			 Cli     ${DUT}    top

Provision ONT with SerialNumber
             [Arguments]    ${DUT}    ${ONTNUM}    ${SERNUM}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Pre-provision ONT using a Global ID and the serial number.
             Cli    ${DUT}    ont ${ONTNUM}
             Cli    ${DUT}    serial-number ${SERNUM}
             Cli    ${DUT}    top

Disable Port
             [Arguments]      ${DUT}    ${PORT_TYPE}    ${PORT}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Puts an interface in no shutdown mode.
			 Cli     ${DUT}    interface ${PORT_TYPE} ${PORT}
			 Cli     ${DUT}    shut    prompt=#    timeout=30
			 Cli     ${DUT}    top

Provision ONT with RegID
             [Arguments]    ${DUT}    ${ONTNUM}    ${REGID}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]   Provision ONT using a Global ID and RegId.
             Cli    ${DUT}    ont ${ONTNUM}
             Cli    ${DUT}    reg-id ${REGID}
             Cli    ${DUT}    top

Provision ONT with MAC Address
             [Arguments]    ${DUT}    ${ONTNUM}    ${MACADD}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Pre-provision ONT using a Global ID a ONT vendor and the MAC address
             Cli    ${DUT}    ont ${ONTNUM}
             Cli    ${DUT}    ont-mac-addr ${MACADD}
             Cli    ${DUT}    top

Provision ONT
             [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${PROVPON}
             [Tags]    @author=<kkandra> Kumari
             [Documentation]    Sets up an ONT on a PON port, CLI should be in config mode, leaves CLI in config mode
             Cli    ${DUT}    ont ${ONTNUM}
             Cli    ${DUT}    profile-id ${PRFID}
             Cli    ${DUT}    serial-number ${SERNUM}
             Cli    ${DUT}    provisioned-pon 1/1/${PROVPON}
             Cli    ${DUT}    top

Deprovision ONT
            [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${PROVPON}    ${PONLOC}
            [Tags]    @author=<kkandra> Kumari
            [Documentation]   Deprovision ONT
            Cli    ${DUT}    ont ${ONTNUM}
            Cli    ${DUT}    no profile-id ${PRFID}
            Cli    ${DUT}    no serial-number ${SERNUM}
            Cli    ${DUT}    no provisioned-pon 1/1/${PROVPON}
            Cli    ${DUT}    no pon-location ${PONLOC}
            Cli    ${DUT}    top

Show ont-link and Status
            [Arguments]    ${DUT}    ${ONTNUM}   ${PROVPON}
            [Tags]    @author=<kkandra> Kumari
            [Documentation]   verify ont-linkages and ont status
            Show ONT-linkages    ${DUT}    ${ONTNUM}    ${PROVPON}
            Command    ${DUT}    do show ont ${ONTNUM} status
            Result Should Contain    present

L2 Create ClassMap and Add Rule
           [Arguments]    ${DUT}    ${CMName}   ${RULE}
           [Documentation]    Create L2 class map and add rule
           [Tags]    @author=<kkandra> Kumari
           Cli    ${DUT}    class-map ethernet ${CMName}
           Cli    ${DUT}    flow 1
           Cli    ${DUT}    rule 1 match ${RULE}
           Cli    ${DUT}    top

Create PolicyMap Add L2 class Map
          [Arguments]    ${DUT}    ${PMName}   ${CMName}
          [Documentation]    Create Plicy and add L2 class map
          [Tags]    @author=<kkandra> Kumari
          Cli    ${DUT}    policy-map ${PMName}
          Cli    ${DUT}    class-map-ethernet ${CMName}
          Cli    ${DUT}    top

Unlink ONT
          [Arguments]   ${DUT}   ${pName}    ${cmName}    ${ONTETHER}    ${SVLAN}
          [Documentation]    Unlink ONT and its services
          [Tags]    @author=<kkandra> Kumari
          Cli    ${DUT}    int ont-ether ${ONTETHER}
          Cli    ${DUT}    vlan ${SVLAN}
          Cli    ${DUT}    no policy-map ${pName}
          Cli    ${DUT}    exit
          Cli    ${DUT}    no vlan ${SVLAN}
          Cli    ${DUT}    top
          Cli    ${DUT}    no policy-map ${pName}
          Cli    ${DUT}    no class-map ethernet ${cmName}
          Cli    ${DUT}    no vlan ${SVLAN}

Unlink ONT Services
         [Arguments]    ${DUT}    ${PMName}   ${CMName}   ${ONTETHER1}   ${ONTETHER2}   ${VLAN1}   ${VLAN2}
         [Documentation]    Unlink ONT by removing its all configured services
         [Tags]    @author=<kkandra> Kumari
         Cli    ${DUT}    int ont-ether ${ONTETHER1}
         Cli    ${DUT}    vlan ${VLAN1}
         Cli    ${DUT}    no policy-map ${PMName}
         Cli    ${DUT}    exit
         Cli    ${DUT}    no vlan ${VLAN1}
         Cli    ${DUT}    top
         Cli    ${DUT}    int ont-ether ${ONT.ontNum}/${ONTETHER2}
         Cli    ${DUT}    vlan ${VLAN2}
         Cli    ${DUT}    no policy-map ${PMName}
         Cli    ${DUT}    exit
         Cli    ${DUT}    no vlan ${VLAN2}
         Cli    ${DUT}    top
         Cli    ${DUT}    no policy-map ${PMName}
         Cli    ${DUT}    no class-map ethernet ${CMName}
         Cli    ${DUT}    no vlan ${VLAN1}
         Cli    ${DUT}    no vlan ${VLAN2}

Create ONT-Profile
         [Arguments]    ${DUT}   ${ONTPROFILE}   ${ONTETHER1}  ${ONTETHER2}
         [Documentation]    Create ONT Profile
         [Tags]    @author=<kkandra> Kumari
         Cli    ${DUT}    ont-profile ${ONTPROFILE}
         Cli    ${DUT}    interface ont-ethernet ${ONTETHER1}
         Cli    ${DUT}    exit
         Cli    ${DUT}    interface ont-ethernet ${ONTETHER2}
         Cli    ${DUT}    top
         Cli    ${DUT}    do show running-config ont-profile ${ONTPROFILE}
         Result Should Contain    ${ONTETHER1}
         Result Should Contain    ${ONTETHER2}

Full ONT Provision
         [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${PROVPON}   ${ONTMAC}   ${ONTSUBID}
         [Documentation]    Full ONT Provision with subscriber ID
         [Tags]    @author=<kkandra> Kumari
         Cli    ${DUT}   ont ${ONTNUM}
         Cli    ${DUT}    profile-id ${PRFID}
         Cli    ${DUT}    serial-number ${SERNUM}
         Cli    ${DUT}    provisioned-pon 1/1/${PROVPON}
         Cli    ${DUT}    ont-mac-addr ${ONTMAC}
         Cli    ${DUT}    subscriber-id ${ONTSUBID}
         Cli    ${DUT}    top

List ONT
         [Arguments]    ${DUT}
         [Documentation]    List ONT using specified ID
         [Tags]    @author=<kkandra> Kumari
         Result Should Contain    ont ${ONT.ontNum}
         Result Should Contain    ${ONT.ontSerNum}
         Result Should Contain    ${ONT.ontPort}
         Result Should Contain    ${ONT.ontMACAdd}
         Result Should Contain    ${ONT.ontSubId}

AXOS_E72_PARENT-TC-485-78 teardown
    [Arguments]    ${DUT}    ${ONTNUM}    ${PRFID}    ${SERNUM}    ${PROVPON}    ${MACADD}
    ...    ${SubID}    ${PORT_TYPE}    ${PORT}
    [Documentation]    Deprovision ONT
    [Tags]    @author=<kkandra> Kumari
    Cli    ${DUT}    ont ${ONTNUM}
    Cli    ${DUT}    no serial-number ${SERNUM}
    Cli    ${DUT}    no provisioned-pon ${PROVPON}
    Cli    ${DUT}    no ont-mac-addr ${MACADD}
    Cli    ${DUT}    no subscriber-id ${SUBID}
    Cli    ${DUT}    top
    Cli    ${DUT}    no ont ${ONTNUM}
    Disable Port    ${DUT}    ${PORT_TYPE}    ${PORT}
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Sleep      3
    # modified by llin due to Milan need to have at lease 3 second time delay between shutdown and no shutdown operate on pon port.
    Cli    ${DUT}    exit


init pon port
    [Arguments]      ${device}    ${type}    ${portid}
    [Tags]    @author=llin
    Disable Port   ${device}    ${type}    ${portid}
    sleep   3
    Enable Port    ${device}    ${type}    ${portid}


wait ont discosver
    [Arguments]      ${device}    ${expectsn}
    [Tags]    @author=llin
    Cli      ${device}       end
    Cli      ${device}       show discovered-ont
    Result Should Contain   ${expectsn}


wait ont statble
    [Arguments]      ${device}    ${type}    ${portid}    ${expectsn}
    [Tags]    @author=llin
    Cli   ${device}    end
    Cli   ${device}    configure
    init pon port     ${device}    ${type}    ${portid}
    Wait Until Keyword Succeeds    60s    3s    wait ont discosver     ${device}    ${expectsn}























