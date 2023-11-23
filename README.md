# AWS-INFRA-SAMPLE
# キーペアの作成
```
ssh-keygen -t rsa -b 2048 -f sample-ec2-bastion
```

# 踏み台へのSSH接続
```
ssh -i sample-ec2-bastion ec2-user@3.112.233.91
```
