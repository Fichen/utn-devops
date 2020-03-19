node default {}

node 'test.utn-devops.localhost' {
    include docker_install
    include app_config
}
