#Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount
$Location = "WestEurope"
## 1
$RG1 = "ResourceGroup1"
$VNetName1 = "VNet1"
$Subnet1 = "Subnet1RG1"
$VnetIP1 = "10.1.0.0/16"
$SubnetIP1  = "10.1.0.0/24"
$GWName1 = "VNet1GW"
$GWIPName1 = "VNet1GWIP"
$GWIPconfName1 = "gwipconf1"
$Connect1to2 = "VNet1toVNet2"
#Create Resource Group1
New-AzResourceGroup -Name $RG1 -Location $Location
#config subnet1 for vnet1
$sub1 = New-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix $SubnetIP1
#create vnet1
New-AzVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1 -Location $Location -AddressPrefix $VnetIP1 -Subnet $sub1
#gateway public ip1
$gwpip1 = New-AzPublicIpAddress -Name $GWIPName1 -ResourceGroupName $RG1 -AllocationMethod Dynamic -Location $Location
#gateway 1 config
$vnet1 = Get-AzVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1
$subnet1 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
$gwipconf1 = New-AzVirtualNetworkGatewayIpConfig -Name $GWIPconfName1 -Subnet $subnet1 -PublicIpAddress $gwpip1
#create gateway
New-AzVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1 -Location $Location -IpConfigurations $gwipconf1 -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw1
Write-Host "Network 1 setup is done"
## Virtual network2
$RG2 = "ResourceGroup2"
$VNetName2 = "VNet2"
$Subnet2 = "Subnet2RG2"
$VnetIP2 = "10.2.0.0/16"
$SubnetIP2  = "10.2.0.0/24"
$GWName2 = "VNet2GW"
$GWIPName2 = "VNet2GWIP"
$GWIPconfName2 = "gwipconf2"
$Connect2to1 = "VNet2toVNet1"
#create Resource group 2
New-AzResourceGroup -Name $RG2 -Location $Location
#create config for subnet for vnet2
$sub2 = New-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix $SubnetIP2
#create vnet2
New-AzVirtualNetwork -Name $VNetName2 -ResourceGroupName $RG2 -Location $Location -AddressPrefix $VnetIP2 -Subnet $sub2
#gateway public ip2
$gwpip2 = New-AzPublicIpAddress -Name $GWIPName2 -ResourceGroupName $RG2 -AllocationMethod Dynamic -Location $Location
#gateway2 config
$vnet2 = Get-AzVirtualNetwork -Name $VnetName2 -ResourceGroupName $RG2
$subnet2 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet2
$gwipconf2 = New-AzVirtualNetworkGatewayIpConfig -Name $GWIPconfName2 -Subnet $subnet2 -PublicIpAddress $gwpip2
#create gateway
New-AzVirtualNetworkGateway -Name $GWName2 -ResourceGroupName $RG2 -Location $Location -IpConfigurations $gwipconf2 -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw2
Write-Host "Network 2 setup is done"
#get gateways for networks
$vnet1gateway = Get-AzVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
$vnet2gateway = Get-AzVirtualNetworkGateway -Name $GWName2 -ResourceGroupName $RG2
#making connection 1
New-AzVirtualNetworkGatewayConnection -Name $Connect1to2 -ResourceGroupName $RG1 -VirtualNetworkGateway1 $vnet1gateway -VirtualNetworkGateway2 $vnet2gateway -Location $Location -ConnectionType Vnet2Vnet -SharedKey 'MySharedKey'
#making connection2
New-AzVirtualNetworkGatewayConnection -Name $Connect2to1 -ResourceGroupName $RG2 -VirtualNetworkGateway1 $vnet2gateway -VirtualNetworkGateway2 $vnet1gateway -Location $Location -ConnectionType Vnet2Vnet -SharedKey 'MySharedKey'
Write-Host "Setup is all done"