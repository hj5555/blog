
# provider.tf 파일 (필요함) 먼저 여기 만들어줘야 돼:
# modules/vpc/provider.tf
provider "aws" {
  region = "ap-northeast-2"
}

