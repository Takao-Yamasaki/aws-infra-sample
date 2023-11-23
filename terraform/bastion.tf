# 踏み台サーバー
resource "aws_instance" "ec2-bastion" {
  ami           = "ami-06cd52961ce9f0d85"  # Amazon Linux 2 AMIのID
  instance_type = "t2.micro"              # インスタンスタイプ
  subnet_id = aws_subnet.go-nginx-subnet-public01.id
  vpc_security_group_ids = [module.sg_bastion.security_group_id, module.sg_all_intra.security_group_id]
  key_name = aws_key_pair.ec2-bastion.key_name
  tags = {
    Name = "ec2-bastion"
  }
}

resource "aws_key_pair" "ec2-bastion" {
  key_name = "ec2-bastion"
  public_key = file("./key_pair/ec2-bastion.pub")
}
