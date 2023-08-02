locals {
  name_prefix = "meli-mrkt-url-shortener-"

  tags = {
    app_tags = {
      project_name = "UrlShortener"
    }

    environment_tags = {
      environment = "dev"
    }

    iac_tags = {
      iac = "terraform"
    }

    team_tags = {
      leader = "jimmy.matlag@gmail.com"
    }

    company_tags = {
      company_name = "meli"
    }
  }

  common_tags = merge(
    local.tags.app_tags,
    local.tags.environment_tags,
    local.tags.iac_tags,
    local.tags.team_tags,
    local.tags.company_tags,
  )
}

data "aws_region" "current" {}
