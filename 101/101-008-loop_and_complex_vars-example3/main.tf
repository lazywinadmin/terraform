variable "iam_role_bindings" {

  default = {
    "member1" = {
      "dataset1" : ["role1", "role2", "role5"],
      "dataset2" : ["role3", "role2"],
    },
    "member2" = {
      "dataset3" : ["role1", "role4"],
      "dataset2" : ["role5"],
    }
  }
}

locals {

  helper_list = flatten([for member, value in var.iam_role_bindings :
    flatten([for dataset, roles in value :
      [for role in roles :
        { "member"  = member
          "dataset" = dataset
        "role" = role }
    ]])
  ])
}

output "helper_list" {
  value = local.helper_list
}

# helper_list = [
#       + {
#           + dataset = "dataset1"
#           + member  = "member1"
#           + role    = "role1"
#         },
#       + {
#           + dataset = "dataset1"
#           + member  = "member1"
#           + role    = "role2"
#         },
#       + {
#           + dataset = "dataset1"
#           + member  = "member1"
#           + role    = "role5"
#         },
#       + {
#           + dataset = "dataset2"
#           + member  = "member1"
#           + role    = "role3"
#         },
#       + {
#           + dataset = "dataset2"
#           + member  = "member1"
#           + role    = "role2"
#         },
#       + {
#           + dataset = "dataset2"
#           + member  = "member2"
#           + role    = "role5"
#         },
#       + {
#           + dataset = "dataset3"
#           + member  = "member2"
#           + role    = "role1"
#         },
#       + {
#           + dataset = "dataset3"
#           + member  = "member2"
#           + role    = "role4"
#         },
#     ]
