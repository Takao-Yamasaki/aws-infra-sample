# VPCの作成
resource "aws_vpc" "go-nginx-vpc" {
  cidr_block = "10.0.0.0/16"
  # DNSサーバーによる名前解決の有効化
  enable_dns_support = true
  # DNSホスト名を自動割り当て
  enable_dns_hostnames = true
  
  tags = {
    Name = "go-nginx-vpc"
  }
}

# パブリックサブネット
resource "aws_subnet" "go-nginx-subnet-public01" {
  vpc_id = aws_vpc.go-nginx-vpc.id
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

# パブリックサブネット
resource "aws_subnet" "go-nginx-subnet-public02" {
  vpc_id = aws_vpc.go-nginx-vpc.id
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
}

# プライベートサブネット
resource "aws_subnet" "go-nginx-subnet-private01" {
  vpc_id = aws_vpc.go-nginx-vpc.id
  cidr_block = "10.0.64.0/20"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
}

# プライベートサブネット
resource "aws_subnet" "go-nginx-subnet-private02" {
  vpc_id = aws_vpc.go-nginx-vpc.id
  cidr_block = "10.0.80.0/20"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "go-nginx-igw" {
  vpc_id = aws_vpc.go-nginx-vpc.id
}

# NATゲートウェイ用のEIP
resource "aws_eip" "go-nginx-nat_gateway" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.go-nginx-igw ]
}

# NATゲートウェイ(public01のみ設置)
resource "aws_nat_gateway" "go-nginx-ngw-01" {
  allocation_id = aws_eip.go-nginx-nat_gateway.id
  subnet_id = aws_subnet.go-nginx-subnet-public01.id
  # 暗黙的な依存関係
  depends_on = [ aws_internet_gateway.go-nginx-igw ]
}

# パブリックルートテーブル
resource "aws_route_table" "go-nginx-rt-public" {
  vpc_id = aws_vpc.go-nginx-vpc.id
}

# パブリックルート（デフォルトルートの設定）
# IGW経由でInternetへデータを流す
resource "aws_route" "go-nginx-public" {
  route_table_id = aws_route_table.go-nginx-rt-public.id
  gateway_id = aws_internet_gateway.go-nginx-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# パブリックルートテーブルの関連付け
resource "aws_route_table_association" "go-nginx-public01" {
  subnet_id = aws_subnet.go-nginx-subnet-public01.id
  route_table_id = aws_route_table.go-nginx-rt-public.id
}

# パブリックルートテーブルの関連付け
resource "aws_route_table_association" "go-nginx-public02" {
  subnet_id = aws_subnet.go-nginx-subnet-public02.id
  route_table_id = aws_route_table.go-nginx-rt-public.id
}

# プライベートルートテーブル
resource "aws_route_table" "go-nginx-rt-private01" {
  vpc_id = aws_vpc.go-nginx-vpc.id
}

# プライベートルートテーブルの関連付け
resource "aws_route_table_association" "go-nginx-private01" {
  subnet_id = aws_subnet.go-nginx-subnet-private01.id
  route_table_id = aws_route_table.go-nginx-rt-private01.id
}

# プライベートルートテーブルのルート（デフォルトルートの設定）
# NAT経由でInternetへデータを流す
resource "aws_route" "go-nginx-private01" {
  route_table_id = aws_route_table.go-nginx-rt-private01.id
  gateway_id = aws_nat_gateway.go-nginx-ngw-01.id
  destination_cidr_block = "0.0.0.0/0"
}

# TODO: go-nginx-rt-private02はNATを配置していないので、ルートテーブルを設置していない

# セキュリティグループの定義(踏み台サーバー用)
module "sg_bastion" {
  source = "./modules"
  name = "sg_bastion"
  vpc_id = aws_vpc.go-nginx-vpc.id
  port = 22
  cidr_blocks = ["0.0.0.0/0"]
}

# セキュリティグループの定義(VPC内全てのリソースの通信を許可)
module "sg_all_intra" {
  source = "./modules"
  name = "sg_all_intra"
  vpc_id = aws_vpc.go-nginx-vpc.id
  port = 0
  cidr_blocks = ["0.0.0.0/0"]
}
