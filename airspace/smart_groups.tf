resource "aviatrix_smart_group" "edge" {
  name = "Edge"
  selector {
    match_expressions {
      cidr = "10.40.251.16/28"
    }
  }
}

resource "aviatrix_smart_group" "dev" {
  name = "Dev"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Environment = "Dev"
      }
    }
  }
}

resource "aviatrix_smart_group" "qa" {
  name = "QA"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Environment = "QA"
      }
    }
  }
}

resource "aviatrix_smart_group" "prod" {
  name = "Prod"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Environment = "Prod"
      }
    }
  }
}
