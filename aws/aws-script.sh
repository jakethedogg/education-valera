#!/bin/bash


awsRegion="us-east-1"
availabilityZonePublic="us-east-1a"
availabilityZonePrivate="us-east-1b"
name="Aws Script"
vpcName="$name VPC"
publicsubnetName="$name Public Subnet"
privatesubnetName="$name Private Subnet"
gatewayName="$name Internet Gateway"
routeTableName="$name Route Table"
securityGroupName="$name Security Group"
vpcCidrBlock="10.0.0.0/16"
publicSubNetCidrBlock="10.0.1.0/24"
privateSubNetCidrBlock="10.0.2.0/24"
port22CidrBlock="0.0.0.0/0"
destinationCidrBlock="0.0.0.0/0"

#creation of VPC

	vpcId=$(aws ec2 create-vpc --cidr-block "$vpcCidrBlock" --query 'Vpc.{VpcId:VpcId}' --region "$awsRegion" --output text)
	echo "VPC ID '$vpcId' Created in '$awsRegion' region "

#Name of VPC

	aws ec2 create-tags --resources "$vpcId" --tags Key=Name,Value="$vpcName" --region "$awsRegion"
	echo "VPC ID '$vpcId' named as '$vpcName'."

#create internet gateway

	gatewayID=$( aws ec2 create-internet-gateway --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' --output text --region $awsRegion) 
	echo "Internet Gateway created ID='$gatewayID'" 

#give Name to internet gateway

	aws ec2 create-tags --resources "$gatewayID" --tags Key=Name,Value="$gatewayName" --region "$awsRegion"
        echo "Internet Gateway '$gatewayID' named as '$gatewayName'."

#attach internet gateway to vpc

	aws ec2 attach-internet-gateway --internet-gateway-id "$gatewayID" --vpc-id "$vpcId" --output text 
	echo "Internet gateway '$gatewayID' is attached to vpc '$vpcId'."

#create of public subnet in our vpc

	publicSubnetID=$( aws ec2 create-subnet --cidr-block "$publicSubNetCidrBlock" --vpc-id "$vpcId" --availability-zone "$availabilityZonePublic" \
	--query 'Subnet.{SubnetID:SubnetId}' --region "$awsRegion" --output text)
	echo "Public subnet created ID='$publicSubnetID' in availability zone '$availabilityZonePublic'."

#give Name to public subnet
	
	aws ec2 create-tags --resources "$publicSubnetID" --tags Key=Name,Value="$publicsubnetName" --region "$awsRegion"
	echo "Public Subnet '$publicSubnetID' named as '$publicsubnetName'."

#create of private subnet in our vpc

	privateSubnetID=$( aws ec2 create-subnet --cidr-block "$privateSubNetCidrBlock" --vpc-id "$vpcId" --availability-zone "$availabilityZonePrivate" \
	--query 'Subnet.{SubnetID:SubnetId}' --region "$awsRegion" --output text )
	echo "Private subnet created ID='$privateSubnetID' in availability zone '$availabilityZonePrivate'."

#give name to private subnet
	
	aws ec2 create-tags --resources "$privateSubnetID" --tags Key=Name,Value="$privatesubnetName" --region "$awsRegion"
	echo "Public Subnet '$privateSubnetID' named as '$privatesubnetName'."

#create a route table for vpc 

	routeTableID=$( aws ec2 create-route-table --vpc-id "$vpcId" --query 'RouteTable.{RouteTableID:RouteTableId}' --region "$awsRegion" --output text)
	echo "Route table created ID='$routeTableID'."

# add route for a internet gateway
	
	routeID=$( aws ec2 create-route --route-table-id "$routeTableID" --destination-cidr-block "$destinationCidrBlock" --gateway-id "$gatewayID" \
	 --region "$awsRegion")
	echo "Added route '$destinationCidrBlock' for Internet Gateway '$gatewayName'."

# add route to a subnet

	associate=$(aws ec2 associate-route-table --subnet-id "$publicSubnetID" --route-table-id "$routeTableID" --region "$awsRegion")
	echo "Public Subnet associated with Route Table."

# enable public IP on subnet
	
	aws ec2 modify-subnet-attribute --subnet-id "$publicSubnetID" --map-public-ip-on-launch
	echo "Enable Auto-assign Public IP on public subnet."

#create an Elastic IP address for NAT Gateway

	elasticIP=$( aws ec2 allocate-address --domain vpc --query 'AllocationId.{AllocationID:AllocationId}' --output text --region "$awsRegion")
	echo "Elastic Ip address is allocated ID='$elasticIP'"

#create NAT gateway

	natGatewayID=$( aws ec2 create-nat-gateway --subnet-id "$publicSubnetID" --allocation-id "$elasticIP" --query 'NatGateway.{NatGatewayID:NatGatewayId}' \
	--output text --region "$awsRegion")
	echo "Nat gateway has created ID='$natGatewayID'. "	

#create security group

	securityGroupID=$( aws ec2 create-security-group --group-name "$securityGroupName" --description "Security rules of public subnet" --vpc-id "$vpcId" \
	--query 'GroupId.{GroupId:GroupId}' --output json --region "$awsRegion")
	echo "Created security group for public subnet ID='$securityGroupID'."	

#enable port 22 for SSH connection

	aws ec2 authorize-security-group-ingress --group-name "$securityGroupName" --protocol tcp --port 22 --cidr "$port22CidrBlock"






