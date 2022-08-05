variable "variable" {
  type = map
  default = {
  "user 1" = [ "policy1", "policy2" ],
  "user 2" = [ "policy1" ]
}
}

locals {
  association-list = flatten([
    for user in keys(var.variable) : [
      for policy in var.variable[user] : {
        user   = user
        policy = policy
      }
    ]
  ])
}

output "users" {
  value = keys(var.variable)
}

# users = [
#       + "user 1",
#       + "user 2",
#     ]


output "name" {
  value = local.association-list
}

# name = [
#       + {
#           + policy = "policy1"
#           + user   = "user 1"
#         },
#       + {
#           + policy = "policy2"
#           + user   = "user 1"
#         },
#       + {
#           + policy = "policy1"
#           + user   = "user 2"
#         },
#     ]

