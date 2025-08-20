resource "null_resource" "create_env" {
  depends_on = [ null_resource.conf_cluster ]
  
  connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = var.pve_master_ip
    
  }
  
  provisioner "file" {
     source = "sh/04_create_pve_user.sh"
     destination = "/tmp/04_create_pve_user.sh" 

  }
   
 provisioner "file" {
     source = "sh/05_create_env.sh"
     destination = "/tmp/05_create_env.sh" 

  }
  provisioner "remote-exec" {
    inline = [
      "cp /tmp/*.sh .",
      "chmod +x *",
      "./04_create_pve_user.sh",
      "./05_create_env.sh"
      ]
    }

}
