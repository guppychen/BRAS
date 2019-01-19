*** Settings ***
Documentation     CLI Test - Runs ROLT Layer 3 Traffic provisioning and verifies prompt.
Force Tags        @tcid=RLT-TC-14872  @author=dmoran  @priority=P1  @feature=CLI_LAYER_3_PROVISIONING_AUTOMATED  @eut=NGPON2-4   @require=1eut  @subfeature=CLI_LAYER_3_PROVISIONING_AUTOMATED   @eut=GPON-8r2
Resource          ./base.robot

Suite Teardown     clear setup


*** Test Cases ***
Provision Ethernet Port Interface
    [Documentation]  Enters CLI commands to provision the ethernet interface &{devices.n1.ports.p1}[port]
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    int eth &{devices.n1.ports.p1}[port]    (config-ethernet-&{devices.n1.ports.p1}[port])
    wait until keyword succeeds   30    5    Send Command And Confirm Expect    n1    ip addr 192.85.1.100/24   (config-ethernet-&{devices.n1.ports.p1}[port])
    Send Command And Confirm Expect    n1    no shutdown    (config-ethernet-&{devices.n1.ports.p1}[port])
    CLI   n1    end    

Verify CLI for interface
    [Documentation]  Verify ethernet interface &{devices.n1.ports.p1}[port] was provisioned
    CLI    n1    show running-config interface ethernet &{devices.n1.ports.p1}[port]
    Result Should Contain    interface ethernet &{devices.n1.ports.p1}[port]
    Result Should Contain    no shutdown
    Result Should Contain    ip address 192.85.1.100/24
    
Via CLI assign an IP address for L3-DHCP-Profile
    [Documentation]  Enters the CLI commands  to provision l3-dhcp-profile
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    l3-dhcp-profile test    (config-l3-dhcp-profile-test)
    Send Command And Confirm Expect    n1    helper-address 1 192.85.1.20    (config-l3-dhcp-profile-test)
    CLI   n1    end

Verify CLI for l3-dhcp-profile
    [Documentation]  Verify provisioning for l3-dhcp-profile
    CLI    n1    show running-config l3-dhcp-profile
    Result Should Contain    l3-dhcp-profile test
    
Via CLI enter vlan 100
    [Documentation]  Enters the CLI commands  to provision vlan 100
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    vlan 100    (config-vlan-100)
    Send Command And Confirm Expect    n1    L3-service ENABLED    (config-vlan-100)
    Send Command And Confirm Expect    n1    top    (config)
    
Via CLI assign IP address to interface vlan 100
    [Documentation]  Assign ip addresss to vlan 100
    Send Command And Confirm Expect    n1    interface vlan 100    (config-vlan-100)
    Send Command And Confirm Expect    n1    ip address 10.10.10.1/24    (config-vlan-100)
    Send Command And Confirm Expect    n1    l3-dhcp-profile test    (config-vlan-100)
    Send Command And Confirm Expect    n1    no shutdown    (config-vlan-100)
    CLI   n1    end

Verify CLI for interface vlan 100
    [Documentation]  Verify ip addresss to vlan 100
    CLI    n1    show running-config interface vlan 100
    Result Should Contain    interface vlan 100
    Result Should Contain    ip address 10.10.10.1/24
    Result Should Contain    l3-dhcp-profile test
    Result Should Contain    no shutdown
    
Enter ONT
    [Documentation]  Enter ONT #8
    Send Command And Confirm Expect    n1    config    (config) 
    Send Command And Confirm Expect    n1    ont 8    (config-ont-8)
    Send Command And Confirm Expect    n1    description ONT_8    (config-ont-8)
    Send Command And Confirm Expect    n1    profile-id ${ont_profile}    (config-ont-8)
    Send Command And Confirm Expect    n1    serial-number 28F655    (config-ont-8)
    Send Command And Confirm Expect    n1    no shutdown    (config-ont-8)
    CLI   n1    end
    
Verify CLI for ont
    [Documentation]  Verify ONT #8 is entered
    CLI    n1   show running-config ont 8
    Result Should Contain    ont 8
    Result Should Contain    profile-id    ${ont_profile}
    Result Should Contain    serial-number 28F655
    Result Should Contain    description    ONT_8
    
Enter Class Map
    [Documentation]  Enter Class Map cm-L3-in
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    class-map ip cm-L3-in    (config-ip-cm-L3-in)
    Send Command And Confirm Expect    n1    ingress-flow 1    (config-ingress-flow-1)
    Send Command And Confirm Expect    n1    rule 1 match destination-ip-network 0.0.0.0/0    (config-ingress-flow-1)
    CLI   n1    end
     
