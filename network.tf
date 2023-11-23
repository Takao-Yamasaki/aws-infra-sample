# VPCの作成
resource "aws_vpc" "sample-vpc" {
  cidr_block = "10.0.0.0/16"
  # DNSサーバーによる名前解決の有効化
  enable_dns_support = true
  # DNSホスト名を自動割り当て
  enable_dns_hostnames = true
  
  tags = {
    Name = "sample-vpc"
  }
}

# パブリックサブネット
resource "aws_subnet" "sample-subnet-public01" {
  vpc_id = aws_vpc.sample-vpc.id
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

# パブリックサブネット
resource "aws_subnet" "sample-subnet-public02" {
  vpc_id = aws_vpc.sample-vpc.id
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
}

# プライベートサブネット
resource "aws_subnet" "sample-subnet-private01" {
  vpc_id = aws_vpc.sample-vpc.id
  cidr_block = "10.0.64.0/20"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
}

# プライベートサブネット
resource "aws_subnet" "sample-subnet-private02" {
  vpc_id = aws_vpc.sample-vpc.id
  cidr_block = "10.0.80.0/20"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "sample-igw" {
  vpc_id = aws_vpc.sample-vpc.id
}

# NATゲートウェイ用のEIP
resource "aws_eip" "sample-nat_gateway" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.sample-igw ]
}

# NATゲートウェイ(public01のみ設置)
resource "aws_nat_gateway" "sample-ngw-01" {
  allocation_id = aws_eip.sample-nat_gateway.id
  subnet_id = aws_subnet.sample-subnet-public01.id
  # 暗黙的な依存関係
  depends_on = [ aws_internet_gateway.sample-igw ]
}

# パブリックルートテーブル
resource "aws_route_table" "sample-rt-public" {
  vpc_id = aws_vpc.sample-vpc.id
}

# パブリックルート（デフォルトルートの設定）
# IGW経由でInternetへデータを流す
resource "aws_route" "sample-public" {
  route_table_id = aws_route_table.sample-rt-public.id
  gateway_id = aws_internet_gateway.sample-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# パブリックルートテーブルの関連付け
resource "aws_route_table_association" "sample-public01" {
  subnet_id = aws_subnet.sample-subnet-public01.id
  route_table_id = aws_route.sample-public.id
}

# パブリックルートテーブルの関連付け
resource "aws_route_table_association" "sample-public02" {
  subnet_id = aws_subnet.sample-subnet-public02.id
  route_table_id = aws_route.sample-public.id
}

# プライベートルートテーブル
resource "aws_route_table" "sample-rt-private01" {
  vpc_id = aws_vpc.sample-vpc.id
}

# プライベートルートテーブルの関連付け
resource "aws_route_table_association" "sample-private01" {
  subnet_id = aws_subnet.sample-subnet-private01.id
  route_table_id = aws_route.sample-public.id
}

# プライベートルートテーブルのルート（デフォルトルートの設定）
# NAT経由でInternetへデータを流す
resource "aws_route" "sample-private01" {
  route_table_id = aws_route_table.sample-rt-public.id
  gateway_id = aws_nat_gateway.sample-ngw-01.id
  destination_cidr_block = "0.0.0.0/0"
}

# TODO: sample-rt-private02はNATを配置していないので、ルートテーブルを設置していない

# セキュリティグループの定義(踏み台サーバー用)
resource "aws_security_group" "sample_sg_bastion" {
  name = "sample_sg_bastion"
  description = "for bastion server"
  vpc_id = aws_vpc.sample-vpc.id
}

# セキュリティグループルール（インバウンド）
resource "aws_security_group_rule" "ingress_sample_sg_bastion" {
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sample_sg_bastion.id
}

# セキュリティグループルール（アウトバウンド）
# 全ての通信を許可
resource "aws_security_group_rule" "egress_sample_sg_bastion" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sample_sg_bastion.id
}
