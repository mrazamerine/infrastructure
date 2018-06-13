# DigitalOcean Terraform Variables

# DigitalOcean API Token (string)
do_api_token = ""

# Droplet root user ssh keys (list)
root_ssh_keys = []

# Droplet size (indexed map; defaults to "s-1vcpu-1gb")
droplet_size = {}

# Droplet hostnames (list)
droplet_hostname = []

# Droplet tags (list of lists)
droplet_tags = []