Verify CLI for class maps
    [Documentation]  Verify Class Map cm-L3-in was entered
    CLI    n1    show running-config class-map ip cm-L3-in
    Result Should Contain    class-map ip cm-L3-in
    Result Should Contain    ingress-flow 1
    Result Should Contain    rule 1 match destination-ip-network 0.0.0.0/0
    
Enter Policy Map
    [Documentation]  Enter Policy Map pm-L3
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    policy-map pm-L3    (config-policy-map-pm-L3)
    Send Command And Confirm Expect    n1    class-map-ip cm-L3-in    (config-class-map-ip-cm-L3-in)
    Send Command And Confirm Expect    n1    ingress-flow 1    (config-ingress-flow-1)
    CLI   n1    end
     
Verify CLI for policy maps maps
    [Documentation]  Verify Policy Map pm-L3 entered
    CLI    n1    show running-config policy-map pm-L3
    Result Should Contain    policy-map pm-L3
    Result Should Contain    class-map-ip cm-L3-in
    Result Should Contain    ingress-flow 1
    
Assign Policy Map to ONT-Ethernet Interface
    [Documentation]  Assign Policy Map pm-L3 to ONT-Ethernet
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    interface ont-ethernet 8/g1    (config-ont-ethernet-8/g1)
    Send Command And Confirm Expect    n1    no shutdown    (config-ont-ethernet-8/g1)
    Send Command And Confirm Expect    n1    vlan 100    (config-vlan-100)
    Send Command And Confirm Expect    n1    policy-map pm-L3    (config-policy-map-pm-L3)
    Send Command And Confirm Expect    n1    no shutdown    (config-policy-map-pm-L3)
    CLI   n1    end
    
Verify CLI for interface ont-ethernet
    [Documentation]  Verify interface ONT-Ethernet 8/g1
    CLI    n1    show running-config interface ont-ethernet 8/g1
    Result Should Contain    interface ont-ethernet 8/g1
    Result Should Contain    vlan 100
    Result Should Contain    policy-map pm-L3 
    
Enable PON Interface
    [Documentation]  Enters CLI commands to enable the PON &{devices.n1.ports.p2}[port] interface
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    interface pon &{devices.n1.ports.p2}[port]    (config-pon-&{devices.n1.ports.p2}[port])
    Send Command And Confirm Expect    n1    no shutdown    (config-pon-&{devices.n1.ports.p2}[port])
    CLI   n1    end 
           
Verify CLI for PON Interface
    [Documentation]  Verifies that the PON &{devices.n1.ports.p2}[port] interface was enabled
    CLI    n1    show running-config interface pon &{devices.n1.ports.p2}[port]
    Result Should Contain    interface pon &{devices.n1.ports.p2}[port]
    Result Should Contain    no shutdown
    
    
 De-Provision PON Interface
    [Documentation]  De-Provision the PON &{devices.n1.ports.p2}[port] interface
    Send Command And Confirm Expect    n1    config    (config) 
    Send Command And Confirm Expect    n1    no interface pon &{devices.n1.ports.p2}[port]    (config)
    CLI   n1    end
    
Verify CLI for PON Interface de-provisioned
    [Documentation]  Verify the PON &{devices.n1.ports.p2}[port] interface has been de_provisioned
    CLI    n1    show running-config interface pon &{devices.n1.ports.p2}[port]
    Result Should Not Contain    no shutdown
    
De-Provision Ethernet Interface
    [Documentation]  De-Provision the ethernet interface &{devices.n1.ports.p1}[port]
    Send Command And Confirm Expect    n1    config    (config)  
    Send Command And Confirm Expect    n1    interface ethernet &{devices.n1.ports.p1}[port]    (config-ethernet-&{devices.n1.ports.p1}[port])
    Send Command And Confirm Expect    n1    shut    (config-ethernet-&{devices.n1.ports.p1}[port])
    Send Command And Confirm Expect    n1    no ip addr    (config-ethernet-&{devices.n1.ports.p1}[port])
    CLI   n1    end
    
 Verify CLI for Ethernet interface de-provisioned
    [Documentation]  Verify the ethernet interface &{devices.n1.ports.p1}[port] has been de-provisioned
    CLI    n1    show running-config interface ethernet &{devices.n1.ports.p1}[port]
    Result Should Not Contain    no shutdown
    Result Should Not Contain    ip address 192.85.1.100/24
    
