module "dev" {
    source = "../Day9-modules"
    instance_type = "t3.micro"
    name = "my-instance"
    ami_id = "ami-0152204c1a187337c"
}