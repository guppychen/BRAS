*** Settings ***
Documentation     id-profile operation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_id_profile_operation
    [Documentation]    1	create ID Profile	provision succeed
    ...    2	delete ID Profile	provision succeed
    ...    3	modify ID Profile	provision succeed
    ...    4	display id profile	show correct info
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2201    @globalid=2344017    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create ID Profile provision succeed
    prov_id_profile    eutA     ryi
    ${tmp}    Axos Cli With Error Check    eutA    show running-config id-profile
    should contain    ${tmp}    id-profile ryi
    log    STEP:3 modify ID Profile provision succeed
    prov_id_profile    eutA    ryi    remote-id=%Desc
    log    STEP:4 display id profile show correct info
    ${tmp}    Axos Cli With Error Check    eutA    show running-config id-profile ryi
    should match regexp    ${tmp}    remote-id  "$Desc"
    log    STEP:2 delete ID Profile provision succeed
    dprov_id_profile    eutA    ryi
    ${tmp}    Axos Cli With Error Check    eutA    show running-config id-profile
    should not contain    ${tmp}    id-profile ryi


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    profile is created in suite setup


case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    dprov_id_profile    eutA    ryi
