resource "null_resource" "conf_cluster" {
  count = length(var.ip_pves) 

  connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = var.ip_pves[count.index]
   }
  
  provisioner "file" {
     source = "sh/01-Repo-fix.sh"
     destination = "/tmp/01-Repo-fix.sh" 

  }
  
  provisioner "file" {
     source = "sh/02_create_pam_user.sh"
     destination = "/tmp/02_create_pam_user.sh" 

  }
 
 provisioner "file" {
     source = "sh/03_secure_access.sh"
     destination = "/tmp/03_secure_access.sh" 

  }
 
 provisioner "remote-exec" {
    inline = [
      "cp /tmp/*.sh .",
      "chmod +x *",
      "./01-Repo-fix.sh",
      "./02_create_pam_user.sh",
      "./03_secure_access.sh"
      ]
    
  }
 
}
