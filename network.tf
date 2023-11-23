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
  depends_on = [ aws_internet_gateway.sample-igw ]
}

# ルートテーブル
resource "aws_route_table" "sample-rt-public" {
  vpc_id = aws_vpc.sample-vpc.id
}

# ルート（デフォルトルートの設定）
# IGW経由でInternetへデータを流す
resource "aws_route" "sample-public" {
  route_table_id = aws_route_table.sample-rt-public.id
  gateway_id = aws_internet_gateway.sample-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルの関連付け
resource "aws_route_table_association" "sample-public01" {
  subnet_id = aws_subnet.sample-subnet-private01.id
  route_table_id = aws_route.sample-public.id
}

# ルートテーブルの関連付け
resource "aws_route_table_association" "sample-public02" {
  subnet_id = aws_subnet.sample-subnet-private02.id
  route_table_id = aws_route.sample-public.id
}

# TODO: プライベートルートテーブルの作成から
