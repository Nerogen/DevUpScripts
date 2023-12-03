import boto3
import paramiko
import time

# Замените значения на свои
region = 'your_region'
key_pair_name = 'your_key_pair_name'
instance_type = 'your_instance_type'
ami_id = 'your_ami_id'

ec2 = boto3.resource('ec2', region_name=region)

# Создание EC2 инстанса
instance = ec2.create_instances(
    ImageId=ami_id,
    MinCount=1,
    MaxCount=1,
    InstanceType=instance_type,
    KeyName=key_pair_name
)[0]

# Ожидание, пока инстанс запустится
instance.wait_until_running()
instance.reload()

# Получение информации о инстансе
instance_id = instance.id
public_ip = instance.public_ip_address
private_ip = instance.private_ip_address
instance_type = instance.instance_type
os_type = 'Linux'  # Замените на нужное вам значение

# Дополнительная информация, например, метрики можно получить через AWS CloudWatch

# Печать полученной информации
print(f"Instance ID: {instance_id}")
print(f"Public IP: {public_ip}")
print(f"Private IP: {private_ip}")
print(f"Instance Type: {instance_type}")
print(f"OS Type: {os_type}")

# Смена ключа
new_key_path = 'path_to_new_key.pem'  # Замените на путь к новому ключу
key = paramiko.RSAKey(filename=new_key_path)

# Подключение к инстансу по новому ключу
ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

# Ожидание доступности SSH
while True:
    try:
        ssh_client.connect(public_ip, username='ec2-user', pkey=key)
        break
    except paramiko.SSHException as e:
        print("Waiting for SSH to be available...")
        time.sleep(5)

print("SSH connection established with the new key.")

# Удаление инстанса
instance.terminate()
