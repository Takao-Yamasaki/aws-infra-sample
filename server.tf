# 踏み台サーバー
resource "aws_instance" "sample-ec2-bastion" {
  ami           = "ami-06cd52961ce9f0d85"  # Amazon Linux 2 AMIのID（リージョンによって異なります）
  instance_type = "t2.micro"              # インスタンスタイプ
  subnet_id = aws_subnet.sample-subnet-public01.id
  vpc_security_group_ids = [aws_security_group.sample_sg_bastion.id, aws_security_group.sample_sg_all_intra_vpc.id]
  key_name = aws_key_pair.sample-ec2-bastion.key_name
  tags = {
    Name = "sample-ec2-bastion"
  }
}

resource "aws_key_pair" "sample-ec2-bastion" {
  key_name = "sample-ec2-bastion"
  public_key = file("sample-ec2-bastion.pub")
}
