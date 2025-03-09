from aws_cdk import (
    Stack,
    aws_ec2 as ec2,
    aws_iam as iam,
)
from constructs import Construct

class Task1Stack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create a VPC with a public subnet
        vpc = ec2.Vpc(self, "WebAppVPC",
            max_azs=1,  # Use 1 availability zone for simplicity
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="PublicSubnet",
                    subnet_type=ec2.SubnetType.PUBLIC,
                    cidr_mask=24
                )
            ]
        )

        # Create a security group allowing HTTP traffic
        security_group = ec2.SecurityGroup(self, "WebAppSecurityGroup",
            vpc=vpc,
            description="Allow HTTP traffic",
            allow_all_outbound=True
        )
        security_group.add_ingress_rule(
            peer=ec2.Peer.any_ipv4(),
            connection=ec2.Port.tcp(80),
            description="Allow HTTP from anywhere"
        )

        # Create an EC2 instance in the public subnet
        instance = ec2.Instance(self, "WebAppInstance",
            instance_type=ec2.InstanceType("t2.micro"),
            machine_image=ec2.AmazonLinuxImage(),
            vpc=vpc,
            security_group=security_group,
            vpc_subnets=ec2.SubnetSelection(subnet_type=ec2.SubnetType.PUBLIC)
        )

        # Output the public IP of the instance
        self.output_public_ip = instance.instance_public_ip