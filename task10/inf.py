import datetime

import boto3
import paramiko
import time
from creds import AWS_SERVER_PUBLIC_KEY, AWS_SERVER_SECRET_KEY


def a_few_time_loop(ssh_client, ip, user, key, description):
    time_outs = 0
    # wait for access by SSH
    while time_outs < 3:
        print("Time_out: ", time_outs)
        try:
            ssh_client.connect(ip, username=user, pkey=key)
            break
        except Exception as e:
            time_outs += 1
            print(description, e, sep="\n")
            time.sleep(5)

    else:
        return "All bad!"

    return "All ok in ssh connection!"


def cloud_watch(instance_id):
    # Specify the metric names and dimensions
    metric_names = ['StatusCheckFailed', 'DiskWriteOps', 'DiskReadOps', 'DiskWriteBytes',
                    'DiskReadBytes', 'NetworkIn', 'NetworkOut', 'CPUUtilization', 'MetadataNoToken',
                    'CPUCreditUsage']
    dimensions = [{'Name': 'InstanceId', 'Value': instance_id}]

    cloudwatch = boto3.client('cloudwatch',
                              aws_access_key_id=AWS_SERVER_PUBLIC_KEY,
                              aws_secret_access_key=AWS_SERVER_SECRET_KEY,
                              region_name='us-east-1'
                              )

    current_time_utc = datetime.datetime.utcnow()

    # formation time to string
    start_time = (current_time_utc - datetime.timedelta(minutes=10)).strftime('%Y-%m-%dT%H:%M:%SZ')

    time.sleep(300)
    # get time in utc
    current_time_utc = datetime.datetime.utcnow()

    end_time = current_time_utc.strftime('%Y-%m-%dT%H:%M:%SZ')

    print("Times: ", start_time, end_time)

    # Get metric data
    response = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                'Id': f'metric_{metric_name}',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/EC2',
                        'MetricName': metric_name,
                        'Dimensions': dimensions
                    },
                    'Period': 360,
                    'Stat': 'Average'
                },
                'ReturnData': True
            }
            for metric_name in metric_names
        ],
        StartTime=start_time,
        EndTime=end_time
    )

    # Print the metric data
    print("CloudWatch summary: ", "*" * 100)
    for result in response['MetricDataResults']:
        print(f"MetricName: {result['Id']}")
        for timestamp, value in zip(result['Timestamps'], result['Values']):
            print(f"Timestamp: {timestamp}, Value: {value}")
        print()


def main():
    region = 'us-east-1'
    key_pair_name = 'Task4'

    session = boto3.Session(
        aws_access_key_id=AWS_SERVER_PUBLIC_KEY,
        aws_secret_access_key=AWS_SERVER_SECRET_KEY,
    )

    ec2 = session.resource('ec2', region_name=region)

    response = ec2.create_instances(
        BlockDeviceMappings=[
            {
                'DeviceName': '/dev/xvda',
                'Ebs': {
                    'DeleteOnTermination': True,
                    'VolumeSize': 8,
                    'VolumeType': 'gp3'
                },
            },
        ],
        KeyName=key_pair_name,
        ImageId='ami-0fc5d935ebf8bc3bc',
        InstanceType='t2.nano',
        MaxCount=1,
        MinCount=1,
        Monitoring={
            'Enabled': False
        },
        SecurityGroupIds=[
            'launch-wizard-9',
        ],
    )

    # Wait starting instance
    response[0].wait_until_running()

    # Get info about instance
    instance = ec2.Instance(response[0].id)
    instance_id = instance.id
    public_ip = instance.public_ip_address
    private_ip = instance.private_ip_address
    instance_type = instance.instance_type
    os_type = instance.image.description

    # Print data
    print("EC2 summary: ", "*" * 100)
    print(f"Instance ID: {instance_id}")
    print(f"Public IP: {public_ip}")
    print(f"Private IP: {private_ip}")
    print(f"Instance Type: {instance_type}")
    print(f"OS Type: {os_type}")

    cloud_watch(instance_id)

    # Connect to instance by SSH
    key = paramiko.RSAKey(filename='Task2.pem')
    key_old = paramiko.RSAKey(filename='Task4.pem')
    public_key_openssh = "ssh-rsa " + key.get_base64() + " Task2"

    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    print("Keys manipulation: ", "*" * 100)

    print(a_few_time_loop(ssh_client, public_ip, 'ubuntu', key_old, 'first'))

    # Rewrite key of instance
    command = f'echo "{public_key_openssh}" > ~/.ssh/authorized_keys'

    try:
        ssh_client.exec_command(command)
        # close connection
        ssh_client.close()
    except Exception as ex:
        print(ex)

    print(a_few_time_loop(ssh_client, public_ip, 'ubuntu', key, 'second'))

    # terminate instance
    response[0].terminate()


if __name__ == '__main__':
    main()
