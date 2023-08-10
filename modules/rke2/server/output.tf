output "token" {
    value = random_string.random.result
}

output "server_ip" {
    value = module.server-node[0].node_ip
}