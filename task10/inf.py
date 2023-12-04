import datetime

import boto3
import paramiko
import time
from creds import AWS_SERVER_PUBLIC_KEY, AWS_SERVER_SECRET_KEY


def a_few_time_loop(ssh_client, ip, user, key):
    time_outs = 0
    # Ожидание доступности SSH
    while time_outs < 3:
        try:
            ssh_client.connect(ip, username=user, pkey=key)
            break
        except paramiko.SSHException as e:
            time_outs += 1
            print(e)
            time.sleep(5)

    else:
        return "All bad!"

    return "All ok in ssh connection!"


def cloud_watch(instance_id):
    # Получение метрик (пример с использованием CloudWatch)
    cloudwatch = boto3.client('cloudwatch',
                              aws_access_key_id=AWS_SERVER_PUBLIC_KEY,
                              aws_secret_access_key=AWS_SERVER_SECRET_KEY,
                              region_name='us-east-1'
    )

    # Получение метрики CPUUtilization за последний час
    start_time = (datetime.datetime.utcnow() - datetime.timedelta(minutes=1)).strftime('%Y-%m-%dT%H:%M:%SZ')
    end_time = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/EC2',
        MetricName='CPUUtilization',
        Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
        StartTime=start_time,
        EndTime=end_time,
        Period=300,
        Statistics=['Average']
    )

    print(response)


def main():
    # Замените значения на свои
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

    # Ожидание, пока инстанс запустится
    response[0].wait_until_running()

    # Получение информации об инстансе
    instance = ec2.Instance(response[0].id)
    instance_id = instance.id
    public_ip = instance.public_ip_address
    private_ip = instance.private_ip_address
    instance_type = instance.instance_type
    os_type = instance.image.description

    cloud_watch(instance_id)

    # Печать полученной информации
    print(f"Instance ID: {instance_id}")
    print(f"Public IP: {public_ip}")
    print(f"Private IP: {private_ip}")
    print(f"Instance Type: {instance_type}")
    print(f"OS Type: {os_type}")

    try:
        # Подключение к инстансу по SSH
        key = paramiko.RSAKey(filename='Task2.pem')  # Замените на путь к вашему закрытому ключу
        key_old = paramiko.RSAKey(filename='Task4.pem')  # Замените на путь к вашему закрытому ключу
        public_key_openssh = "ssh-rsa " + key.get_base64() + " Task2"

        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        a_few_time_loop(ssh_client, public_ip, 'ubuntu', key_old)

        # Переписывание ключа на инстансе
        command = f'echo "{public_key_openssh}" > ~/.ssh/authorized_keys'
        ssh_client.exec_command(command)

        # Закрытие SSH-соединения
        ssh_client.close()

        a_few_time_loop(ssh_client, public_ip, 'ubuntu', key)
        print("SSH connection established with the new key.")

    except Exception as ex:
        print(ex)

    finally:
        # Удаление инстанса
        response[0].terminate()


if __name__ == '__main__':
    main()