De-Provision ONT-Ethernet Interface
    [Documentation]  De-provision the ont-ethernet interface 8/g1
    Send Command And Confirm Expect    n1    conf    (config)
    Send Command And Confirm Expect    n1    interface ont-ethernet 8/g1    (config-ont-ethernet-8/g1)
    Send Command And Confirm Expect    n1    shutdown    (config-ont-ethernet-8/g1)
    Send Command And Confirm Expect    n1    vlan 100    (config-vlan-100)
    Send Command And Confirm Expect    n1    no policy-map pm-L3    (config-vlan-100)
    Send Command And Confirm Expect    n1    exit    (config-ont-ethernet-8/g1)
    Send Command And Confirm Expect    n1    no vlan 100    (config-ont-ethernet-8/g1)
    Send Command And Confirm Expect    n1    top    (config)
    Send Command And Confirm Expect    n1    int vlan 100    (config-vlan-100)
    Send Command And Confirm Expect    n1    no ip address    (config-vlan-100)
    Send Command And Confirm Expect    n1    shut    (config-vlan-100)
    Send Command And Confirm Expect    n1    top    (config)
    Send Command And Confirm Expect    n1    no interface vlan 100    (config)
    Send Command And Confirm Expect    n1    no vlan 100    (config)
    CLI   n1    end
    
 De-provision ont
    [Documentation]  De-Provision the ONT# 8
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    ont 8    (config-ont-8)
    Send Command And Confirm Expect    n1    no serial-number    (config-ont-8)
    Send Command And Confirm Expect    n1    no description ONT_8    (config-ont-8)
    Send Command And Confirm Expect    n1    no profile-id ${ont_profile}    (config-ont-8)
    Send Command And Confirm Expect    n1    top    (config)
    Send Command And Confirm Expect    n1    no ont 8    (config)
    CLI   n1    end
    
Verify CLI for interface ont-ethernet de-provisioned
    [Documentation]  Verify ont-ethernet interface 8/g1 has been de-provisioned
    CLI    n1    show running-config interface ont-ethernet 8/g1
    Result Should Contain    syntax error: element does not exist
    Result Should Not Contain    vlan 100
    Result Should Not Contain    policy-map pm-L3
    
De-provision Policy-Map & Class-Map
    [Documentation]  De-Provision the Policy-Map and Class-Map
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    policy-map pm-L3    (config-policy-map-pm-L3)
    Send Command And Confirm Expect    n1    class-map-ip cm-L3-in    (config-class-map-ip-cm-L3-in)
    Send Command And Confirm Expect    n1    no ingress-flow 1    (config-class-map-ip-cm-L3-in)
    Send Command And Confirm Expect    n1    exit    (config-policy-map-pm-L3)
    Send Command And Confirm Expect    n1    no class-map-ip cm-L3-in    (config-policy-map-pm-L3)
    Send Command And Confirm Expect    n1    top    (config)
    Send Command And Confirm Expect    n1    no policy-map pm-L3    (config)
    Send Command And Confirm Expect    n1    no class-map ip cm-L3-in    (config)
    CLI   n1    end
    
Verify CLI for class maps de-provisioned
     [Documentation]  Verify Class-Map de-provisioned
    CLI    n1    show running-config class-map ip cm-L3-in
    Result Should Contain    syntax error: unknown match
    Result Should Not Contain    ingress-flow 1
    Result Should Not Contain    rule 1 match destination-ip-network 0.0.0.0/0

Verify CLI for policy maps maps de-provisioned
    [Documentation]  Verify Policy-Map de-provisioned
    wait until keyword succeeds    5s   1s     Send Command And Confirm Expect    n1   show running-config policy-map pm-L3   element does not exist
    CLI    n1    show running-config policy-map pm-L3
    Result Should Not Contain    class-map-ip cm-L3-in
    Result Should Not Contain    ingress-flow 1
    CLI   n1    end
    
De-provision L3-dhcp-profile
    [Documentation]  De-Provision the L3-dhcp-profile
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    l3-dhcp-profile test    (config-l3-dhcp-profile-test)
    Send Command And Confirm Expect    n1    no helper-address 1    (config-l3-dhcp-profile-test)
    Send Command And Confirm Expect    n1    top    (config)
    Send Command And Confirm Expect    n1    no l3-dhcp-profile test    (config)
    CLI   n1    end
    Send Command And Confirm Expect    n1    copy running-config startup-config    (config)
    
Verify CLI for l3-dhcp-profile de-provisioned
    [Documentation]  Verify the L3-dhcp-profile is de-provisioned
    CLI    n1    show running-config l3-dhcp-profile
    Result Should Not Contain    l3-dhcp-profile test

*** Keywords ***
Clear setup
    [Documentation]  Enters CLI commands to provision the ethernet interface &{devices.n1.ports.p1}[port]
    Send Command And Confirm Expect    n1    config    (config)
    Send Command And Confirm Expect    n1    int eth &{devices.n1.ports.p1}[port]    (config-ethernet-&{devices.n1.ports.p1}[port])
    Send Command And Confirm Expect    n1    no ip addr       (config-ethernet-&{devices.n1.ports.p1}[port])
    Send Command And Confirm Expect    n1    shutdown    (config-ethernet-&{devices.n1.ports.p1}[port])
    CLI   n1    end
    Application Restart Check   n1